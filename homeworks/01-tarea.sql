-- 1. Ver todos los registros
SELECT * FROM users;

-- 2. Ver el registro cuyo id sea igual a 10
select * FROM users
WHERE id = 10;

-- 3. Quiero todos los registros que cuyo primer nombre sea Jim (engañosa)
SELECT * FROM users
WHERE name like 'Jim %'

4. Todos los registros cuyo segundo nombre es Alexander
SELECT * FROM users
where name like '% Alexander'

-- 5. Cambiar el nombre del registro con id = 1, por tu nombre Ej:'Fernando Herrera'
UPDATE  users
SET name = 'Samuel Vargas'
WHERE id = 1

-- 6. Borrar el último registro de la tabla
delete from users
WHERE id = (
    SELECT id 
    from users
    order by id desc
    LIMIT 1
)
returning *;