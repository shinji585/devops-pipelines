INSERT INTO language (name)
select DISTINCT language from countrylanguage order by countrylanguage asc;