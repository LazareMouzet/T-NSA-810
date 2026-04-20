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
**Personnes impliquées** : @Salah, @Moise

#### Description
La machine virtuelle pfSense a perdu l'adresse IP de son interface WAN, entraînant une perte totale de connectivité Internet pour l'ensemble de l'infrastructure réseau qui dépend de ce pare-feu.

**Cause identifiée** : Mauvaise manipulation qui a endommagé la configuration de la VM pfSense.

Symptômes observés :
- Interface WAN sans adresse IP
- Perte complète de la configuration réseau du WAN
- Impossibilité d'accéder à Internet depuis l'infrastructure

#### Impact
- **Impact sur le planning** : Retards dans les PoC
- **Impact sur les fonctionnalités** : Pas de connectivité Internet, blocage complet nécessitant un accès externe
- **Impact sur l'équipe** : Perte de productivité, frustration lors des sessions de développement
- **Risques associés** : Instabilité de l'environnement de développement, risque de perte de configuration

#### Contexte technique
- **Environnement** : dev
- **Version** : pfSense (version à préciser)
- **Technologies concernées** : Virtualisation (VMware/VirtualBox/Hyper-V à préciser), pfSense
- **Configuration** : VM avec interface WAN bridgée ou NAT

#### Tentatives de résolution
1. **Date** : 26/01/2026 - Investigation de la cause de la perte de configuration
2. **Date** : 26/01/2026 - Contact de @Moise, responsable de l'infrastructure fournie

#### Solution finale
- **Date de résolution** : 05/02/2026
- **Description de la solution** : Appel à @Moise (responsable de l'infrastructure fournie) qui nous a communiqué l'adresse IP du WAN. Reconfiguration manuelle de l'interface WAN de pfSense avec les paramètres corrects.
- **Actions mises en place** : 
  - Récupération de l'adresse WAN auprès de @Moise
  - Réécriture de la configuration réseau de l'interface WAN
  - Vérification de la connectivité et retour à la normale
- **Coût (temps/ressources)** : ~10 jours d'interruption (du 26/01 au 05/02)

#### Leçons apprises
- Nécessité de documenter et sauvegarder les configurations critiques (notamment les paramètres réseau)
- Importance de former l'équipe aux bonnes pratiques de manipulation des VMs et infrastructures critiques
- Maintenir un contact direct avec les responsables d'infrastructure (@Moise) pour faciliter la résolution rapide des incidents

#### Références
- Documentation pfSense : configuration réseau
- Logs système de la VM
- Configuration de l'hyperviseur

---

### [ID-002] - Difficulté de connexion des VMs au réseau
**Date de détection** : 15/02/2026  
**Statut** : 🟠 Majeur  
**État** : ⏳ En cours  
**Module/Composant concerné** : Infrastructure réseau / Virtualisation  
**Personnes impliquées** : @équipe infrastructure

#### Description
Problème récurrent lors de la configuration réseau des machines virtuelles. Bien que les cartes réseau soient présentes et détectées par le système, la connexion effective au réseau ne fonctionne pas (nous n'avons pas encore trouvé comment faire).

Symptômes observés :
- Cartes réseau visibles dans la VM mais pas de connectivité
- Configuration IP correcte mais impossibilité de ping/communication
- Incohérence entre la configuration de l'hyperviseur et la VM invitée

#### Impact
- **Impact sur le planning** : Ralentissement des PoC
- **Impact sur les fonctionnalités** : Impossibilité de tester les communications inter-VMs et l'accès réseau
- **Impact sur l'équipe** : Temps perdu en essais/erreurs de configuration
- **Risques associés** : Configuration réseau incohérente, architecture réseau mal définie

#### Contexte technique
- **Environnement** : dev
- **Version** : Hyperviseur à préciser (VMware/VirtualBox/Hyper-V)
- **Technologies concernées** : Virtualisation, Configuration réseau (bridges, NAT, vSwitch)
- **Configuration** : Multiples VMs devant communiquer entre elles et avec l'extérieur

#### Tentatives de résolution
1. **Date** : En cours - Test de différents types d'adaptateurs réseau (bridged, NAT, host-only)
2. **Date** : En cours - Vérification des paramètres de l'hyperviseur et des drivers réseau dans les VMs
3. **Date** : En cours - Analyse de la topologie réseau souhaitée vs configuration actuelle

#### Solution finale
- **Date de résolution** : En attente
- **Description de la solution** : 
- **Actions mises en place** : 
- **Coût (temps/ressources)** : 

#### Leçons apprises
- Nécessité de documenter clairement l'architecture réseau dès le départ
- Importance de comprendre les différents modes réseau de l'hyperviseur
- [À compléter]

#### Références
- Documentation de l'hyperviseur utilisé
- Schéma de l'architecture réseau cible
- Guide de configuration réseau en virtualisation

---

### [ID-003] - Tunnel OpenVPN UP mais ping LAN impossible dans les deux sens
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
- Ping inter-LAN impossible (datacenter vers remote et remote vers datacenter)
- Journaux firewall montrant des paquets refusés sur l'interface OpenVPN

#### Impact
- **Impact sur le planning** : Retard des tests de connectivité inter-sites
- **Impact sur les fonctionnalités** : Communication LAN-to-LAN non opérationnelle malgré VPN UP
- **Impact sur l'équipe** : Temps d'investigation supplémentaire sur OpenVPN au lieu de la validation applicative
- **Risques associés** : Fausse impression de bon fonctionnement du VPN

#### Contexte technique
- **Environnement** : dev
- **Version** : pfSense (version à préciser)
- **Technologies concernées** : OpenVPN, Firewall rules, ICMP
- **Configuration** : Site-to-site entre deux pfSense

#### Tentatives de résolution
1. **Date** : 18/02/2026 - Vérification de l'état du tunnel et des routes
2. **Date** : 18/02/2026 - Analyse des logs firewall OpenVPN

#### Solution finale
- **Date de résolution** : 18/02/2026
- **Description de la solution** : Ajout de la règle `Pass / Any / Any` sur l'interface OpenVPN des deux pfSense.
- **Actions mises en place** :
  - Création de la règle de passage sur chaque interface OpenVPN
  - Application des règles et validation par ping dans les deux sens
  - Vérification des flux applicatifs inter-LAN
- **Coût (temps/ressources)** : ~0,5 jour

#### Leçons apprises
- Un tunnel UP ne garantit pas la circulation des flux LAN sans règles firewall adaptées
- Toujours valider simultanément état du tunnel, routage et filtrage

#### Références
- OpenVPN > Status
- Firewall > Rules > OpenVPN

---

### [ID-004] - NAT Outbound cassait le routage VPN
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
- Perte de connectivité LAN-to-LAN intermittente ou totale
- Diagnostic de routes correctes mais flux transformés par NAT

#### Impact
- **Impact sur le planning** : Blocage de la validation réseau inter-sites
- **Impact sur les fonctionnalités** : Routage VPN incohérent
- **Impact sur l'équipe** : Débogage long entre routage, NAT et règles firewall
- **Risques associés** : Exposition de flux non prévus sur WAN

#### Contexte technique
- **Environnement** : dev
- **Version** : pfSense (version à préciser)
- **Technologies concernées** : Outbound NAT, OpenVPN, interfaces `ovpnc1/ovpns1`
- **Configuration** : VPN site-to-site avec NAT Outbound actif

#### Tentatives de résolution
1. **Date** : 19/02/2026 - Vérification des routes et de la table de forwarding
2. **Date** : 19/02/2026 - Audit des règles NAT générées automatiquement

#### Solution finale
- **Date de résolution** : 19/02/2026
- **Description de la solution** : Passage du NAT Outbound en mode manuel puis suppression des règles NAT appliquées à `ovpnc1/ovpns1`.
- **Actions mises en place** :
  - Basculer `Automatic` vers `Manual Outbound NAT`
  - Supprimer les règles NAT sur les interfaces VPN
  - Tester le trafic inter-LAN et vérifier le chemin réseau
- **Coût (temps/ressources)** : ~0,5 jour

#### Leçons apprises
- Le mode NAT Outbound automatique peut casser un design VPN site-to-site
- Valider systématiquement l'absence de NAT sur les interfaces tunnel

#### Références
- Firewall > NAT > Outbound
- OpenVPN interfaces `ovpnc1/ovpns1`

---

### [ID-005] - Virtual Address configurée sur 10.10.10.0 (adresse réseau invalide)
**Date de détection** : 20/02/2026  
**Statut** : 🟢 Résolu  
**État** : ✅ Résolu  
**Module/Composant concerné** : Réseau / OpenVPN  
**Personnes impliquées** : @Salah

#### Description
Le champ `IPv4 Tunnel Network` était configuré avec un plan d'adressage inadapté (`/24`) et une adresse réseau non valide comme adresse hôte, provoquant des anomalies de communication dans le tunnel.

**Cause identifiée** : Mauvais dimensionnement du `Tunnel Network` (`10.10.10.0/24` au lieu d'un réseau de type point-à-point en `/30`).

Symptômes observés :
- Tunnel instable ou trafic non routé correctement
- Adressage ambigu côté extrémités du tunnel
- Difficultés de diagnostic sur la topologie OpenVPN

#### Impact
- **Impact sur le planning** : Retard de validation de la liaison site-to-site
- **Impact sur les fonctionnalités** : Routage tunnel partiellement non fonctionnel
- **Impact sur l'équipe** : Multiplication des tests de configuration
- **Risques associés** : Conflits d'adressage et comportement non déterministe

#### Contexte technique
- **Environnement** : dev
- **Version** : pfSense (version à préciser)
- **Technologies concernées** : OpenVPN, IPv4 Tunnel Network
- **Configuration** : Tunnel point-à-point entre deux pare-feux

#### Tentatives de résolution
1. **Date** : 20/02/2026 - Contrôle de l'adressage côté serveur/client
2. **Date** : 20/02/2026 - Revue du masque utilisé pour le tunnel

#### Solution finale
- **Date de résolution** : 20/02/2026
- **Description de la solution** : Changement du `Tunnel Network` de `/24` vers `/30`.
- **Actions mises en place** :
  - Reconfigurer le champ `IPv4 Tunnel Network`
  - Redémarrer/renégocier le tunnel
  - Revalider la connectivité et les routes associées
- **Coût (temps/ressources)** : ~0,25 jour

#### Leçons apprises
- Pour un lien point-à-point, privilégier un subnet minimal adapté (`/30`)
- Vérifier la validité des adresses réseau/hôte avant mise en production

#### Références
- OpenVPN Server/Client settings
- Plan d'adressage réseau projet

---

### [ID-006] - `iroute` non appliqué, trafic LAN refusé dans le tunnel
**Date de détection** : 21/02/2026  
**Statut** : 🟢 Résolu  
**État** : ✅ Résolu  
**Module/Composant concerné** : Réseau / OpenVPN / PKI  
**Personnes impliquées** : @Salah

#### Description
Le trafic LAN était refusé dans le tunnel malgré la présence des paramètres de routage. Les `Client Specific Overrides` ne s'appliquaient pas correctement.

**Cause identifiée** : Même certificat (CN `pfSense-datacenter`) utilisé côté serveur et client, empêchant l'association correcte des `iroute`.

Symptômes observés :
- Tunnel actif mais trafic LAN bloqué
- `iroute` attendues non prises en compte
- Comportement incohérent des `Client Specific Overrides`

#### Impact
- **Impact sur le planning** : Retard dans la finalisation du routage inter-sites
- **Impact sur les fonctionnalités** : Flux LAN-to-LAN impossibles via le tunnel
- **Impact sur l'équipe** : Débogage complexe entre certificats, CN et routes
- **Risques associés** : Mauvaise identification des pairs VPN

#### Contexte technique
- **Environnement** : dev
- **Version** : pfSense/OpenVPN (versions à préciser)
- **Technologies concernées** : OpenVPN, PKI, CN, `iroute`, `Client Specific Overrides`
- **Configuration** : Site-to-site avec authentification par certificats

#### Tentatives de résolution
1. **Date** : 21/02/2026 - Vérification des `iroute` et des overrides
2. **Date** : 21/02/2026 - Contrôle des certificats et des Common Names

#### Solution finale
- **Date de résolution** : 21/02/2026
- **Description de la solution** : Création d'un certificat client distinct (CN `pfSense-remote`) puis mise à jour des `Client Specific Overrides`.
- **Actions mises en place** :
  - Générer un certificat dédié au client distant
  - Réassocier correctement les overrides au bon CN
  - Tester les flux LAN et valider l'application des `iroute`
- **Coût (temps/ressources)** : ~0,5 jour

#### Leçons apprises
- Chaque pair VPN doit disposer d'une identité certificat unique
- Les `Client Specific Overrides` dépendent directement du CN associé

#### Références
- System > Cert Manager
- OpenVPN > Client Specific Overrides

---

### [ID-007] - `ERROR: FreeBSD route add command failed`
**Date de détection** : 22/02/2026  
**Statut** : 🟢 Résolu  
**État** : ✅ Résolu  
**Module/Composant concerné** : Réseau / Routage / OpenVPN  
**Personnes impliquées** : @Salah

#### Description
Une erreur `route add command failed` apparaissait lors de l'établissement du tunnel OpenVPN.

**Cause identifiée** : Route statique manuelle en doublon avec la route poussée automatiquement par OpenVPN.

Symptômes observés :
- Message d'erreur `ERROR: FreeBSD route add command failed`
- Ajout de route impossible lors de l'initialisation
- Comportement instable du routage inter-sites

#### Impact
- **Impact sur le planning** : Ralentissement de la mise en service VPN
- **Impact sur les fonctionnalités** : Routage non fiable, flux potentiellement non acheminés
- **Impact sur l'équipe** : Temps d'analyse des logs système/OpenVPN
- **Risques associés** : Conflits de routes et diagnostic trompeur

#### Contexte technique
- **Environnement** : dev
- **Version** : pfSense/FreeBSD (versions à préciser)
- **Technologies concernées** : Routing table, OpenVPN pushed routes, Static Routes
- **Configuration** : Route ajoutée manuellement + route dynamique OpenVPN

#### Tentatives de résolution
1. **Date** : 22/02/2026 - Analyse des logs OpenVPN
2. **Date** : 22/02/2026 - Audit des routes statiques dans pfSense

#### Solution finale
- **Date de résolution** : 22/02/2026
- **Description de la solution** : Suppression de la route statique manuelle redondante dans `System > Routing > Static Routes`.
- **Actions mises en place** :
  - Identifier la route en doublon
  - Supprimer l'entrée manuelle conflictuelle
  - Redémarrer le service OpenVPN et vérifier l'absence d'erreur
- **Coût (temps/ressources)** : ~0,25 jour

#### Leçons apprises
- Éviter les routes statiques manuelles quand OpenVPN pousse déjà les routes nécessaires
- En cas d'erreur `route add`, vérifier immédiatement les doublons de table de routage

#### Références
- System > Routing > Static Routes
- Logs OpenVPN / système pfSense

---

## Classification par Catégorie

### Infrastructure & DevOps
- [ID-001] - Perte de l'adresse WAN sur la VM pfSense
- [ID-002] - Difficulté de connexion des VMs au réseau
- [ID-003] - Tunnel OpenVPN UP mais ping LAN impossible
- [ID-004] - NAT Outbound cassait le routage VPN
- [ID-005] - Virtual Address tunnel invalide (`10.10.10.0/24`)
- [ID-006] - `iroute` non appliqué (certificat CN non distinct)
- [ID-007] - `route add command failed` (route statique en doublon)

### Backend
- [ID-XXX] - Problème description courte

### Frontend
- [ID-XXX] - Problème description courte

### Base de données
- [ID-XXX] - Problème description courte

### IoT / Hardware
- [ID-XXX] - Problème description courte

### Sécurité
- [ID-XXX] - Problème description courte

### Performance
- [ID-XXX] - Problème description courte

### Intégration / API
- [ID-XXX] - Problème description courte

---

## Statistiques

### Par Statut
- 🔴 Bloquant : 0
- 🟠 Majeur : 1
- 🟡 Mineur : 0
- 🟢 Résolu : 6

### Par État
- ⏳ En cours : 1
- ✅ Résolu : 6
- ⏸️ En attente : 0
- 🔄 Récurrent : 0

### Temps moyen de résolution
- Bloquant : N/A
- Majeur : en cours de calcul
- Mineur : en cours de calcul

---

## Actions Préventives

### Mesures mises en place
1. **Checklist VPN pfSense** : Vérification systématique des règles firewall OpenVPN, NAT Outbound et routes statiques avant recette (implémentée le 22/02/2026).
2. **Standard PKI OpenVPN** : Certificat unique par pair VPN + nomenclature CN documentée (`pfSense-datacenter`, `pfSense-remote`) (implémentée le 21/02/2026).

### Points de vigilance identifiés
- Un tunnel UP ne valide pas à lui seul la connectivité inter-LAN (contrôler firewall + NAT + routes)
- Éviter les configurations automatiques non maîtrisées (NAT automatique, routes manuelles redondantes)

### Formations / Montées en compétence nécessaires
- Formation pfSense avancée (OpenVPN site-to-site, NAT, routage)
- Atelier diagnostic réseau (lecture logs OpenVPN + table de routage)

---

## Historique des mises à jour

| Date | Auteur | Modifications |
|------|--------|---------------|
| JJ/MM/AAAA | Nom | Création du document |
| 20/04/2026 | @équipe infrastructure | Ajout des incidents ID-003 à ID-007 + mise à jour classification/statistiques/actions préventives |
| | | |
