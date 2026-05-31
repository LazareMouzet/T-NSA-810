# VPN Point-to-Site (P2S)

## Objectif

Afin de disposer d'un accès d'administration indépendant du VPN Site-to-Site, un VPN Point-to-Site (P2S) est en cours de déploiement sur le site Remote.

Cette solution permettra aux administrateurs autorisés de se connecter directement à l'infrastructure via un client VPN, sans dépendre du tunnel inter-sites.

L'objectif principal est de garantir la continuité de l'administration de l'infrastructure, notamment en cas d'activation du Kill Switch ou d'indisponibilité du VPN Site-to-Site.

---

## Cas d'utilisation

Le VPN Point-to-Site permettra notamment :

* l'accès au bastion depuis l'extérieur ;
* l'administration des équipements du site Remote ;
* les opérations de maintenance ;
* les actions de remédiation en cas d'incident ;
* la récupération de l'infrastructure après activation du Kill Switch.

---

## Architecture cible

```text
Administrateur
      │
      ▼
VPN Point-to-Site
      │
      ▼
pfSense Remote
      │
      ▼
Bastion
      │
      ▼
Infrastructure interne
```

Cette architecture sépare les flux d'administration des flux de production transitant par le VPN Site-to-Site.

---

## Éléments déjà configurés

Les composants suivants ont été mis en place :

* Autorité de certification OpenVPN existante réutilisée ;
* Certificat serveur dédié au VPN Point-to-Site ;
* Serveur OpenVPN de type **Remote Access (SSL/TLS + User Authentication)** ;
* Utilisateur VPN dédié avec certificat client ;
* Règles firewall nécessaires à l'écoute du service VPN (règle large destinée à être restreinte ensuite);
* Préparation de l'accès aux réseaux internes du site Remote.

---

## Travaux restants

Les actions suivantes restent à finaliser :

* installation du package **OpenVPN Client Export** sur pfSense ;
* génération et distribution des profils clients ;
* validation de la connexion depuis un poste externe ;
* tests d'accès au bastion et aux services internes ;
* intégration du VPN Point-to-Site dans les procédures d'exploitation.

---

## Intégration avec le Kill Switch

Le VPN Point-to-Site constitue le moyen privilégié de rétablir l'accès d'administration après l'activation du Kill Switch.

En cas d'incident de sécurité, les communications inter-sites peuvent être interrompues tout en conservant un accès sécurisé à l'infrastructure via le VPN Point-to-Site.

Cette approche permet d'éviter tout verrouillage administratif de l'environnement et facilite les opérations de diagnostic et de restauration.

---

## État d'avancement

| Élément                        | Statut        |
| ------------------------------ | ------------- |
| Autorité de certification (CA) | ✅ Configurée  |
| Certificat serveur P2S         | ✅ Configuré   |
| Serveur OpenVPN P2S            | ✅ Configuré   |
| Utilisateur VPN                | ✅ Configuré   |
| Règles Firewall                | ⏳ En cours |
| Export client OpenVPN          | ⏳ À réaliser |
| Tests de connexion             | ⏳ À réaliser  |
| Validation complète            | ⏳ À réaliser    |

```
```