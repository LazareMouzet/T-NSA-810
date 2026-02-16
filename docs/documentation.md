# Documentation du Projet Cloud & Cybersécurité

## Sommaire

1. [Introduction et contexte du projet](#1-introduction-et-contexte-du-projet)
2. [Architecture Globale](#2-architecture-globale)
3. [Justification des choix technologiques](#3-justification-des-choix-technologiques)
4. [Architecture réseau détaillée](#4-architecture-réseau-détaillée)
5. [Sécurité et contrôle d'accès](#5-sécurité-et-contrôle-daccès)
6. [Supervisions, logs et traçabilité](#6-supervisions-logs-et-traçabilité)
7. [Déploiement et exploitation](#7-déploiement-et-exploitation)
8. [Tests validation et scénario](#8-tests-validation-et-scénario)
9. [Conclusion](#9-conclusion)

---

## 1. Introduction et contexte du projet

### 1.1 Contexte client

Dans le cadre du projet de spécialité Cloud & Cybersécurité, il est demandé de concevoir et déployer une infrastructure sécurisée répartie sur deux sites distincts : un site **on-premise** et un site **distant (remote)**.

### 1.2 Objectifs globaux du projet

Les objectifs demandés sont les suivants :

* Déployer une infrastructure hybride.
* Mettre en place une interconnexion sécurisée site-to-site via un VPN.
* Ajouter des firewalls pour chaque site, avec une capacité de *killSwitch*.
* Mettre un place un hôte **bastion** pour un accès externe au site distant.
* Automatiser le management des IP via IPAM et conserver l’IPAM à jour.
* Centraliser les logs et implémenter une solution d'observabilité (Elastic / ElasticSearch).
* Publier un site web accessible seulement depuis un réseau interne.
* Établir une base architecturale permettant l'intégration ultérieure de sites supplémentaires.

### 1.3 Contraintes imposées

Le projet s’inscrit dans un contexte contraint, notamment par :

* Une limitation du nombre de machines virtuelles par site.
* Des exigences fortes en matière de sécurité et de traçabilité des flux.
* L’utilisation de technologies supportées, maintenues et mises à jour par la communauté.

### 1.4 Livrables

Pour atteindre ces objectifs, nous rendrons les livrables suivants :

* Une documentation technique.
* Un code sous contrôle de source.
* Un stockage sécurisé des identifiants.
* Un diagramme d’infrastructure.
* Une documentation relative à la reprise après sinistre.

### 1.5 Rôle de la documentation

Cette documentation a pour objectif de décrire l’architecture retenue, de justifier les choix technologiques effectués et de présenter les mécanismes de sécurité mis en place afin de répondre aux besoins exprimés.

---

## 2. Architecture Globale

### 2.1 Présentation des deux sites

#### 2.1.1 Site on-premise

Le site on-premise représente le datacenter interne de l’entreprise. Il constitue l’environnement principal de contrôle et d’administration de l’infrastructure.

Il héberge les composants d’infrastructure nécessaires à la gestion du réseau, à la sécurité et à l’interconnexion avec le site distant. Les accès administrateurs y sont centralisés et strictement contrôlés. Ce site n’est pas destiné à exposer des services métiers directement à internet, mais à assurer un rôle de socle et de supervision.

#### 2.1.2 Site distant (remote)

Le site distant représente un environnement de Cloud externe, séparé du datacenter on-premise. Il héberge les services applicatifs et métiers de l’infrastructure.

Ce site est conçu selon des principes de sécurité renforcés, notamment via une segmentation réseau stricte et l’utilisation d’un bastion d’administration. Les accès aux services sont réalisés de manière indirecte, à travers des flux contrôlés. L’interconnexion entre le site on-premise et le site distant est assurée par un VPN site-to-site sécurisé.

### 2.2 Principe de segmentation réseau

### 2.3 Rôle du VPN site-to-site

---

## 3. Justification des choix technologiques

### 3.1 Proxmox

Proxmox VE est une plateforme de virtualisation open-source basée sur KVM et LXC, largement utilisée en environnement professionnel.

* **Justification :**
* Permet de déployer et gérer plusieurs VM sur une même infrastructure physique.
* Supporte la haute disponibilité, la sauvegarde et la restauration.
* Interface web simple pour la gestion centralisée.
* Intégration native avec des réseaux complexes (VLAN, bridges).
* Compatible avec une approche Infrastructure as a Service (IaaS).

* **Valeur apportée au projet :**
Proxmox permet de simuler une infrastructure d’entreprise réaliste, tout en respectant la contrainte de ressources (3 VM max par site), et sert de socle à l’ensemble de l’architecture Cloud privée.

### 3.2 pfSense

pfSense est une solution de pare-feu open-source reconnue, utilisée en production dans de nombreuses entreprises.

* **Justification :**
* Pare-feu stateful avec filtrage fin des flux.
* Support natif du routage inter-réseaux.
* Gestion avancée des VPN, NAT et règles de sécurité.
* Interface claire facilitant l’audit et la traçabilité.
* Approche *deny-by-default* conforme aux bonnes pratiques sécurité.

* **Valeur apportée au projet :**
pfSense joue un rôle central dans la segmentation réseau, le contrôle des flux inter-sites et la protection des ressources critiques, garantissant un haut niveau de sécurité.

### 3.3 OpenVPN

OpenVPN est une solution VPN éprouvée, robuste et largement adoptée.

* **Justification :**
* Chiffrement fort (TLS, certificats).
* Support du VPN site-to-site.
* Intégration native avec pfSense.
* Authentification par certificats, limitant les risques d’intrusion.
* Surveillance et logs des connexions.

* **Valeur apportée au projet :**
OpenVPN permet d’établir un canal sécurisé entre le site on-premise et le site remote, assurant la confidentialité et l’intégrité des échanges, tout en considérant le VPN comme un réseau non fiable filtré par le firewall.

### 3.4 NetBox (IPAM)

NetBox est un outil open-source de référence pour la gestion de l’adressage IP et de l’infrastructure réseau.

* **Justification :**
* Centralisation de l’IP Address Management (IPAM).
* Documentation des réseaux, sous-réseaux et équipements.
* Réduction des erreurs de configuration.
* Vision claire de l’architecture réseau.
* Facilite la maintenance et l’évolution de l’infrastructure.

* **Valeur apportée au projet :**
NetBox apporte une traçabilité et une documentation structurée du réseau, indispensable dans un contexte multi-sites et orienté sécurité.

### 3.5 Elasticsearch

ElasticSearch est une solution de collecte et d’analyse de logs utilisée à grande échelle dans les environnements Cloud et sécurité.

* **Justification :**
* Centralisation des logs système, réseau et sécurité.
* Recherche rapide et corrélation d’événements.
* Détection d’anomalies et d’incidents.
* Amélioration de la visibilité sur l’infrastructure.
* Support des audits et investigations post-incident.

* **Valeur apportée au projet :**
ElasticSearch permet une surveillance centralisée, essentielle pour détecter des comportements suspects, analyser les incidents de sécurité et démontrer une approche proactive de la cybersécurité.

### 3.6 Terraform

Terraform est un outil d’Infrastructure as Code (IaC) permettant de définir, déployer et maintenir une infrastructure de manière déclarative et reproductible.

* **Justification :**
* Permet de décrire l’infrastructure sous forme de code, facilitant sa compréhension et sa maintenance.
* Garantit la reproductibilité des environnements on-premise et remote.
* Réduit les erreurs humaines liées aux configurations manuelles.
* Facilite la gestion des évolutions de l’infrastructure (ajout, modification, suppression de ressources).
* S’intègre dans une démarche DevOps / Cloud moderne, proche des standards industriels.
* Permet un versionning de l’infrastructure via un système de contrôle de versions (Git).

* **Valeur apportée au projet :**
Terraform apporte une approche structurée, automatisée et documentée du déploiement de l’infrastructure. Il renforce la cohérence entre les environnements, améliore la traçabilité des changements et prépare l’architecture à une évolution future vers des pratiques DevOps et Cloud à plus grande échelle.

---

## 4. Architecture réseau détaillée

### 4.1 Description des réseaux

### 4.2 Plan d’adressage

#### 4.2.1 Objectifs du plan d’adressage

Le plan d’adressage a pour objectif de structurer les réseaux de l’infrastructure de manière claire et cohérente, tout en garantissant la séparation des rôles, la sécurité des flux et l’évolutivité de l’architecture. Chaque sous-réseau est associé à une fonction précise afin de limiter les interactions non nécessaires entre les différents composants.

#### 4.2.2 Plage d’adressage globale

L’infrastructure repose sur une plage d’adresses privées `192.168.0.0/20`, offrant une capacité suffisante pour le découpage en sous-réseaux distincts tout en conservant une marge d’évolution. Cette plage permet un découpage homogène en sous-réseaux de type `/24`, facilitant la lisibilité et l’exploitation de l’architecture.

#### 4.2.3 Plan d’adressage - Site distant (Remote / Cloud)

Le site distant représente l’environnement Cloud hébergeant les services applicatifs et les composants exposés. Il est segmenté en plusieurs réseaux afin de séparer les usages et renforcer la sécurité.

* **LAN SERVICES – 192.168.10.0/24**
Réseau dédié à l’hébergement des services métiers et applicatifs.
* **LAN USERS – 192.168.20.0/24**
Réseau destiné aux accès utilisateurs aux services, distinct des flux d’administration.
* **LAN ADMIN – 192.168.30.0/24**
Réseau d’administration du site distant. Il héberge notamment le bastion, point d’entrée unique pour les opérations d’administration des services.

Cette segmentation permet d’isoler les accès utilisateurs, les flux d’administration et les services applicatifs, conformément aux principes de sécurité.

#### 4.2.4 Plan d’adressage – Site on-premise

Le site on-premise représente le datacenter interne de l’entreprise. Il constitue le point central de contrôle et d’administration de l’infrastructure.

* **LAN SERVICES – 192.168.100.0/24**
Réseau hébergeant les services internes nécessaires au fonctionnement de l’infrastructure.
* **LAN ADMIN – 192.168.110.0/24**
Réseau d’administration interne, utilisé par les administrateurs pour accéder aux équipements et au site distant via le VPN.

#### 4.2.5 Réseau d’interconnexion VPN

* **VPN Site-to-Site – 10.8.0.0/24**
Un réseau dédié est utilisé pour l’interconnexion VPN entre le site on-premise et le site distant. L’utilisation d’une plage distincte permet d’éviter tout conflit d’adressage avec les réseaux internes et de faciliter le routage et le filtrage des flux.

#### 4.2.6 Principes de conception

Le plan d’adressage respecte les principes suivants :

* Un réseau = un rôle fonctionnel.
* Séparation stricte entre administration, utilisateurs et services.
* Utilisation de plages privées non routables sur Internet.
* Découpage homogène en `/24` pour simplifier l’exploitation et la maintenance.
* Possibilité d’évolution sans remise en cause de l’architecture existante.

---

## 5. Sécurité et contrôle d’accès

## 6. Supervisions, logs et traçabilité

## 7. Déploiement et exploitation

## 8. Tests validation et scénario

## 9. Conclusion
