SELECT code, name FROM continent WHERE name like '%America%'
UNION
SELECT code, name FROM continent WHERE code in (3,5)
ORDER BY code ASC;