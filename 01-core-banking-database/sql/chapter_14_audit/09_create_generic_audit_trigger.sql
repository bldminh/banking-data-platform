/* ============================================================
   PROJECT 01 - BANKING DATABASE DESIGN
   CHAPTER 14 - AUDIT DATA MODEL

   FILE 09
   GENERIC AUDIT TRIGGER FRAMEWORK

   PURPOSE
   ------------------------------------------------------------
   Capture INSERT / UPDATE / DELETE activity from Core Banking
   tables and store audit records in:

       audit.audit_event
       audit.audit_change

   This file creates reusable trigger functions only.

   Trigger attachment is performed separately by:

       10_attach_customer_audit.sql
       11_attach_account_audit.sql
       12_attach_card_audit.sql
       13_attach_loan_audit.sql
       14_attach_transaction_audit.sql

   ============================================================ */


/* ============================================================
   FUNCTION
   GET SESSION CONTEXT
   ============================================================ */

CREATE OR REPLACE FUNCTION audit.get_context_value
(
    p_key TEXT,
    p_default TEXT
)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
    v_value TEXT;
BEGIN

    BEGIN

        v_value :=
            current_setting(p_key, TRUE);

    EXCEPTION
        WHEN OTHERS THEN
            v_value := NULL;
    END;

    RETURN COALESCE(v_value, p_default);

END;
$$;


/* ============================================================
   FUNCTION
   WRITE FIELD LEVEL CHANGE
   ============================================================ */

CREATE OR REPLACE FUNCTION audit.write_column_change
(
    p_audit_event_id BIGINT,
    p_audit_event_time TIMESTAMPTZ,
    p_column_name TEXT,
    p_old_value JSONB,
    p_new_value JSONB
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE

    v_change_type VARCHAR(20);

BEGIN

    IF p_old_value IS NULL
       AND p_new_value IS NOT NULL
    THEN
        v_change_type := 'ADDED';

    ELSIF p_old_value IS NOT NULL
          AND p_new_value IS NULL
    THEN
        v_change_type := 'REMOVED';

    ELSE
        v_change_type := 'MODIFIED';
    END IF;

    PERFORM audit.create_audit_change
    (
        p_audit_event_id,
        p_audit_event_time,
        p_column_name,
        p_old_value,
        p_new_value,
        NULL,
        v_change_type
    );

END;
$$;


/* ============================================================
   FUNCTION
   GENERIC AUDIT TRIGGER

   ARGUMENTS

   TG_ARGV[0]
       entity_id column name

   Example

       customer_id
       account_id
       card_id
       loan_id
       transaction_id

   ============================================================ */

CREATE OR REPLACE FUNCTION audit.generic_audit_trigger()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE

    v_entity_id_column TEXT;

    v_entity_id TEXT;

    v_action VARCHAR(50);

    v_event_type VARCHAR(100);

    v_actor_type VARCHAR(30);

    v_actor_id VARCHAR(100);

    v_source_system VARCHAR(100);

    v_channel VARCHAR(50);

    v_request_id VARCHAR(100);

    v_correlation_id VARCHAR(100);

    v_audit_event_id BIGINT;

    v_audit_event_time TIMESTAMPTZ;

    v_old JSONB;

    v_new JSONB;

    v_key TEXT;

    v_old_value JSONB;

    v_new_value JSONB;

BEGIN

    /* --------------------------------------------------------
       GET ENTITY COLUMN
       -------------------------------------------------------- */

    v_entity_id_column := TG_ARGV[0];

    /* --------------------------------------------------------
       ACTION
       -------------------------------------------------------- */

    IF TG_OP = 'INSERT' THEN

        v_action := 'INSERT';

        v_event_type :=
            upper(TG_TABLE_NAME) || '_CREATED';

        EXECUTE format(
            'SELECT ($1).%I::TEXT',
            v_entity_id_column
        )
        INTO v_entity_id
        USING NEW;

    ELSIF TG_OP = 'UPDATE' THEN

        v_action := 'UPDATE';

        v_event_type :=
            upper(TG_TABLE_NAME) || '_UPDATED';

        EXECUTE format(
            'SELECT ($1).%I::TEXT',
            v_entity_id_column
        )
        INTO v_entity_id
        USING NEW;

    ELSIF TG_OP = 'DELETE' THEN

        v_action := 'DELETE';

        v_event_type :=
            upper(TG_TABLE_NAME) || '_DELETED';

        EXECUTE format(
            'SELECT ($1).%I::TEXT',
            v_entity_id_column
        )
        INTO v_entity_id
        USING OLD;

    END IF;

    /* --------------------------------------------------------
       CONTEXT
       -------------------------------------------------------- */

    v_actor_type :=
        audit.get_context_value(
            'audit.actor_type',
            'SYSTEM'
        );

    v_actor_id :=
        audit.get_context_value(
            'audit.actor_id',
            'UNKNOWN'
        );

    v_source_system :=
        audit.get_context_value(
            'audit.source_system',
            'POSTGRESQL'
        );

    v_channel :=
        audit.get_context_value(
            'audit.channel',
            'DATABASE'
        );

    v_request_id :=
        audit.get_context_value(
            'audit.request_id',
            NULL
        );

    v_correlation_id :=
        audit.get_context_value(
            'audit.correlation_id',
            NULL
        );

    /* --------------------------------------------------------
       CREATE AUDIT EVENT
       -------------------------------------------------------- */

    SELECT
        audit_event_id,
        audit_event_time
    INTO
        v_audit_event_id,
        v_audit_event_time
    FROM audit.create_audit_event
    (
        CURRENT_TIMESTAMP,
        v_actor_type,
        v_actor_id,
        v_action,
        v_event_type,
        TG_TABLE_SCHEMA,
        TG_TABLE_NAME,
        v_entity_id,
        v_source_system,
        v_channel,
        v_request_id,
        v_correlation_id,
        NULL,
        NULL,
        'SUCCESS',
        NULL,
        NULL,
        NULL,
        NULL
    );

    /* --------------------------------------------------------
       INSERT
       -------------------------------------------------------- */

    IF TG_OP = 'INSERT' THEN

        v_new := to_jsonb(NEW);

        FOR v_key IN
            SELECT jsonb_object_keys(v_new)
        LOOP

            v_new_value := v_new -> v_key;

            PERFORM audit.write_column_change
            (
                v_audit_event_id,
                v_audit_event_time,
                v_key,
                NULL,
                v_new_value
            );

        END LOOP;

        RETURN NEW;

    END IF;

    /* --------------------------------------------------------
       DELETE
       -------------------------------------------------------- */

    IF TG_OP = 'DELETE' THEN

        v_old := to_jsonb(OLD);

        FOR v_key IN
            SELECT jsonb_object_keys(v_old)
        LOOP

            v_old_value := v_old -> v_key;

            PERFORM audit.write_column_change
            (
                v_audit_event_id,
                v_audit_event_time,
                v_key,
                v_old_value,
                NULL
            );

        END LOOP;

        RETURN OLD;

    END IF;

    /* --------------------------------------------------------
       UPDATE
       -------------------------------------------------------- */

    IF TG_OP = 'UPDATE' THEN

        v_old := to_jsonb(OLD);

        v_new := to_jsonb(NEW);

        FOR v_key IN
            SELECT jsonb_object_keys(v_new)
        LOOP

            v_old_value := v_old -> v_key;
            v_new_value := v_new -> v_key;

            IF v_old_value IS DISTINCT FROM v_new_value THEN

                PERFORM audit.write_column_change
                (
                    v_audit_event_id,
                    v_audit_event_time,
                    v_key,
                    v_old_value,
                    v_new_value
                );

            END IF;

        END LOOP;

        RETURN NEW;

    END IF;

    RETURN NULL;

END;
$$;


/* ============================================================
   VALIDATION
   ============================================================ */

SELECT
    routine_schema,
    routine_name
FROM information_schema.routines
WHERE routine_schema = 'audit'
  AND routine_name IN
  (
      'get_context_value',
      'write_column_change',
      'generic_audit_trigger'
  )
ORDER BY routine_name;