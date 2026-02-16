-- 1) Create users
CREATE USER mm_cloud WITH PASSWORD 'NFqxWBuGuxjbcAvK' NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT;

-- 2) Restrict database connections
REVOKE CONNECT ON DATABASE mattermost FROM PUBLIC;
GRANT CONNECT ON DATABASE mattermost TO mm_cloud;

-- 3) Connect to the DB
\c mattermost

-- 4) Lock down public schema
REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE CREATE ON SCHEMA public FROM PUBLIC;

-- 5) Create schema
CREATE SCHEMA IF NOT EXISTS mm_cloud_schema;
ALTER SCHEMA mm_cloud_schema OWNER TO mm_cloud;

-- 6) Grant schema access
GRANT ALL ON SCHEMA mm_cloud_schema TO mm_cloud;

-- 7) Ensure user cannot access other schemas (optional)
-- REVOKE ALL ON SCHEMA other_schema FROM mm_cloud;

-- 8) Set default search_path
ALTER ROLE mm_cloud SET search_path = mm_cloud_schema;
