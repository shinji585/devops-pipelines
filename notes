---
cssclasses:
  - minecraft
---
# SQL / PostgreSQL Study Guide

A reference guide built from my own project (`shinji585/devops-pipelines`) — database and table creation, constraints, data manipulation, querying, aggregation, dates, and combining result sets — in the same format as the SQLAlchemy Core guide: Problem Statement → How It Works → Example → Comparison → When to Use / When to Avoid.

---

## Table of Contents

### [Database & Table Creation](#database--table-creation)

- [CREATE DATABASE](#create-database)
- [CREATE TABLE](#create-table)
- [Primary Key](#primary-key)
- [Identity Columns (GENERATED AS IDENTITY)](#identity-columns-generated-as-identity)
- [Constraints & Indexes](#constraints--indexes)
- [Foreign Key & Relationships](#foreign-key--relationships)
- [Altering Tables](#altering-tables)

### [Views — Composition vs. Tables](#views--composition-vs-tables)

- [CREATE VIEW](#create-view)
- [DROP VIEW](#drop-view)
- [Views vs. Tables vs. CTEs](#views-vs-tables-vs-ctes)

### [Data Manipulation](#data-manipulation)

- [INSERT INTO](#insert-into)
- [DELETE FROM](#delete-from)
- [UPDATE](#update)
- [TRUNCATE vs. DELETE vs. DROP](#truncate-vs-delete-vs-drop)
- [Backups & Schema Reset](#backups--schema-reset)

### [Querying & Filtering](#querying--filtering)

- [SELECT / WHERE](#select--where)
- [LIKE Statements](#like-statements)
- [LIMIT and OFFSET](#limit-and-offset)
- [ORDER BY](#order-by)
- [DISTINCT](#distinct)
- [String Functions](#string-functions)

### [Aggregation](#aggregation)

- [COUNT() and Aggregate Functions](#count-and-aggregate-functions)
- [GROUP BY](#group-by)
- [HAVING](#having)

### [Date & Time](#date--time)

- [Basic Date/Time Functions](#basic-datetime-functions)
- [CASE WHEN for Bucketing](#case-when-for-bucketing)
- [INTERVAL & AGE()](#interval--age)
- [Filtering by Date Ranges](#filtering-by-date-ranges)

### [Combining Tables & Result Sets](#combining-tables--result-sets)

- [JOIN Types](#join-types)
- [UNION / UNION ALL](#union--union-all)
- [INTERSECT and EXCEPT](#intersect-and-except)

### [Putting It Together — Modern PostgreSQL Style](#putting-it-together--modern-postgresql-style)

- [The Full Lifecycle of a Schema](#the-full-lifecycle-of-a-schema)
- [SERIAL vs. IDENTITY](#serial-vs-identity)
- [A Complete Modern Table Definition](#a-complete-modern-table-definition)

---

## Database & Table Creation

### CREATE DATABASE

**Problem Statement**

Every project needs an isolated namespace for its tables — separate from other applications' data, with its own permissions and lifecycle. `CREATE DATABASE` is the entry point: it provisions that namespace before any table can exist inside it.

**How It Works**

`CREATE DATABASE` allocates a new, empty database on the server. It doesn't create any tables — only the container. In practice, for a dockerized project this is usually done once, outside of raw SQL, by the container image itself reading environment variables at first boot.

**Example**

This is exactly how my own project provisions its database — no `CREATE DATABASE` statement at all, because `docker-compose.yml` hands Postgres the name/user/password and the image creates it on first startup:

```yaml
services:
  myDB:
    image: postgres:17
    environment:
      - POSTGRES_USER=alumno
      - POSTGRES_PASSWORD=123456
      - POSTGRES_DB=course-db
```

The manual-SQL equivalent, if I weren't using Docker, would be:

```sql
CREATE DATABASE "course-db";
```

**When to Use**

- Once per project/environment — typically the very first step, whether that's a raw `CREATE DATABASE` statement or, as in my setup, an env var the container image reads on first run

**When to Avoid**

- Don't run `CREATE DATABASE` as part of routine application code — it's administrative and one-time, not something a running app should trigger on every startup

---

### CREATE TABLE

**Problem Statement**

A database on its own has nowhere to put structured data. A table defines the shape every row must conform to: which columns exist, what type each holds, and which constraints the database itself enforces.

**How It Works**

`CREATE TABLE` lists columns as `name TYPE [constraints]`, comma-separated. Each column gets a data type and optional constraints (`NOT NULL`, `PRIMARY KEY`). I default to `BIGINT GENERATED ALWAYS AS IDENTITY` for the primary key instead of `SERIAL` — see [Identity Columns](#identity-columns-generated-as-identity).

**Example** (`sqlCommands/create.sql`)

```sql
CREATE TABLE IF NOT EXISTS users(
    id BIGINT generated always as identity primary key,
    name varchar(100) not null,
    age integer not null
)
```

**Common Column Types I actually used**

|Type|Where I used it|
|---|---|
|`BIGINT`|Identity primary keys (`users.id`, `continent.code`)|
|`INT` / `INT4`|Fixed-width identifiers (`regions.region_id`, `language.code`)|
|`VARCHAR(n)`|Bounded strings (`name varchar(100)`, `country_id CHAR(2)`)|
|`TEXT`|Unbounded strings (`transformers2.name`)|
|`DECIMAL(p, s)`|Money-like values (`jobs.min_salary DECIMAL(8,2)`)|
|`BOOLEAN`|Flags (`countrylanguage.isofficial`, `post.is_published`)|
|`DATE` / `TIMESTAMP`|`employees.hire_date`, `claps.created_at`|
|`UUID`|Alternate PK type — `transformers2.id`|

**When to Use**

- Once per logical entity (`users`, `transformers2`, `country`, `continent`, `employees`...)
- Declare `NOT NULL` on every column that should never be empty

**When to Avoid**

- Don't leave every column nullable "just in case" — a permissive schema silently accepts bad data a stricter one would reject at write time

---

### Primary Key

**Problem Statement**

Every row needs a way to be referred to unambiguously. Without a guaranteed-unique identifier, "update this row" and "update every row that looks like this" become indistinguishable.

**How It Works**

A **primary key** is one column, or a combination (a _composite key_), that the database guarantees is both unique and never `NULL`. It doesn't have to be declared at `CREATE TABLE` time — I added composite keys after the fact with `ALTER TABLE` more than once.

**Example — single-column, at creation time** (`sqlCommands/create.sql`)

```sql
CREATE TABLE IF NOT EXISTS users(
    id BIGINT generated always as identity primary key,
    ...
)
```

**Example — composite, added later** (`ids/alter_table.sql`, `intermedia_part/55-llaves-checks.sql`)

```sql
ALTER TABLE transformers
ADD CONSTRAINT transformers_pkey
PRIMARY KEY (id, team_id);

-- same idea on countrylanguage: neither column alone is unique,
-- but the pair (countrycode, language) is
ALTER TABLE countrylanguage
ADD PRIMARY KEY (countrycode, language);
```

**Example — discovering duplicates before constraining a real dataset** (`intermedia_part/adding_primary_key.sql`) — the realistic version of this workflow, since `country.code` wasn't clean data yet:

```sql
SELECT name, count(*) FROM country GROUP BY name HAVING count(*) > 1;
SELECT * FROM country WHERE name = 'Netherlands';
DELETE FROM country WHERE code = 'NLD' AND code2 = 'NA';
ALTER TABLE country ADD PRIMARY KEY (code);
```

**Dropping one** (`ids/drop_constraint_transformers.sql`)

```sql
ALTER TABLE transformers
DROP CONSTRAINT transformers_pkey;
```

**When to Use**

- Every table gets a primary key, no exceptions
- Composite keys specifically when uniqueness is defined by a _combination_ of columns (`countrylanguage`: a country can have many languages, a language many countries, but each pair is unique)

**When to Avoid**

- Don't add a primary key blindly to real data — check for duplicates first, the way `adding_primary_key.sql` does, or the `ADD PRIMARY KEY` will simply fail

---

### Identity Columns (GENERATED AS IDENTITY)

**Problem Statement**

A primary key needs a value on every row, but the application shouldn't decide what that value is — picking the "next" integer manually invites race conditions the moment two inserts happen near-simultaneously.

**How It Works**

`GENERATED ... AS IDENTITY` backs a column with an internal sequence the database maintains. `ALWAYS` vs `BY DEFAULT` controls whether a manually supplied value is rejected or allowed.

**Example — `ALWAYS`, app never supplies an id** (`sqlCommands/create.sql`)

```sql
id BIGINT generated always as identity primary key
```

**Example — `BY DEFAULT`, used across an entire schema meant for seeding** (`tablas_designed/Medium.sql`)

```sql
CREATE TABLE "users" (
  "user_id" INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  "username" varchar(50) UNIQUE NOT NULL,
  ...
);
```

**Example — UUID as an alternative to a sequence entirely** (`ids/install.sql`, `ids/identity.sql`)

```sql
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE transformers2 (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL
);
```

**Comparison — reading my own two schemas side by side**

||`sqlCommands/create.sql` (`ALWAYS`)|`Medium.sql` (`BY DEFAULT`)|
|---|---|---|
|Manual id supplied|Rejected|Accepted|
|Why|New app table, database is the single source of truth|Every table in a seed/migration-style schema|
|Data type|`BIGINT`|`INTEGER`|

**When to Use**

- `ALWAYS` for tables the app itself owns and always inserts into fresh
- `BY DEFAULT` when I know I'll be seeding or restoring rows with known ids, like the entire `Medium.sql` schema
- UUID instead of a sequence when ids need to be unpredictable or generated client-side before insert

**When to Avoid**

- Don't default to UUID everywhere out of habit — it's a bigger, non-sequential key, worse for index locality than `BIGINT IDENTITY` when I don't actually need the unpredictability
- Don't compute a "next id" in application code — that's exactly the race condition identity/sequences exist to remove

---

### Constraints & Indexes

**Problem Statement**

A column type alone doesn't stop bad values (`-500` surface area, an unrecognized continent name), and a primary key alone doesn't stop slow lookups on other frequently-queried columns.

**How It Works**

`CHECK` constraints enforce a rule on every row at write time. Indexes speed up lookups/uniqueness on non-PK columns; `UNIQUE INDEX` does both at once.

**Example — CHECK as an enum substitute** (`intermedia_part/adding_constrains.sql`)

```sql
SELECT DISTINCT continent FROM country;

ALTER TABLE country ADD CHECK (
    continent IN (
        'Asia','South America','North America','Oceania',
        'Antarctica','Africa','Europe','Central America'
    )
);
```

**Example — CHECK for numeric ranges** (`check_values.sql`, `55-llaves-checks.sql`)

```sql
ALTER TABLE country ADD CHECK (surfacearea >= 0);

ALTER TABLE countrylanguage ADD CHECK (
    (percentage >= 0) AND (percentage <= 100)
);
```

**Example — unique and composite indexes** (`adding_index.sql`, `compositeIndex.sql`, `Medium.sql`)

```sql
CREATE UNIQUE INDEX "idx_country_name" ON country(name);
CREATE INDEX "idx_country_continent" ON country(continent);

CREATE UNIQUE INDEX "uidx_name_countrycode_district"
    ON city (name, countrycode, district);

-- Medium.sql: a "claps" table where a user can only clap once per post
CREATE UNIQUE INDEX ON "claps" ("post_id", "user_id");
```

**Comparison**

||`CHECK`|`INDEX`|`UNIQUE INDEX`|
|---|---|---|---|
|Enforces a rule|Yes|No|Yes (uniqueness)|
|Speeds up lookups|No|Yes|Yes|
|Typical use|Enum-like values, ranges|Frequently filtered columns|Natural-key uniqueness that isn't the PK|

**When to Use**

- `CHECK` for any invariant the database can enforce cheaply instead of trusting application code (percentages, non-negative values)
- Composite unique index when uniqueness is a natural business rule but not the table's actual primary key (`claps`: one clap-row per user per post)

**When to Avoid**

- Don't `CHECK` against a hardcoded list that changes often (continents rarely change; a "status" list for a fast-moving app might) — a lookup table with a `FOREIGN KEY` scales better than editing a `CHECK` constraint every time a value is added

---

### Foreign Key & Relationships

**Problem Statement**

Data is rarely self-contained: a language belongs to a country, an employee belongs to a department. Without an enforced link, nothing stops a row from pointing at an id that doesn't exist.

**How It Works**

A **foreign key** is a column that must match a primary key value in another table (or be `NULL`). `ON DELETE`/`ON UPDATE` decide what happens to the dependent row when the referenced row changes.

**Example — full cascade chain** (`date_time/01-estructura.sql`)

```sql
CREATE TABLE countries (
    country_id CHAR(2) PRIMARY KEY,
    country_name VARCHAR(40),
    region_id INT NOT NULL,
    FOREIGN KEY (region_id) REFERENCES regions (region_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    ...
    manager_id INT DEFAULT NULL,
    department_id INT DEFAULT NULL,
    FOREIGN KEY (department_id) REFERENCES departments (department_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (manager_id) REFERENCES employees (employee_id)
);
```

`manager_id` references `employees` itself — a self-referencing FK for the reporting hierarchy.

**Example — adding an FK to an existing table** (`creating_foreign_keys.sql`)

```sql
ALTER TABLE countrylanguage
ADD CONSTRAINT fk_country_code
FOREIGN KEY (countrycode) REFERENCES country(code)
ON DELETE CASCADE;
-- delete a country -> every countrylanguage row referencing it is deleted too
```

**Example — migrating a plain text column into a real FK relationship** — this is the full pattern I actually used to turn `country.continent` (free text) into a proper foreign key:

```sql
CREATE TABLE continent (
    code BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name TEXT NOT NULL
);

-- preview the mapping before touching data
SELECT a.name, a.continent,
       (SELECT code FROM continent b WHERE b.name = a.continent)
FROM country a;

-- retype the column, backfill, then constrain
ALTER TABLE country ALTER COLUMN continent TYPE int8 USING continent::integer;

UPDATE country a
SET continent = (SELECT code FROM continent b WHERE b.name = a.continent);

ALTER TABLE country
ADD CONSTRAINT fk_continent
FOREIGN KEY (continent) REFERENCES continent(code);
```

**Example — deferrable FK** (`Medium.sql`) — postpones the constraint check to the end of the transaction, useful when insert order between mutually dependent tables isn't guaranteed:

```sql
ALTER TABLE "post" ADD FOREIGN KEY ("owner_id")
    REFERENCES "users" ("user_id") DEFERRABLE INITIALLY IMMEDIATE;
```

**When to Use**

- Any time a row's meaning depends on another row existing
- `ON DELETE CASCADE` when the dependent rows genuinely have no reason to exist without the parent (`countrylanguage` without its `country`)
- Self-referencing FKs for hierarchies (`manager_id`)

**When to Avoid**

- Don't reach for `CASCADE` reflexively — for something like `orders.customer_id`, cascading a delete could silently wipe financial history; `ON DELETE RESTRICT` (the default) or a soft-delete flag is often safer

---

### Altering Tables

**Problem Statement**

A schema is never final. Columns get added, types get corrected, and constraints get dropped and reapplied as data and requirements evolve.

**How It Works**

`ALTER TABLE` covers adding/dropping columns, changing a column's type (with `USING` to tell Postgres how to cast existing data), and adding/dropping constraints — all without recreating the table.

**Example — add columns, then backfill with a function** (`creating_new_columns.sql`)

```sql
ALTER TABLE users
ADD COLUMN IF NOT EXISTS first_name VARCHAR(12),
ADD COLUMN IF NOT EXISTS last_name VARCHAR(12);

UPDATE users
SET first_name = SUBSTRING(name, 1, POSITION(' ' IN name) - 1),
    last_name  = SUBSTRING(name, 0, POSITION(' ' IN name) + 1);
```

**Example — change a column's type safely** (`changing_type.sql`, `68-language-table.sql`)

```sql
ALTER TABLE country
ALTER COLUMN continent TYPE int8
USING continent::integer;
```

`USING` is required whenever Postgres can't implicitly cast the existing values (text → integer here) — without it, the statement is rejected.

**Example — set a column's default after creation** (`ids/alter_column.sql`)

```sql
ALTER TABLE transformers
ALTER COLUMN id SET DEFAULT gen_random_uuid()::uuid;
```

**Example — drop a constraint that's no longer valid** (`intermedia_part2/drop_constrain.sql`)

```sql
ALTER TABLE country DROP CONSTRAINT country_continent_check;
```

**When to Use**

- Any schema evolution on a table that already has data — adding/removing columns, correcting a type, retiring a constraint made obsolete by a migration (like the `continent` CHECK becoming an FK)

**When to Avoid**

- Don't change a column's type without `USING` and without first checking what the cast will do to existing values — run the `SELECT` preview (like the `continent` migration above) before the `ALTER`

---

## Views — Composition vs. Tables

### CREATE VIEW

**Problem Statement**

Some queries get reused constantly — my `official languages per continent` join, for instance. Copy-pasting the same `SELECT` everywhere means every schema change has to be hunted down in every copy.

**How It Works**

A `VIEW` stores a **query**, not data — every `SELECT` against it re-runs the underlying query against live data. Not present in my repo yet, but it slots directly onto my existing `country`/`continent`/`countrylanguage`/`language` schema.

**Example**

```sql
CREATE OR REPLACE VIEW v_official_languages AS
    SELECT DISTINCT d.name AS language, c.name AS continent
    FROM countrylanguage a
    INNER JOIN country b ON a.countrycode = b.code
    INNER JOIN continent c ON b.continent = c.code
    INNER JOIN "language" d ON d.code = a.languagecode
    WHERE a.isofficial IS TRUE;

-- used exactly like a table
SELECT * FROM v_official_languages WHERE continent = 'Europe';
```

**When to Use**

- A filtered/joined shape needed by name, repeatedly, across many queries (this four-table join is exactly that case)

**When to Avoid**

- Don't use a view purely for performance — it re-runs the query every time and caches nothing (that's a _materialized view_, a different concept)

---

### DROP VIEW

**Problem Statement**

A view that no longer matches how data is queried becomes dead weight, or a trap for someone assuming it's still accurate.

**How It Works**

`DROP VIEW` removes only the saved query definition — it never touches the base tables.

**Example**

```sql
DROP VIEW v_official_languages;
```

**When to Use**

- Cleaning up views made obsolete by a schema change — e.g., if `language`/`countrylanguage` gets restructured the way `continent` did

**When to Avoid**

- Don't drop a view without checking what still queries it — no FK-style safety net stops you

---

### Views vs. Tables vs. CTEs

**Problem Statement**

Three different ways to get a "table-shaped" result to query against — picking the wrong one wastes storage or duplicates logic.

**How It Works**

A **table** stores rows. A **view** stores a query, re-run every time. A **CTE** (`WITH x AS (...)`) is a view's temporary cousin, scoped to a single statement.

**Example — the same join as a CTE instead of a permanent view**

```sql
WITH official_languages AS (
    SELECT DISTINCT a.language, c.name AS continent
    FROM countrylanguage a
    INNER JOIN country b ON a.countrycode = b.code
    INNER JOIN continent c ON b.continent = c.code
    WHERE a.isofficial IS TRUE
)
SELECT continent, count(*) FROM official_languages GROUP BY continent;
```

**Comparison**

||Table|View|CTE|
|---|---|---|---|
|Stores data|Yes|No|No|
|Reusable across queries|Yes|Yes, by name|No, single statement only|
|Example from my schema|`country`, `continent`|`v_official_languages`|the `official_languages` block above|

**When to Use**

- Table: persistent entities (`country`, `continent`, `employees`)
- View: the same composed query needed by name, repeatedly
- CTE: breaking one complex query into readable steps — I already do this informally with subqueries in `multiple_joins.sql`

**When to Avoid**

- Don't reach for a permanent view when a CTE would do inside a single report query

---

## Data Manipulation

### INSERT INTO

**Problem Statement**

A newly created table is empty. Rows need a well-defined way to be added that specifies exactly which columns are set.

**How It Works**

`INSERT INTO table (columns...) VALUES (values...)` maps each listed column to the value in the same position.

**Example — multi-row insert** (`sqlCommands/insert.sql`)

```sql
INSERT INTO users (name, age)
VALUES ('samuel', 20), ('santiago', 16), ('sebastian', 16),
       ('francisco', 49), ('martha', 47);
```

**Example — inserting from a `SELECT` instead of literal values** (`giving_values_continent_table.sql`)

```sql
INSERT INTO language (name)
SELECT DISTINCT language FROM countrylanguage ORDER BY language ASC;
```

**When to Use**

- Always list target columns explicitly — immune to a later `ALTER TABLE` reordering columns
- `INSERT ... SELECT` when populating a new lookup table from existing data, exactly like building `language` out of `countrylanguage`

**When to Avoid**

- Don't omit the column list relying on positional order — fragile, breaks silently

---

### DELETE FROM

**Problem Statement**

Rows that are no longer valid need to be removed — precisely the rows matching a condition, and no others.

**How It Works**

`DELETE FROM table WHERE condition` removes matching rows. `RETURNING` gets the deleted row(s) back in the same statement.

**Example** (`sqlCommands/delete.sql`)

```sql
DELETE FROM users
WHERE id = 1;
```

**Example — delete the last row and return it** (`homeworks/01-tarea.sql`)

```sql
DELETE FROM users
WHERE id = (SELECT id FROM users ORDER BY id DESC LIMIT 1)
RETURNING *;
```

**Example — delete with a compound condition** (`delete_on_cascade.sql`)

```sql
DELETE FROM countrylanguage
WHERE countrycode = 'COL' AND language = 'Arawakan';
```

**When to Use**

- Any time specific, identifiable rows need to be permanently removed
- `RETURNING` when the caller needs to confirm/log exactly what was deleted, without a follow-up `SELECT`

**When to Avoid**

- Never run `DELETE FROM table` without `WHERE` unless clearing the whole table is genuinely intended — test the equivalent `SELECT ... WHERE` first

---

### UPDATE

**Problem Statement**

Existing rows change over time without needing to be deleted and reinserted.

**How It Works**

`UPDATE table SET column = value WHERE condition` modifies only matching rows.

**Example** (`sqlCommands/updateTable.sql`)

```sql
UPDATE users
SET email = 'samuel@gmail.com'
WHERE id = 1;
```

**Example — updating from a correlated subquery** (`updating_all.sql`)

```sql
UPDATE country a
SET continent = (SELECT code FROM continent b WHERE b.name = a.continent);
```

**When to Use**

- Modifying columns on a known, filtered set of rows — including backfilling a new FK column from a subquery, as above

**When to Avoid**

- Don't run `UPDATE` without confirming, via a matching `SELECT ... WHERE`, exactly how many rows it touches — same "every row" risk as `DELETE`

---

### TRUNCATE vs. DELETE vs. DROP

**Problem Statement**

"Empty this table" and "remove this table" are different operations with very different costs and reversibility.

**How It Works**

`DELETE` removes rows one at a time (can be filtered, is logged per-row). `TRUNCATE` empties the whole table at once (faster, but all-or-nothing). `DROP` removes the table definition itself.

**Example** (`sqlCommands/truncate.sql`, `sqlCommands/drop.sql`)

```sql
TRUNCATE TABLE users;

DROP TABLE users;
```

**Comparison**

||`DELETE`|`TRUNCATE`|`DROP`|
|---|---|---|---|
|Can filter with `WHERE`|Yes|No|N/A|
|Removes table structure|No|No|Yes|
|Typical use|Targeted row removal|Full reset, keep schema|Retiring a table entirely|

**When to Use**

- `TRUNCATE` for a full reset during dev/testing when the schema itself stays
- `DROP` only when the table is genuinely being retired

**When to Avoid**

- Don't `TRUNCATE` a table with `ON DELETE CASCADE` dependents without checking what else empties with it

---

### Backups & Schema Reset

**Problem Statement**

Destructive operations (retyping a column, dropping a constraint, wiping a schema) are safer with an escape hatch.

**How It Works**

A quick backup is just `INSERT INTO backup_table SELECT * FROM table`. A full schema reset drops and recreates the `public` schema.

**Example** (`intermedia_part2/backup.sql`, `drop_table_back_up.sql`, `tablas_designed/resent_database.sql`)

```sql
INSERT INTO countrylanguage_bk SELECT * FROM countrylanguage;
-- ... do the risky migration ...
DROP TABLE countrylanguage_bk;

-- nuke and rebuild the whole schema when starting a module over
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
```

**When to Use**

- Before any migration that retypes a column or restructures a relationship (I did this before the `continent`/`language` FK migrations)
- `DROP SCHEMA ... CASCADE` when practicing on a throwaway local database, not anywhere with real data

**When to Avoid**

- Don't treat a same-database backup table as a real backup for anything that matters — it lives in the same schema and dies with the same `DROP SCHEMA CASCADE`

---

## Querying & Filtering

### SELECT / WHERE

**Problem Statement**

Most of the time an application needs some rows and some columns, not the entire table.

**How It Works**

`SELECT columns FROM table WHERE condition` filters rows first, then returns the listed columns for survivors.

**Example** (`sqlCommands/select_by_keywords.sql`)

```sql
SELECT * FROM users
WHERE name LIKE 's%';
```

**Common Comparison Operators I use regularly**

|Operator|Meaning|Where I used it|
|---|---|---|
|`=`|Equals|`WHERE id = 1`|
|`>` / `<`|Greater/less than|`WHERE followers > 4600`|
|`BETWEEN a AND b`|Inclusive range|`WHERE followers BETWEEN 1000 AND 3000`|
|`LIKE`|Pattern match|`WHERE last_connection LIKE '221.%'`|
|`IN (a, b, c)`|Matches any in a list|`WHERE code IN (3, 5)`|
|`IS NULL`|Null check|`WHERE a.continent IS NULL`|

**When to Use**

- List explicit columns in production queries rather than `SELECT *`

**When to Avoid**

- Don't compare against `NULL` with `=` — use `IS NULL` (this is exactly how `right_outer_join.sql` finds continents with zero countries)

---

### LIKE Statements

**Problem Statement**

Sometimes the exact value isn't known, only a pattern — "starts with 221." or "starts with s".

**How It Works**

`%` matches zero or more characters, `_` matches exactly one.

**Example** (`select_by_keywords.sql`, `32-calentamiento.sql`)

```sql
-- name starts with 's'
WHERE name LIKE 's%';

-- last connection IP starts with '221.'
WHERE last_connection LIKE '221.%';
```

**When to Use**

- Partial/fuzzy text matching, prefix filters like the IP-range check above

**When to Avoid**

- A leading `%` can't use a standard B-tree index efficiently — fine at my current table sizes, worth revisiting on a large `users` table

---

### LIMIT and OFFSET

**Problem Statement**

A query might match thousands of rows when only a page's worth is needed.

**How It Works**

`LIMIT n` caps rows returned; `OFFSET n` skips the first `n` matches.

**Example** (`select_with_limit_offset.sql`)

```sql
SELECT * FROM users
LIMIT 2
OFFSET 2;
```

**Example — `LIMIT 1` to get a single "top" result** (`total_cities.sql`)

```sql
SELECT count(a.*) AS total_cities, b.name AS country
FROM city a
INNER JOIN country b ON a.countrycode = b.code
GROUP BY b.name
ORDER BY count(a.*) DESC
LIMIT 1;
```

**When to Use**

- Pagination, and — combined with `ORDER BY` — grabbing a single max/min-by-group row without a window function

**When to Avoid**

- `OFFSET` gets slower as it grows since the database still scans and discards skipped rows

---

### ORDER BY

**Problem Statement**

Rows come back in no guaranteed order unless one is explicitly requested.

**How It Works**

`ORDER BY column [ASC|DESC]`, multiple columns break ties in listed order.

**Example** (`between_example.sql`, `unions_basic.sql`)

```sql
SELECT first_name, last_name, country
FROM users
WHERE followers BETWEEN 1000 AND 3000
ORDER BY followers ASC;
```

**When to Use**

- Any query whose result order matters — pairing it with `LIMIT` for "top N" queries especially

**When to Avoid**

- Skip it on intermediate subqueries (like the inner `SELECT` in `multiple_joins.sql`) where only the final order matters

---

### DISTINCT

**Problem Statement**

The same value can repeat across many rows; sometimes only the unique set matters.

**How It Works**

`SELECT DISTINCT column` collapses duplicate rows in the result.

**Example** (`grouping_ordering/distinc.sql`)

```sql
SELECT DISTINCT country FROM users
ORDER BY country ASC;
```

**Example — DISTINCT across a join, feeding an outer aggregate** (`selecting_by_language.sql`)

```sql
SELECT DISTINCT d.name, c.name AS continent
FROM countrylanguage a
INNER JOIN country b ON a.countrycode = b.code
INNER JOIN continent c ON b.continent = c.code
INNER JOIN "language" d ON d.code = a.languagecode
WHERE a.isofficial IS TRUE;
```

**When to Use**

- Getting the unique set of values, or de-duplicating a many-to-many join before counting

**When to Avoid**

- Don't reach for `DISTINCT` to paper over a join that's producing unwanted row multiplication — worth checking whether the join condition itself is right first

---

### String Functions

**Problem Statement**

Raw column values sometimes need reshaping for display or for splitting into new columns.

**How It Works**

`UPPER`/`LOWER`/`LENGTH`/`CONCAT` transform values in the `SELECT` list; `SUBSTRING` + `POSITION` split a string on a delimiter.

**Example** (`transforming_strings.sql`)

```sql
SELECT
    name, id,
    UPPER(name)  AS upper_name,
    LOWER(name)  AS lower_name,
    LENGTH(name) AS length_name,
    CONCAT(id, ' ', name) AS concat_name
FROM users;
```

**Example — splitting a full name into first/last** (`creating_names_lastname.sql`)

```sql
SELECT
    name,
    SUBSTRING(name, 0, POSITION(' ' IN name)) AS first_name,
    SUBSTRING(name, POSITION(' ' IN name) + 1) AS last_name
FROM users
LIMIT 10;
```

**When to Use**

- Ad-hoc reshaping for a query result, or a one-time backfill of new columns (I used this exact pattern in `creating_new_columns.sql` to populate `first_name`/`last_name`)

**When to Avoid**

- Don't repeat the same `SUBSTRING(..., POSITION(...))` expression across `SELECT` and `GROUP BY` without double-checking it — Postgres won't let `GROUP BY` reference a `SELECT` alias, so the full expression has to be repeated (see `group_by_2.sql` below)

---

## Aggregation

### COUNT() and Aggregate Functions

**Problem Statement**

Some questions collapse many rows into one number — "how many users," "what's the average follower count."

**How It Works**

`COUNT(*)` counts rows; `COUNT(column)` counts non-null values. Other aggregates follow the same pattern.

**Example** (`grouping_ordering/added_functions.sql`)

```sql
SELECT
   count(*) AS total_users,
   min(followers) AS min_followers,
   max(followers) AS max_followers,
   round(avg(followers)) AS avg_followers
FROM users;
```

**When to Use**

- Any summary statistic, usually paired with `GROUP BY` below

**When to Avoid**

- Don't mix an aggregate and a plain column in the same `SELECT` without `GROUP BY` — Postgres rejects it as ambiguous

---

### GROUP BY

**Problem Statement**

A single `COUNT(*)` collapses the whole table. Usually what's needed is one number _per category_.

**How It Works**

`GROUP BY column` buckets rows sharing a value, then applies aggregates per bucket.

**Example — grouped with a WHERE filter first** (`group_by.sql`)

```sql
SELECT country, count(*) AS users_in_follower_range
FROM users
WHERE followers BETWEEN 2000 AND 3900
GROUP BY country
ORDER BY country ASC;
```

**Example — grouping by a computed expression** (`group_by_2.sql`)

```sql
SELECT count(*), SUBSTRING(email, POSITION('@' IN email) + 1) AS domain
FROM users
GROUP BY SUBSTRING(email, POSITION('@' IN email) + 1)
HAVING count(*) > 1
ORDER BY domain ASC;
```

Note the expression is repeated in `GROUP BY` rather than referencing the `domain` alias — Postgres evaluates `GROUP BY` before `SELECT` aliases exist.

**When to Use**

- Any per-category breakdown — counts by country, by email domain, by continent (`join_unions/aggregations.sql`)

**When to Avoid**

- Every non-aggregated column in `SELECT` must appear in `GROUP BY`, or it's an error

---

### HAVING

**Problem Statement**

`WHERE` filters rows before grouping. Filtering on the _result_ of an aggregate — "only countries with more than 100 users" — has to happen after grouping.

**How It Works**

`HAVING` is `WHERE` for aggregated groups, evaluated after `GROUP BY`.

**Example** (`grouping_ordering/having.sql`)

```sql
SELECT count(*) AS total, country
FROM users
GROUP BY country
HAVING count(*) BETWEEN 5 AND 9
ORDER BY count(*) DESC;
```

**When to Use**

- Filtering on the result of `count()`, `sum()`, `avg()` after grouping

**When to Avoid**

- Don't put raw-column conditions in `HAVING` — that belongs in `WHERE`, which runs first and is cheaper

---

## Date & Time

### Basic Date/Time Functions

**Problem Statement**

Reporting and auditing frequently need "now," or a specific piece of a timestamp (just the year, just the hour).

**How It Works**

`now()`, `CURRENT_DATE`, `CURRENT_TIME` return the current moment; `date_part('unit', value)` extracts a single field.

**Example** (`date_time/basic_functions.sql`)

```sql
SELECT
    now(),
    CURRENT_DATE AS current_date,
    CURRENT_TIME AS current_time,
    date_part('hours', now())  AS hours,
    date_part('minutes', now()) AS minutes,
    date_part('years', now())  AS years;
```

**When to Use**

- Timestamps on new rows, or extracting a single date component for grouping/reporting

**When to Avoid**

- Don't call `now()` multiple times expecting different values within the same statement — it's fixed for the duration of the transaction

---

### CASE WHEN for Bucketing

**Problem Statement**

Raw `hire_date` values aren't directly useful in a report — what's useful is a bucket like "1 to 3 years."

**How It Works**

`CASE WHEN condition THEN result ... ELSE fallback END` evaluates conditions top-to-bottom and returns the first match.

**Example** (`date_time/case_then.sql`)

```sql
SELECT first_name, last_name, hire_date,
    CASE
        WHEN hire_date > now() - INTERVAL '1 year' THEN '1 year or less'
        WHEN hire_date > now() - INTERVAL '3 year' THEN '1 to 3 years'
        WHEN hire_date > now() - INTERVAL '6 year' THEN '3 to 6 years'
        ELSE '6+ years'
    END AS seniority_range
FROM employees
ORDER BY hire_date DESC;
```

**When to Use**

- Turning a continuous value (a date, a number) into report-friendly categories

**When to Avoid**

- Order the `WHEN` branches carefully — since it stops at the first match, a looser condition placed too early silently swallows the stricter ones after it

---

### INTERVAL & AGE()

**Problem Statement**

"How long ago" is a common question that raw date subtraction doesn't answer cleanly in human units (years, not just days).

**How It Works**

`age(later_date, earlier_date)` returns an interval; `date_part('year', ...)` pulls the year count out of it.

**Example** (`date_time/interval.sql`)

```sql
SELECT hire_date,
    date_part('year', age(current_date, hire_date))::integer AS years_employed
FROM employees
ORDER BY hire_date DESC;
```

**When to Use**

- Computing tenure, age, or any "time since X" value as a clean integer

**When to Avoid**

- Don't subtract raw dates and divide by 365 for a "years" figure — `age()` handles leap years and calendar months correctly, manual division doesn't

---

### Filtering by Date Ranges

**Problem Statement**

Reports frequently need "everything after X" or "everything between X and Y."

**How It Works**

`DATE('YYYY-MM-DD')` builds a literal date; compare or `BETWEEN` it against a date column.

**Example** (`date_time/selecting_by_date.sql`)

```sql
SELECT * FROM employees
WHERE hire_date > DATE('1998-02-05')
ORDER BY hire_date ASC;

SELECT max(hire_date) AS newest_hire, min(hire_date) AS oldest_hire
FROM employees;

SELECT * FROM employees
WHERE hire_date BETWEEN DATE('1995-02-05') AND DATE('2000-02-05')
ORDER BY hire_date ASC;
```

**When to Use**

- Any report scoped to a specific time window

**When to Avoid**

- `BETWEEN` on `TIMESTAMP` (not `DATE`) columns needs care — `BETWEEN '2024-01-01' AND '2024-01-31'` silently excludes anything after midnight on the 31st

---

## Combining Tables & Result Sets

### JOIN Types

**Problem Statement**

Related data lives in separate tables by design — a query needing both a country's name and its continent has to bring the two back together at query time.

**How It Works**

A `JOIN` combines rows based on a matching condition. Different types decide what happens to unmatched rows on either side.

**Example — INNER JOIN** (`join_unions/inner_join.sql`)

```sql
SELECT a.name AS country, b.name AS continent
FROM country a
INNER JOIN continent b ON a.continent = b.code
ORDER BY b.name ASC;
```

**Example — the old comma-join, functionally equivalent, avoided going forward** (`joins_where.sql`)

```sql
SELECT a.name AS country, b.name AS continent
FROM country a, continent b
WHERE a.continent = b.code
ORDER BY b.name ASC;
```

**Example — FULL OUTER JOIN** (`full_outer.sql`)

```sql
SELECT a.name AS country, a.continent AS continent_code, b.name AS continent_name
FROM country a
FULL OUTER JOIN continent b ON a.continent = b.code;
```

**Example — RIGHT OUTER JOIN used specifically to find orphans** (`right_outer_join.sql`)

```sql
SELECT a.name AS country, b.name AS continent
FROM country a
RIGHT OUTER JOIN continent b ON a.continent = b.code
WHERE a.continent IS NULL;
-- continents with zero countries pointing at them
```

**Example — multiple joins feeding a subquery, then grouped** (`multiple_joins.sql`)

```sql
SELECT count(*) AS number_languages, continent
FROM (
    SELECT DISTINCT a.language, c.name AS continent
    FROM countrylanguage a
    INNER JOIN country b ON a.countrycode = b.code
    INNER JOIN continent c ON b.continent = c.code
    WHERE a.isofficial IS TRUE
) AS totales
GROUP BY continent
ORDER BY count(*) ASC;
```

**Join Type Reference**

|Join|Includes|Used for, in my schema|
|---|---|---|
|`INNER JOIN`|Only matched rows both sides|Country ↔ continent, always expected to match|
|`FULL OUTER JOIN`|All rows both sides|Auditing — see every country and every continent regardless of match|
|`RIGHT OUTER JOIN` + `IS NULL`|Right-side rows with no left match|Finding continents with zero countries|

**When to Use**

- `INNER JOIN` by default when a match is required for the row to be meaningful
- `RIGHT`/`LEFT JOIN` + `IS NULL` specifically to find orphaned rows on one side

**When to Avoid**

- Avoid the comma-join style (`joins_where.sql`) going forward — `INNER JOIN ... ON` is the same result and much harder to write incorrectly by forgetting the `WHERE` filter

---

### UNION / UNION ALL

**Problem Statement**

A `JOIN` combines tables side by side. Sometimes two result sets need to be stacked on top of each other instead.

**How It Works**

`UNION` stacks rows from compatible `SELECT`s and removes exact duplicates; `UNION ALL` keeps duplicates and skips the dedup pass.

**Example** (`unions_basic.sql`)

```sql
SELECT code, name FROM continent WHERE name LIKE '%America%'
UNION
SELECT code, name FROM continent WHERE code IN (3, 5)
ORDER BY code ASC;
```

**Example — real use case: splitting a grouped count into one custom bucket vs. everything else** (`81-tarea-generar-tabla.sql`) — the pattern for when a single `GROUP BY` can't express the bucketing needed:

```sql
SELECT count(a.*) AS number_countries, b.name AS continent
FROM country a
INNER JOIN continent b ON a.continent = b.code
WHERE b.name NOT LIKE '%America%'
GROUP BY b.name
UNION
SELECT count(a.*) AS total, 'America'
FROM country a
INNER JOIN continent b ON a.continent = b.code
WHERE b.name LIKE '%America%';
```

**When to Use**

- Combining rows from structurally similar queries — here, "every continent except the Americas, grouped" plus "the Americas, collapsed into one row"

**When to Avoid**

- Don't default to `UNION` when duplicates are known to be impossible — `UNION ALL` skips the unnecessary dedup pass

---

### INTERSECT and EXCEPT

**Problem Statement**

Beyond stacking result sets, some questions ask about the relationship _between_ them — which rows appear in both, or in one but not the other.

**How It Works**

`INTERSECT` returns rows present in both sets; `EXCEPT` returns rows in the first but not the second.

**Example — against my own schema**

```sql
-- countries that have at least one language recorded
SELECT code FROM country
INTERSECT
SELECT countrycode FROM countrylanguage;

-- countries with no language recorded at all
SELECT code FROM country
EXCEPT
SELECT countrycode FROM countrylanguage;
```

**When to Use**

- Comparing membership across two sets defined by separate queries — this is effectively the same "orphan-finding" question the `RIGHT OUTER JOIN ... IS NULL` example answers, just phrased as set logic instead of a join

**When to Avoid**

- For large tables, an equivalent `JOIN`/`WHERE NOT EXISTS` sometimes gets a better execution plan — worth comparing against the `RIGHT JOIN` version above if performance matters

---

## Putting It Together — Modern PostgreSQL Style

### The Full Lifecycle of a Schema

**Problem Statement**

Every topic above is one piece of a schema. It helps to see how they stack together in the order a real migration actually uses them — this is literally the order I built the `continent`/`country`/`countrylanguage`/`language` relationship in.

**How It Works**

```
CREATE TABLE (continent, language)  → new lookup tables, IDENTITY/SEQUENCE-backed PKs
ALTER COLUMN ... TYPE ... USING     → retype the old text column to match the new FK type
UPDATE ... SET col = (SELECT ...)   → backfill using a correlated subquery
ALTER TABLE ADD CONSTRAINT FK       → lock in the relationship once data is clean
SELECT / JOIN                       → the application reads it back, combined
GROUP BY / HAVING                   → raw rows summarized into reporting numbers
```

Each layer only works because the one before it was done correctly: the FK constraint could only be added because the backfill `UPDATE` had already replaced every text value with a valid `continent.code`.

**When to Use**

- As a checklist any time a "just text" column needs to become a real relationship: new table → preview mapping → retype → backfill → constrain

**When to Avoid**

- Don't add the FK constraint before the backfill `UPDATE` runs — it will fail the moment it hits a value that doesn't yet have a matching row

---

### SERIAL vs. IDENTITY

**Problem Statement**

Different parts of my own repo use different auto-increment styles — worth being explicit about which is intentional.

**How It Works**

`SERIAL` is Postgres-specific shorthand around a sequence + default. `GENERATED ... AS IDENTITY` is the SQL-standard replacement with explicit `ALWAYS`/`BY DEFAULT` control. A raw `SEQUENCE` + manual `DEFAULT nextval(...)` is a third, more manual option.

**Example — all three, as they actually appear across my project**

```sql
-- IDENTITY (sqlCommands/create.sql)
id BIGINT generated always as identity primary key

-- Manual sequence (intermedia_part2/68-language-table.sql)
CREATE SEQUENCE IF NOT EXISTS language_code_seq;
"code" int4 NOT NULL DEFAULT nextval('language_code_seq'::regclass)

-- UUID, no sequence at all (ids/identity.sql)
id uuid DEFAULT gen_random_uuid() PRIMARY KEY
```

**Comparison**

||`IDENTITY`|Manual `SEQUENCE`|`UUID`|
|---|---|---|---|
|Standard|SQL standard|Postgres-specific, more control|Not sequential|
|Control over start/name|Less direct|Full — own the sequence object|N/A|
|Used where|New app tables (`users`)|A lookup table built via migration (`language`)|Alternate PK style (`transformers2`)|

**When to Use**

- `IDENTITY` as the default for new tables
- A manual `SEQUENCE` when the sequence itself needs to be referenced or reset independently

**When to Avoid**

- Don't mix styles within the same table without a reason — pick one PK strategy per table and stay consistent

---

### A Complete Modern Table Definition

**Problem Statement**

Seeing each constraint in isolation is useful, but a real schema combines all of them — this is the closest thing in my repo to a finished, production-shaped schema.

**How It Works**

`Medium.sql` composes identity PKs, unique constraints, defaults, and deferrable foreign keys across six related tables in one script.

**Example** (`tablas_designed/Medium.sql`, abridged)

```sql
CREATE TABLE "users" (
  "user_id" INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  "username" varchar(50) UNIQUE NOT NULL,
  "email" varchar UNIQUE NOT NULL,
  "created_at" timestamp DEFAULT 'now()'
);

CREATE TABLE "post" (
  "post_id" INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  "slug" varchar UNIQUE NOT NULL,
  "owner_id" integer
);

CREATE TABLE "claps" (
  "clap_id" INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  "post_id" integer,
  "user_id" integer,
  "counter" integer DEFAULT 0
);

CREATE UNIQUE INDEX ON "claps" ("post_id", "user_id");

ALTER TABLE "post" ADD FOREIGN KEY ("owner_id")
    REFERENCES "users" ("user_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "claps" ADD FOREIGN KEY ("post_id")
    REFERENCES "post" ("post_id") DEFERRABLE INITIALLY IMMEDIATE;
```

**When to Use**

- As the reference shape for any new multi-table feature: `IDENTITY` PK, `UNIQUE` on natural keys (`username`, `slug`), a composite unique index for join-table-style rules (`claps`), deferrable FKs everywhere

**When to Avoid**

- Don't skip straight to writing queries against a schema that hasn't nailed down its identity/constraint story first — cheaper to fix at `CREATE TABLE` time than after data exists

---

## Final Summary Table

|Concept|Purpose|My example|
|---|---|---|
|`CREATE TABLE`|Define column shape and constraints|`sqlCommands/create.sql`|
|Primary Key|Guarantee a unique, non-null row identifier|`ids/alter_table.sql` (composite)|
|`GENERATED ... AS IDENTITY`|Auto-generate unique IDs|`sqlCommands/create.sql`, `Medium.sql`|
|`CHECK` / Indexes|Enforce rules and speed up lookups|`adding_constrains.sql`, `compositeIndex.sql`|
|Foreign Key|Enforce a valid link between tables|`creating_foreign_keys.sql`, the `continent` migration|
|`ALTER TABLE`|Evolve a schema that already has data|`changing_type.sql`, `creating_new_columns.sql`|
|`VIEW` / CTE|Reusable or single-query named composition|`v_official_languages` (constructed)|
|`INSERT` / `DELETE` / `UPDATE`|Add, remove, modify rows|`insert.sql`, `01-tarea.sql` (`RETURNING`)|
|`SELECT` / `WHERE` / `LIKE`|Choose columns and filter rows|`select_by_keywords.sql`|
|`LIMIT` / `OFFSET` / `ORDER BY` / `DISTINCT`|Paginate, sort, de-duplicate|`select_with_limit_offset.sql`, `distinc.sql`|
|`COUNT` / `GROUP BY` / `HAVING`|Summarize rows into per-group statistics|`group_by_2.sql`, `having.sql`|
|Date/Time functions|Extract, bucket, and range-filter dates|`case_then.sql`, `interval.sql`|
|`JOIN`|Combine tables side by side|`inner_join.sql`, `multiple_joins.sql`|
|`UNION` / `INTERSECT` / `EXCEPT`|Combine or compare result sets|`81-tarea-generar-tabla.sql`|

---

**Source repository:** `shinji585/devops-pipelines` **Last Updated:** August 27, 2026 **Version:** 2.0
