SELECT name
     name,
     id, 
     UPPER(name) as upper_name,
     LOWER(name) as lower_name,
     LENGTH(name) as lenght_name,
     CONCAT(id, ' ', name) as concat_name
FROM users;