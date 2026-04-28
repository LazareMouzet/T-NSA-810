# Risk Register

**Projet :** T-NSA-810 — Infrastructure Hybride Sécurisée Multi-Sites
**Équipe :** Équipe T-NSA-810 — Epitech 2025-2027
**Dernière mise à jour :** 2026-02-23

---

## Grille d'évaluation

| Niveau | Probabilité | Impact |
| :--- | :--- | :--- |
| 🟢 Faible | < 20 % | Perturbation mineure, sans impact sur les livrables |
| 🟡 Moyen | 20 – 60 % | Retard ou dégradation d'une fonctionnalité |
| 🔴 Élevé | > 60 % | Blocage d'un livrable ou remise en cause de l'architecture |

Le **score de risque** est calculé comme suit : `Probabilité (1–5) × Impact (1–5)`.
Un score ≥ 12 déclenche un plan de mitigation prioritaire.

---

## Registre des risques

| ID | Risque | Catégorie | Probabilité | Impact | Score |
| :--- | :--- | :--- | :---: | :---: | :---: | :---: |
| R-01 | Interruption du tunnel VPN inter-sites causant une perte de connectivité entre les deux sites | Réseau | 🟡 Moyen (3) | 🔴 Élevé (5) | **15** |
| R-02 | Mauvaise configuration d'un pare-feu pfSense exposant un service interne | Sécurité | 🟡 Moyen (3) | 🔴 Élevé (4) | **12** |

---

## Détail des risques

### R-01 — Interruption du tunnel VPN inter-sites

| Champ | Détail |
| :--- | :--- |
| **Description** | Une défaillance du tunnel OpenVPN entre les deux sites entraîne une coupure totale de la communication inter-sites, rendant inaccessibles les services centralisés depuis le site distant. |
| **Probabilité** | 🟡 Moyen (3/5) — incidents réseaux courants en environnement pédagogique partagé |
| **Impact** | 🔴 Élevé (5/5) — blocage complet des opérations inter-sites |
| **Score** | **15 / 25** |
| **Mitigation** | Configurer une supervision active du tunnel (Elastic/alerting). Prévoir un tunnel de secours (failover). Documenter la procédure de redémarrage manuel du service VPN. |

---

### R-02 — Mauvaise configuration du pare-feu pfSense exposant un service interne

| Champ | Détail |
| :--- | :--- |
| **Description** | Une règle de pare-feu mal configurée sur pfSense pourrait exposer involontairement un service interne (ex. interface d'administration Proxmox, base de données) vers l'extérieur ou vers un autre VLAN non autorisé. |
| **Probabilité** | 🟡 Moyen (3/5) — erreur humaine probable lors des itérations de configuration |
| **Impact** | 🔴 Élevé (4/5) — compromission potentielle d'un service critique |
| **Score** | **12 / 25** |
| **Mitigation** | Appliquer le principe du moindre privilège sur toutes les règles pare-feu. Effectuer des audits de règles. Utiliser NetBox pour tracer les flux autorisés et les comparer aux règles réelles. |

---

## Documents liés

- [ADR.md](ADR.md) — Décisions d'architecture liées à la résilience et à la sécurité
- [gouvernance.md](gouvernance.md) — Procédures d'urgence et accès hotfix
