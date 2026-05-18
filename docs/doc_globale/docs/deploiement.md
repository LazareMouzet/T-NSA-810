# Déploiement et exploitation

## Prérequis

Avant tout déploiement, les éléments suivants doivent être opérationnels et correctement configurés.

### Infrastructure

- Les machines virtuelles Ubuntu Server 24.04 Minimal sont déployées et accessibles ;
- Le VPN Site-to-Site entre les deux firewalls pfSense est fonctionnel ;
- Le bastion SSH est accessible depuis Internet via son port dédié ;
- La résolution DNS des domaines `.local` est opérationnelle entre les deux sites.

### Poste administrateur

- WSL est installé sur le poste Windows ;
- Ansible est installé dans l’environnement WSL :

```bash
pip3 install ansible
```

- Une clé SSH `~/.ssh/id_ed25519` est générée et déployée sur l’ensemble des machines virtuelles ;
- Le fichier `~/.ssh/config` est configuré avec les entrées `ProxyJump` nécessaires à l’administration via le bastion ;
- Le service `ssh-agent` est démarré avec la clé SSH chargée :

```bash
eval $(ssh-agent -s)
ssh-add ~/.ssh/id_ed25519
```

## Procédure de déploiement via Ansible

L’ensemble de la configuration de l’infrastructure est automatisée à l’aide d’Ansible.
Les playbooks sont organisés par service et peuvent être rejoués à tout moment afin de reconstruire ou reconfigurer une machine virtuelle à partir d’un état minimal.

---

## Structure du projet Ansible

```text
|T-NSA-810/
├── ansible.cfg              ← Configuration globale d'Ansible
├── inventory/
│   ├── hosts.yml            ← Liste de vos machines cibles
│   └── group_vars/all
|       ├── main.yml         ← Variables communes non sensibles
│       ├── vault.yml        ← Secrets chiffrés avec Ansible Vault ⚠️
│
├── playbooks/
│   ├── common.yml             ← Playbook de configuration commun à toute les vms
│   ├── elasticsearch.yml      ← Playbook du rôle elasticsearch
│   |── netbox.yml             ← Playbook du rôle netbox
│   ├── proxmox.yml            ← Playbook du rôle proxmox
│   ├── vault.yml              ← Playbook du rôle vault
│   └── vm_ip_to_netbox.yml    ← Playbook du rôle vm_ip_to_netbox.yml
│
├── roles/
│   └── [nom-du-role]/
│       ├── tasks/
│       │   └── main.yml     ← Les tâches du rôle
│       ├── templates/
│       │   └── *.j2         ← Templates Jinja2
│       ├── vars/
│       │   └── main.yml     ← Variables du rôle
│       └── handlers/
│           └── main.yml     ← Handlers (ex : restart service)
│
└── README.md
```

---

## Ordre de déploiement recommandé

```bash
# 1. Configuration de base sur l’ensemble des VMs
ansible-playbook playbooks/common.yml

# 2. Déploiement de HashiCorp Vault
ansible-playbook playbooks/vault.yml

# 3. Déploiement de la stack Elasticsearch / Kibana
ansible-playbook playbooks/elastic.yml

# 4. Déploiement de NetBox
ansible-playbook playbooks/netbox.yml
```

⚠️ Il est recommandé d’exécuter systématiquement les playbooks avec les options `--check` et `--diff` afin de valider les modifications avant application.

---

## Sécurité des secrets

Les secrets (mots de passe sudo, tokens, clés d’unsealing Vault, etc.) sont chiffrés à l’aide d’Ansible Vault et stockés dans le fichier :

```text
inventory/group_vars/all/vault.yml
```

Le mot de passe permettant le déchiffrement d’Ansible Vault (`.vault_pass`) n’est jamais versionné dans le dépôt Git afin d’éviter toute fuite de secrets.

---

## Bonnes pratiques d’exploitation

Cette section décrit les règles opérationnelles à respecter afin de garantir la stabilité, la sécurité et la reproductibilité de l’infrastructure.

---

### Mises à jour système

- Les mises à jour système sont réalisées via `apt upgrade`.
- L’utilisation de `apt dist-upgrade` est évitée afin de limiter les changements majeurs non maîtrisés sur les dépendances critiques.
- L’espace disque disponible doit être vérifié avant toute opération de mise à jour, notamment sur le serveur de supervision (`monitoring.local`).
- Les composants critiques (Elasticsearch, Kibana, Filebeat) sont placés en mode `hold` (`apt-mark hold`) afin de garantir la stabilité de la stack de monitoring.

Toute mise à jour de ces composants doit faire l’objet d’une validation manuelle préalable.

---

### Gestion des secrets

- Les identifiants et mots de passe utilisateurs sont stockés dans un coffre-fort sécurisé (KeePass).
- Les secrets applicatifs et d’infrastructure sont centralisés dans HashiCorp Vault.
- Les variables sensibles utilisées par Ansible sont chiffrées via Ansible Vault.
- Aucun secret ne doit être stocké en clair dans un fichier de configuration, un script ou un dépôt Git.

---

### Accès à l’infrastructure

- L’accès aux machines se fait exclusivement via le bastion SSH ou une connexion VPN P2S.
- Aucun accès direct aux VMs internes depuis Internet n’est autorisé.
- Les accès aux interfaces web internes sont réalisés via tunnels SSH sécurisés ou via une connexion VPN P2S.
- Le service `ssh-agent` doit être utilisé pour la gestion des clés SSH lors des sessions d’administration.

---

### Contrôle des changements

- Toute modification de configuration doit être réalisée via Ansible.
- Les changements doivent être versionnés dans un dépôt Git avant application.
- Les modifications manuelles exceptionnelles doivent être documentées dans un runbook afin d’assurer la traçabilité des actions.

## Sauvegarde

### Stratégie de sauvegarde

La stratégie de sauvegarde repose sur deux mécanismes complémentaires permettant d’assurer la continuité de service et la capacité de restauration de l’infrastructure.

---

### 1. Snapshots Proxmox

Des snapshots sont réalisés sur l’ensemble des machines virtuelles via Proxmox. Ils permettent une restauration rapide en cas de défaillance système, de corruption ou de mauvaise manipulation.

Les snapshots sont effectués avant toute intervention majeure sur les services critiques.

| VM              | Fréquence / déclencheur            |
|-----------------|------------------------------------|
| outils.local    | Avant intervention majeure         |
| monitoring.local| Avant intervention majeure         |
| bastion.local   | Avant intervention majeure         |
| intranet.local  | Avant intervention majeure         |

⚠️ Contrainte d’infrastructure : la création de nouvelles machines virtuelles n’est pas autorisée par le prestataire. En cas de perte complète d’une VM, la restauration s’effectue soit à partir d’un snapshot existant, soit via un redéploiement automatisé à l’aide des playbooks Ansible sur une machine vierge fournie par le prestataire.

---

### 2. Infrastructure as Code (Ansible)

Les playbooks Ansible constituent une sauvegarde logique de la configuration des systèmes.

En cas de réinitialisation d’une machine virtuelle, l’exécution des playbooks permet de reconstituer l’ensemble de l’environnement applicatif et système.

Cette approche permet de garantir une reproductibilité complète de l’infrastructure.

---

### Éléments nécessitant une sauvegarde manuelle

Certains éléments critiques ne sont pas couverts par les snapshots ou Ansible et nécessitent une sauvegarde manuelle.

| Élément                    | Emplacement       | Méthode de sauvegarde |
|---------------------------|------------------|------------------------|
| Unseal Key Vault         | KeePass          | Coffre-fort sécurisé   |
| Root Token Vault         | KeePass          | Coffre-fort sécurisé   |
| Base de données NetBox   | outils.local     | `pg_dump` PostgreSQL   |
| Configuration pfSense     | Interface GUI    | Export XML             |
| Certificats SSL          | `/etc/ssl`       | Copie sécurisée manuelle |

---

### Sauvegarde de la base NetBox

```bash
ssh outils
sudo -u postgres pg_dump netbox > /opt/backups/netbox_$(date +%Y%m%d).sql
```

---

### Sauvegarde de la configuration pfSense

La configuration pfSense est exportée via :

`Diagnostics > Backup & Restore > Download configuration as XML`

Le fichier XML généré est ensuite stocké dans un emplacement sécurisé.
