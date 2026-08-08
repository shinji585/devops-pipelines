SELECT a.name as country, b.name as continent from country a, continent b 
WHERE a.continent= b.code 
ORDER BY b.name ASC;