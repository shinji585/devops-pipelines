SELECT a.name, a.continent,
    (select code from continent b WHERE b.name = a.continent)
FROM country a;

UPDATE country a 
SET continent = (select code from continent b WHERE b.name = a.continent)