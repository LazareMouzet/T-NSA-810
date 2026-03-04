# Architecture réseau détaillé

## Description et rôle des réseaux 

## Plan d'adressage IP 

### Objectifs du plan d'adressage

Le plan d'adressage a pour objectif de structurer les réseaux de
l'infrastructure de manière claire et cohérente, tout en garantissant la
séparation des rôles, la sécurité des flux et l'évolutivité de
l'architecture. Chaque sous-réseau est associé à une fonction précise
afin de limiter les interactions non nécessaires entre les différents
composants.

### Plage d'adressage globale

L'infrastructure repose sur une plage d'adresses privées 192.168.0.0/20,
offrant une capacité suffisante pour le découpage en sous-réseaux
distincts tout en conservant une marge d'évolution. Cette plage permet
un découpage homogène en sous-réseaux de type /24, facilitant la
lisibilité et l'exploitation de l'architecture.

### Plan d'adressage - Site distant (Remote / Cloud)

Le site distant représente l'environnement Cloud hébergeant les services
applicatifs et les composants exposés. Il est segmenté en plusieurs
réseaux afin de séparer les usages et renforcer la sécurité.

-   LAN SERVICES -- 192.168.10.0/24

Réseau dédié à l'hébergement des services métiers et applicatifs.

-   LAN USERS -- 192.168.20.0/24

Réseau destiné aux accès utilisateurs aux services, distinct des flux
d'administration.

-   LAN ADMIN -- 192.168.30.0/24

> Réseau d'administration du site distant. Il héberge notamment le
> bastion, point d'entrée unique pour les opérations d'administration
> des services.

Cette segmentation permet d'isoler les accès utilisateurs, les flux
d'administration et les services applicatifs, conformément aux principes
de sécurité.

### Plan d'adressage -- Site on-premise

Le site on-premise représente le datacenter interne de l'entreprise. Il
constitue le point central de contrôle et d'administration de
l'infrastructure.

LAN SERVICES -- 192.168.100.0/24

Réseau hébergeant les services internes nécessaires au fonctionnement de
l'infrastructure.

LAN ADMIN -- 192.168.110.0/24

Réseau d'administration interne, utilisé par les administrateurs pour
accéder aux équipements et au site distant via le VPN.

### Réseau d'interconnexion VPN

VPN Site-to-Site -- 10.8.0.0/24

Un réseau dédié est utilisé pour l'interconnexion VPN entre le site
on-premise et le site distant. L'utilisation d'une plage distincte
permet d'éviter tout conflit d'adressage avec les réseaux internes et de
faciliter le routage et le filtrage des flux.

### Principes de conception

Le plan d'adressage respecte les principes suivants :

-   Un réseau = un rôle fonctionnel

-   Séparation stricte entre administration, utilisateurs et services

-   Utilisation de plages privées non routables sur Internet

-   Découpage homogène en /24 pour simplifier l'exploitation et la
    maintenance

-   Possibilité d'évolution sans remise en cause de l'architecture
    existante

### Évolutivité et extensibilité de l'architecture

L'architecture réseau a été conçue avec un objectif d'évolutivité afin
de permettre l'ajout futur de nouveaux composants d'infrastructure sans
remise en cause du plan d'adressage existant.

Le découpage global en plage /20 permet de réserver plusieurs
sous-réseaux supplémentaires non encore attribués, destinés à accueillir
de futurs segments (nouveaux services, zones de sécurité, ou nœuds
d'infrastructure supplémentaires).

Dans cette optique, la conception intègre la possibilité d'ajout d'un
troisième nœud d'infrastructure ou d'un nœud d'arbitrage (witness /
quorum) pour le cluster de virtualisation. Les réseaux d'administration
et d'interconnexion ont été dimensionnés pour supporter ces extensions
sans modification des sous-réseaux actuels.

Cette approche garantit :

-   l'ajout de nouveaux nœuds sans conflit d'adressage

-   la continuité du modèle de segmentation par rôle

-   la compatibilité avec une architecture multi-sites étendue

-   la scalabilité horizontale de l'infrastructure

## Schéma réseau détaillé
