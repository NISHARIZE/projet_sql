/*
PROJET : Analyse de l'industrie pétrolière
FICHIER : 2_requetes_analytiques.sql
*/

-- ====================== CONFIGURATION ======================
.headers ON
.mode box
.nullvalue NULL

-- ====================== 1. PRODUCTION PAR RÉGION ======================
SELECT '*** PRODUCTION PAR RÉGION (TOP 10) ***' AS titre;

SELECT 
    r.sub_region AS "Région",
    r.offshore AS "Offshore (kb/j)",
    r.onshore AS "Onshore (kb/j)",
    (r.offshore + r.onshore) AS "Total",
    PRINTF('%.1f%%', (r.offshore * 100.0) / (r.offshore + r.onshore)) AS "% Offshore"
FROM regional_distribution r
ORDER BY "Total" DESC
LIMIT 10;

-- ====================== 2. CROISSANCE DES PAYS ======================
SELECT '*** TOP 10 CROISSANCE 2023-2025 (PAYS AVEC DONNÉES 2023) ***' AS titre;

SELECT
    p.country_area AS "Pays",
    p.y2023 AS "2023",
    p.y2025_expected AS "2025 (prévision)",
    (p.y2025_expected - p.y2023) AS "Δ Production",
    CASE 
        WHEN p.y2023 > 0 THEN PRINTF('%.1f%%', ((p.y2025_expected - p.y2023) * 100.0) / p.y2023)
        ELSE 'N/A'
    END AS "% Croissance"
FROM production_timeline p
WHERE p.y2023 > 0
ORDER BY "% Croissance" DESC
LIMIT 10;

-- ====================== 3. SYNTHÈSE MONDIALE - VERSION FINALE ======================
SELECT '*** SYNTHÈSE MONDIALE ***' AS titre;

WITH production_par_region AS (
    SELECT 
        SUM(offshore) AS total_offshore,
        SUM(onshore) AS total_onshore,
        SUM(offshore + onshore) AS production_totale
    FROM regional_distribution
),
pays_actifs AS (
    SELECT COUNT(DISTINCT country_area) AS nb_pays
    FROM production_status
    WHERE operating > 0
)
SELECT
    p.nb_pays AS "Pays Producteurs",
    r.production_totale AS "Capacité Totale (kb/j)",
    r.total_offshore AS "Capacité Offshore",
    r.total_onshore AS "Capacité Onshore",
    PRINTF('%.1f%%', (r.total_offshore * 100.0) / r.production_totale) AS "% Offshore"
FROM production_par_region r, pays_actifs p;


-- 1. Requêtes de base
SELECT '*** RÉGIONS AVEC >100 OFFSHORE ***' AS titre;
SELECT sub_region, offshore 
FROM regional_distribution 
WHERE offshore > 100
ORDER BY offshore DESC;

-- 2. Jointure avec données de population
SELECT '*** PRODUCTION PAR HABITANT ***' AS titre;
SELECT 
    r.sub_region,
    (r.offshore + r.onshore) * 1000.0 / p.population_millions AS bbl_jour_1000h
FROM regional_distribution r
JOIN population p ON r.sub_region = p.sub_region;

-- 3. Ratios et indicateurs
SELECT '*** RATIOS OFFSHORE/ONSHORE ***' AS titre;
SELECT 
    sub_region,
    ROUND(offshore * 1.0 / NULLIF(onshore, 0), 2) AS ratio
FROM regional_distribution
ORDER BY ratio DESC;

-- 4. Top 5 Offshore
SELECT '*** TOP 5 RÉGIONS OFFSHORE ***' AS titre;
SELECT sub_region, offshore 
FROM high_offshore_regions
LIMIT 5;