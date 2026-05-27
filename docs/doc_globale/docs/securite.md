# Sécurité et contrôle d'accès

## Principes de sécurité appliqués

L'architecture du projet CIA repose sur plusieurs principes de sécurité fondamentaux appliqués à tous les niveaux de l'infrastructure.

**Zero Trust Network** : Aucun flux réseau n'est implicitement autorisé. Chaque communication entre deux composants doit être explicitement définie et autorisée par une règle firewall. Le VPN site-to-site lui-même est considéré comme un réseau non fiable et soumis au filtrage.

**Moindre privilège** : Chaque service dispose uniquement des droits strictement nécessaires à son fonctionnement. Les comptes système dédiés (vault, netbox, elasticsearch) ne disposent d'aucun accès shell et ne peuvent pas élever leurs privilèges.

**Cloisonnement par VLAN** : Chaque VM est isolée dans son propre VLAN dédié. Les communications inter-VLANs sont explicitement filtrées par pfSense. Aucun service n'est accessible directement depuis Internet.

**Défense en profondeur** : La sécurité est assurée par plusieurs couches successives : firewall pfSense, segmentation VLAN, bastion SSH, authentification par clé, fail2ban sur toutes les VMs.

## Rôle du bastion

Le bastion (`bastion.local`, `192.168.20.10`) constitue le point d'entrée unique pour toute administration de l'infrastructure. Aucune VM n'est accessible directement depuis Internet.
Tout accès administrateur transite obligatoirement par le bastion.

Caractéristiques du bastion :

- Authentification exclusivement par clé SSH. L'authentification par mot de passe est désactivée
- Journalisation de toutes les connexions via syslog et Filebeat vers Elasticsearch
- Protection contre les attaques par force brute via fail2ban
- Exposition minimale. Seul le port SSH custom est ouvert sur Internet

Flux d'accès administrateur :

```ini
Poste admin → Bastion (SSH, clé) → VM cible (SSH, clé via ProxyJump)
```

## Gestion des accès administrateur

L'accès aux interfaces web des services internes (NetBox, Kibana, Vault, pfSense) n'est jamais exposé directement. Il s'effectue exclusivement via des tunnels SSH établis depuis le poste administrateur à travers le bastion.

| Interface | Mécanisme d'accès |
|---|---|
| NetBox | Tunnel SSH → HTTPS localhost |
| Kibana | Tunnel SSH → HTTP localhost |
| Vault | Tunnel SSH → HTTPS localhost |
| PfSense Remote | Tunnel SSH → HTTP localhost |
| PfSense Datacenter | Tunnel SSH → HTTPS localhost |

## VPN considéré comme non fiable

Bien que le tunnel VPN site-to-site chiffre les communications entre les deux sites, il est délibérément traité comme un réseau non fiable dans l'architecture CIA. Les flux transitant par le VPN sont soumis au même niveau de filtrage que les flux provenant d'Internet.
Cette approche garantit que la compromission d'un équipement sur l'un des sites ne permet pas automatiquement d'accéder librement aux ressources de l'autre site.
