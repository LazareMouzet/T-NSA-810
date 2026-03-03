# Architecture Globale

## Présentation des deux sites

### Site on-premise

Le site on premise représente le datacenter interne de l'entreprise. Il
constitue l'environnement principal de contrôle et d'administration de
l'infrastructure.

Il héberge les composants d'infrastructure nécessaires à la gestion du
réseau, à la sécurité et à l'interconnexion avec le site distant. Les
accès administrateurs y sont centralisés et strictement contrôlés.

Ce site n'est pas destiné à exposer des services métiers directement à
internet, mais à assurer un rôle de socle et de supervision.

### Site distant (remote)

Le site distant représente un environnement de Cloud externe, séparé du
datacenter on-premise. Il héberge les services applicatifs et métiers de
l'infrastructure.

Ce site est conçu selon des principes de sécurité renforcés, notamment
via une segmentation réseau stricte et l'utilisation d'un bastion
d'administration. Les accès aux services sont réalisés de manière
indirecte, à travers des flux contrôlés.

L'interconnexion entre le site on-premise et le site distant est assurée
par un VPN site-to-site sécurisé.

## Principe de segmentation réseau

## Rôle du VPN site-to-site

## Schéma global
