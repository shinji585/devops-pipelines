SELECT name, count(*)
FROM country
GROUP BY name
HAVING count(*) > 1;


SELECT * from country WHERE name = 'Netherlands';

delete FROM country WHERE code = 'NLD' and code2 = 'NA';

-- I give to code a contraint that is the primary key, so it is going to function as unique identifier for that table 
ALTER TABLE country
add primary key (code);