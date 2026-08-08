-- ¿Cuál es el idioma (y código del idioma) oficial más hablado por diferentes países en Europa?
select *
from countrylanguage
where isofficial = true;
select *
from country;
select *
from continent;
Select *
from "language";

SELECT * FROM city;


SELECT count(*), b.languagecode, b.language FROM country a    
INNER JOIN countrylanguage b on a.code = b.countrycode
WHERE a.continent = 5 and b.isofficial is TRUE
GROUP BY b.languagecode, b.language 
ORDER BY count(*) DESC
LIMIT 1; 


-- Listado de todos los países cuyo idioma oficial es el más hablado de Europa 
-- (no hacer subquery, tomar el código anterior)

SELECT * FROM country a 
INNER JOIN countrylanguage b ON a.code = b.countrycode 
WHERE a.continent = 5 AND b.isofficial is TRUE AND b.languagecode = 135;