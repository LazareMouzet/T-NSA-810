# Justification des choix technologiques

## Proxmox 

Proxmox VE est une plateforme de virtualisation open-source basée sur
KVM et LXC, largement utilisée en environnement professionnel.

Justification

-   Permet de déployer et gérer plusieurs VM sur une même infrastructure
    physique

-   Supporte la haute disponibilité, la sauvegarde et la restauration

-   Interface web simple pour la gestion centralisée

-   Intégration native avec des réseaux complexes (VLAN, bridges)

-   Compatible avec une approche Infrastructure as a Service (IaaS)

Valeur apportée au projet

Proxmox permet de simuler une infrastructure d'entreprise réaliste, tout
en respectant la contrainte de ressources (3 VM max par site), et sert
de socle à l'ensemble de l'architecture Cloud privée.

## PfSense 

pfSense est une solution de pare-feu open-source reconnue, utilisée en
production dans de nombreuses entreprises.

Justification

-   Pare-feu stateful avec filtrage fin des flux

-   Support natif du routage inter-réseaux

-   Gestion avancée des VPN, NAT et règles de sécurité

-   Interface claire facilitant l'audit et la traçabilité

-   Approche deny-by-default conforme aux bonnes pratiques sécurité

Valeur apportée au projet

pfSense joue un rôle central dans la segmentation réseau, le contrôle
des flux inter-sites et la protection des ressources critiques,
garantissant un haut niveau de sécurité.

## OpenVPN 

OpenVPN est une solution VPN éprouvée, robuste et largement adoptée.

Justification

-   Chiffrement fort (TLS, certificats)

-   Support du VPN site-to-site

-   Intégration native avec pfSense

-   Authentification par certificats, limitant les risques d'intrusion

-   Surveillance et logs des connexions

Valeur apportée au projet

OpenVPN permet d'établir un canal sécurisé entre le site on-premise et
le site remote, assurant la confidentialité et l'intégrité des échanges,
tout en considérant le VPN comme un réseau non fiable filtré par le
firewall.

## NetBox (IPAM)

NetBox est un outil open-source de référence pour la gestion de
l'adressage IP et de l'infrastructure réseau.

Justification

-   Centralisation de l'IP Address Management (IPAM)

-   Documentation des réseaux, sous-réseaux et équipements

-   Réduction des erreurs de configuration

-   Vision claire de l'architecture réseau

-   Facilite la maintenance et l'évolution de l'infrastructure

Valeur apportée au projet

NetBox apporte une traçabilité et une documentation structurée du
réseau, indispensable dans un contexte multi-sites et orienté sécurité.

## Elasticsearch 

ElasticSearch est une solution de collecte et d'analyse de logs utilisée
à grande échelle dans les environnements Cloud et sécurité.

Justification

-   Centralisation des logs système, réseau et sécurité

-   Recherche rapide et corrélation d'événements

-   Détection d'anomalies et d'incidents

-   Amélioration de la visibilité sur l'infrastructure

-   Support des audits et investigations post-incident

Valeur apportée au projet

ElasticSearch permet une surveillance centralisée, essentielle pour
détecter des comportements suspects, analyser les incidents de sécurité
et démontrer une approche proactive de la cybersécurité.
