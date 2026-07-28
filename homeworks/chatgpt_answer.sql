-- ============================================
-- SQL HOMEWORK
-- ============================================

-- ==========================
-- Beginner
-- ==========================

-- 1. Count the total number of users.
SELECT count(*) as number_of_users
FROM users;

-- 2. Find the oldest user.
SELECT age
FROM users
ORDER BY age DESC
LIMIT 1;

-- 3. Find the youngest user.
SELECT age FROM users ORDER BY age ASC LIMIT 1;

-- 4. Calculate the average age.
SELECT ROUND(AVG(age)) as average_age FROM users;

-- 5. Round the average age to two decimals.
SELECT ROUND(AVG(age), 2) as average_age_two_decimals FROM users;



-- ==========================
-- Intermediate
-- ==========================

-- 6. Count users by country.
SELECT  country, count(*) as number_of_users_by_country
FROM users
GROUP BY country;

-- 7. Order countries from the most users to the fewest.
SELECT country, count(*) as number_of_users_by_country
FROM users
GROUP BY country
ORDER BY count(*) DESC;

-- 8. Count users by email domain.
SELECT count(*), SUBSTRING(email, POSITION('@' in email) + 1) as domain
FROM users
GROUP BY  SUBSTRING(email, POSITION('@' in email) + 1)
ORDER BY SUBSTRING(email, POSITION('@' in email) + 1) ASC;


-- 9. Show only domains with more than 500 users.
SELECT count(*), SUBSTRING(email, POSITION('@' in email) + 1) as domain
FROM users
GROUP BY  SUBSTRING(email, POSITION('@' in email) + 1)
HAVING count(*) > 500
ORDER BY SUBSTRING(email, POSITION('@' in email) + 1) ASC;

-- 10. Find the average age for each country.
SELECT ROUND(AVG(age), 2) as average_age_by_country, country
FROM users
GROUP BY country
ORDER BY country ASC;


-- ==========================
-- Advanced
-- ==========================

-- 11. Which country has the oldest average age?
SELECT ROUND(AVG(age), 2) as country_with_the_oldest_average_age, country
FROM users
GROUP BY country
ORDER BY country_with_the_oldest_average_age DESC
LIMIT 1;


-- 12. Which email provider has the youngest users on average?
SELECT ROUND(AVG(age), 2) as email_with_the_youngest_average_users, email
FROM users
GROUP BY email
ORDER BY email_with_the_youngest_average_users ASC
LIMIT 1;

-- 13. Which countries have more than 1,000 users?

-- 14. Show all distinct email domains.
SELECT distinct SUBSTRING(email, POSITION('@' in email) + 1) as distinct_email_domain from users;

-- 15. Count how many users are between 18 and 25 years old for each country.
SELECT  country, count(age) as total_users_between_18_25
FROM users
WHERE  age BETWEEN 18 AND 25
GROUP BY country;