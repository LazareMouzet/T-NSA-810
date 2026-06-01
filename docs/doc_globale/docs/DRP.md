# Plan de Reprise d'Activité (PRA/DRP)
## Projet CIA — Cloud Infrastructure Architects

| Champ | Valeur |
|---|---|
| Projet | CIA |
| Établissement | Epitech |
| Date | Mai 2026 |
| Version | 1.0 |

---

## Sommaire

1. [Introduction & Objectifs](#1-introduction--objectifs)
2. [Inventaire des composants critiques](#2-inventaire-des-composants-critiques)
   - 2.1 [Tableau de criticité](#21-tableau-de-criticité)
   - 2.2 [Dépendances entre services](#22-dépendances-entre-services)
   - 2.3 [Ordre de reprise des services](#23-ordre-de-reprise-des-services)
3. [Scénarios de panne & procédures](#3-scénarios-de-panne--procédures)
   - 3.1 [Perte d'un service systemd](#31-perte-dun-service-systemd)
   - 3.2 [Vault sealed / indisponible](#32-vault-sealed--indisponible)
   - 3.3 [Perte du bastion SSH](#33-perte-du-bastion-ssh)
   - 3.4 [Disque plein](#34-disque-plein)
   - 3.5 [Configuration corrompue](#35-configuration-corrompue)
   - 3.6 [Perte du VPN Site-to-Site](#36-perte-du-vpn-site-to-site)
   - 3.7 [Perte de configuration pfSense](#37-perte-de-configuration-pfsense)
   - 3.8 [Restauration depuis snapshot](#38-restauration-depuis-snapshot)
4. [Reconstruction via Ansible](#4-reconstruction-via-ansible)
   - 4.1 [Préparation de l'environnement](#41-préparation-de-lenvironnement)
   - 4.2 [Rejeu des playbooks](#42-rejeu-des-playbooks)
   - 4.3 [Vérifications post-déploiement](#43-vérifications-post-déploiement)
5. [Tests de reprise](#5-tests-de-reprise)
   - 5.1 [Procédures de test](#51-procédures-de-test)
   - 5.2 [Validation des services](#52-validation-des-services)
   - 5.3 [Limites du PRA](#53-limites-du-pra)

---

## 1. Introduction & Objectifs

### 1.1 Objectif du document

Ce Plan de Reprise d'Activité (PRA) définit les procédures à suivre pour rétablir le fonctionnement de l'infrastructure CIA en cas d'incident ou de panne. Il a pour objectif de minimiser le temps d'indisponibilité des services et de garantir la continuité opérationnelle de l'infrastructure.

Ce document complète le Runbook opérationnel, là où le Runbook décrit les opérations courantes, le PRA décrit les procédures à suivre lorsque quelque chose ne fonctionne plus normalement.

### 1.2 Périmètre

Ce PRA couvre l'ensemble des composants de l'infrastructure CIA :

- Les quatre VMs Ubuntu 24.04 (`bastion.local`, `intranet.local`, `outils.local`, `monitoring.local`)
- Les services déployés sur ces VMs (Vault, NetBox, Elasticsearch, Kibana, Filebeat)
- Les équipements réseau (pfSense Remote, pfSense Datacenter)
- Le tunnel VPN Site-à-Site

### 1.3 Contraintes

> ⚠️ **Contrainte majeure :** Le prestataire hébergeant les environnements Proxmox ne permet pas la création de nouvelles VMs. En conséquence, tout scénario impliquant la perte totale et irrémédiable d'une VM ne peut être résolu que par deux moyens :
> - Restauration depuis un snapshot Proxmox existant
> - Remise à zéro de la VM par le prestataire, suivie d'un redéploiement via Ansible

Cette contrainte impose une discipline rigoureuse en matière de snapshots et de sauvegarde des configurations.

### 1.4 Stratégie générale de reprise

La stratégie de reprise repose sur trois piliers complémentaires :

**1. Snapshots Proxmox :** Des snapshots réguliers permettent de restaurer une VM dans un état antérieur connu et fonctionnel. C'est la solution la plus rapide en cas de corruption ou de mauvaise manipulation.

**2. Playbooks Ansible :** L'ensemble de la configuration est codifiée sous forme de playbooks Ansible. Sur une VM remise à zéro, rejouer les playbooks suffit à reconfigurer tous les services. C'est la solution de reprise complète en cas de perte irrémédiable d'une VM.

**3. Sauvegardes manuelles :** Certains éléments critiques (configuration pfSense, données NetBox, secrets Vault) font l'objet de sauvegardes manuelles régulières stockées dans KeePass et le dépôt Git.

---

## 2. Inventaire des composants critiques

### 2.1 Tableau de criticité

| Composant | VM | Criticité | Impact si indisponible |
|---|---|---|---|
| pfSense Remote | Remote | 🔴 Critique | Perte d'accès à toute l'infrastructure |
| pfSense Datacenter | Datacenter | 🔴 Critique | Perte d'accès aux services datacenter |
| Bastion SSH | bastion.local | 🔴 Critique | Impossible d'administrer l'infrastructure |
| VPN Site-to-Site | pfSense | 🔴 Critique | Perte de communication inter-sites |
| HashiCorp Vault | outils.local | 🟠 Élevée | Secrets inaccessibles |
| NetBox | outils.local | 🟡 Moyenne | Perte de la source de vérité IPAM |
| Elasticsearch | monitoring.local | 🟡 Moyenne | Perte de visibilité sur les logs |
| Kibana | monitoring.local | 🟡 Moyenne | Perte d'interface de visualisation |
| Filebeat | toutes VMs | 🟢 Faible | Logs non centralisés, services non affectés |
| Intranet | intranet.local | 🟡 Moyenne | Site web inaccessible |

### 2.2 Dépendances entre services

**Dépendances critiques :**
- Sans pfSense → aucun accès possible à l'infrastructure
- Sans VPN Site-to-Site → les deux sites sont isolés l'un de l'autre
- Sans bastion → aucune administration SSH possible
- Sans Vault → les secrets ne sont plus accessibles aux services qui en dépendent
- Sans PostgreSQL → NetBox est indisponible

### 2.3 Ordre de reprise des services

En cas de reconstruction complète, respecter impérativement cet ordre :

```
1. pfSense Remote        → point d'entrée de l'infrastructure
2. pfSense Datacenter    → accès au datacenter
3. VPN Site-to-Site      → interconnexion inter-sites
4. Bastion SSH           → accès administration
5. Vault                 → secrets disponibles
6. PostgreSQL            → base de données NetBox
7. NetBox                → IPAM opérationnel
8. Elasticsearch         → indexation des logs
9. Kibana                → visualisation
10. Filebeat (toutes VMs) → collecte des logs
11. Intranet             → application web
```

---

## 3. Scénarios de panne & procédures

### 3.1 Perte d'un service systemd

**Symptômes :** Un service ne répond plus, erreur de connexion à une interface web, timeout.

**Diagnostic :**

```bash
# Vérifier l'état du service
sudo systemctl status <nom_service>

# Consulter les logs du service
sudo journalctl -u <nom_service> -n 50 --no-pager
```

**Procédure de reprise :**

```bash
# Tentative de redémarrage
sudo systemctl restart <nom_service>

# Vérification après redémarrage
sudo systemctl status <nom_service>
```

**Si le redémarrage échoue :**
1. Analyser les logs pour identifier la cause racine (`journalctl -u <service> -n 100`)
2. Vérifier l'espace disque disponible (`df -h /`)
3. Vérifier les fichiers de configuration du service
4. Si la configuration est corrompue → voir scénario 3.5
5. Si le disque est plein → voir scénario 3.4

**Référence des services par VM :**

| VM | Services à vérifier |
|---|---|
| outils.local | `vault`, `vault-unseal`, `netbox`, `netbox-rq`, `nginx`, `postgresql` |
| monitoring.local | `elasticsearch`, `kibana`, `filebeat` |
| bastion.local | `ssh`, `fail2ban` |
| intranet.local | `nginx`, `fail2ban` |

---

### 3.2 Vault sealed / indisponible

**Symptômes :** Vault démarre mais est dans l'état `Sealed: true`, les secrets sont inaccessibles.

**Causes possibles :**
- Redémarrage de la VM sans auto-unseal
- Échec du service `vault-unseal`
- Corruption des données Vault

**Diagnostic :**

```bash
ssh outils
export VAULT_ADDR="http://127.0.0.1:8200"
vault status
```

**Procédure de reprise : Auto-unseal échoué :**

```bash
# Vérifier l'état du service vault-unseal
sudo systemctl status vault-unseal

# Redémarrer le service vault-unseal
sudo systemctl restart vault-unseal

# Vérifier que Vault est bien unsealed
vault status
# Sealed doit être : false
```

**Procédure de reprise : Unseal manuel :**

```bash
ssh -L 8200:localhost:8200 outils

# Unseal manuel avec la clé stockée dans KeePass
vault operator unseal
# Entrer l'unseal key quand demandée
```

**Procédure de reprise : Vault indisponible (service down) :**

```bash
# Redémarrer Vault
sudo systemctl restart vault
sleep 10

# Vérifier l'état
sudo systemctl status vault
vault status
```

> ⚠️ L'unseal key et le root token sont stockés exclusivement dans KeePass. Sans ces éléments, les données Vault sont inaccessibles de façon définitive.

---

### 3.3 Perte du bastion SSH

**Symptômes :** Impossible de se connecter en SSH au bastion (`ssh bastion` timeout ou refused).

**Impact :** Critique ; sans bastion, aucune VM n'est administrable en SSH.

**Diagnostic depuis le poste admin :**

```bash
# Test de connectivité réseau
ping 5.196.51.230

# Test SSH verbose
ssh -v bastion
```

**Procédure de reprise :**

1. **Vérifier la connectivité réseau :** si ping échoue, le problème est réseau (pfSense ou prestataire)
2. **Vérifier pfSense Remote :** accéder au GUI pfSense via tunnel SSH et vérifier les règles NAT
3. **Vérifier le service SSH sur le bastion :** accèder à l'interface web du proxmox si impossibilité de se connecter à la VM via le tunnel SSH. Par la suite, vérifier le status SSH.
4. **Vérifier fail2ban :** une IP bannie peut simuler une perte de bastion :

```bash
# Depuis une autre IP ou après contact prestataire
sudo fail2ban-client status sshd
sudo fail2ban-client set sshd unbanip <ip>
```

> ⚠️ En cas de perte totale du bastion sans accès console Proxmox, contacter le prestataire pour une intervention directe sur la VM.

---

### 3.4 Disque plein

**Symptômes :** Erreurs d'écriture, services qui crashent, `No space left on device` dans les logs.

> ⚠️ Ce scénario s'est produit sur `monitoring.local` lors d'une mise à jour `apt dist-upgrade` qui a tenté de télécharger 1152 MB de mises à jour Elasticsearch sur un volume LVM de 7.6 GB.

**Diagnostic :**

```bash
# Vérifier l'espace disque
df -h /

# Identifier les dossiers volumineux
du -sh /* 2>/dev/null | sort -rh | head -20
du -sh /var/log/* 2>/dev/null | sort -rh | head -10
```

**Procédure de reprise :**

```bash
# 1. Nettoyer le cache apt
sudo apt clean
sudo apt autoremove -y

# 2. Nettoyer les logs journald anciens
sudo journalctl --vacuum-time=7d
sudo journalctl --vacuum-size=200M

# 4. Vérifier les logs applicatifs volumineux
du -sh /var/log/elasticsearch/

# 5. Supprimer les fichiers de log trop anciens si nécessaire
sudo ls -lh /var/log/elasticsearch/
sudo find /var/log/elasticsearch/ -name "gc.log.[0-9]*" -delete
sudo find /var/log/elasticsearch/ -name "*.gz" -mtime +7 -delete

# 6. Supprimer les fichiers syslog trop anciens si nécessaire
ls /var/log/
sudo find /var/log/ -name "syslog.[0-9]*.gz" -delete

# 7. Vérification final de l'espace dique du LVM
df -h
```

**Après libération d'espace, redémarrer les services affectés :**

```bash
sudo systemctl restart elasticsearch
sudo systemctl restart kibana
```

> ⚠️ Ne jamais lancer `apt dist-upgrade` sur `monitoring.local`, Elasticsearch et Kibana sont gelés via `apt-mark hold` et pèsent plusieurs centaines de MB chacun.

---

### 3.5 Configuration corrompue

**Symptômes :** Un service refuse de démarrer après une modification de configuration, erreur de parsing dans les logs.

**Procédure de reprise via Ansible :**

La solution privilégiée est de **rejouer le playbook Ansible** correspondant au service concerné, il va redéployer la configuration saine depuis les templates.

```bash
cd ~/ansible-CIA
eval $(ssh-agent -s) && ssh-add ~/.ssh/id_ed25519

# Vérifier ce qui va changer
ansible-playbook playbooks/<service>.yml --check --diff

# Appliquer la configuration saine
ansible-playbook playbooks/<service>.yml
```

**Correspondance service → playbook :**

| Service affecté | Playbook à rejouer |
|---|---|
| Vault | `playbooks/vault.yml` |
| Elasticsearch / Kibana / Filebeat | `playbooks/elastic.yml` |
| NetBox / Nginx / PostgreSQL | `playbooks/netbox.yml` |
| Configuration de base (fail2ban, timezone...) | `playbooks/common.yml` |

**Cas spécifique : Elasticsearch ne démarre pas après une mise à jour :**

Vérifier que `elasticsearch.yml` ne contient pas de paramètres de niveau index :

```bash
sudo grep "index\." /etc/elasticsearch/elasticsearch.yml
```

Si des paramètres `index.*` sont présents en dehors des commentaires, les supprimer ou les commenter, puis redémarrer :

```bash
sudo systemctl restart elasticsearch
```

> ℹ️ Ce problème s'est produit lors d'une mise à jour partielle avortée qui a réécrit `elasticsearch.yml` avec `index.number_of_replicas: 0`, paramètre invalide au niveau nœud depuis Elasticsearch 5.x.

---

### 3.6 Perte du VPN Site-to-Site

**Symptômes :** Les VMs d'un site ne peuvent plus communiquer avec les VMs de l'autre site. Les pings inter-sites échouent.

**Diagnostic :**

```bash
# Depuis bastion.local, tenter de pinguer outils.local
ssh bastion
ping 192.168.200.10

# Vérifier le statut du VPN depuis le GUI pfSense
# Status > OpenVPN
```

**Procédure de reprise :**

1. **Accéder au GUI pfSense Remote** via tunnel SSH : `ssh -N pfsense-remote` → `http://localhost:8080`
2. Naviguer vers **Status > OpenVPN**
3. Vérifier l'état du tunnel. Si `Disconnected` :
   - Cliquer sur le bouton **Reconnect**
   - Attendre 30 secondes et vérifier le statut
4. Si le tunnel ne remonte pas :
   - Vérifier les logs OpenVPN : **Status > System Logs > OpenVPN**
   - Vérifier que pfSense Datacenter est accessible et que le service OpenVPN serveur est actif
5. En dernier recours, redémarrer le service OpenVPN :
   - **Status > OpenVPN** → bouton **Restart**

**Vérification après reprise :**

```bash
ssh bastion
ping 192.168.200.10   # outils.local
ping 192.168.130.10   # monitoring.local
```
---

### 3.7 Perte de configuration pfSense

**Symptômes :** pfSense redémarre avec une configuration par défaut, les règles firewall et la config VPN sont perdues.

**Procédure de reprise :**

1. **Accéder au GUI pfSense** via tunnel SSH
2. Naviguer vers **Diagnostics > Backup & Restore**
3. Dans la section **Restore Backup**, sélectionner le fichier XML de sauvegarde stocké dans KeePass
4. Cliquer sur **Restore Configuration**
5. pfSense va redémarrer automatiquement avec la configuration restaurée
6. Vérifier le VPN Site-to-Site et les règles firewall après le redémarrage

> ⚠️ Les sauvegardes XML pfSense doivent être réalisées régulièrement et après chaque modification de configuration. Elles sont stockées dans KeePass.

---

### 3.8 Restauration depuis snapshot

**Symptômes :** Une VM est dans un état irrécupérable, configuration trop corrompue, services impossibles à redémarrer, système instable.

**Prérequis :** Un snapshot récent et fonctionnel doit exister dans Proxmox.

**Procédure de reprise :**

1. **Accéder à l'interface Proxmox** via l'interface web fourni
2. Sélectionner la VM concernée
3. Eteigner la dite VM
4. Naviguer vers **Snapshots**
5. Identifier le dernier snapshot stable (noter la date)
6. Cliquer sur **Rollback** sur le snapshot choisi
7. Confirmer la restauration, la VM va redémarrer dans l'état du snapshot

**Après restauration :**

```bashX
# Vérifier que la VM est accessible
ssh <vm>

# Vérifier l'état des services
sudo systemctl status <services>

# Vérifier la connectivité réseau
ping 8.8.8.8
ping 192.168.200.10  # test inter-sites
```

> ⚠️ Un rollback snapshot annule toutes les modifications effectuées après la date du snapshot. S'assurer que les données critiques (base PostgreSQL NetBox, données Vault) sont sauvegardées avant tout rollback.

---

## 4. Reconstruction via Ansible

Cette section décrit la procédure complète de reconstruction d'une VM depuis un état minimal (Ubuntu 24.04 Server Minimal fraîchement installé).

### 4.1 Préparation de l'environnement

**Sur le poste administrateur (WSL) :**

```bash
# Démarrer ssh-agent
eval $(ssh-agent -s)
ssh-add ~/.ssh/id_ed25519

# Se positionner dans le projet Ansible
cd ~/ansible-CIA

# Vérifier que l'inventaire est correct
cat inventory/hosts.yml

# Vérifier la connectivité avec toutes les VMs
ansible all -m ping
```

**Sur la VM à reconstruire :**

Avant de lancer les playbooks, s'assurer que :
- La VM est accessible en SSH
- La clé publique SSH est déposée dans `~/.ssh/authorized_keys`
- L'utilisateur a les droits sudo

### 4.2 Rejeu des playbooks

Respecter impérativement l'ordre de déploiement suivant :

```bash
# Étape 1 : Configuration de base (obligatoire en premier)
ansible-playbook playbooks/common.yml --check --diff
ansible-playbook playbooks/common.yml

# Étape 2 : Vault (avant NetBox car NetBox peut en dépendre)
ansible-playbook playbooks/vault.yml --check --diff
ansible-playbook playbooks/vault.yml

# Étape 3 : Elastic
ansible-playbook playbooks/elastic.yml --check --diff
ansible-playbook playbooks/elastic.yml

# Étape 4 : NetBox
ansible-playbook playbooks/netbox.yml --check --diff
ansible-playbook playbooks/netbox.yml
```

> ⚠️ Toujours exécuter le `--check --diff` avant le vrai lancement pour identifier les changements attendus et détecter toute anomalie.

**Pour reconstruire une VM spécifique uniquement :**

```bash
ansible-playbook playbooks/common.yml --limit outils
ansible-playbook playbooks/vault.yml --limit outils
ansible-playbook playbooks/netbox.yml --limit outils
```

### 4.3 Vérifications post-déploiement

Après le rejeu des playbooks, effectuer les vérifications suivantes :

**Vérification Ansible :**

```bash
ansible all -m ping
ansible all -m shell -a "df -h /"
```

**Vérification des services :**

```bash
# Sur outils.local
ssh outils
sudo systemctl status vault vault-unseal netbox netbox-rq nginx postgresql

# Sur monitoring.local
ssh monitoring
sudo systemctl status elasticsearch kibana filebeat

# Sur bastion.local
ssh bastion
sudo systemctl status ssh fail2ban

# Sur intranet.local
ssh intranet
sudo systemctl status nginx fail2ban
```

**Vérification de Vault :**

```bash
ssh -L 8200:localhost:8200 outils
vault status
# Initialized: true
# Sealed: false
```

**Vérification Elasticsearch :**

```bash
ssh -L 9200:localhost:9200 monitoring
curl -u elastic:<mot_de_passe> http://localhost:9200/_cluster/health?pretty
# "status" : "green"
```

**Vérification NetBox :**

```bash
ssh outils
curl -s http://localhost/api/ | python3 -m json.tool | head -5
```

**Vérification connectivité inter-sites :**

```bash
ssh bastion
ping -c 3 192.168.200.10   # outils.local
ping -c 3 192.168.130.10   # monitoring.local
```

---

## 5. Tests de reprise

### 5.1 Procédures de test

Les tests de reprise permettent de valider que les procédures du PRA fonctionnent réellement avant qu'un incident ne survienne. Ils doivent être réalisés régulièrement.

| Test | Fréquence recommandée | Durée estimée |
|---|---|---|
| Redémarrage d'un service et vérification | Mensuelle | 5 min |
| Unseal manuel de Vault | Trimestrielle | 10 min |
| Rejeu d'un playbook Ansible | Avant chaque livraison | 15-30 min |
| Restauration configuration pfSense | Avant chaque livraison | 20 min |
| Simulation disque plein | Trimestrielle | 15 min |

### 5.2 Validation des services

Après chaque test de reprise, valider le bon fonctionnement de l'infrastructure via la checklist suivante :

```
□ ansible all -m ping → 4/4 SUCCESS
□ Vault status → Initialized: true, Sealed: false
□ NetBox accessible via tunnel SSH
□ Kibana accessible via tunnel SSH
□ Elasticsearch cluster health → green
□ Ping inter-sites (bastion → outils, bastion → monitoring)
□ VPN Site-to-Site → Connected
□ Filebeat envoie bien des logs → vérifier dans Kibana
```

### 5.3 Limites du PRA

Ce PRA présente plusieurs limites inhérentes aux contraintes du projet :

**Limite 1 : Dépendance au prestataire**
La création de nouvelles VMs n'est pas possible sans intervention du prestataire. En cas de perte totale d'une VM sans snapshot valide, le délai de reprise dépend entièrement de la réactivité du prestataire pour remettre à zéro la VM.

**Limite 2 : Snapshots non automatisés**
Les snapshots Proxmox sont réalisés manuellement. Il n'existe pas de politique de snapshots automatiques. Un oubli de snapshot avant une intervention risquée peut compromettre la capacité de reprise.

**Limite 3 : Pas de haute disponibilité**
L'infrastructure repose sur des services en instance unique, il n'y a pas de redondance. La panne d'une VM entraîne l'indisponibilité de tous les services qu'elle héberge.

**Limite 4 : Vault en instance unique**
HashiCorp Vault est déployé en mode standalone sans cluster ni réplication. La perte de la VM `outils.local` sans snapshot entraîne la perte définitive des secrets si l'unseal key et le root token ne sont pas sauvegardés dans KeePass.

**Limite 5 : Sauvegarde PostgreSQL non automatisée**
La sauvegarde de la base de données NetBox (`pg_dump`) est manuelle. Les données créées entre la dernière sauvegarde et l'incident seront perdues.

**Améliorations possibles hors périmètre du projet :**
- Automatisation des snapshots Proxmox via l'API
- Mise en place de sauvegardes PostgreSQL automatiques via cron
- Déploiement de Vault en mode cluster pour la haute disponibilité
- Mise en place d'un monitoring des snapshots et des sauvegardes
