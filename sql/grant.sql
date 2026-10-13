-- tables


SELECT *
FROM pg_tables
WHERE schemaname NOT IN ('pg_catalog', 'information_schema');


DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN
        SELECT schemaname, tablename
        FROM pg_tables
        WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
    LOOP
        EXECUTE format(
            'ALTER TABLE %I.%I OWNER TO c******',
            r.schemaname,
            r.tablename
        );
    END LOOP;
END $$;

-- sequences


DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN
        SELECT sequence_schema, sequence_name
        FROM information_schema.sequences
        WHERE sequence_schema NOT IN ('pg_catalog', 'information_schema')
    LOOP
        EXECUTE format(
            'ALTER SEQUENCE %I.%I OWNER TO c******',
            r.sequence_schema,
            r.sequence_name
        );
    END LOOP;
END $$;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN
        SELECT table_schema, table_name
        FROM information_schema.views
        WHERE table_schema NOT IN ('pg_catalog', 'information_schema')
    LOOP
        EXECUTE format(
            'ALTER VIEW %I.%I OWNER TO c******',
            r.table_schema,
            r.table_name
        );
    END LOOP;
END $$;

-- materialised views

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN
        SELECT schemaname, matviewname
        FROM pg_matviews
    LOOP
        EXECUTE format(
            'ALTER MATERIALIZED VIEW %I.%I OWNER TO c******',
            r.schemaname,
            r.matviewname
        );
    END LOOP;
END $$;

-- schema

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN
        SELECT schema_name
        FROM information_schema.schemata
        WHERE schema_name NOT IN ('pg_catalog', 'information_schema')
    LOOP
        EXECUTE format(
            'ALTER SCHEMA %I OWNER TO c******',
            r.schema_name
        );
    END LOOP;
END $$;



