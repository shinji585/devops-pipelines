CREATE TABLE users (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
    name VARCHAR(100),
    age INTEGER,
    country VARCHAR(50),
    email VARCHAR(255)
);

INSERT INTO users (name, age, country, email)
SELECT
    'User ' || n,
    (RANDOM() * 50 + 18)::INT,
    (
        ARRAY[
            'Colombia',
            'Brazil',
            'USA',
            'Argentina',
            'Mexico'
        ]
    )[floor(random()*5+1)],
    'user' || n || '@' ||
    (
        ARRAY[
            'gmail.com',
            'hotmail.com',
            'yahoo.com',
            'outlook.com'
        ]
    )[floor(random()*4+1)]
FROM generate_series(1,5000) AS n;