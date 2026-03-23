.headers ON
.mode csv

-- =============================
-- Export données graphique 1
-- Production par région
-- =============================

.output production_region.csv

SELECT 
    r.sub_region AS Region,
    r.offshore AS Offshore,
    r.onshore AS Onshore,
    (r.offshore + r.onshore) AS Total
FROM regional_distribution r
ORDER BY Total DESC;

.output stdout


-- =============================
-- Export données graphique 2
-- Croissance production pays
-- =============================

.output croissance_pays.csv

SELECT
    p.country_area AS Pays,
    p.y2023 AS Production_2023,
    p.y2025_expected AS Prevision_2025,
    (p.y2025_expected - p.y2023) AS Variation,
    ((p.y2025_expected - p.y2023) * 100.0) / p.y2023 AS Croissance
FROM production_timeline p
WHERE p.y2023 > 0
ORDER BY Croissance DESC
LIMIT 10;

.output stdout