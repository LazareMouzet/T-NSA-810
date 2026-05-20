# Runbook — Projet CIA
## Cloud Infrastructure Architects

| Champ | Valeur |
|---|---|
| Projet | CIA — Cloud Infrastructure Architects |
| Auteur | Salah-Wassim ARFA |
| Établissement | Epitech |
| Date | Mai 2026 |
| Version | 1.0 |

---

## Sommaire

1. [Introduction & Vue d'ensemble](#1-introduction--vue-densemble)
2. [Prérequis & Accès](#2-prérequis--accès)
3. [Procédures opérationnelles](#3-procédures-opérationnelles)
   - 3.1 [Accès à l'infrastructure](#31-accès-à-linfrastructure)
   - 3.2 [Vérification de l'état de l'infrastructure](#32-vérification-de-létat-de-linfrastructure)
   - 3.3 [Gestion des services](#33-gestion-des-services)
   - 3.4 [Ansible — Relancer un playbook](#34-ansible--relancer-un-playbook)
   - 3.5 [Vault — Unsealing manuel](#35-vault--unsealing-manuel)
   - 3.6 [NetBox — Accès et utilisation](#36-netbox--accès-et-utilisation)
   - 3.7 [Elasticsearch & Kibana — Accès et vérification](#37-elasticsearch--kibana--accès-et-vérification)
4. [Tâches de maintenance](#4-tâches-de-maintenance)
   - 4.1 [Mise à jour des packages](#41-mise-à-jour-des-packages)
   - 4.2 [Rotation des secrets Vault](#42-rotation-des-secrets-vault)
   - 4.3 [Nettoyage des logs](#43-nettoyage-des-logs)
5. [Contacts & Ressources](#5-contacts--ressources)

---

## 1. Introduction & Vue d'ensemble

### 1.1 Objectif du document

Ce Runbook décrit l'ensemble des procédures opérationnelles nécessaires au bon fonctionnement et à la maintenance de l'infrastructure CIA. Il s'adresse à toute personne amenée à intervenir sur l'infrastructure, que ce soit pour des opérations courantes ou des interventions de maintenance.

### 1.2 Description de l'infrastructure

L'infrastructure CIA est une architecture hybride multi-sites composée de deux environnements Proxmox interconnectés via un tunnel VPN Site-à-Site OpenVPN, pilotés par des firewalls pfSense.

#### Schéma général

```
Internet
   │
   ├── pfSense Remote (5.196.51.230)
   │       ├── bastion.local  (192.168.20.10)  — SSH Jump Host
   │       └── intranet.local (192.168.30.10)  — Application web
   │
   └── pfSense Datacenter
           ├── outils.local    (192.168.200.10) — NetBox + Vault
           └── monitoring.local (192.168.130.10) — Elasticsearch + Kibana
```

#### Inventaire des VMs

| VM | Site | IP | Rôle | OS |
|---|---|---|---|---|
| `bastion.local` | Remote | 192.168.20.10 | SSH Jump Host | Ubuntu 24.04 |
| `intranet.local` | Remote | 192.168.30.10 | Application web | Ubuntu 24.04 |
| `outils.local` | Datacenter | 192.168.200.10 | NetBox + Vault | Ubuntu 24.04 |
| `monitoring.local` | Datacenter | 192.168.130.10 | Elasticsearch + Kibana | Ubuntu 24.04 |

#### Inventaire des services

| Service | VM | Port | Rôle |
|---|---|---|---|
| OpenSSH | toutes | 22 | Accès SSH |
| HashiCorp Vault | outils.local | 8200 | Gestion des secrets |
| NetBox | outils.local | 80/443 | IPAM |
| Elasticsearch | monitoring.local | 9200 | Indexation des logs |
| Kibana | monitoring.local | 5601 | Visualisation des logs |
| Filebeat | monitoring.local | — | Collecte des logs |

### 1.3 Outils utilisés

| Outil | Usage |
|---|---|
| Ansible | Automatisation et configuration des VMs |
| Ansible Vault | Chiffrement des secrets Ansible |
| HashiCorp Vault | Gestion centralisée des secrets |
| pfSense | Firewall et routage |
| OpenVPN | VPN Site-à-Site et Point-à-Site |

---

## 2. Prérequis & Accès

### 2.1 Prérequis poste de travail

- WSL (Windows Subsystem for Linux) installé
- Ansible installé dans WSL
- Clé SSH `~/.ssh/id_ed25519` générée et déposée sur toutes les VMs
- `ssh-agent` démarré avec la clé chargée
- Fichier `~/.ssh/config` configuré (voir section 3.1)

### 2.2 Démarrer ssh-agent

À chaque nouvelle session WSL, démarrer `ssh-agent` et charger la clé :

```bash
eval $(ssh-agent -s)
ssh-add ~/.ssh/id_ed25519
```

> ⚠️ Sans cette étape, les connexions SSH via ProxyJump et les playbooks Ansible échoueront.

### 2.3 Configuration SSH (`~/.ssh/config`)

```
Host bastion
    HostName 5.196.51.230
    User epicloud111
    Port 2250
    IdentityFile ~/.ssh/id_ed25519
    ForwardAgent yes

Host outils
    HostName 192.168.200.10
    User epicloud
    Port 22
    ProxyJump bastion

Host monitoring
    HostName 192.168.130.10
    User epicloud
    Port 22
    ProxyJump bastion

Host intranet
    HostName 192.168.30.10
    User epicloud211
    Port 22
    ProxyJump bastion

# Tunnels GUI pfSense
Host pfsense-remote
    HostName 5.196.51.230
    User epicloud111
    Port 2250
    IdentityFile ~/.ssh/id_ed25519
    LocalForward 8080 192.168.10.10:80

Host pfsense-datacenter
    HostName 192.168.200.10
    User epicloud
    ProxyJump bastion
    LocalForward 8443 192.168.100.10:443
```

---

## 3. Procédures opérationnelles

### 3.1 Accès à l'infrastructure

#### Connexion SSH aux VMs

```bash
# Bastion
ssh bastion

# VM Outils (NetBox + Vault)
ssh outils

# VM Monitoring (Elasticsearch + Kibana)
ssh monitoring

# VM Intranet
ssh intranet
```

#### Accès aux interfaces web via tunnel SSH

Ouvrir le tunnel dans un terminal WSL, puis accéder à l'URL dans le navigateur :

| Interface | Commande tunnel | URL |
|---|---|---|
| NetBox | `ssh -N outils` | `https://localhost:8443` |
| Kibana | `ssh -L 5601:localhost:5601 monitoring` | `http://localhost:5601` |
| Vault | `ssh -L 8200:localhost:8200 outils` | `http://localhost:8200` |
| pfSense Remote | `ssh -N pfsense-remote` | `http://localhost:8080` |
| pfSense Datacenter | `ssh -N pfsense-datacenter` | `https://localhost:8443` |

> ℹ️ L'option `-N` ouvre uniquement le tunnel sans ouvrir de shell interactif.

#### Connexion VPN Point-à-Site

Pour un accès complet au réseau de l'infrastructure sans tunnel SSH individuel :

1. Lancer le client OpenVPN
2. Charger le profil `CIA-Remote.ovpn`
3. Se connecter
4. L'ensemble des réseaux de l'infrastructure est alors accessible directement

---

### 3.2 Vérification de l'état de l'infrastructure

#### Vérification globale via Ansible

```bash
cd ~/ansible-CIA
eval $(ssh-agent -s) && ssh-add ~/.ssh/id_ed25519
ansible all -m ping
```

Résultat attendu :

```
bastion     | SUCCESS => {"ping": "pong"}
outils      | SUCCESS => {"ping": "pong"}
monitoring  | SUCCESS => {"ping": "pong"}
intranet    | SUCCESS => {"ping": "pong"}
```

#### Vérification de l'espace disque

```bash
ansible all -m shell -a "df -h /"
```

> ⚠️ Surveiller particulièrement `monitoring.local` — Elasticsearch est gourmand en espace disque.

#### Vérification des services sur chaque VM

```bash
# Sur outils.local
ssh outils
sudo systemctl status vault
sudo systemctl status netbox
sudo systemctl status netbox-rq
sudo systemctl status nginx
sudo systemctl status postgresql

# Sur monitoring.local
ssh monitoring
sudo systemctl status elasticsearch
sudo systemctl status kibana
sudo systemctl status filebeat

# Sur bastion.local
ssh bastion
sudo systemctl status fail2ban
sudo systemctl status ssh

# Sur intranet.local
ssh intranet
sudo systemctl status fail2ban
```

---

### 3.3 Gestion des services

#### Démarrer un service

```bash
sudo systemctl start <nom_service>
```

#### Arrêter un service

```bash
sudo systemctl stop <nom_service>
```

#### Redémarrer un service

```bash
sudo systemctl restart <nom_service>
```

#### Vérifier les logs d'un service

```bash
sudo journalctl -u <nom_service> -n 50 --no-pager
```

#### Référence des noms de services

| Service | Nom systemd | VM |
|---|---|---|
| Vault | `vault` | outils.local |
| Vault Auto-Unseal | `vault-unseal` | outils.local |
| NetBox | `netbox` | outils.local |
| NetBox Worker | `netbox-rq` | outils.local |
| Nginx | `nginx` | outils.local |
| PostgreSQL | `postgresql` | outils.local |
| Elasticsearch | `elasticsearch` | monitoring.local |
| Kibana | `kibana` | monitoring.local |
| Filebeat | `filebeat` | monitoring.local |
| Fail2ban | `fail2ban` | toutes |

---

### 3.4 Ansible - Relancer un playbook

#### Prérequis

```bash
cd ~/ansible-CIA
eval $(ssh-agent -s) && ssh-add ~/.ssh/id_ed25519
```

#### Playbooks disponibles

| Playbook | Cible | Description |
|---|---|---|
| `common.yml` | Toutes les VMs | Configuration de base |
| `vault.yml` | outils.local | Déploiement Vault |
| `elastic.yml` | monitoring.local | Déploiement Elastic Stack |
| `netbox.yml` | outils.local | Déploiement NetBox |

#### Procédure standard

```bash
# 1. Toujours tester en mode check avant
ansible-playbook playbooks/<playbook>.yml --check --diff

# 2. Si le check est satisfaisant, lancer pour de vrai
ansible-playbook playbooks/<playbook>.yml
```

> ⚠️ Ne jamais lancer un playbook sans avoir fait le `--check` au préalable.

#### Cibler une VM spécifique

```bash
ansible-playbook playbooks/common.yml --limit outils
```

---

### 3.5 Vault - Unsealing manuel

En temps normal, Vault se déverrouillie automatiquement au démarrage via le service `vault-unseal`. Si ce mécanisme échoue, procéder manuellement :

```bash
ssh outils
export VAULT_ADDR="http://127.0.0.1:8200"

# Vérifier l'état de Vault
vault status

# Si Sealed: true, unseal manuellement
vault operator unseal
# Entrer l'unseal key quand demandée
```

> ⚠️ L'unseal key est stockée dans KeePass. Ne jamais la stocker en clair sur un système.

#### Vérification après unsealing

```bash
vault status
# Sealed doit être : false
# Initialized doit être : true
```

---

### 3.6 NetBox — Accès et utilisation

#### Accès à l'interface web

```bash
# Ouvrir le tunnel SSH
ssh -N outils -L 443:localhost:443

# Accéder dans le navigateur
https://localhost
```

#### Vérification de l'état de NetBox

```bash
ssh outils
sudo systemctl status netbox netbox-rq nginx postgresql
```

#### Redémarrage complet de la stack NetBox

```bash
ssh outils
sudo systemctl restart postgresql
sudo systemctl restart netbox netbox-rq
sudo systemctl restart nginx
```

---

### 3.7 Elasticsearch & Kibana — Accès et vérification

#### Accès à Kibana

```bash
# Ouvrir le tunnel SSH
ssh -L 5601:localhost:5601 monitoring

# Accéder dans le navigateur
http://localhost:5601
```

#### Vérification de l'état d'Elasticsearch

```bash
ssh monitoring
curl -u elastic:<mot_de_passe> http://localhost:9200/_cluster/health?pretty
```

Résultat attendu :

```json
{
  "status" : "green",
  "number_of_nodes" : 1,
  "active_shards" : 1
}
```

#### Vérification de l'espace disque avant toute opération

```bash
df -h /
```

> ⚠️ Ne jamais lancer de mise à jour apt sur `monitoring.local` sans avoir vérifié l'espace disque disponible. Elasticsearch et Kibana sont des paquets volumineux.

---

## 4. Tâches de maintenance

### 4.1 Mise à jour des packages

> ⚠️ Ne jamais utiliser `apt dist-upgrade`. Utiliser uniquement `apt upgrade` (équivalent `upgrade: safe` dans Ansible).

> ⚠️ Elasticsearch, Kibana et Filebeat sont gelés (`apt-mark hold`) et ne doivent pas être mis à jour sans validation préalable.

#### Via Ansible (recommandé)

```bash
cd ~/ansible-CIA
ansible-playbook playbooks/common.yml --check --diff
ansible-playbook playbooks/common.yml
```

#### Manuellement sur une VM

```bash
sudo apt update
sudo apt upgrade -y
```

---

### 4.2 Rotation des secrets Vault

#### Connexion à Vault

```bash
ssh outils
export VAULT_ADDR="http://127.0.0.1:8200"
export VAULT_TOKEN="<root_token>"
```

#### Lister les secrets existants

```bash
vault kv list secret/
```

#### Mettre à jour un secret

```bash
vault kv put secret/<chemin> <clé>=<nouvelle_valeur>
```

#### Vérifier un secret

```bash
vault kv get secret/<chemin>
```

---

### 4.3 Nettoyage des logs

#### Logs journald (toutes les VMs)

```bash
# Voir l'espace occupé par journald
journalctl --disk-usage

# Nettoyer les logs de plus de 7 jours
sudo journalctl --vacuum-time=7d

# Ou limiter à 500MB
sudo journalctl --vacuum-size=500M
```

#### Logs Elasticsearch

Les logs Elasticsearch sont configurés avec une rotation automatique. En cas de disque plein :

```bash
ssh monitoring

# Vérifier l'espace disque
df -h /

# Nettoyer le cache apt
sudo apt clean

# Vider les logs journald anciens
sudo journalctl --vacuum-time=7d

# Vérifier la taille des logs Elasticsearch
du -sh /var/log/elasticsearch/
```

---

## 5. Contacts & Ressources

### 5.1 Contacts

| Rôle | Nom | Contact |
|---|---|---|
| Auteur / Admin infra | Salah-Wassim ARFA | — |

### 5.2 Ressources techniques

| Ressource | URL |
|---|---|
| Documentation Ansible | https://docs.ansible.com |
| Documentation Vault | https://developer.hashicorp.com/vault/docs |
| Documentation NetBox | https://docs.netbox.dev |
| Documentation Elasticsearch | https://www.elastic.co/guide |
| Documentation pfSense | https://docs.netgate.com/pfsense |

### 5.3 Accès aux interfaces

| Interface | Accès | Credentials |
|---|---|---|
| pfSense Remote | Tunnel SSH → `http://localhost:8080` | KeePass |
| pfSense Datacenter | Tunnel SSH → `https://localhost:8443` | KeePass |
| NetBox | Tunnel SSH → `https://localhost:8443` | KeePass |
| Kibana | Tunnel SSH → `http://localhost:5601` | KeePass |
| Vault | Tunnel SSH → `http://localhost:8200` | KeePass |

> ℹ️ Tous les credentials sont stockés dans KeePass. Ne jamais les noter en clair dans ce document.
