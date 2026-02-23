# Gouvernance du dépôt

**Projet :** T-NSA-810 — Infrastructure Hybride Sécurisée Multi-Sites  
**Équipe :** Équipe T-NSA-810 — Epitech 2025-2027  
**Dernière mise à jour :** 2026-02-23

---

## 1. Qui peut merger sur `main`

Le merge sur `main` est réservé aux **mainteneurs** du dépôt. Seuls les rôles suivants sont autorisés à effectuer un merge :

| Rôle | Merge sur `main` | Approuver des PRs | Créer des branches |
| :--- | :---: | :---: | :---: |
| **Mainteneur** | ✅ | ✅ | ✅ |
| **Contributeur** | ❌ | ✅ | ✅ |
| **Relecteur externe** | ❌ | ✅ | ❌ |

> Les **mainteneurs** sont les membres de l'équipe disposant explicitement d'un accès en écriture au dépôt. Tous les autres membres sont contributeurs par défaut.

Les pushs directs sur `main` sont **interdits**. Toute modification doit passer par une Pull Request, quel que soit le rôle.

---

## 2. Exigences de revue

Toute Pull Request ciblant `main` **doit** satisfaire l'ensemble des conditions suivantes avant de pouvoir être mergée :

### 2.1 Approbations

- Un minimum de **2 approbations** de membres de l'équipe est requis.
- L'auteur de la PR **ne peut pas** approuver sa propre pull request.
- Les approbations sont invalidées si de nouveaux commits sont poussés après la dernière approbation.

### 2.2 Vérifications

- Tous les contrôles automatisés (CI, linting, tests) doivent passer **sans échec**.

### 2.3 Contenu

- Aucun commentaire de revue non résolu ne doit subsister au moment du merge.

### 2.4 Stratégie de merge

| Cible | Stratégie autorisée |
| :--- | :--- |
| Feature / Fix → `dev` | **Squash and merge** |
| `dev` → `main` | **Squash and merge** (privilégié) ou **Merge commit** |
| Hotfix → `main` | Merge commit (pour préserver la traçabilité) |

Les merges en rebase sont **interdits** sur `main` afin de conserver un historique linéaire et traçable jusqu'aux PRs.

---

## 3. Accès d'urgence

Dans des situations exceptionnelles (panne critique, vulnérabilité de sécurité majeure, blocage d'un livrable), la procédure suivante s'applique.

### 3.1 Définition d'une urgence

Une urgence est une situation qui répond à **tous** les critères suivants :

- Le problème a un impact direct et immédiat sur l'intégrité du projet ou sur un livrable.
- La revue normale d'une PR ne peut pas être complétée dans un délai raisonnable.
- Le correctif ne peut pas être différé.

### 3.2 Procédure d'urgence

1. **Notifier** au moins un autre mainteneur via le canal de communication du projet avant toute action.
2. **Créer une branche hotfix** en respectant la convention de nommage : `hotfix/<ticket-id>-description-courte`.
3. **Ouvrir une PR** même si l'approbation ne peut pas attendre — ajouter le label `emergency` et documenter la raison dans la description de la PR.
4. **Merger** avec une seule approbation si aucun second approbateur n'est joignable dans les **30 minutes**.
5. **Rédiger un post-mortem** sous forme d'issue dans les **24 heures** en documentant ce qui s'est passé, pourquoi le bypass d'urgence a été utilisé, et ce qui a été fait.

### 3.3 Limites

- Les bypasses d'urgence ne doivent **pas** être utilisés pour contourner la revue de modifications non urgentes.
- Une utilisation répétée sans justification valable entraînera une révision des accès.

---

## 4. Règles de protection de branche (paramètres GitHub)

Les règles de protection de branche suivantes **doivent** être configurées sur la branche `main` dans GitHub :

- [x] Exiger une pull request avant le merge
- [x] Exiger des approbations : **2**
- [x] Invalider les approbations existantes lors de nouveaux commits
- [x] Exiger que les vérifications de statut passent avant le merge
- [x] Exiger que la branche soit à jour avant le merge
- [x] Ne pas autoriser le contournement de ces règles (sauf procédure d'urgence ci-dessus)

---

## 5. Flux de branches

### 5.1 Règle générale

Toutes les branches de développement (features, fixes, chores…) doivent être mergées vers **`dev`** et **jamais directement vers `main`**. La branche `main` est réservée aux versions stables et validées.

```
feature/<nom>  ─┐
fix/<nom>      ─┤──► dev ──► main  (merge planifié)
chore/<nom>    ─┘
```

### 5.2 Merges planifiés de `dev` vers `main`

Les merges de `dev` vers `main` sont **planifiés** et ne se font pas en continu. L'objectif est de préserver la stabilité de `main` et de regrouper les changements en livraisons cohérentes.

| Cadence recommandée | Déclencheur |
| :--- | :--- |
| Fin de sprint | Revue de sprint validée, tous les tickets de la sprint terminés |
| Release | Décision de l'équipe ou jalon du projet |
| Correctif critique | Hotfix — voir section 3 |

> Un merge non planifié de `dev` vers `main` doit être discuté en équipe et approuvé par un mainteneur avant d'être initié.

### 5.3 État de `dev`

- `dev` doit rester **fonctionnelle** à tout moment : les branches mergées dessus doivent compile et passer les vérifications CI.
- Les pushs directs sur `dev` sont **interdits** ; toute contribution passe par une PR comme pour `main`, mais avec une seule approbation requise.

---

## Documents liés

- [CONTRIBUTING.md](contributing.md) — Nommage des branches, conventions de commits, processus de PR
- [ADR.md](ADR.md) — Registre des décisions d'architecture
