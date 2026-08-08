SELECT count(a.*) as number_countries, b.name as continent  from country a
FULL OUTER JOIN continent b ON a.continent = b.code
GROUP BY b.name
ORDER BY count(a.*) ASC; 

-- The number of countries associated with each continent.