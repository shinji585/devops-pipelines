SELECT count(*),
    SUBSTRING(email, POSITION('@' in email) + 1) as domain
FROM users
GROUP BY SUBSTRING(email, POSITION('@' in email) + 1)
HAVING count(*) > 1
ORDER BY SUBSTRING(email, POSITION('@' in email) + 1) asc;