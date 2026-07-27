SELECT
    first_name,
    last_name,
    country
FROM users
WHERE followers BETWEEN 1000 AND 3000
ORDER BY followers ASC