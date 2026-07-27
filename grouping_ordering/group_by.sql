SELECT country, count(*) as users_that_are_in_the_range_2000_3900_followers
FROM users
WHERE followers BETWEEN 2000 AND 3900
GROUP BY country
ORDER BY country ASC;