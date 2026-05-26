# Règles firewall et flux autorisés

## Tableau des flux autorisés

| Source          | Destination   | Port / Protocole | Description               |
| --------------- | ------------- | ---------------- | ------------------------- |
| Administrateur  | Bastion       | SSH / 22         | Administration sécurisée  |
| Bastion         | VMs internes  | SSH / 22         | Rebond SSH                |
| VMs             | Elasticsearch | TCP / 9200       | Envoi des logs            |
| Site on-premise | Site distant  | VPN IPsec        | Communication inter-sites |

Les flux réseau ont été restreints au strict nécessaire afin de limiter la surface d’exposition et de renforcer la sécurité globale de l’infrastructure.

## Traduction en règles pfSense (Remote)

Les flux réseau identifiés comme nécessaires au fonctionnement de l’infrastructure ont été traduits en règles de filtrage au sein du firewall PfSense.

Ces règles permettent de contrôler les communications entre les différents sous-réseaux et d’appliquer le principe du moindre privilège en n’autorisant que les flux strictement nécessaires.

### WAN

| Interface      | Source           | Destination     | Port     | Action | Description                           |
| -------------- | ---------------- | --------------- | -------- | ------ | ------------------------------------- |
| WAN | ReservedNot assigned by IANA | * | * | BLOCK | Bloque tous les flux par défaut |
| WAN | * | * | IPv4 UDP | PASS | Autorise l'accès distant au VPN S2S |

### LAN

| Interface      | Source           | Destination     | Port     | Action | Description                           |
| -------------- | ---------------- | --------------- | -------- | ------ | ------------------------------------- |
| LAN | *  | LAN Address | 80 | PASS | Règle Anti-Lockout |
| LAN | LAN Subnets | 192.168.100.0/24 | * | PASS   | Autoriser les connexion LAN vers le Datacenter |
| LAN | BASTION Subnets | This Firewall (self) | * | PASS   | Autoriser l'accès à l'interface GUI du Pfsense remote depuis le Bastion |

### BASTION

| Interface      | Source           | Destination     | Port     | Action | Description                           |
| -------------- | ---------------- | --------------- | -------- | ------ | ------------------------------------- |
| BASTION    | BASTION Subnets  | * | * | PASS   | Autorise les flux d’administration nécessaires depuis le réseau Bastion |

### INTRANET

| Interface      | Source           | Destination     | Port     | Action | Description                           |
| -------------- | ---------------- | --------------- | -------- | ------ | ------------------------------------- |
| INTRANET   | INTRANET Subnets  | BASTION subnets | IPv4*   | BLOCK   | Isolation : l'intranet ne doit pas accéder au bastion |
| INTRANET | 192.168.20.10 | INTRANET Subnets | 223 | PASS   | Autorise les connexions SSH via le port personnalisé 223 afin d’imposer le passage par le bastion |
| INTRANET   | INTRANET Subnets  | WAN | * | PASS   | Autoriser l'intranet à acceder à internet |

### OpenVPN

| Interface      | Source           | Destination     | Port     | Action | Description                           |
| -------------- | ---------------- | --------------- | -------- | ------ | ------------------------------------- |
| OpenVPN | * | * | IPv4* | PASS   | Autorise tous le traffic dans le tunnel |


## Traduction en règles pfSense (On-premise)

### WAN

| Interface      | Source           | Destination     | Port     | Action | Description                           |
| -------------- | ---------------- | --------------- | -------- | ------ | ------------------------------------- |
| WAN | ReservedNot assigned by IANA | * | * | BLOCK | Bloque tous les flux par défaut |
| WAN | * | * | 1998 | PASS | Autorise l'accès distant au VPN S2S |

### LAN

| Interface      | Source           | Destination     | Port     | Action | Description                           |
| -------------- | ---------------- | --------------- | -------- | ------ | ------------------------------------- |
| LAN | *  | LAN Address | 80 | PASS | Règle Anti-Lockout |
| LAN | LAN Subnets | 192.168.10.0/24 | * | PASS   | Autoriser les connexion LAN vers le Remote |                 |

### OUTILS

| Interface      | Source           | Destination     | Port     | Action | Description                           |
| -------------- | ---------------- | --------------- | -------- | ------ | ------------------------------------- |
| OUTILS | OUTILS Subnets  | 192.168.20.0/24 | IPv4*   | BLOCK | Isolation : Outils ne doit pas accéder au bastion |
| OUTILS | OUTILS Subnets  | 192.168.30.0/24 | IPv4*   | BLOCK | Isolation : Outils ne doit pas accéder au réseau Intranet sans besoin réel identifié |
| OUTILS | 192.168.20.10 | OUTILS Subnets | 222 | PASS   | Autorise les connexions SSH via le port personnalisé 222 afin d’imposer le passage par le bastion |
| OUTILS | OUTILS Subnets | WAN | * | PASS | Autorise les flux nécessaires depuis le réseau Outils |

### MONITORING

| Interface      | Source           | Destination     | Port     | Action | Description                           |
| -------------- | ---------------- | --------------- | -------- | ------ | ------------------------------------- |
| MONITORING | MONITORING Subnets | 192.168.20.0/24 | IPv4*   | BLOCK | Isolation : Monitoring ne doit pas accéder au bastion |
| MONITORING | MONITORING Subnets | OUTILS Subnets | IPv4*   | BLOCK | Isolation : Monitoring ne doit pas accéder au réseau Outils |
| MONITORING | MONITORING Subnets | 192.168.30.0/24 | IPv4*   | BLOCK | Isolation : Monitoring ne doit pas accéder au réseau Intranet |
| MONITORING | 192.168.20.10 | MONITORING Subnets | 22 | PASS   | Autorise les connexions SSH via le port 22 afin d’imposer le passage par le bastion |
| MONITORING | MONITORING Subnets | WAN | * | PASS | Autorise les flux nécessaires depuis le réseau Monitoring |

### OpenVPN

| Interface      | Source           | Destination     | Port     | Action | Description                           |
| -------------- | ---------------- | --------------- | -------- | ------ | ------------------------------------- |
| OpenVPN | * | * | IPv4* | PASS   | Autorise tous le traffic dans le tunnel |
| OpenVPN | 192.168.20.0/24 | This Firewall (self) | * | PASS | Autoriser l'accès à l'interface GUI du PfSense datacenter depuis le Bastion |


## Justification des règles critiques

**Bastion → Toutes les VMs (SSH)**

Le bastion constitue le point d’entrée unique pour l’administration de l’infrastructure. Il est le seul hôte autorisé à initier des connexions SSH vers l’ensemble des machines virtuelles internes.

Cette règle est volontairement étendue afin de garantir la capacité d’administration centralisée, tout en limitant l’exposition directe des VMs au réseau d’administration.

Elle s’inscrit dans le principe de réduction de la surface d’attaque, en évitant toute connexion SSH directe depuis d’autres réseaux.

**VLANs → Elasticsearch (port 9200)**

Les agents Filebeat déployés sur chaque machine envoient les logs vers Elasticsearch via le port TCP 9200.

Ce flux est strictement limité à ce port afin d’éviter toute communication non autorisée entre les VLANs.

Cette segmentation permet :

- d’isoler la couche de supervision du reste de l’infrastructure,
- de centraliser les logs dans un environnement dédié
- limiter les communications entre les différents sous-réseaux afin de réduire les possibilités de mouvement latéral en cas de compromission d’une machine.

**Règles NAT Outbound**

Chaque VLAN dispose d’une règle de NAT Outbound permettant aux machines internes d’accéder à Internet via l’adresse WAN de pfSense.

Cette configuration assure un accès sortant contrôlé tout en maintenant l’anonymisation des réseaux internes.

Les règles OpenVPN sont positionnées au-dessus des règles WAN afin de garantir que le trafic inter-sites transite exclusivement par le tunnel VPN et ne soit pas NATé vers Internet.

## Exemples des flux interdits

L’infrastructure repose sur une politique de sécurité restrictive de type “deny by default”, où seuls les flux explicitement autorisés sont acceptés.

Tous les échanges inter-segments non nécessaires au fonctionnement des services sont automatiquement bloqués par le firewall pfSense.

À titre d’exemple :

- Les réseaux ne peuvent pas initier de connexion vers le Bastion afin de préserver l’isolation du point d’administration.
- Le réseau Monitoring est isolé des différents réseaux car le service de supervision reçoit des données mais n'a aucun besoins d'initier des connexions vers les autres réseaux.
- Aucun service interne n’est exposé directement sur Internet, toutes les communications entrantes étant filtrées par le pare-feu.
- Les échanges entre réseaux Outils et Intranet sont bloqués par défaut en l’absence de besoin fonctionnel identifié.
