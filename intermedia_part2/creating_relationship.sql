ALTER TABLE country
add constraint fk_continent
foreign key (continent)
references continent(code);