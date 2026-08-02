alter table countrylanguage
add constraint fk_country_code 
foreign key ( countrycode )
references country(code)
on delete cascade;
-- If a country is deleted, automatically delete every row in countrylanguage that references that country.