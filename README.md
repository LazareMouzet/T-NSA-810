# 🏗️ Infrastructure Hybride Sécurisée Multi-Sites avec Proxmox

[![Proxmox](https://img.shields.io/badge/Proxmox-VE-orange?style=flat-square&logo=proxmox)](https://www.proxmox.com/)
[![pfSense](https://img.shields.io/badge/pfSense-Firewall-blue?style=flat-square)](https://www.pfsense.org/)
[![OpenVPN](https://img.shields.io/badge/OpenVPN-VPN-green?style=flat-square&logo=openvpn)](https://openvpn.net/)
[![NetBox](https://img.shields.io/badge/NetBox-IPAM-purple?style=flat-square)](https://netbox.dev/)
[![Elastic](https://img.shields.io/badge/Elastic-Stack-yellow?style=flat-square&logo=elastic)](https://www.elastic.co/)

> Projet pédagogique de conception et déploiement d'une infrastructure réseau sécurisée, segmentée et observable sur deux sites interconnectés.

---

## 📋 Table des matières

- [Contexte du projet](#contexte-du-projet)
- [Vue d'ensemble](#vue-densemble)
- [Architecture générale](#architecture-générale)
- [Technologies utilisées](#technologies-utilisées)
- [Prérequis](#prérequis)
- [Sécurité & segmentation réseau](#sécurité--segmentation-réseau)
- [Interconnexion inter-sites](#interconnexion-inter-sites)
- [Services transverses](#services-transverses)
- [Résilience & détection de panne](#résilience--détection-de-panne)
- [Structure du projet](#structure-du-projet)
- [Installation et déploiement](#installation-et-déploiement)
- [Roadmap](#roadmap)
- [Limites connues](#limites-connues)
- [Documentation & livrables](#documentation--livrables)
- [Contribution](#contribution)
- [Auteurs](#auteurs)
- [Licence](#license)

---

## 🎯 Contexte du projet
Ce projet vise à concevoir et déployer une **infrastructure hybride sécurisée**, répartie sur **deux sites distincts** :
- **Site 1**: On-premise
- **Site 2**: Remote
, en s’appuyant sur des hyperviseurs **Proxmox** et des services open source.

Le projet est réalisé dans un **cadre pédagogique**, avec des **contraintes fortes de ressources** (nombre limité de VMs), et met l’accent sur :
- la **segmentation réseau**
- la **sécurité périmétrique**
- l’**interconnexion inter-sites**
- l’**observabilité**
- la **documentation et la justification des choix**

L’objectif n’est pas de fournir une haute disponibilité complète, mais une **architecture réaliste, maîtrisée et argumentée**.

Ce dossier contient la **documentation, le planning, les diagrammes, et les éléments de configuration** du projet.

---

## 🔍 Vue d'ensemble

Ce projet déploie une infrastructure hybride sécurisée composée de :

- **2 sites géographiquement séparés** (on-premise & remote)
- **2 hyperviseurs Proxmox** (virtualisation)
- **2 pare-feu pfSense** (sécurité périmétrique)
- **Tunnel VPN site-à-site** (interconnexion sécurisée)
- **DMZ isolées** (exposition contrôlée des services)
- **Stack d'observabilité centralisée** (logs et monitoring)
- **IPAM NetBox** (gestion documentaire)

### Diagramme d'architecture
A REVOIR
```
┌─────────────────────────────────────────────────────────────────────┐
│                         INTERNET                                     │
└────────────┬───────────────────────────────────────┬─────────────────┘
             │                                       │
    ┌────────▼────────┐                    ┌────────▼────────┐
    │  Site On-Prem   │◄──── VPN Tunnel ───►│  Site Remote    │
    │   pfSense FW    │                    │   pfSense FW    │
    └────────┬────────┘                    └────────┬────────┘
             │                                       │
    ┌────────┴────────┐                    ┌────────┴────────┐
    │   DMZ / LAN     │                    │   DMZ / LAN     │
    │  Services       │                    │  Services       │
    │  Proxmox VMs    │                    │  Proxmox VMs    │
    └─────────────────┘                    └─────────────────┘
```

---

## 🏗️ Architecture générale

###  Sites
- **Site on-premise**
  - Hébergement des services centraux
  - Considéré comme le site principal
- **Site remote**
  - Exposition contrôlée à Internet grâce à un bastion
  - Hébergement des services accessibles depuis l’extérieur

###  Virtualisation
- 2 hyperviseurs **Proxmox** (un par site)
- Limite : **3 machines virtuelles maximum par site**

---

## 🛠️ Technologies utilisées

### Infrastructure & Virtualisation
- **Proxmox VE** - Hyperviseur de virtualisation open source
- **pfSense** - Pare-feu et routeur open source

### Sécurité & Réseau
- **OpenVPN** - Solution VPN site-à-site
- **DNS Forwarder** - Résolution de noms interne

### Observabilité & Gestion
- **Elastic Stack** - Centralisation et analyse des logs
  - Elasticsearch
- **NetBox** - IPAM et source de vérité réseau

### Services complémentaires
- **Bastion** - Point d'accès sécurisé SSH/RDP

---

## ✅ Prérequis

### Réseau
- Connexion Internet sur chaque site
- Possibilité de créer des VLANs (recommandé)
- Plages IP disponibles :
    - Plan global : 192.168.0.0/20 (4096 adresses soit 16 LAN disponibles)
    - Site Remote :
        - LAN SERVICES : 192.168.10.0/24
        - LAN USERS : 192.168.20.0/24
        - LAN ADMIN : 192.168.30.0/24
        - LAN BASTION  : 192.168.40.0/24
    - Site On-Premise :
        - LAN SERVICES : 192.168.100.0/24
        - LAN ADMIN    : 192.168.110.0/24
    - Réseau VPN :
        - VPN Site-to-Site : 10.8.0.0/24

---

## 🔒 Sécurité & segmentation réseau

### Pare-feu
- **Un pare-feu par site** (pfSense)
- Chaque pare-feu constitue la **frontière de sécurité** locale
- Rôles principaux :
  - filtrage réseau
  - segmentation WAN / DMZ / LAN
  - terminaison VPN site-à-site

---

A REVOIR
### DMZ
- Chaque site dispose de sa **propre DMZ**
- La DMZ est un **réseau intermédiaire**, situé **derrière le pare-feu**
- Elle héberge uniquement les **services exposés**

#### Contenu de la DMZ


#### Exclusions
- Aucun service interne critique
- Aucun accès direct WAN → LAN

---

### Bastion
- Point d’entrée unique pour les accès externes
- Accès restreint, contrôlé et journalisé
- Permet l’administration sécurisée des services internes

---

## 🌐 Interconnexion inter-sites

### VPN site-à-site
- Technologie : **OpenVPN**
- Tunnel chiffré entre les deux pare-feu
- Permet :
  - la communication sécurisée entre les LANs
  - l’accès aux services internes via des flux maîtrisés

---

## 🔧 Services transverses

### DNS interne (forwarder)
- Service DNS basé sur le **forwarding**
- Assure la résolution de noms :
  - entre les sites
  - pour les services internes
- Service fondation pour le VPN, le bastion et l’observabilité

---

### IPAM / Source de vérité
- Outil : **NetBox**
- Utilisé pour :
  - documenter l’architecture réseau
  - centraliser l’adressage IP
  - préparer l’évolution de l’infrastructure

---

### Observabilité & centralisation des logs
- Stack **Elastic**
- Centralisation des logs :
  - pare-feu
  - bastion
  - services
- Objectifs :
  - visibilité globale
  - diagnostic
  - aide à la détection d’incidents

---

## 🛡️ Résilience & détection de panne
A REVOIR
### Témoin logiciel (witness)
Il peut être ajouté facilement à cette infrastructure 
- Implémenté sous forme de **service léger**
- Hébergé dans une **VM existante**
- Rôle :
  - identifier quel site est indisponible
  - distinguer une panne de site d’une panne de lien inter-sites

> Aucun mécanisme de quorum, de bascule automatique ou de haute disponibilité n’est implémenté.

---

## 📁 Structure du projet
A REVOIR
```
T-NSA-810/
├── README.md                    # Ce fichier
├── docs/                        # Documentation technique
│   ├── architecture/            # Schémas et diagrammes
│   ├── network/                 # Plans d'adressage et flux
│   ├── security/                # Règles de pare-feu et politiques
│   └── procedures/              # Guides d'installation et maintenance
├── configs/                     # Fichiers de configuration
│   ├── pfsense/                 # Configurations pfSense
│   ├── openvpn/                 # Certificats et configs VPN
│   ├── elastic/                 # Configuration Elastic Stack
│   └── netbox/                  # Configuration NetBox
├── scripts/                     # Scripts d'automatisation
│   ├── deployment/              # Scripts de déploiement
│   ├── monitoring/              # Scripts de surveillance
│   └── backup/                  # Scripts de sauvegarde
├── planning/                    # Planning et suivi du projet
│   ├── gantt.md                 # Diagramme de Gantt
│   └── milestones.md            # Jalons du projet
└── presentations/               # Supports de présentation
    └── final-presentation.pdf   # Soutenance finale
```

---

## 🚀 Installation et déploiement
A REVOIR
### Phase 1 : Préparation de l'infrastructure

#### 1.1 Installation des hyperviseurs Proxmox
```bash
# Sur chaque serveur physique
# Télécharger Proxmox VE ISO depuis https://www.proxmox.com/
# Installer Proxmox VE sur les serveurs
# Configurer les interfaces réseau (WAN + LAN)
```

#### 1.2 Création des VMs pare-feu (pfSense)
- Créer une VM par site avec 2 interfaces réseau
- Installer pfSense depuis l'ISO officiel
- Configuration minimale : 2 vCPU, 2 GB RAM, 20 GB disque

### Phase 2 : Configuration de la sécurité

#### 2.1 Configuration des pare-feu
```bash
# Accéder à l'interface web de pfSense
# https://<IP_LAN_PFSENSE>:443

# Configuration de base :
# - Interface WAN (DHCP ou IP fixe)
# - Interface LAN (ex: 10.1.1.1/24)
# - Interface DMZ (ex: 10.1.10.1/24)
```

#### 2.2 Création des VLANs et règles de filtrage
- Créer les VLANs pour LAN, DMZ
- Définir les règles de pare-feu (voir `docs/security/firewall-rules.md`)
- Activer les logs de connexion

### Phase 3 : VPN site-à-site

#### 3.1 Configuration OpenVPN sur Site 1 (serveur)
```bash
# Dans pfSense > VPN > OpenVPN > Servers
# Mode : Peer to Peer (SSL/TLS)
# Protocol : UDP sur port 1194
# Tunnel Network : 10.8.0.0/24
# Local Network : 192.168.1.0/24
# Remote Network : 192.168.2.0/24
```

#### 3.2 Configuration OpenVPN sur Site 2 (client)
```bash
# Dans pfSense > VPN > OpenVPN > Clients
# Importer les certificats générés sur Site 1
# Configurer les routes vers le réseau distant
```

### Phase 4 : Déploiement des services

#### 4.1 Bastion (DMZ)
- Déployer une VM Debian/Ubuntu en DMZ
- Installer et configurer SSH avec authentification par clé
- Configurer fail2ban pour la protection

#### 4.2 DNS Forwarder
- Activer le DNS Forwarder sur pfSense
- Configurer les entrées DNS internes
- Tester la résolution entre les sites

#### 4.3 Elastic Stack (observabilité)
```bash
# Déployer une VM pour Elastic Stack
# Installation via Docker Compose recommandée
docker-compose up -d elasticsearch kibana logstash
```

#### 4.4 NetBox (IPAM)
```bash
# Déployer NetBox via Docker
git clone https://github.com/netbox-community/netbox-docker.git
cd netbox-docker
docker-compose up -d
```

### Phase 5 : Configuration de l'observabilité

#### 5.1 Agents de collecte de logs
- Installer Filebeat sur les pare-feu
- Configurer l'envoi des logs vers Logstash
- Créer les dashboards Kibana

#### 5.2 Témoin logiciel (Witness)
```bash
# Script Python léger pour la détection de pannes
# Déploiement sur une VM existante
python3 witness-monitor.py --config witness.conf
```

### Phase 6 : Tests et validation
- Tester la connectivité inter-sites via VPN
- Vérifier l'isolation des DMZ
- Valider l'accès via le bastion
- Tester la remontée des logs dans Kibana
- Simuler une panne de site

---

## 🗓️ Roadmap

### ✅ Phase actuelle (MVP)
- [x] Architecture réseau segmentée (WAN/DMZ/LAN)
- [x] Pare-feu pfSense sur chaque site
- [x] VPN site-à-site OpenVPN
- [x] Bastion en DMZ
- [x] DNS Forwarder
- [x] Elastic Stack pour les logs
- [x] NetBox pour l'IPAM
- [x] Témoin logiciel

### 🔄 Évolutions futures
A REVOIR
Malgré les contraintes actuelles, l'architecture anticipe :
- [ ] Ajout de nouveaux sites (Site 3, Site 4...)
- [ ] Duplication de services critiques
- [ ] Extension du plan d'adressage IP
- [ ] Implémentation de mécanismes de haute disponibilité :
  - [ ] Cluster pfSense avec CARP
  - [ ] Cluster Proxmox
  - [ ] Réplication des services
- [ ] Intégration d'un système d'alertes (Prometheus + Grafana)
- [ ] Automatisation complète avec Ansible/Terraform

---

A REVOIR
## ⚠️ Limites connues
- Pas de haute disponibilité automatique
- Ressources limitées (nombre de VMs)
- Pare-feu non redondés
- Résilience basée sur la détection et le diagnostic humain

Ces limites sont **assumées et documentées**.

---

## 📚 Documentation & livrables

### Documentation technique
- 📊 Schémas d'infrastructure (diagrammes réseau)
- 🗓️ Planning prévisionnel (diagramme de Gantt)
- 🌐 Description détaillée des flux réseau
- 🔒 Règles de pare-feu et politiques de sécurité
- 📖 Procédures d'accès et de diagnostic
- 🔧 Guides d'installation et de maintenance

### Livrables finaux
- 📄 Rapport technique complet
- 🎤 Support de soutenance
- 💾 Fichiers de configuration (anonymisés)

---

## 🤝 Contribution

Ce projet est réalisé dans un cadre pédagogique. Les contributions sont limitées aux membres de l'équipe projet.

### Pour l'équipe

#### Guidelines de contribution
1. Créer une branche pour chaque fonctionnalité : `git checkout -b feature/nom-fonctionnalite`
2. Commiter régulièrement avec des messages explicites
3. Documenter toute modification d'architecture
4. Tester avant de merger dans `main`

#### Workflow Git
```bash
# Cloner le repository
git clone <repository-url>
cd T-NSA-810

# Créer une branche
git checkout -b feature/ma-fonctionnalite

# Faire vos modifications
git add .
git commit -m "Description claire de la modification"

# Pousser la branche
git push origin feature/ma-fonctionnalite

# Créer une Pull Request pour review
```

---

## 👥 Auteurs

**Équipe T-NSA-810**
- Étudiant(s) en Master/Ingénierie Systèmes et Réseaux
- Établissement : Epitech
- Promotion : 2025-2027
- Encadrant : Mathis Onillon

---

## 📞 Contact & Support

---

## 📄 License

Ce projet est réalisé dans un cadre pédagogique et n'est pas destiné à une utilisation en production.

**Usage académique uniquement** - Les configurations et documentations sont fournies à titre d'exemple éducatif.

---

## 🎯 Objectifs pédagogiques

Ce projet démontre la maîtrise de :
- ✅ **Architecture réseau sécurisée** - Conception d'une infrastructure multi-sites
- ✅ **Segmentation réseau** - Isolation DMZ/LAN et gestion des flux
- ✅ **Sécurité périmétrique** - Configuration avancée de pare-feu
- ✅ **VPN inter-sites** - Mise en place de tunnels sécurisés
- ✅ **Observabilité** - Centralisation et analyse des logs
- ✅ **Documentation technique** - Approche professionnelle et structurée
- ✅ **Gestion de contraintes** - Optimisation des ressources limitées
- ✅ **Choix techniques justifiés** - Argumentation des décisions d'architecture