SELECT a.name as country, a.continent as continentCode, b.name as continentName FROM country a 
FULL OUTER JOIN continent b ON a.continent = b.code;