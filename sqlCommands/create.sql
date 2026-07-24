CREATE TABLE IF NOT EXISTS users(
    id BIGINT generated always as identity primary key,
    name varchar(100) not null,
    age integer not null
)