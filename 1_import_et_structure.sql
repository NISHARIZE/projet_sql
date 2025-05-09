/*
PROJET : Analyse de l'industrie pétrolière
FICHIER : 1_import_et_structure.sql
*/

-- ====================== NETTOYAGE INITIAL ======================
PRAGMA foreign_keys = OFF;

DROP TABLE IF EXISTS production_timeline;
DROP TABLE IF EXISTS regional_distribution;
DROP TABLE IF EXISTS production_status;

PRAGMA foreign_keys = ON;

-- ====================== CRÉATION DES TABLES ======================
-- Table 1: production_status (8 colonnes)
CREATE TABLE production_status (
    country_area TEXT PRIMARY KEY,
    discovered INTEGER,
    in_development INTEGER,
    pre_production INTEGER,
    operating INTEGER,
    shut_in INTEGER,
    other INTEGER,
    total INTEGER
);

-- Table 2: production_timeline (16 colonnes - SANS CONTRAINTE INITIALE)
CREATE TABLE production_timeline (
    country_area TEXT,
    before_2016 INTEGER,
    y2016 INTEGER,
    y2017 INTEGER,
    y2018 INTEGER,
    y2019 INTEGER,
    y2020 INTEGER,
    y2021 INTEGER,
    y2022 INTEGER,
    y2023 INTEGER,
    y2024 INTEGER,
    y2025_expected INTEGER,
    y2026_expected INTEGER,
    y2027_expected INTEGER,
    y2028_expected INTEGER,
    y2029_expected INTEGER
);

-- Table 3: regional_distribution (3 colonnes)
CREATE TABLE regional_distribution (
    sub_region TEXT PRIMARY KEY,
    offshore INTEGER,
    onshore INTEGER
);

-- ====================== IMPORT DES DONNÉES ======================
.mode csv
.separator ";"

-- Import dans l'ordre avec gestion des erreurs
.import --skip 1 table1.csv production_status
.import --skip 1 table3.csv regional_distribution

-- Import spécial pour table2 avec vérification
CREATE TEMP TABLE temp_timeline AS SELECT * FROM production_timeline WHERE 1=0;
.import --skip 1 table2.csv temp_timeline

-- Nettoyage des données avant insertion
INSERT INTO production_timeline
SELECT * FROM temp_timeline
WHERE country_area IN (SELECT country_area FROM production_status);

-- Comptage des lignes ignorées
SELECT 'Lignes ignorées (pays non référencés): ' || 
       (SELECT COUNT(*) FROM temp_timeline 
        WHERE country_area NOT IN (SELECT country_area FROM production_status));

DROP TABLE temp_timeline;

-- ====================== AJOUT DES CONTRAINTES ======================
-- Maintenant que les données sont propres, on ajoute la FK
BEGIN;
PRAGMA foreign_keys = OFF;

CREATE TABLE new_production_timeline (
    country_area TEXT REFERENCES production_status(country_area),
    before_2016 INTEGER,
    y2016 INTEGER,
    y2017 INTEGER,
    y2018 INTEGER,
    y2019 INTEGER,
    y2020 INTEGER,
    y2021 INTEGER,
    y2022 INTEGER,
    y2023 INTEGER,
    y2024 INTEGER,
    y2025_expected INTEGER,
    y2026_expected INTEGER,
    y2027_expected INTEGER,
    y2028_expected INTEGER,
    y2029_expected INTEGER
);

INSERT INTO new_production_timeline SELECT * FROM production_timeline;
DROP TABLE production_timeline;
ALTER TABLE new_production_timeline RENAME TO production_timeline;

COMMIT;
PRAGMA foreign_keys = ON;

-- ====================== VÉRIFICATION FINALE ======================

PRAGMA foreign_keys = OFF;  -- Désactive temporairement les FK pour les diagnostics

-- 1. Statistiques de base
.headers ON
.mode box
SELECT '*** STATISTIQUES D IMPORTATION ***' AS titre;
SELECT 
    (SELECT COUNT(*) FROM production_status) AS pays,
    (SELECT COUNT(*) FROM production_timeline) AS historiques,
    (SELECT COUNT(*) FROM regional_distribution) AS regions;

-- 2. Diagnostic des données problématiques (sans risque de FK)
SELECT '*** DONNÉES MANQUANTES ***' AS titre;
CREATE TEMP TABLE temp_diagnostics AS
SELECT 
    t.country_area AS pays_manquant,
    COUNT(*) AS occurrences,
    'Manquant dans production_status' AS description
FROM (
    SELECT DISTINCT country_area 
    FROM production_timeline
    EXCEPT 
    SELECT country_area FROM production_status
) t
GROUP BY t.country_area;

-- Affichage sécurisé
SELECT * FROM temp_diagnostics;
DROP TABLE temp_diagnostics;

-- 3. Vérification d'intégrité approfondie
SELECT '*** VÉRIFICATION D INTÉGRITÉ ***' AS titre;
SELECT 
    (SELECT COUNT(*) FROM production_timeline 
     WHERE country_area NOT IN (
         SELECT country_area FROM production_status
     )) AS references_invalides;

-- 4. Extraits de vérification (3 premières lignes de chaque table)
SELECT '*** EXTRAITS DE DONNÉES ***' AS titre;
SELECT * FROM production_status LIMIT 3;
SELECT * FROM production_timeline LIMIT 3;
SELECT * FROM regional_distribution LIMIT 3;

PRAGMA foreign_keys = ON;  -- Réactivation des contraintes




-- === Table Population ===
-- Suppression si elle existe déjà (pour ré-exécution propre)
DROP TABLE IF EXISTS population;

-- Création avec gestion optimisée des clés
CREATE TABLE population (
    sub_region TEXT PRIMARY KEY,
    population_millions INTEGER CHECK(population_millions > 0)
) WITHOUT ROWID;

-- Insertion avec gestion des conflits
BEGIN TRANSACTION;
INSERT OR IGNORE INTO population VALUES
    ('Northern Africa', 250),
    ('Sub-Saharan Africa', 1200),
    ('Northern America', 370),
    ('Latin America and the Caribbean', 650),
    ('Central Asia', 75),
    ('Eastern Asia', 1600),
    ('South-eastern Asia', 675),
    ('Southern Asia', 1900),
    ('Western Asia', 300),
    ('Northern Europe', 100),
    ('Eastern Europe', 290),
    ('Southern Europe', 150),
    ('Western Europe', 195),
    ('Australia and New Zealand', 30),
    ('Melanesia', 10);
COMMIT;

-- Vérification
SELECT '*** DONNÉES POPULATION IMPORTÉES ***' AS titre;
SELECT COUNT(*) AS total_regions_population FROM population;