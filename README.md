# Analyse de l'Industrie Pétrolière et des Exportations

## Réalisé par AZZOUG Dalia et NISHARIZE Jeancy Candela

Base de données SQLite analysant les données du [Global Oil & Gas Extraction Tracker](https://globalenergymonitor.org/projects/global-oil-gas-extraction-tracker/summary-tables/) avec intégration d'indicateurs économiques.

## Structure Exacte du Projet
```
projet_petrole/
├── data/
│ ├── table1.csv # Statuts de production (production_status)
│ ├── table2.csv # Chronologie (production_timeline)
│ └── table3.csv # Répartition régionale (regional_distribution)
├── scripts/
│ ├── 1_import_et_structure.sql 
│ └── 2_requetes_analytiques.sql 
└── exportation_petrole.db
```

## Correspondance des Tables

| Fichier CSV | Table SQLite         | Description Conforme à la Source |
|-------------|----------------------|----------------------------------|
| table1.csv  | production_status    | Statuts des projets (Operating/Discovered) |
| table2.csv  | production_timeline  | Calendriers 2016-2029 comme dans votre code |
| table3.csv  | regional_distribution| Données offshore/onshore par région |

## Installation Garantie

# 1. Placer les fichiers table1.csv, table2.csv, table3.csv dans /data
# 2. Exécuter dans l'ordre :

sqlite3 exportation_petrole.db < 1_import_et_structure.sql
sqlite3 exportation_petrole.db < 2_requetes_analytiques.sql

Requêtes Clés 
1. Production par Statut
```sql
SELECT 
    country_area,
    operating,
    discovered,
    ROUND(operating*100.0/total,1) AS operating_pct
FROM production_status
WHERE total > 0;
```
2. Projections Régionales
```sql
SELECT 
    sub_region,
    SUM(offshore) AS total_offshore,
    SUM(onshore) AS total_onshore
FROM regional_distribution
GROUP BY sub_region;
```

Licence et Conformité
Source Primaire : Global Energy Monitor

Licence Données : CC BY 4.0

Code : MIT License
