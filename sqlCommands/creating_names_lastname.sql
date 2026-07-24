SELECT NAME
     name,
     SUBSTRING(name, 0, POSITION(' ' in name)) as first_name,
     SUBSTRING(name, POSITION(' ' in name) + 1) as last_name
FROM users
LIMIT 10;

-- first you select the name, then create a sub-string that returns to you the first name, and the last name because we now that the first character is 0 and the stop part we want to finished it is ' '
