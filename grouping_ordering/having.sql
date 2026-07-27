SELECT count(*) as total,
    country
FROM users
GROUP BY country
HAVING count(*) BETWEEN 5 AND 9
ORDER BY count(*) desc;