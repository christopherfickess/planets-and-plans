-- 1) Create users
CREATE USER ${NEW_DB_USER} WITH PASSWORD '${NEW_DB_PASSWORD}' NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT;

-- 2) Restrict database connections
REVOKE CONNECT ON DATABASE ${PGDATABASE} FROM PUBLIC;
GRANT CONNECT ON DATABASE ${PGDATABASE} TO ${NEW_DB_USER};

-- 3) Connect to the DB
\c ${PGDATABASE}

-- 4) Lock down public schema
REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE CREATE ON SCHEMA public FROM PUBLIC;

-- 5) Create schema
CREATE SCHEMA IF NOT EXISTS ${NEW_DB_USER}_schema;
ALTER SCHEMA ${NEW_DB_USER}_schema OWNER TO ${NEW_DB_USER};

-- 6) Grant schema access
GRANT ALL ON SCHEMA ${NEW_DB_USER}_schema TO ${NEW_DB_USER};

-- 7) Ensure user cannot access other schemas (optional)
-- REVOKE ALL ON SCHEMA other_schema FROM ${NEW_DB_USER};

-- 8) Set default search_path
ALTER ROLE ${NEW_DB_USER} SET search_path = ${NEW_DB_USER}_schema;
