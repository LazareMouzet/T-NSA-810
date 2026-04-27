#!/bin/bash
# =============================================================================
#  Script d'installation automatisé NetBox
#  Compatible : Ubuntu 22.04 / 24.04
#  Usage      : sudo bash install-netbox.sh
# =============================================================================

set -euo pipefail

# =============================================================================
# COULEURS & HELPERS
# =============================================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

info()    { echo -e "${CYAN}[INFO]${NC}  $*"; }
success() { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error()   { echo -e "${RED}[ERREUR]${NC} $*"; exit 1; }
banner()  { echo -e "\n${BOLD}${CYAN}========== $* ==========${NC}\n"; }

# =============================================================================
# VÉRIFICATIONS PRÉLIMINAIRES
# =============================================================================
banner "Vérifications préliminaires"

[[ $EUID -ne 0 ]] && error "Ce script doit être exécuté en tant que root (sudo)."

# Détection de l'IP principale du serveur
SERVER_IP=$(hostname -I | awk '{print $1}')
info "IP détectée du serveur : ${SERVER_IP}"

# =============================================================================
# PARAMÈTRES — MODIFIEZ CES VALEURS AVANT EXÉCUTION
# =============================================================================
DB_NAME="netbox"
DB_USER="netbox"
DB_PASSWORD="${DB_PASSWORD:-}"          # Peut aussi être passé en variable d'env
ALLOWED_HOST="${ALLOWED_HOST:-$SERVER_IP}"   # Ex: "192.168.100.100" ou "*"
NETBOX_BRANCH="master"

# Si le mot de passe n'est pas défini, on le demande interactivement
if [[ -z "$DB_PASSWORD" ]]; then
    echo ""
    read -rsp "$(echo -e "${YELLOW}Entrez le mot de passe PostgreSQL pour l'utilisateur 'netbox' : ${NC}")" DB_PASSWORD
    echo ""
    [[ -z "$DB_PASSWORD" ]] && error "Le mot de passe ne peut pas être vide."
fi

# =============================================================================
# ÉTAPE 1 — MISE À JOUR SYSTÈME & DÉPENDANCES
# =============================================================================
banner "Étape 1 — Mise à jour et installation des dépendances"

apt update -y && apt upgrade -y

apt install -y \
    python3 python3-pip python3-venv python3-dev \
    build-essential \
    libxml2-dev libxslt1-dev libffi-dev libpq-dev libssl-dev zlib1g-dev \
    postgresql postgresql-contrib \
    redis-server \
    nginx \
    git curl

success "Dépendances installées."

# =============================================================================
# ÉTAPE 2 — DÉMARRAGE & VÉRIFICATION DES SERVICES
# =============================================================================
banner "Étape 2 — Démarrage des services PostgreSQL et Redis"

systemctl enable --now postgresql
systemctl enable --now redis-server

systemctl is-active --quiet postgresql && success "PostgreSQL est actif." \
    || error "PostgreSQL n'a pas démarré correctement."

systemctl is-active --quiet redis-server && success "Redis est actif." \
    || error "Redis n'a pas démarré correctement."

# =============================================================================
# ÉTAPE 3 — BASE DE DONNÉES POSTGRESQL
# =============================================================================
banner "Étape 3 — Configuration de la base de données PostgreSQL"

# Création de la base et de l'utilisateur (idempotent)
sudo -u postgres psql <<EOF
DO \$\$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = '${DB_USER}') THEN
        CREATE USER ${DB_USER} WITH PASSWORD '${DB_PASSWORD}';
    ELSE
        ALTER USER ${DB_USER} WITH PASSWORD '${DB_PASSWORD}';
    END IF;
END
\$\$;

SELECT 'CREATE DATABASE ${DB_NAME} OWNER ${DB_USER}'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '${DB_NAME}') \gexec

ALTER ROLE ${DB_USER} SET client_encoding TO 'utf8';
ALTER ROLE ${DB_USER} SET default_transaction_isolation TO 'read committed';
ALTER ROLE ${DB_USER} SET timezone TO 'UTC';
GRANT ALL PRIVILEGES ON DATABASE ${DB_NAME} TO ${DB_USER};
EOF

# Permissions sur le schéma public
sudo -u postgres psql -d "${DB_NAME}" <<EOF
GRANT ALL ON SCHEMA public TO ${DB_USER};
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO ${DB_USER};
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO ${DB_USER};
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO ${DB_USER};
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO ${DB_USER};
EOF

success "Base de données '${DB_NAME}' configurée."

# =============================================================================
# ÉTAPE 4 — CLONAGE DE NETBOX
# =============================================================================
banner "Étape 4 — Clonage du dépôt NetBox"

mkdir -p /opt/netbox
cd /opt/netbox

if [[ -d /opt/netbox/.git ]]; then
    warn "NetBox semble déjà cloné. Mise à jour du dépôt..."
    git -C /opt/netbox pull
else
    git clone -b "${NETBOX_BRANCH}" --depth 1 \
        https://github.com/netbox-community/netbox.git /opt/netbox
fi

success "Dépôt NetBox prêt dans /opt/netbox."

# =============================================================================
# ÉTAPE 5 — UTILISATEUR SYSTÈME & PERMISSIONS
# =============================================================================
banner "Étape 5 — Création de l'utilisateur système netbox"

if ! id -u netbox &>/dev/null; then
    adduser --system --group netbox
    success "Utilisateur système 'netbox' créé."
else
    warn "L'utilisateur 'netbox' existe déjà."
fi

chown --recursive netbox /opt/netbox/
mkdir -p /opt/netbox/netbox/media
chown --recursive netbox /opt/netbox/netbox/media/
success "Permissions appliquées."

# =============================================================================
# ÉTAPE 6 — CONFIGURATION DE NETBOX
# =============================================================================
banner "Étape 6 — Génération de configuration.py"

CONFIG_DIR="/opt/netbox/netbox/netbox"
CONFIG_FILE="${CONFIG_DIR}/configuration.py"

# Générer la clé secrète
SECRET_KEY=$(python3 /opt/netbox/netbox/generate_secret_key.py)
info "Clé secrète générée."

# Copier l'exemple si le fichier n'existe pas encore
if [[ ! -f "${CONFIG_FILE}" ]]; then
    cp "${CONFIG_DIR}/configuration_example.py" "${CONFIG_FILE}"
fi

# Injecter la configuration complète
cat > "${CONFIG_FILE}" <<PYEOF
# =============================================================================
#  NetBox configuration — généré automatiquement par install-netbox.sh
# =============================================================================

ALLOWED_HOSTS = ['${ALLOWED_HOST}']

DATABASE = {
    'NAME': '${DB_NAME}',
    'USER': '${DB_USER}',
    'PASSWORD': '${DB_PASSWORD}',
    'HOST': 'localhost',
    'PORT': '',
    'CONN_MAX_AGE': 300,
}

REDIS = {
    'tasks': {
        'HOST': 'localhost',
        'PORT': 6379,
        'PASSWORD': '',
        'DATABASE': 0,
        'SSL': False,
    },
    'caching': {
        'HOST': 'localhost',
        'PORT': 6379,
        'PASSWORD': '',
        'DATABASE': 1,
        'SSL': False,
    }
}

SECRET_KEY = '${SECRET_KEY}'

# Optionnel — activer le débogage uniquement en développement
DEBUG = False

# Optionnel — fuseau horaire de l'interface
TIME_ZONE = 'Europe/Paris'
PYEOF

chown netbox "${CONFIG_FILE}"
success "configuration.py écrit."

# =============================================================================
# ÉTAPE 7 — EXÉCUTION DU SCRIPT D'UPGRADE
# =============================================================================
banner "Étape 7 — Initialisation de l'environnement Python & migrations"

bash /opt/netbox/upgrade.sh
success "upgrade.sh terminé (venv, dépendances, migrations, static files)."

# =============================================================================
# ÉTAPE 8 — CRÉATION DU SUPER-UTILISATEUR
# =============================================================================
banner "Étape 8 — Création du superutilisateur NetBox"

warn "Vous allez créer le compte administrateur NetBox."
source /opt/netbox/venv/bin/activate
cd /opt/netbox/netbox
python3 manage.py createsuperuser
deactivate
success "Superutilisateur créé."

# =============================================================================
# ÉTAPE 9 — SERVICES SYSTEMD (Gunicorn + RQ)
# =============================================================================
banner "Étape 9 — Configuration des services systemd"

cp /opt/netbox/contrib/gunicorn.py /opt/netbox/gunicorn.py

# Copier uniquement les fichiers .service (pas les autres contrib)
for svc in /opt/netbox/contrib/*.service; do
    cp "$svc" /etc/systemd/system/
done

systemctl daemon-reload

systemctl enable --now netbox netbox-rq

sleep 3
systemctl is-active --quiet netbox     && success "Service 'netbox' actif."     \
    || error "Le service 'netbox' n'a pas démarré."
systemctl is-active --quiet netbox-rq  && success "Service 'netbox-rq' actif."  \
    || error "Le service 'netbox-rq' n'a pas démarré."

# =============================================================================
# ÉTAPE 10 — INSTALLATION NGINX
# =============================================================================
banner "Étape 10 - Installation de Nginx"

sudo apt update
sudo apt install -y nginx

sudo systemctl is-active --quiet nginx && success "Service 'nginx' actif." || error "Le service 'nginx' n'a pas démarré"

# =============================================================================
# ÉTAPE 11 — CONFIGURATION NGINX
# =============================================================================
banner "Étape 11 — Configuration de Nginx"

NGINX_CONF="/etc/nginx/sites-available/netbox"

cat > "${NGINX_CONF}" <<NGINXEOF
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    server_name ${ALLOWED_HOST};

    client_max_body_size 25m;

    location /static/ {
        alias /opt/netbox/netbox/static/;
    }

    location / {
        proxy_pass http://127.0.0.1:8001;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
NGINXEOF

# Activer le site NetBox, désactiver le site par défaut
[[ -f /etc/nginx/sites-enabled/default ]] && rm /etc/nginx/sites-enabled/default
ln -sf "${NGINX_CONF}" /etc/nginx/sites-enabled/netbox

# Valider la configuration Nginx
nginx -t || error "La configuration Nginx est invalide. Vérifiez ${NGINX_CONF}."

systemctl enable --now nginx
systemctl restart nginx

systemctl is-active --quiet nginx && success "Nginx redémarré avec succès." \
    || error "Nginx n'a pas redémarré correctement."

# =============================================================================
# RÉCAPITULATIF FINAL
# =============================================================================
banner "Installation terminée"

echo -e "${GREEN}${BOLD}"
echo "  ██╗   ██╗███████╗████████╗██████╗  ██████╗ ██╗  ██╗"
echo "  ███╗  ██║██╔════╝╚══██╔══╝██╔══██╗██╔═══██╗╚██╗██╔╝"
echo "  ████╗ ██║█████╗     ██║   ██████╔╝██║   ██║ ╚███╔╝ "
echo "  ██╔██╗██║██╔══╝     ██║   ██╔══██╗██║   ██║ ██╔██╗ "
echo "  ██║╚████║███████╗   ██║   ██████╔╝╚██████╔╝██╔╝╚██╗"
echo "  ╚═╝ ╚═══╝╚══════╝   ╚═╝   ╚═════╝  ╚═════╝ ╚═╝  ╚═╝"
echo -e "${NC}"

echo -e "  ${CYAN}URL d'accès   :${NC} http://${ALLOWED_HOST}"
echo -e "  ${CYAN}Base de données :${NC} ${DB_NAME} (utilisateur : ${DB_USER})"
echo -e "  ${CYAN}Répertoire    :${NC} /opt/netbox"
echo ""
echo -e "  ${YELLOW}Conseil sécurité :${NC}"
echo -e "  - Changez ALLOWED_HOSTS = ['*'] par votre IP/FQDN réel en production."
echo -e "  - Activez HTTPS en décommentant le bloc SSL dans ${NGINX_CONF}."
echo ""
success "NetBox est accessible sur http://${ALLOWED_HOST} 🎉"