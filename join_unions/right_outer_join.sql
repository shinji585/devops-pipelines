SELECT a.name as country, b.name as continent FROM country a
RIGHT OUTER JOIN continent b ON a.continent = b.code
WHERE a.continent IS NULL;