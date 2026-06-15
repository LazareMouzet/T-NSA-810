# Accès distant via VPN Point-to-Site (P2S)

## Objectif

Le VPN Point-to-Site (P2S) permet à un administrateur ou à un utilisateur autorisé d’accéder à l’infrastructure depuis un poste externe, tout en conservant un accès sécurisé aux réseaux internes.

Cette solution permet également de retrouver l’accès à l’infrastructure lorsque les règles de type kill switch sont activées.

## Vue d’ensemble

L’infrastructure repose sur deux accès P2S distincts afin de séparer les usages quotidiens des interventions critiques. Cette séparation applique le principe du moindre privilège et limite les risques en cas de compromission ou de mauvaise manipulation.

| Accès | Usage |
| --- | --- |
| P2S Remote | Administration courante, maintenance, bastion |
| P2S Datacenter | Intervention critique, récupération, break-glass |

## P2S Remote

### Rôle

Le VPN P2S Remote est destiné à un usage courant d’administration et de maintenance. Il constitue le point d’entrée principal pour les utilisateurs autorisés.

Il permet :

- l’accès aux services internes
- l’administration du bastion
- la maintenance des applications et outils internes
- les opérations quotidiennes sur l’infrastructure

### Portée

Le P2S Remote donne accès à :

- réseau bastion
- VLAN outils, par exemple `outils.local`
- VLAN monitoring
- services internes applicatifs

### Restrictions

Ce VPN n’autorise pas :

- l’accès direct au réseau datacenter
- l'accés direct aux VMs applicatives

### Objectif sécurité

Le P2S Remote sert à :

- travailler au quotidien
- centraliser les accès via le bastion
- réduire les accès directs aux machines critiques

### Point d'entrée unique

Comme le VPN Remote ne donne d'accès direct qu'au bastion, l'administration des autres machines s'effectue en SSH depuis le bastion, ce qui respecte le principe de point d'entrée unique.

```text
┌───────────────────────────┐
│       Poste utilisateur    │
│    Windows / Linux / macOS │
└──────────────┬────────────┘
               │
               ▼
┌───────────────────────────┐
│        OpenVPN P2S        │
│        10.8.0.0/24        │
└──────────────┬────────────┘
               │
               ▼
┌───────────────────────────┐
│     pfSense Remote VPN    │
└──────────────┬────────────┘
               │
               ▼
┌───────────────────────────┐
│          Bastion          │
│        192.168.20.10      │
│         SSH : 2250        │
└──────────────┬────────────┘
               │
      ┌────────|──────|──────────────────┐
      ▼               ▼                  ▼
┌─────────────┐ ┌──────────────┐ ┌───────────────┐
│ Intranet    │ │  Outils      │ │ Monitoring    │
│192.168.30.10| │192.168.200.10│ | 192.168.130.10│
└─────────────┘ └──────────────┘ └───────────────┘
```

Connexion au bastion depuis le poste connecté au VPN :

```bash
ssh -p 2250 epicloud111@192.168.20.10
```

Une fois connecté au bastion, l’accès aux autres VM se fait en SSH :

### Accès à l'intranet

Depuis le bastion, l'intranet est accessible en SSH et via le service web local.

```bash
ssh epicloud211@192.168.30.10
ping 192.168.30.10
curl http://192.168.30.10
```

### Accès aux outils

Depuis le bastion, les machines du VLAN outils restent joignables uniquement par SSH.

```bash
ssh epicloud@192.168.200.10
ping 192.168.200.10
```

### Accès au monitoring

Depuis le bastion, les machines du VLAN monitoring restent joignables uniquement par SSH.

```bash
ssh epicloud@192.168.130.10
ping 192.168.130.10
```

## P2S Datacenter

### Rôle

Le VPN P2S Datacenter est un accès restreint d’urgence, utilisé uniquement lorsque les autres moyens d’accès sont indisponibles, par exemple en cas d’activation d’un kill switch, de panne du bastion ou d’incident majeur.

Il permet une intervention directe sur les composants critiques de l’infrastructure.

### Portée

Le P2S Datacenter est volontairement limité à :

- l’interface d’administration pfSense Datacenter

### Restrictions strictes

Le VPN interdit explicitement :

- l’accès aux machines virtuelles applicatives
- l’accès aux VLAN métiers, notamment outils et monitoring
- toute navigation latérale dans les réseaux internes

## Comparaison des deux accès

| Critère | P2S Remote | P2S Datacenter |
| --- | --- | --- |
| Usage | Quotidien / maintenance | Urgence / incident |
| Accès bastion | Oui | Non |
| Accès VLAN métiers | Oui | Non |
| Accès VMs de production | Oui | Non |
| Accès pfSense | Oui | Oui (uniquement datacenter) |

## Installation du client OpenVPN

### Prérequis

- fichier de configuration `.ovpn` fourni
- identifiants VPN pour l’authentification
- client OpenVPN GUI installé sous Windows, ou client OpenVPN sous Linux

### Sous Windows

1. Télécharger OpenVPN Community Edition : https://openvpn.net/community-downloads/
2. Installer OpenVPN avec les options par défaut.
3. Lancer OpenVPN GUI avec les droits administrateur.

### Import du profil VPN

Le profil VPN est fourni sous la forme d’un fichier `.ovpn`, par exemple `p2s_remote.ovpn` ou `p2s_datacenter.ovpn`.

Ce fichier contient :

- les paramètres de connexion
- le certificat de l’autorité de certification (CA)
- le certificat client
- la clé privée du client
- la clé TLS Authentication

Pour importer le profil :

1. Ouvrir OpenVPN GUI.
2. Cliquer sur **Import File**.
3. Sélectionner le fichier `.ovpn` fourni.
4. Vérifier que le profil apparaît dans la liste des connexions.

ou
1. Double-cliquer sur le fichier .ovpn téléchargé (cela devrait l'importer automatiquement dans OpenVPN GUI)

## Connexion au VPN

1. Clic droit sur l’icône OpenVPN dans la zone de notification.
2. Sélectionner le profil VPN.
3. Cliquer sur **Connect**.
4. Saisir les identifiants de connexion :

   - utilisateur : `vpnP2Sadmin`
   - mot de passe : mot de passe défini dans pfSense

Une fois la connexion établie, l’état du profil doit passer à **Connected**.

## Vérification de la connexion

### Vérification du tunnel VPN

Dans les logs OpenVPN, la présence du message suivant confirme l’établissement du tunnel :

```text
Initialization Sequence Completed
```

### Vérification de la connectivité réseau

Tester l’accès à une machine du réseau interne :

```bash
ping 192.168.30.10
```

Résultat attendu :

```text
Reply from 192.168.30.10
```

Aucune perte de paquets ne doit être observée.

### Vérification de la résolution DNS

Tester la résolution du domaine interne :

```linux
nslookup intranet.local
```

Résultat attendu :

```text
Name:    intranet.local
Address: 192.168.30.10
```

### Vérification de l’accès HTTP

Tester l’accès au site hébergé sur le réseau interne :

Depuis un navigateur :

```text
http://intranet.local
```

Le site doit s’afficher correctement.

Depuis PowerShell :

```powershell
Invoke-WebRequest -Uri http://intranet.local -Method Head
```

Depuis Linux :

```bash
curl -I http://intranet.local
```

Résultat attendu :

```text
StatusCode : 200
StatusDescription : OK
```

## Vérifications par profil

### VPN Remote

Connexion attendue avec le profil `p2s_remote.ovpn`.

Vérifications post-connexion :

- vérifier l’adresse VPN avec `ipconfig` depuis powershell ou `ip addr` depuis linux
- vérifier l’accès au pfSense Remote avec `ping  192.168.10.10`
- vérifier l’accès au bastion avec `ping 192.168.20.10`

Résultats attendus en cas de blocage :

- accès direct au datacenter interdit
- accès au VLAN monitoring et outils interdit

Toutes les commandes évoqués précédemment dans la section P2S Remote > Point d'entrée unique doivent aboutir.

### VPN Datacenter

Connexion attendue avec le profil `p2s_datacenter.ovpn`.

Vérifications post-connexion :

- vérifier l’adresse VPN avec `ipconfig`
- vérifier l’accès au pfSense Datacenter avec `ping 192.168.100.10`
- vérifier l’accès à l’interface pfSense avec `https://192.168.100.10`
- vérifier la résolution DNS interne avec `nslookup outils.local`

Tests de blocage attendus :

- `ping 192.168.100.100`
- `ping 192.168.200.10`
- `ping 192.168.130.10`
- `curl -I http://outils.local`

Les requêtes ci-dessus doivent échouer par timeout ou refus.

## Validation

Le VPN Point-to-Site est considéré comme opérationnel lorsque :

- le client OpenVPN affiche l’état Connected
- le message `Initialization Sequence Completed` apparaît dans les logs
- le ping vers les réseaux internes fonctionne
- la résolution DNS interne fonctionne
- le site web interne est accessible
- les ressources internes restent accessibles lorsque les règles kill switch sont activées

## Conclusion

Cette architecture permet de séparer clairement :

- les opérations quotidiennes via le P2S Remote
- les interventions critiques via le P2S Datacenter

Elle garantit :

- une réduction de la surface d’attaque
- une meilleure résilience en cas d’incident
- un contrôle strict des accès sensibles
- une conformité avec le principe de moindre privilège
