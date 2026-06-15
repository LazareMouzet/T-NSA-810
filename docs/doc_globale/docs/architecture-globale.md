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

La segmentation réseau consiste à découper un réseau en plusieurs sous-réseaux isolés afin de séparer les environnements et de contrôler les communications entre eux.

Dans le cadre du projet, l’infrastructure a été segmentée en plusieurs sous-réseaux, chacun associé à un rôle ou à un ensemble de services (intranet, monitoring, outils, bastion, etc.), à l’exception du réseau du firewall PfSense.

Cette segmentation permet d’isoler les machines virtuelles dans des environnements dédiés et de contrôler strictement les communications inter-VMs via des règles réseau.

Elle contribue également à une meilleure organisation de l’infrastructure en regroupant les machines par fonction ou par service.

Enfin, cette approche permet de limiter les interactions non nécessaires entre les composants du système.

La segmentation réseau apporte plusieurs bénéfices majeurs :

- **Réduction de la surface d’attaque** : une compromission est contenue dans un sous-réseau isolé et n’impacte pas directement l’ensemble de l’infrastructure.
- **Limitation de la propagation latérale** : un attaquant ne peut pas se déplacer librement entre les différents segments réseau.
- **Contrôle des flux** : les communications entre les sous-réseaux sont explicitement autorisées ou bloquées via des règles de filtrage.
- **Meilleure organisation de l’infrastructure** : séparation claire des rôles (administration, supervision, services utilisateurs, outils internes).

## Rôle du VPN site-to-site (S2S)

Le VPN Site-to-Site est un tunnel réseau sécurisé permettant d’interconnecter deux réseaux distants comme s’ils faisaient partie d’un même environnement privé.

Dans notre architecture, il assure la communication entre le site on-premise et le site distant (Cloud) à travers Internet, tout en garantissant la confidentialité et l’intégrité des échanges grâce à un chiffrement des flux.

Concrètement, ce tunnel VPN permet :

- de faire transiter les communications entre les deux sites de manière sécurisée,
- d’éviter toute exposition directe des réseaux internes sur Internet,
- et d’assurer une interconnexion transparente pour les services distribués.

Grâce à ce mécanisme, les machines présentes sur le site on-premise peuvent communiquer avec les services hébergés sur le site distant (et inversement) sans configuration complexe côté applicatif.


### Intérêt dans l'architecture

L’utilisation d’un VPN Site-to-Site (S2S) présente plusieurs avantages :

- Sécurité : les données sont chiffrées pendant leur transit sur Internet
- Isolation : les réseaux internes ne sont pas exposés publiquement
- Transparence : les services communiquent comme s’ils étaient sur le même réseau local
- Centralisation : permet de relier plusieurs environnements (Cloud / On-premise)


## Schéma global (HLD)
