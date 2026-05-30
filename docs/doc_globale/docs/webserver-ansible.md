# Déploiement du site web interne (webserver Nginx)

## Présentation

Un site web interne a été déployé sur la VM `intranet` à l’aide d’Ansible et de Nginx.

Le site est volontairement accessible uniquement depuis le réseau interne via le bastion et la configuration de routage/VLAN mise en place.

La résolution DNS interne du domaine `.local` permet d’accéder au service via le nom :

```text
intranet.local
```

---

# Architecture de l’infrastructure

## Topologie réseau

```text
Poste utilisateur
        ↓
VPN / Accès interne
        ↓
Bastion (VLAN 20)
192.168.20.X
        ↓
Routage pfSense
192.168.20.1 ↔ 192.168.30.1
        ↓
VM Intranet (VLAN 30)
192.168.30.10
```

---

# Restrictions de sécurité

Le site web n’est pas exposé publiquement.

Les restrictions d’accès sont assurées par :

- la segmentation VLAN
- les règles firewall pfSense
- l’accès SSH via le bastion
- l’absence d’exposition HTTP directe sur le WAN

Seules les machines internes autorisées peuvent accéder au serveur web.

---

# Configuration du serveur web

## Serveur web

- Nginx
- Port : `80/TCP`

## Webroot

```text
/var/www/site_remote
```

## DNS interne

Le site est accessible via le domaine interne :

```text
intranet.local
```

Résolution DNS :

```text
intranet.local → 192.168.30.10
```

## Contenu du site

Le contenu statique du site est déployé automatiquement via Ansible.

---

# Déploiement Ansible

## Fonctionnalités mises en place

- installation de Nginx
- démarrage automatique du service
- activation du service au boot
- création automatique du webroot
- déploiement automatique du site web
- configuration du virtual host Nginx
- intégration DNS interne
- accessibilité uniquement depuis le réseau interne
- déploiement idempotent

---

# Accès au site web

L’accès HTTP direct depuis des réseaux externes est volontairement bloqué.

Le site peut être consulté de manière sécurisée grâce à un tunnel SSH via le bastion.

---

# Accès via tunnel SSH

## Commande

Depuis le poste utilisateur ou l’environnement WSL :

```bash
ssh -L 8080:intranet.local:80 bastion
```

---

## Accès navigateur

Une fois le tunnel SSH établi, ouvrir dans un navigateur :

```text
http://localhost:8080/
```

---

# Validation du fonctionnement

## Vérifier l’état de Nginx

```bash
systemctl status nginx
```

---

## Vérifier la configuration Nginx

```bash
sudo nginx -t
```

---

## Tester le site localement depuis la VM

```bash
curl localhost
```

---

## Tester le site depuis le bastion

```bash
curl http://intranet.local
```

---

# Règles de sécurité appliquées

## Isolation réseau

- le VLAN INTRANET ne peut pas accéder au VLAN BASTION
- le réseau OUTILS ne peut pas accéder au réseau INTRANET
- le réseau MONITORING ne peut pas accéder au réseau INTRANET
- les flux sont limités selon le principe du moindre privilège

## Administration sécurisée

- accès SSH imposé via le bastion
- ports SSH personnalisés
- accès WAN direct interdit

## Publication du site

Le site web est uniquement accessible :
- depuis le bastion
- via tunnel SSH
- depuis les réseaux internes autorisés

Le service n’est pas exposé publiquement.

---

# Notes

- L’accès HTTP externe est volontairement refusé
- Le site est accessible uniquement via les chemins réseau internes autorisés
- Le bastion est obligatoire pour l’administration et l’accès web
- Le déploiement du site est géré via des rôles et playbooks Ansible
- La résolution DNS `.local` est opérationnelle entre les deux sites

---

# Améliorations futures possibles

- mise en place du HTTPS/TLS
- ajout d’une couche d’authentification


## Validation de l’accès web

Le bon fonctionnement du site a été validé :

- via navigateur grâce à un tunnel SSH sécurisé
- via la commande `curl` depuis la VM et le bastion

Les tests ont confirmé :
- la disponibilité du service Nginx
- la résolution DNS interne
- l’accessibilité uniquement depuis le réseau autorisé

L’accès au site n’est pas filtré au niveau applicatif Nginx mais directement au niveau réseau via la segmentation VLAN et les règles firewall pfSense. Cette approche limite l’exposition du service avant même d’atteindre le serveur web.


## Validation et tests du déploiement

Plusieurs tests ont été réalisés afin de valider le bon fonctionnement du site web interne et la qualité du déploiement via Ansible.

---

### Test d’idempotence Ansible

Le playbook de déploiement a été exécuté plusieurs fois afin de vérifier son comportement idempotent.

```bash
ansible-playbook playbooks/webserver.yml
```

Résultat :
- aucune modification inattendue lors des exécutions successives
- seules les actions nécessaires sont exécutées
- confirmation de la stabilité de la configuration

---

### Vérification des fichiers déployés

La présence et la bonne configuration des fichiers du site ont été vérifiées sur la VM intranet.

```bash
ls -l /var/www/site_remote
```

Résultat :

- le fichier `index.html` est présent
- le dossier `css/` est correctement déployé
- les permissions sont conformes (`www-data:www-data`)
- les droits sont standards (644 pour les fichiers, 755 pour les dossiers)

---

### Test de disponibilité HTTP

L’accessibilité du site via le réseau interne a été validée depuis le bastion.

```bash
curl -I http://intranet.local
```

Résultat attendu :

```text
HTTP/1.1 200 OK
```

Ce test confirme :
- la résolution DNS interne fonctionnelle
- la bonne configuration du serveur Nginx
- l’accès HTTP autorisé uniquement depuis le réseau interne

---

### Conclusion des tests

L’ensemble des tests confirme que :

- le déploiement Ansible est idempotent et reproductible
- le site web est correctement déployé sur la VM
- l’accès au service est fonctionnel uniquement depuis le réseau interne
- la configuration Nginx est stable et opérationnelle