SELECT count(*) as number_languages,
    continent
FROM(
        SELECT distinct a.language,
            c.name as continent
        FROM countrylanguage a
            INNER JOIN country b ON a.countrycode = b.code
            INNER JOIN continent c ON b.continent = c.code
        WHERE a.isofficial is TRUE
    ) as totales
GROUP BY continent
ORDER BY count(*) ASC;