# Limites, risques et amélioration

## Limites liées aux contraintes du projet

Plusieurs contraintes techniques et organisationnelles ont influencé les choix d’architecture et les possibilités d’automatisation du projet.

---

### Capacité de stockage limitée

L’espace disque disponible sur certaines machines virtuelles est limité à environ 7 Go.
Cette contrainte rend l’installation de certaines briques lourdes (notamment Elasticsearch et Kibana) plus complexe et nécessite une optimisation des services déployés.

---

### Accès restreint à l’infrastructure hyperviseur

L’accès à la console Proxmox ainsi qu’à son API n’est pas disponible dans le cadre du projet.
Cela limite les possibilités d’automatisation avancée, notamment la récupération dynamique d’informations d’infrastructure.

---

### Intégration réseau limitée

L’impossibilité d’utiliser une configuration “VLAN aware” au niveau de l’hyperviseur conduit à une implémentation des réseaux via une configuration manuelle dans Netplan, ce qui limite une segmentation réseau totalement centralisée et industrialisée. Cette approche fonctionne mais repose davantage sur la configuration des VMs que sur une centralisation au niveau de l’infrastructure, ce qui peut augmenter le risque d’erreur de configuration.

---

### Absence de gestion complète de l’infrastructure via IaC bas niveau

L’impossibilité de créer et gérer dynamiquement des machines virtuelles empêche la mise en place d’outils comme Terraform pour l’orchestration complète de l’infrastructure.

---

### Gestion des snapshots non garantie

Les snapshots Proxmox sont régulièrement supprimés par le prestataire.
Cela limite la possibilité de mettre en place des chaînes de snapshots successifs pour versionner finement l’évolution des configurations.

---

### Contraintes de temps et d’environnement

Le projet, réalisé sur une période de six mois, a été fortement contraint par les limitations de l’infrastructure fournie.
Ces contraintes ont orienté les choix vers une architecture pragmatique basée sur l’automatisation via Ansible et des mécanismes de restauration simples.

## Points de vigilance sécurité

Certaines règles de filtrage réseau ont été volontairement définies de manière permissive durant la phase de développement et d’intégration afin de faciliter les tests et le déploiement des services.

Le durcissement final des règles firewall (principe de moindre privilège strict) devra être réalisé en phase de stabilisation.

Par ailleurs, le VPN Site-to-Site est actuellement configuré avec des règles larges, ce qui constitue un point de vigilance en termes de segmentation inter-sites.

## Améliorations possibles

Plusieurs améliorations peuvent être envisagées afin de renforcer la robustesse et la sécurité de l’infrastructure :

- Mise en place d’une architecture haute disponibilité pour les composants critiques (pfSense, Proxmox, services de monitoring)
- Durcissement des règles de filtrage réseau selon le principe du moindre privilège strict
- Mise en place d’un SIEM plus avancé pour l’analyse des logs et la détection d’incidents
- Renforcement de la segmentation réseau avec un contrôle plus fin des flux inter-VLAN
- Automatisation complète du durcissement post-déploiement via Ansible
