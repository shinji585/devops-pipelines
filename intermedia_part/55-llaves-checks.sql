

-- 1. Crear una llave primaria en city (id)
ALTER TABLE city
add  primary key (id); 

-- 2. Crear un check en population, para que no soporte negativos
ALTER TABLE city
add check(
    population >= 0
);

-- 3. Crear una llave primaria compuesta en "countrylanguage"
-- los campos a usar como llave compuesta son countrycode y language
ALTER TABLE countrylanguage
add primary key  (countrycode, language);

-- 4. Crear check en percentage, 
-- Para que no permita negativos ni números superiores a 100
ALTER TABLE countrylanguage
add check(
  (percentage >= 0) and (percentage <= 100)
);

