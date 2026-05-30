# Kill Switch Strategy — V1

## Objectif

Mettre en place une procédure d’arrêt d’urgence (“Kill Switch”) permettant d’isoler rapidement les communications inter-sites et l’infrastructure distante en cas :

- d’intrusion
- de compromission
- d’activité réseau suspecte
- d’incident de sécurité critique

La stratégie doit :

- limiter la propagation d’un incident
- préserver les capacités de restauration
- éviter la destruction de l’infrastructure
- permettre une reprise contrôlée des services

## Principe de fonctionnement

Le Kill Switch repose principalement sur :

- les règles firewall pfSense
- l’isolation réseau VLAN
- la coupure du trafic VPN inter-sites
- l’arrêt optionnel des services exposés

## Architecture concernée

### Site Remote

- VLAN Bastion : `192.168.20.0/24`
- VLAN Intranet : `192.168.30.0/24`

### Site Datacenter

- Réseaux internes
- Tunnel VPN site-à-site OpenVPN

## Règles mises en place

### Site Remote

#### Interface concernée

```text
Firewall → Rules → OpenVPN
```

#### Règle de protection du VLAN Intranet

| Paramètre | Valeur |
|---|---|
| Action | Block |
| Source | any |
| Destination | 192.168.30.0/24 |
| Description | Kill Switch - Isolate Remote Intranet |
| État par défaut | Disabled |

#### Objectif

Empêcher tout accès provenant du site Datacenter vers le VLAN Intranet du site Remote.

### Site Datacenter

#### Interface concernée

```text
Firewall → Rules → OpenVPN
```

#### Règle de protection du réseau LAN

| Paramètre | Valeur |
|---|---|
| Action | Block |
| Source | any |
| Destination | LAN subnet |
| Description | Kill Switch - Protect LAN |
| État par défaut | Disabled |

#### Règle de protection du réseau OUTILS

| Paramètre | Valeur |
|---|---|
| Action | Block |
| Source | any |
| Destination | OUTILS subnet |
| Description | Kill Switch - Protect OUTILS |
| État par défaut | Disabled |

#### Règle de protection du réseau MONITORING

| Paramètre | Valeur |
|---|---|
| Action | Block |
| Source | any |
| Destination | MONITORING subnet |
| Description | Kill Switch - Protect MONITORING |
| État par défaut | Disabled |

## Fonctionnement

### Situation normale

Les règles restent désactivées :

- les communications VPN inter-sites fonctionnent normalement
- les services restent accessibles selon les règles firewall classiques

### En cas d’incident

Les règles peuvent être activées manuellement depuis pfSense :

1. Activation des règles Kill Switch
2. Application des changements firewall
3. Isolation immédiate des communications inter-sites

## Effets du Kill Switch

### Communications inter-sites

| Flux | Résultat |
|---|---|
| Datacenter → Remote | Bloqué |
| Remote → Datacenter | Bloqué |

### Infrastructure locale

| Élément | État |
|---|---|
| Machines virtuelles | Conservées |
| Services locaux | Fonctionnels |
| Configuration VPN | Conservée |
| Possibilité de restauration | Oui |

## Accès d’administration après activation du Kill Switch

L’activation du Kill Switch bloque les communications inter-sites transitant par le tunnel VPN Site-to-Site OpenVPN.

Cette isolation empêche notamment :

- les communications entre les VLANs des deux sites
- les accès applicatifs inter-sites
- les mouvements latéraux potentiels en cas de compromission

Afin d’éviter toute perte totale d’administration de l’infrastructure, un accès séparé est prévu via un VPN Point-to-Site (P2S).

### Rôle du VPN Point-to-Site

Le VPN Point-to-Site permet :

- aux administrateurs de se connecter directement au réseau d’administration
- de conserver un accès au bastion même lorsque le VPN Site-to-Site est isolé
- d’assurer les opérations de remédiation et de restauration

Cette séparation permet de distinguer :

- les flux d’administration
- les flux inter-sites de production

### Fonctionnement en cas d’incident

#### Avant activation du Kill Switch

```text
Datacenter ↔ Remote : accessible
VPN Site-to-Site : actif
VPN Point-to-Site : disponible pour l’administration
```

#### Après activation du Kill Switch

```text
Datacenter ↔ Remote : bloqué
VPN Site-to-Site : isolé
VPN Point-to-Site : toujours accessible
```
L’administration d’urgence reste possible même après activation du Kill Switch grâce au VPN Point-to-Site.
Les administrateurs peuvent ainsi :

- accéder au bastion
- analyser les logs
- corriger l’incident
- rétablir les communications

sans devoir désactiver les mesures de confinement.

## Avantages

- confinement rapide d’un incident
- limitation des impacts réseau
- conservation de l’infrastructure
- restauration rapide possible
- procédure simple et reproductible
- isolation rapide et réversible
- limitation des mouvements latéraux
- réduction de l’impact d’un incident
- maintien d’un accès d’urgence sécurisé
- évite l’auto-verrouillage administratif
- améliore les capacités de remédiation
- meilleure séparation des usages réseau
- architecture plus résiliente

## Limites

- interruption temporaire des communications inter-sites
- accès distant potentiellement indisponible durant l’incident
- nécessite un accès administrateur pfSense

## Conclusion

Cette stratégie de Kill Switch permet une isolation rapide et contrôlée du site distant tout en garantissant la possibilité de reprise des services après remédiation.

L’approche choisie privilégie :

- la segmentation réseau
- le confinement
- la continuité opérationnelle
- la simplicité d’exécution

La stratégie de Kill Switch mise en place permet d’isoler rapidement les deux sites via les règles firewall OpenVPN tout en conservant la possibilité de rétablir les communications après remédiation.