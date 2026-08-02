SELECT DISTINCT continent FROM country;

-- we could add a check transforming the table into a enum 
SELECT DISTINCT region FROM country;



ALTER TABLE country add check (
    continent in (
    'continent',
    'Asia',
    'South America',
    'North America',
    'Oceania',
    'Antarctica',
    'Africa',
    'Europe',
    'Central America'
    )
);

