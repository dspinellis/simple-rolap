--
-- Maintain table creation times for PostreSQL
-- This allows multiple people to collaborate on
-- the same database, without recreating already
-- created tables.
--
-- See https://stackoverflow.com/a/52368225/20520
--

DROP TABLE IF EXISTS t_create_history CASCADE;
CREATE TABLE t_create_history (
    gid serial primary key,
    object_type varchar(20),
    schema_name varchar(50),
    object_identity varchar(200),
    creation_date timestamp without time zone 
    );


--delete event trigger before dropping function
DROP EVENT TRIGGER IF EXISTS t_create_history_trigger;

--create history function
DROP FUNCTION IF EXISTS public.t_create_history_func();

CREATE OR REPLACE FUNCTION t_create_history_func()
RETURNS event_trigger
LANGUAGE plpgsql
AS $$
DECLARE
    obj record;
BEGIN
    FOR obj IN SELECT * FROM pg_event_trigger_ddl_commands  () WHERE command_tag in ('SELECT INTO','CREATE TABLE','CREATE TABLE AS')
    LOOP
        UPDATE public.t_create_history SET creation_date = (SELECT CURRENT_TIMESTAMP AT TIME ZONE 'UTC')
	WHERE
	  object_type = obj.object_type AND
	  schema_name = obj.schema_name AND
	  object_identity = obj.object_identity;
	IF NOT found THEN
          INSERT INTO public.t_create_history (object_type, schema_name, object_identity, creation_date) SELECT obj.object_type, obj.schema_name, obj.object_identity, (SELECT CURRENT_TIMESTAMP AT TIME ZONE 'UTC');
	END IF;
    END LOOP;

    FOR obj IN SELECT * FROM pg_event_trigger_ddl_commands  () WHERE command_tag = 'DROP TABLE'
    LOOP
        DELETE FROM public.t_create_history
	WHERE
	  object_type = obj.object_type AND
	  schema_name = obj.schema_name AND
	  object_identity = obj.object_identity;
    END LOOP;
END;
$$;

--ALTER EVENT TRIGGER t_create_history_trigger DISABLE;
--DROP EVENT TRIGGER t_create_history_trigger;

CREATE EVENT TRIGGER t_create_history_trigger ON ddl_command_end
WHEN TAG IN ('SELECT INTO','CREATE TABLE','CREATE TABLE AS')
EXECUTE PROCEDURE t_create_history_func();
