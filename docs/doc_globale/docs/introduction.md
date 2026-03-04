# Introduction et contexte du projet

## Contexte client

Dans le cadre du projet de spécialité Cloud & Cybersécurité, il est
demandé de concevoir et déployer une infrastructure sécurisée répartie
sur deux sites distincts: un site on-premise et un site distant
(remote).

## Cas d'usage et périmètre fonctionnelle

### Contexte général

L'infrastructure que nous concevons a pour objectif de créer un
environnement sécurisé, bien structuré et facile à administrer pour un
système d'information hybride.Celui-ci est réparti entre

-   un site on-premise, représentant un datacenter interne hébergeant
    les services cœur,
-   un site remote, représentant un environnement cloud servant de point
    d'accès distant et de zone d'extension.

Cette infrastructure est pensée pour être gérée par un petit nombre
d'administrateurs, dans un cadre où les exigences en matière de
sécurité, de traçabilité et de cloisonnement réseau sont
particulièrement élevées.

### Objectifs fonctionnels

L'infrastructure doit permettre :

-   la gestion centralisée du réseau (adressage IP, inventaire,
    topologie),
-   la gestion sécurisée des secrets (identifiants, tokens, clés),
-   la collecte et la visualisation des journaux de l'infrastructure,
-   l'administration distante sécurisée des ressources,
-   la séparation stricte des rôles et des flux entre les services.

### Répartition des rôles entre les sites

Site On-premise (Datacenter)

Le site on-premise héberge les services cœur, considérés comme sensibles
mais non exposables :

-   NetBox : gestion des adresses IP et de l'inventaire réseau
-   Vault : stockage et distribution sécurisée des secrets
-   Elastic : centralisation et visualisation des logs

-   DNS Forwarder : résolution des noms internes (services, hôtes ...)

Ces services ne sont jamais exposés directement : ils sont accessibles
uniquement via des mécanismes d'accès contrôlés et isolés dans des LAN
dédiés. Le site on-premise sert ainsi de source de vérité pour
l'ensemble de l'infrastructure.

Site Remote (Cloud)

Le site remote représente un environnement cloud, qui agit comme une
zone d'accès sécurisé pour les administrateurs distants et comme une
zone tampon entre Internet et le cœur du système d'information.

Il héberge notamment :

-   Un Bastion d'administration

-   Les composants nécessaires à l'accès VPN et à la gestion des flux
    inter-sites

-   Staging / Zone de détonation (manipuler du contenu non fiable doit
    être sacrifiable)

Contrairement au site on-premise, il ne contient aucune donnée critique
métier, ce qui limite les risques en cas de compromission.

### Accès et administration

Les administrateurs peuvent accéder à l'infrastructure selon deux modes
contrôlés

Accès via bastion :

-   accès administratif centralisé

-   traçabilité des connexions

-   segmentation stricte des droits

Accès via VPN (Point-to-Site ou Site-to-Site)

-   flux restreints par usage

-   accès limité à des services précis (ex : consultation Elastic)

-   filtrage assuré par les firewalls

### Communications inter-sites

Les deux sites sont interconnectés par un VPN Site-to-Site chiffré, qui
assure la confidentialité des échanges. Les flux inter-sites sont
explicitement définis et strictement limités, avec un filtrage
systématique par firewall pour empêcher tout trafic non autorisé.

### Principes de sécurité structurants

L'architecture s'appuie sur plusieurs principes de sécurité
fondamentaux. Elle adopte une approche Zero Trust pour le réseau, où
aucun flux n'est implicite et où chaque connexion doit être vérifiée. Le
cloisonnement est assuré par LAN et par service, limitant les
interactions au strict nécessaire. Le principe du moindre privilège
guide l'attribution des droits, tandis que les services sensibles ne
sont jamais exposés directement. De plus, il n'y a pas de dépendance
inutile entre les sites, ce qui maintient l'indépendance opérationnelle.
Enfin, l'observabilité est intégrée sans impact sur le fonctionnement,
permettant une surveillance proactive sans compromettre les
performances.

### Résilience et impact

L'indisponibilité du site remote n'interrompt pas les services coeurs.
Cela empêche uniquement l'accès distant de manière temporaire. De plus,
l'indisponibilité d'un service de supervision tel que Elastic, n'empêche
pas le fonctionnement du SI. En revanche, il réduit la visibilité
opérationnelle.

## Objectifs globaux du projet

Les objectifs demandés sont les suivantes :

-   Déployé une infrastructure hybride

-   Mettre en place une interconnection sécurisés site-to-site via un
    VPN

-   Ajouter des firewalls pour chaque site, avec une capacité de
    killSwitch

-   Mettre un place un host bastion pour un accès externe au site
    distant

-   Automatiser le management des IP via IPAM et conserver l'IPAM à jour

-   Centraliser les logs et implémentation un observable (Elastic /
    ElasticSearch)

-   Publier un site web accessible seulement depuis un réseau interne

-   Établir une base architecturale permettant l\'intégration ultérieure
    de sites supplémentaires.

## Contraintes imposés

Le projet s'inscrit dans un contexte contraint, notamment par une
limitation du nombre de machines virtuelles par site, des exigences
fortes en matière de sécurité et de traçabilité des flux ainsi que
l'utilisation de technologie supportée, maintenue et mise à jour par la
communauté.

## Livrables

Pour atteindre ces objectifs nous rendrons les livrables suivant :

-   Une documentation technique

-   Un code sous contrôle de source

-   Un stockage sécurisé des identifiants

-   Un diagramme d'infrastructure

-   Une documentation relative à la reprise après sinistre

## Rôle de la documentation

Cette documentation a pour objectif de décrire l'architecture retenue,
de justifier les choix technologiques effectués et de présenter les
mécanismes de sécurité mis en place afin de répondre aux besoins
exprimés.
