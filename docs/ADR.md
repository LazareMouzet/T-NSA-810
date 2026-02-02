# ADR - Choix du DNS forwarder

## Statut
Accepté

**Date:** 02/02/2026

**Auteurs:** Gwendoline Rouleau, choix effectué en équipe

## Contexte

Dans un contexte de nombre de VM limité, nous ne pouvons pas dédier une VM à notre DNS forwarder.

## Décision

La décision prise est d'utiliser Unbound comme DNS forwarder, qui sera intégré à pfSense. Cela permet de gagner une VM.


# ADR - Choix du contexte et des rôles des sites

## Statut
Accepté

**Date:** 02/02/2026

**Auteurs:** Gwendoline Rouleau, choix effectué en équipe

## Contexte

Besoin d'un cas d'usage et d'un cadre clair pour effectuer nos choix d'infrastructure.

## Décision

La décision prise est d'attribuer le rôle de datacenter au site on-premise et le rôle de cloud au site remote. Ainsi, le datacenter ne sera pas connecté à Internet public ; le seul point d'accès au datacenter se fera en VPN via le cloud qui contiendra le bastion pour entrer sur le réseau. Tous nos services seront situés sur le datacenter qui jouera le rôle de master, et l'entrée depuis le réseau public se fera via le cloud.

# ADR - Choix de la méthode pour mettre à jour les services

## Statut
Accepté

**Date:** 02/02/2026

**Auteurs:** Gwendoline Rouleau, choix effectué en équipe

## Contexte

Comment gérer les mises à jour de nos services hébergés sur le datacenter ?

## Décision

La décision prise est de mettre en place une zone de détonation qui gère la fiabilité des paquets de mise à jour. C'est cette zone qui télécharge les paquets, vérifie le checksum et les fait ensuite passer par VPN sur le datacenter pour mettre à jour les services.
Les mises à jour ne seront pas automatiques et nécessiteront une maintenance programmée.
Cette décision est un point intéressant à avoir dans la documentation, mais son implémentation est considérée comme un bonus par le jury.

## Options considérées

### Option 1 : [Nom de l'option]
**Description:** [Description brève]

**Avantages:**
- 
- 

**Inconvénients:**
- 
- 

### Option 2 : [Nom de l'option]
**Description:** [Description brève]

**Avantages:**
- 
- 

**Inconvénients:**
- 
- 

### Option 3 : [Nom de l'option] (si applicable)
**Description:** [Description brève]

**Avantages:**
- 
- 

**Inconvénients:**
- 
- 

## Conséquences

### Positives
- 
- 

### Négatives
- 
- 

### Risques
- 
- 

## Notes complémentaires

[Toute information additionnelle pertinente, références, liens vers des discussions, prototypes, etc.]

## Références

- [Lien vers documentation]
- [Lien vers discussion]
- [Lien vers ticket/issue]
