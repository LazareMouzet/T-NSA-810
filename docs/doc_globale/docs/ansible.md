# 🚀 CIA — Documentation Ansible

> Bienvenue sur la documentation du projet **[CIA]**. Lisez-le **entièrement** avant de lancer quoi que ce soit.

---

## 📋 Table des matières

1. [Présentation du projet](#-présentation-du-projet)
2. [Prérequis](#-prérequis)
3. [Architecture du projet](#-architecture-du-projet)
4. [Installation & configuration initiale](#-installation--configuration-initiale)
5. [Comment lancer un playbook](#-comment-lancer-un-playbook)
6. [✅ Ce qu'il faut faire](#-ce-quil-faut-faire)
7. [❌ Ce qu'il ne faut surtout pas faire](#-ce-quil-ne-faut-surtout-pas-faire)
8. [Problèmes fréquents (Troubleshooting)](#-problèmes-fréquents-troubleshooting)
9. [Lexique Ansible](#-lexique-ansible)
10. [Configuration des accès SSH aux VMs](#-configuration-des-accès-ssh-aux-vms)

---

## 📌 Présentation de Ansible

> **Ansible**, c'est quoi ?
> C'est un outil d'automatisation qui permet de configurer des machines distantes **sans installer d'agent dessus**. Il se connecte en SSH, exécute des tâches définies dans des fichiers YAML (appelés *playbooks*), puis se déconnecte. C'est aussi simple que ça.

---

## 🔧 Prérequis

Avant de commencer, assurez-vous d'avoir les éléments suivants sur votre machine **local** (celle depuis laquelle vous lancez Ansible) :

| Prérequis | Version minimale | Commande de vérification |
|---|---|---|
| Python | 3.8+ | `python3 --version` |
| Ansible | 2.14+ | `ansible --version` |
| Accès SSH | — | `ssh user@host` |
| Git | 2.x+ | `git --version` |

### Installation Ansible dans WSL (si pas encore fait)

```bash
# Mise à jour
sudo apt update && sudo apt upgrade -y

# Installation des dépendances
sudo apt install -y python3 python3-pip sshpass

# Installation Ansible
pip3 install ansible --break-system-packages

# Vérification
ansible --version
```
---

## 🗂 Architecture du projet

```ini
[nom-du-projet]/
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
│   |── vm_ip_to_netbox.yml    ← Playbook du rôle vm_ip_to_netbox.yml
|   └── webserver.yml          ← Playbook du rôle webserver.yml
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

> **💡 À retenir :** Ne modifiez jamais un fichier sans comprendre son rôle dans cette arborescence. Chaque fichier a une place précise et une raison d'être.

---

## ⚙️ Installation & configuration initiale

### 1. Cloner le dépôt

```bash
git clone git@github.com:LazareMouzet/T-NSA-810.git
cd T-NSA-810
```

### 2. Configurer votre inventaire

Éditez le fichier `inventory/hosts.yml` pour renseigner vos machines cibles :

> **💡 Explication :**`ansible_host` est l'IP de la machine, `ansible_user` est l'utilisateur SSH utilisé pour se connecter.


### 3. Vérifier la connectivité

Avant tout, vérifiez qu'Ansible peut joindre les machines :

```bash
# Tester TOUTES les machines
ansible all -m ping
```
```bash
# Tester une machines
ansible intranet -m ping
```
Résultat attendu :

```ini
vm2 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

> **⚠️ Si vous obtenez une erreur ici, ne continuez pas.** Résolvez le problème de connectivité SSH d'abord.

### 4. Configurer le vault (secrets)

Les mots de passe et informations sensibles sont chiffrés via **Ansible Vault**. Pour déchiffrer le fichier de secrets :

```bash
# Créer un fichier contenant le mot de passe du vault (UNE SEULE FOIS)
echo "votre_mot_de_passe_vault" > ~/.vault_pass
chmod 600 ~/.vault_pass
```

Assurez-vous que `ansible.cfg` pointe vers ce fichier :

```ini
[defaults]
vault_password_file = ~/.vault_pass
```

Pour ajouter un secret dans le fichier vault.yml, il suffit de lancer cette commmande :

```bash
ansible-vault edit inventory/group_vars/all/vault.yml
```

**Remarque** l'éditeur ouvert par ansible-vault est VI. Les raccourcis clavier à connaître sont :
```ini
    [echap] [i] ← Mode Insertion
    [echap]     ← Sortir du mode actuel
    [:wq]       ← Sauvegarder les modifications actuelles
    [!q]        ← Quitter sans sauvegarder les modifications actuelles
```

### Configuration du fichier ansible.cfg

```ini
[defaults]
inventory = inventory/hosts.yaml
host_key_checking = False
roles_path = chemin_d_acces/T-NSA-810/ansible/roles
vault_password_file = chemin_d_acces/T-NSA-810/ansible/.vault-pass

[ssh_connection]
ssh_executable = ssh
ssh_args = -F chemin_d_acces/.ssh/config -o ControlMaster=auto -o ControlPersist=60s
```

---

## ▶️ Comment lancer un playbook

### Syntaxe de base

```yml
- name: "Exemple : Installer nginx"
  hosts: webservers
  become: yes  # sudo requis

  tasks:
    - name: "1. Installer le paquet nginx"
      ansible.builtin.apt:
        name: nginx
        state: present
      tag:
        - install
```

```bash
ansible-playbook playbooks/[nom-du-playbook].yml
```

### Options utiles

```bash
# Simulation à sec — AUCUNE modification n'est appliquée sur les machines
ansible-playbook playbooks/[nom-du-playbook] --check

# Afficher le diff des fichiers qui seraient modifiés
ansible-playbook playbooks/[nom-du-playbook] --check --diff

# Augmenter la verbosité pour déboguer
ansible-playbook -vvv playbooks/[nom-du-playbook]

# Lancer seulement certaines tâches via des tags
ansible-playbook playbooks/[nom-du-playbook] --tags "install"
```

> **💡 Bonne pratique :** Lancez **toujours** avec `--check` avant une vraie exécution. C'est votre filet de sécurité.

---

## ✅ Ce qu'il faut faire

### 🔐 Sécurité & secrets

- ✅ **Toujours chiffrer** les données sensibles (mots de passe, tokens, clés API) avec `ansible-vault edit inventory/group_vars/all/vault.yml`
- ✅ **Stocker le mot de passe du vault** dans un fichier avec les permissions `600` (`chmod 600 ~/.vault_pass`)
- ✅ **Ajouter `vault.yml` dans `.gitignore`** si le fichier n'est pas chiffré

### 🧪 Avant d'exécuter

- ✅ **Toujours faire un `--check`** avant d'appliquer un playbook sur un environnement critique
- ✅ **Relire le playbook** entièrement avant de le lancer
- ✅ **Vérifier l'inventaire ciblé** s'assurer qu'on ne vise pas accidentellement la mauvaise vm

### 📁 Gestion du code

- ✅ **Versionner tout le code Ansible** dans Git
- ✅ **Commenter vos tâches** avec le champ `name:` de manière explicite
- ✅ **Utiliser des variables** plutôt que des valeurs codées en dur dans les tâches

---

## ❌ Ce qu'il ne faut surtout pas faire

### 🚨 Erreurs critiques

- ❌ **Ne jamais écrire un mot de passe en clair** dans un playbook, un fichier de variables, ou un inventaire
  ```yaml
  # ❌ JAMAIS ça
  db_password: MonSuperMotDePasse123

  # ✅ À la place
  db_password: "{{ vault_db_password }}"
  ```

- ❌ **Ne jamais commiter le fichier `.vault_pass`** ou tout fichier contenant des secrets non chiffrés dans Git

### 🐍 Python & dépendances

- ❌ **Ne jamais faire `pip install` sans environnement virtuel** — Surtout pas avec `--break-system-packages` ou `sudo pip`

### ❌ À bannir absolument
  ```yml
  - name: Installer mon package
    ansible.builtin.pip:
      name: mon_package
      state: present
  ```

### ✅ À faire à la place
  ````yml
    - name: Créer un virtualenv et installer mon package
    ansible.builtin.pip:
      name: mon_package
      state: present
      virtualenv: "/opt/ansible/venv"
      virtualenv_command: /usr/bin/python3 -m venv
  ````

## ⚠️ Erreurs courantes qui causent des incidents

- ❌ **Ne pas utiliser `shell:` ou `command:` à la place des modules Ansible** — ces modules contournent la gestion d'idempotence
  ```yaml
  # ❌ Éviter autant que possible
  - name: Démarrer nginx
    shell: systemctl start nginx

  # ✅ Utiliser le module dédié
  - name: Démarrer nginx
    ansible.builtin.service:
      name: nginx
      state: started
  ```

- ❌ **Ne pas installer** avec `ignore_errors: yes` sans documenter pourquoi

- ❌ **Ne pas ignorer les erreurs** avec `ignore_errors: yes` sans documenter pourquoi

- ❌ **Ne pas utiliser `become: yes` (sudo) partout par défaut** — n'escaladez les privilèges que là où c'est nécessaire

- ❌ **Ne jamais lancer un playbook sur `all`** sans savoir exactement quelles machines sont dans cet inventaire

---

## Problèmes fréquents (Troubleshooting)

### 🔍 Démarche de diagnostic (à faire SOI-MÊME avant d'appeler quelqu'un)

1. `ansible all -m ping` → La machine répond-elle ?
2. `ansible-playbook playbook.yml --check --diff` → Que ferait Ansible ?
3. `ansible-playbook playbook.yml -vvv` → Regarder la dernière ligne d'erreur
4. Vérifier `~/.vault_pass` existe et a les droits `600`

---

### Erreur : `MODULE FAILURE` ou `Python not found`

**Cause :** Python n'est pas installé ou n'est pas trouvé sur la machine cible.

**Solution :**
```ini
# Dans inventory/hosts.yml ou group_vars/all/all.yml ou dans le playbook en question
ansible_python_interpreter=/usr/bin/python3
```

---

### Erreur : `Decryption failed`

**Cause :** Le mot de passe du vault est incorrect ou le fichier `.vault_pass` est mal configuré.

**Solutions :**
```bash
# Vérifier que le fichier vault_pass existe et a les bons droits
ls -la ~/.vault_pass

# Tester manuellement le déchiffrement
ansible-vault view group_vars/all/vault.yml
```

---

### Erreur : `changed` alors qu'on ne voulait rien modifier

**Cause :** Une tâche n'est pas **idempotente**, elle modifie quelque chose à chaque exécution même si l'état est déjà le bon.

**Solution :** Utiliser les modules Ansible natifs plutôt que `shell:` ou `command:`, qui ne savent pas vérifier l'état actuel d'une ressource.

---

## 📖 Lexique Ansible

| Terme | Définition |
|---|---|
| **Playbook** | Fichier YAML décrivant une série de tâches à exécuter |
| **Task** | Une action unitaire (ex : installer un paquet, créer un fichier) |
| **Role** | Regroupement de tâches, variables et templates autour d'une fonctionnalité |
| **Inventory** | Liste des machines sur lesquelles Ansible va agir |
| **Module** | Unité de code Ansible qui réalise une action (ex : `package`, `copy`, `service`) |
| **Handler** | Tâche déclenchée uniquement si une autre tâche l'a notifiée (ex : restart nginx) |
| **Vault** | Système de chiffrement des secrets dans Ansible |
| **Idempotence** | Propriété d'une tâche : l'exécuter plusieurs fois donne le même résultat que l'exécuter une seule fois |
| **Become** | Mécanisme d'escalade de privilèges (équivalent de `sudo`) |
| **Template (Jinja2)** | Fichier de configuration avec des variables dynamiques (extension `.j2`) |
| **Tag** | Étiquette sur une tâche permettant de n'exécuter qu'une partie du playbook |
| **Check mode (`--check`)** | Mode simulation : Ansible calcule ce qu'il ferait, sans rien modifier |

> En cas de doute, **ne lancez rien** et demandez à un membre de l'équipe. Il vaut mieux poser une question que de casser un environnement.

---

## Configuration des accès SSH aux VMs

```bash
# 1. Chaque membre crée SA clé (UNE SEULE FOIS)
ssh-keygen -t ed25519 -C "prenom.nom@epitech.eu"

# 2. Il donne sa clé publique (fichier .pub) au responsable du vault
cat ~/.ssh/id_ed25519.pub
# Copier-coller la ligne

# 3. Le responsable l'ajoute dans vault
ansible-vault edit inventory/group_vars/all/vault.yml
# Ajouter la ligne dans team_ssh_keys

# 4. On exécute le playbook
ansible-playbook playbooks/distribute_ssh_keys.yml
```

### Astuce : Éviter de retaper sa passphrase à chaque connexion SSH

Votre clé SSH étant protégée par une passphrase, vous devez la saisir à chaque nouvelle connexion à une VM. Voici comment configurer `ssh-agent` pour ne la saisir qu'une seule fois par session.

### Configuration de ssh-agent

```bash
# Démarrer l'agent SSH
eval $(ssh-agent -s)

# Ajouter votre clé privée (avec passphrase)
ssh-add ~/.ssh/id_ed25519
```

---

## Configuration des accès aux VMs via Bastion

Dans votre dossier **~/.ssh/**, créer un fichier config dans lequel vous ajouterez la configuration suivante :

```ini
Host bastion
    HostName [IP_WAN_REMOTE]
    User [USER_VM_BASTION]
    Port [PORT]
    IdentityFile ~/.ssh/id_ed25519
    ForwardAgent yes

Host intranet
    HostName [IP_INTRANET]
    User [USER_VM_INTRANET]
    Port [PORT]
    ProxyJump bastion

Host monitoring
    HostName [IP_MONITORING]
    User [USER_VM_MONITORING]
    Port [PORT]
    ProxyJump bastion

Host outils
    HostName [IP_OUTILS]
    User [USER_VM_OUTILS]
    Port [PORT]
    ProxyJump bastion

Host pfsense-remote
    HostName [IP_WAN_REMOTE]
    User [USER_VM_BASTION]
    Port [PORT]
    IdentityFile ~/.ssh/id_ed25519
    LocalForward 8080 [IP_LAN_REMOTE]:80
    ServerAliveInterval 60
    ServerAliveCountMax 3

Host pfsense-datacenter
    HostName [IP_WAN_REMOTE]
    User [USER_VM_BASTION]
    Port [PORT]
    IdentityFile ~/.ssh/id_ed25519
    LocalForward 8443 [IP_LAN_DATACENTER]:443
    ServerAliveInterval 60
    ServerAliveCountMax 3

```
---
