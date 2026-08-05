INSERT INTO continent (name)
select DISTINCT continent from country order by continent asc;