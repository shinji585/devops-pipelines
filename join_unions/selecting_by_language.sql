SELECT DISTINCT d.name, c.name as continent FROM countrylanguage a 
INNER JOIN country b ON a.countrycode = b.code
INNER JOIN continent c ON b.continent = c.code
INNER JOIN "language" d ON d.code = a.languagecode
WHERE a.isofficial IS TRUE; 