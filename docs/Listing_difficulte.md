# Suivi des Difficultés Techniques

## Objectif
Ce document vise à répertorier et suivre l'ensemble des difficultés techniques rencontrées au cours du projet. Il permet de :
- Identifier les problèmes récurrents
- Capitaliser sur les solutions trouvées
- Améliorer les processus de développement
- Faciliter le partage de connaissances au sein de l'équipe

---

## Légende

### Statuts
- 🔴 **Bloquant** : Empêche la progression du projet
- 🟠 **Majeur** : Impact significatif sur le développement
- 🟡 **Mineur** : Impact limité, contournement possible
- 🟢 **Résolu** : Problème résolu définitivement

### États
- ⏳ **En cours** : Investigation ou résolution en cours
- ✅ **Résolu** : Solution implémentée et validée
- ⏸️ **En attente** : Nécessite une intervention externe ou est mis en pause
- 🔄 **Récurrent** : Problème qui revient régulièrement

---

## Difficultés Techniques

### [ID-001] - Perte de l'adresse du WAN sur la VM pfSense
**Date de détection** : 26/01/2026
**Statut** : 🟢 Résolu
**État** : ✅ Résolu
**Module/Composant concerné** : Infrastructure réseau / Virtualisation
**Personnes impliquées** : @Salah, @Mathis

#### Description
La machine virtuelle pfSense a perdu l'adresse IP de son interface WAN, entraînant une perte totale de connectivité Internet pour l'ensemble de l'infrastructure réseau qui dépend de ce pare-feu.

**Cause identifiée** : Mauvaise manipulation qui a endommagé la configuration de la VM pfSense.

Symptômes observés :
- Interface WAN sans adresse IP
- Perte complète de la configuration réseau du WAN
- Impossibilité d'accéder à Internet depuis l'infrastructure

#### Impact
- **Impact sur le planning** : Retard
- **Impact sur les fonctionnalités** : Pas de connectivité Internet, blocage complet nécessitant un accès interne
- **Impact sur l'équipe** : Perte de productivité, frustration lors des sessions de développement
- **Risques associés** : Instabilité de l'environnement de développement, risque de perte de configuration

#### Contexte technique
- **Environnement** : dev
- **Version** : pfSense (version à préciser)
- **Technologies concernées** : Proxmox VE
- **Configuration** : VM avec interface WAN

#### Tentatives de résolution
1. **Date** : 26/01/2026 - Investigation de la cause de la perte de configuration
2. **Date** : 26/01/2026 - Contact de @Mathis, responsable de l'infrastructure fournie

#### Solution finale
- **Date de résolution** : 05/02/2026
- **Description de la solution** : Appel à @Mathis (responsable de l'infrastructure fournie) qui nous a communiqué l'adresse IP du WAN. Reconfiguration manuelle de l'interface WAN de pfSense avec les paramètres corrects.
- **Actions mises en place** :
  - Récupération de l'adresse WAN auprès de @Mathis
  - Réécriture de la configuration réseau de l'interface WAN
  - Vérification de la connectivité et retour à la normale
- **Coût (temps/ressources)** : ~3 semaines

#### Leçons apprises
- Mise en place de snapshots régulière des VMs
- Importance de former l'équipe aux bonnes pratiques de manipulation des VMs et infrastructures critiques
- Maintenir un contact direct avec les responsables d'infrastructure (@Mathis) pour faciliter la résolution rapide des incidents

#### Références
- Documentation pfSense : configuration réseau
- Logs système de la VM
- Configuration de l'hyperviseur

---

### [ID-002] - Difficulté de connexion des VMs au réseau
**Date de détection** : 15/02/2026
**Statut** : 🟠 Majeur
**État** : ✅ Résolu
**Module/Composant concerné** : Infrastructure réseau / Virtualisation
**Personnes impliquées** : @Salah

#### Description
Problème récurrent lors de la configuration réseau des machines virtuelles. Bien que les cartes réseau soient présentes et détectées par le système, la connexion effective au réseau ne fonctionne pas.

Symptômes observés :
- Cartes réseau visibles dans la VM mais pas de connectivité
- DHCP mal configuré sur le pfSense

#### Impact
- **Impact sur le planning** : Ralentissement de la configuration des VMs
- **Impact sur les fonctionnalités** : Impossibilité de finaliser la configuration des VMs à temps
- **Impact sur l'équipe** : RAS
- **Risques associés** : RAS

#### Contexte technique
- **Environnement** : dev
- **Version** : Proxmox VE (version à préciser) - Ubuntu Server (Version à préciser)
- **Technologies concernées** : Proxmox VE - Ubuntu Server
- **Configuration** : Réseau

#### Tentatives de résolution
1. **Date inconnue** : Test (bridge, configuration DHCP)
2. **Date inconnue** : Vérification des paramètres de l'hardware
3. **Date inconnue** : Analyse de la topologie réseau souhaitée

#### Solution finale
- **Date de résolution** : inconnue
- **Description de la solution** :
- **Actions mises en place** :
- **Coût (temps/ressources)** :

#### Leçons apprises
- Nécessité de documenter clairement l'architecture réseau dès le départ
- Importance de comprendre les différents modes réseau de l'hyperviseur

#### Références
- Documentation de l'hyperviseur utilisé
- Schéma de l'architecture réseau cible
- Guide de configuration réseau en virtualisation

---

### [ID-003] - Tunnel OpenVPN S2S - ping LAN impossible dans les deux sens
**Date de détection** : 18/02/2026
**Statut** : 🟢 Résolu
**État** : ✅ Résolu
**Module/Composant concerné** : Réseau / OpenVPN / Firewall pfSense
**Personnes impliquées** : @Salah

#### Description
Le tunnel OpenVPN apparaissait comme actif (UP), mais les hôtes des deux LAN ne pouvaient pas se joindre en ping dans les deux sens.

**Cause identifiée** : Règle firewall manquante sur l'interface OpenVPN des deux pfSense.

Symptômes observés :
- Tunnel établi et stable côté serveur et client
- Ping inter-LAN impossible (datacenter vers remote ou remote vers datacenter)
- Logs Traceroute montrant des paquets non-conformer qux paquets normalement récupéré lors d'un ping

#### Impact
- **Impact sur le planning** : RAS
- **Impact sur les fonctionnalités** : Communication inter-site non opérationnelle malgré VPN S2S
- **Impact sur l'équipe** : RAS
- **Risques associés** : RAS

#### Contexte technique
- **Environnement** : dev
- **Version** : pfSense 2.8.1, OpenVPN 2.6
- **Technologies concernées** : OpenVPN 2.8.1, pfSense
- **Configuration** : VPN S2S entre site remote et on-premise

#### Tentatives de résolution
Tentatives de diagnostique sur un large périmètre

#### Solution finale
- **Date de résolution** : 18/02/2026
- **Description de la solution** : Ajout de la règle `Pass / Any / Any` sur l'interface OpenVPN des deux pfSense.
- **Actions mises en place** :
  - Création de la règle de passage sur chaque interface OpenVPN
  - Application des règles et validation par ping dans les deux sens
  - Vérification des flux applicatifs inter-LAN
- **Coût (temps/ressources)** : 4 jours[^vpn-cost-total]

#### Leçons apprises
- Un tunnel VPN S2S ne garantit pas la circulation des paquest réseaux sans règles firewall adaptées

#### Références
- OpenVPN > Status
- Firewall > Rules > OpenVPN

---

### [ID-003.1] - NAT Outbound cassait le routage VPN
**Date de détection** : 19/02/2026
**Statut** : 🟢 Résolu
**État** : ✅ Résolu
**Module/Composant concerné** : Réseau / NAT / OpenVPN
**Personnes impliquées** : @Salah

#### Description
Le routage du trafic VPN ne fonctionnait pas de manière fiable car des règles NAT Outbound en mode automatique modifiaient les flux destinés au tunnel.

**Cause identifiée** : En mode `Automatic Outbound NAT`, le trafic VPN était NATé vers le WAN.

Symptômes observés :
- Trafic inter-sites qui sortait par WAN au lieu du tunnel
- Aucune connectivité inter-site
- Diagnostic de routes correctes mais flux transformés par NAT

#### Impact
- **Impact sur le planning** : RAS
- **Impact sur les fonctionnalités** : Routage VPN incohérent
- **Impact sur l'équipe** : Débogage long
- **Risques associés** : Exposition de flux non prévus sur WAN

#### Contexte technique
- **Environnement** : dev
- **Version** : pfSense 2.8.1, OpenVPN 2.6
- **Technologies concernées** : OpenVPN, PfSense
- **Configuration** : NAT Outbound

#### Tentatives de résolution
1. **Date** : 19/02/2026 - Audit des règles NAT

#### Solution finale
- **Date de résolution** : 19/02/2026
- **Description de la solution** : Passage du NAT Outbound en mode manuel puis suppression des règles NAT Outbound en mode automatique appliquées à `ovpnc1/ovpns1`.
- **Actions mises en place** :
  - Basculer `Automatic` vers `Manual Outbound NAT`
  - Supprimer les règles NAT Outbound an mode automatique
  - Tester le trafic inter-site via Diagnostique > Traceroute
- **Coût (temps/ressources)** : 4 jours[^vpn-cost-total]

#### Leçons apprises
- Les règles OpenVPN ne doivent pas être naté en mode outbound en mode automatique

#### Références
- Firewall > NAT > Outbound
- OpenVPN interfaces `ovpnc1/ovpns1`

---

### [ID-003.2] - Virtual Address configurée sur 10.10.10.0 (adresse réseau invalide)
**Date de détection** : 20/02/2026
**Statut** : 🟢 Résolu
**État** : ✅ Résolu
**Module/Composant concerné** : Réseau / OpenVPN
**Personnes impliquées** : @Salah

#### Description
Le champ `IPv4 Tunnel Network` était configuré avec un plan d'adressage inadapté (`/24`) et une adresse réseau non valide comme adresse hôte, provoquant des anomalies de communication dans le tunnel.

**Cause identifiée** : Mauvais choix du subnet (`10.10.10.0/24` au lieu d'un réseau de type point-à-point en `/30`).

Symptômes observés :
- Tunnel instable ou trafic non routé correctement
- Adressage ambigu côté extrémités du tunnel

#### Impact
- **Impact sur le planning** : RAS
- **Impact sur les fonctionnalités** : Routage tunnel partiellement non fonctionnel
- **Impact sur l'équipe** : Multiplication des tests de configuration
- **Risques associés** : Conflits d'adressage

#### Contexte technique
- **Environnement** : dev
- **Version** : pfSense 2.8.1 et OpenVPN 2.6
- **Technologies concernées** : OpenVPN, PfSense
- **Configuration** : Tunnel S2S entre site remote et site on-premise

#### Tentatives de résolution
1. **Date** : 20/02/2026 - Revue du masque utilisé pour le tunnel OpenVpn S2S

#### Solution finale
- **Date de résolution** : 20/02/2026
- **Description de la solution** : Modification du subnet de `/24` vers `/30`.
- **Actions mises en place** :
  - Reconfigurer le subnet
  - Redémarrer le tunnel OpenVpn
  - Revalider l'ensemble de la configuration OpenVPN
- **Coût (temps/ressources)** : 4 jours[^vpn-cost-total]

#### Leçons apprises
- Pour un lien S2S, privilégier un subnet minimal adapté (`/30`)

#### Références
- OpenVPN Server/Client settings
- Plan d'adressage réseau projet

---

### [ID-003.3] - `iroute` non appliqué, trafic LAN refusé dans le tunnel
**Date de détection** : 21/02/2026
**Statut** : 🟢 Résolu
**État** : ✅ Résolu
**Module/Composant concerné** : Réseau / OpenVPN / PKI
**Personnes impliquées** : @Salah

#### Description
Le trafic LAN était refusé dans le tunnel malgré la présence des paramètres de routage. Le `Client Specific Overrides` ne s'appliquait pas correctement.

**Cause identifiée** : Même nom de certificat utilisé côté datacenter et remote, empêchant l'association correcte des `iroute`.

Symptômes observés :
- Tunnel actif mais trafic VPN non-fonctionnel
- Les règles `iroute` n'ont pas été prises en compte
- Comportement innatendu du `Client Specific Overrides` côté remote et datacenter

#### Impact
- **Impact sur le planning** : RAS
- **Impact sur les fonctionnalités** : Flux VPN impossibles via le tunnel
- **Impact sur l'équipe** : Recherche de la problématique complexe
- **Risques associés** : Mauvaise identification des pairs VPN

#### Contexte technique
- **Environnement** : dev
- **Version** : pfSense 2.8.1 ; OpenVPN 2.6
- **Technologies concernées** : OpenVPN et PfSense
- **Configuration** : S2S avec authentification par certificats

#### Tentatives de résolution
1. **Date** : 21/02/2026 - Vérification des `iroute` et des règles `Client Specific Overrides`
2. **Date** : 21/02/2026 - Contrôle des certificats et des Common Names

#### Solution finale
- **Date de résolution** : 21/02/2026
- **Description de la solution** : Modification du certificat client (CN `pfSense-remote`) puis mise à jour des règles `Client Specific Overrides`.
- **Actions mises en place** :
  - Mettre un nom spécifique au certificat dédié au client
  - Réassocier correctement les overrides au bon CN
  - Tester les flux VPN et valider l'application des `iroute`
- **Coût (temps/ressources)** : 4 jours[^vpn-cost-total]

#### Leçons apprises
- Chaque certificat doit disposer d'un nom unique
- Les règles du `Client Specific Overrides` dépendent directement du CN associé

#### Références
- System > Cert Manager
- OpenVPN > Client Specific Overrides

---

### [ID-003.4] - `ERROR: FreeBSD route add command failed - DCO (Data Channel Offload)`
**Date de détection** : 22/02/2026
**Statut** : 🟢 Résolu
**État** : ✅ Résolu
**Module/Composant concerné** : Réseau / Routage / OpenVPN
**Personnes impliquées** : @Salah

#### Description
Une erreur `ERROR: FreeBSD route add command failed:` apparaissait lors de l'établissement du tunnel OpenVPN.

**Cause identifiée** : Route statique manuelle en doublon avec la route poussée automatiquement par OpenVPN.

Symptômes observés :
- Message d'erreur `ERROR: FreeBSD route add command failed`
- Le tunnel fonctionne pour les IPs tunnel mais bloque le trafic LAN routé

#### Impact
- **Impact sur le planning** : RAS
- **Impact sur les fonctionnalités** : Impossible pour les LANs des deux sites de communiquer entre eux
- **Impact sur l'équipe** : RAS
- **Risques associés** : RAS

#### Contexte technique
- **Environnement** : dev
- **Version** : pfSense 2.8.1 et OpenVPN 2.6
- **Technologies concernées** : OpenVPN et pfSense
- **Configuration** : S2S

#### Tentatives de résolution
1. **Date** : 22/02/2026 - Analyse des logs OpenVPN
2. **Date** : 22/02/2026 - Audit des routes statiques dans pfSense

#### Solution finale
- **Date de résolution** : 22/02/2026
- **Description de la solution** : Désactivation du DCO dans `VPN > OpenVPN > Client Specific Overrides`.
- **Actions mises en place** :
  - Désactivation du DCO
  - Ajout de la règle : iroute 192.168.10.0 255.255.255.0 dans `VPN > OpenVPN > Client Specific Overrides`.
- **Coût (temps/ressources)** : 4 jours[^vpn-cost-total]

#### Leçons apprises
- Éviter les routes statiques manuelles quand OpenVPN pousse déjà les routes nécessaires
- En cas d'erreur `route add`, vérifier immédiatement les doublons de table de routage

#### Références
- System > Routing > Static Routes
- Logs OpenVPN / système pfSense

[^vpn-cost-total]: Les "4 jours" indiqués pour les incidents ID-003 à ID-003.4 correspondent au temps total cumulé de mise en place et de stabilisation du VPN S2S, et non à 4 jours par incident.

---

### [ID-004] - `ERROR I/O - VM1001`
**Date de détection** : Inconnue
**Statut** : 🟢 Résolu
**État** : ✅ Résolu
**Module/Composant concerné** : Proxmox
**Personnes impliquées** : @Salah

#### Description
Une erreur `ERROR: I/O` apparaissait sur la VM1001, ce qui causait une indisponibilité des fonctionnalités standart (arrêt, restrat).

**Cause identifiée** : Une saturation du stockage LVM, due à l'installation d'elasticsearch et Kibana.

Symptômes observés :
- Message d'erreur `ERROR: I/O`
- VM instable avec des freeze fréquents

#### Impact
- **Impact sur le planning** : Retard sur le POC Elasticsearch
- **Impact sur les fonctionnalités** : Equipement indisponible et instable
- **Impact sur l'équipe** : Impossibilité d'effectué des opérations sur la VM1001
- **Risques associés** : Corruption partielle du système de fichiers, blocage des services critiques, perte de données lors d’un arrêt forcé

#### Contexte technique
- **Environnement** : dev
- **Version** : Proxmox , Ubuntu Server Minimal
- **Technologies concernées** : Proxmox , Ubuntu Server
- **Configuration** : S2S

#### Tentatives de résolution
1. **Date** : / - Analyse du stockage LVM
2. **Date** : / - Analyse des journaux de logs systèmes
3. **Date** : / - Réinstallation d'Ubuntu Server en passant sur Ubuntu Server Minimal

#### Solution finale
- **Date de résolution** : Inconnue
- **Description de la solution** : Nettoyage en profondeur de la VM
- **Actions mises en place** :
  - Suppression de l'ancienne version du kernel non utilisés
  - Netoyage du cache système
  - Suppression d'Elasticsearch
  - Netoyage du journal de logs
- **Coût (temps/ressources)** : 1 jours

#### Leçons apprises
- Réduire la capacité d'écriture dans la configuration d'Elasticsearch lors de son installation

#### Références
- Promox
- Ubuntu Server

---

## Classification par Catégorie

### Infrastructure & DevOps
- [ID-001] - Perte de l'adresse WAN sur la VM pfSense
- [ID-002] - Difficulté de connexion des VMs au réseau
- [ID-003] - Tunnel OpenVPN S2S mais ping LAN impossible
- [ID-003.1] - NAT Outbound cassait le routage VPN
- [ID-003.2] - Virtual Address tunnel invalide (`10.10.10.0/24`)
- [ID-003.3] - `iroute` non appliqué (certificat CN non distinct)
- [ID-003.4] - `route add command failed` (route statique en doublon)
- [ID-004] - `ERROR: I/O` - VM1001

---

## Statistiques

### Par Statut
- 🔴 Bloquant : 0
- 🟠 Majeur : 1
- 🟡 Mineur : 0
- 🟢 Résolu : 6

### Par État
- ⏳ En cours : 0
- ✅ Résolu : 7
- ⏸️ En attente : 0
- 🔄 Récurrent : 0

---

## Historique des mises à jour

| Date | Auteur | Modifications |
|------|--------|---------------|
| JJ/MM/AAAA | Nom | Création du document |
| 20/04/2026 | @Gwendoline | Ajout des incidents ID-003 à ID-007 + mise à jour classification/statistiques/actions préventives |
| 06/05/2026 | @Gwendoline | Mise à jour des incidents ID-001 à ID-003.4 + tri des éléments inutilees dans l'organisation du fichier |
