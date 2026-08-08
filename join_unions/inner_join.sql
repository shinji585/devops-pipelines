SELECT a.name as country, b.name as continent FROM country a
INNER JOIN continent b ON a.continent = b.code
ORDER BY b.name ASC;