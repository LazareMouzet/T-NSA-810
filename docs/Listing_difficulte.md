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

## Classification par Catégorie

### Infrastructure & DevOps
- [ID-XXX] - Problème description courte

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
- 🔴 Bloquant : X
- 🟠 Majeur : X
- 🟡 Mineur : X
- 🟢 Résolu : X

### Par État
- ⏳ En cours : X
- ✅ Résolu : X
- ⏸️ En attente : X
- 🔄 Récurrent : X

### Temps moyen de résolution
- Bloquant : X jours
- Majeur : X jours
- Mineur : X jours

---

## Actions Préventives

### Mesures mises en place
1. **Mesure 1** : Description et date d'implémentation
2. **Mesure 2** : Description et date d'implémentation

### Points de vigilance identifiés
- Point de vigilance 1
- Point de vigilance 2

### Formations / Montées en compétence nécessaires
- Formation 1
- Formation 2

---

## Historique des mises à jour

| Date | Auteur | Modifications |
|------|--------|---------------|
| JJ/MM/AAAA | Nom | Création du document |
| | | |
