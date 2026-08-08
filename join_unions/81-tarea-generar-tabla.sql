SELECT count(a.*) as number_countries,
    b.name as continent
FROM country a
    INNER JOIN continent b ON a.continent = b.code
WHERE b.name NOT LIKE '%America%'
GROUP BY b.name
UNION
SELECT count(a.*) as total,
    'America'
FROM country a
    INNER JOIN continent b ON a.continent = b.code
WHERE b.name LIKE '%America%';


-- Count Union - Tarea
-- Total |  Continent
-- 5	  | Antarctica
-- 28	  | Oceania
-- 46	  | Europe
-- 51	  | America
-- 51	  | Asia
-- 58	  | Africa