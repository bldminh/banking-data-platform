CREATE OR REPLACE FUNCTION audit.generic_audit_trigger()
RETURNS trigger
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

    v_entity_id_column := TG_ARGV[0];

    IF TG_OP = 'INSERT' THEN

        v_action := 'INSERT';
        v_event_type := upper(TG_TABLE_NAME) || '_CREATED';

        EXECUTE format(
            'SELECT ($1).%I::TEXT',
            v_entity_id_column
        )
        INTO v_entity_id
        USING NEW;

    ELSIF TG_OP = 'UPDATE' THEN

        v_action := 'UPDATE';
        v_event_type := upper(TG_TABLE_NAME) || '_UPDATED';

        EXECUTE format(
            'SELECT ($1).%I::TEXT',
            v_entity_id_column
        )
        INTO v_entity_id
        USING NEW;

    ELSIF TG_OP = 'DELETE' THEN

        v_action := 'DELETE';
        v_event_type := upper(TG_TABLE_NAME) || '_DELETED';

        EXECUTE format(
            'SELECT ($1).%I::TEXT',
            v_entity_id_column
        )
        INTO v_entity_id
        USING OLD;

    END IF;

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

        TG_TABLE_SCHEMA::varchar,
        TG_TABLE_NAME::varchar,

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

    IF TG_OP = 'INSERT' THEN

        v_new := to_jsonb(NEW);

        FOR v_key IN
            SELECT jsonb_object_keys(v_new)
        LOOP

            v_new_value :=
                audit.mask_audit_value(
                    v_key,
                    v_new -> v_key
                );

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

    IF TG_OP = 'DELETE' THEN

        v_old := to_jsonb(OLD);

        FOR v_key IN
            SELECT jsonb_object_keys(v_old)
        LOOP

            v_old_value :=
                audit.mask_audit_value(
                    v_key,
                    v_old -> v_key
                );

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

    IF TG_OP = 'UPDATE' THEN

        v_old := to_jsonb(OLD);
        v_new := to_jsonb(NEW);

        FOR v_key IN
            SELECT jsonb_object_keys(v_new)
        LOOP

            v_old_value :=
                audit.mask_audit_value(
                    v_key,
                    v_old -> v_key
                );

            v_new_value :=
                audit.mask_audit_value(
                    v_key,
                    v_new -> v_key
                );

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