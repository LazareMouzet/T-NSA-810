# Kill Switch Strategy — V1

## Objectif

Le Kill Switch est une procédure d’arrêt d’urgence destinée à couper rapidement les communications entre les sites et à contenir un incident de sécurité sans détruire l’infrastructure existante.

Il est activé lorsqu’un événement critique rend le réseau potentiellement non fiable, par exemple :

- intrusion détectée
- compromission d’un équipement ou d’un compte
- activité réseau suspecte
- incident majeur nécessitant un confinement immédiat

Son objectif est de :

- limiter la propagation de l’incident
- préserver les services et la configuration nécessaires à la remédiation
- maintenir une capacité de reprise contrôlée après l’isolement

En pratique, le Kill Switch doit permettre d’isoler les flux inter-sites tout en conservant un accès d’administration d’urgence pour diagnostiquer et corriger la situation.

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

Empêcher tout accès provenant du site Datacenter vers le VLAN Intranet du site Remote et isoler rapidement les deux environnements via les règles firewall OpenVPN.

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

L’activation du Kill Switch bloque les communications inter-sites transitant par le tunnel VPN Site-to-Site OpenVPN et réduit les possibilités de mouvement latéral en cas de compromission.

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
L’administration d’urgence reste possible grâce au VPN Point-to-Site, ce qui permet de :

- accéder au bastion
- analyser les logs
- corriger l’incident
- rétablir les communications

sans désactiver les mesures de confinement.

## Avantages

- confinement rapide d’un incident
- conservation de l’infrastructure et des services utiles à la remédiation
- restauration rapide et réversible
- maintien d’un accès d’urgence sécurisé
- procédure simple, reproductible et adaptée au contexte de crise

## Limites

- interruption temporaire des communications inter-sites
- accès distant potentiellement indisponible durant l’incident
- nécessite un accès administrateur pfSense

## Conclusion

Cette stratégie de Kill Switch permet d’isoler rapidement le site distant, de limiter la propagation d’un incident et de conserver les moyens nécessaires à une reprise contrôlée après remédiation.