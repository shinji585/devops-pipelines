SELECT count(a.*) as total_cities, b.name as country FROM city a
INNER JOIN country b ON a.countrycode = b.code
GROUP BY b.name
ORDER BY count(a.*) DESC
LIMIT 1; 