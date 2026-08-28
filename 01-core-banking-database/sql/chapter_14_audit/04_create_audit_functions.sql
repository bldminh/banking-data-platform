/* ============================================================
   PROJECT 01 - BANKING DATABASE DESIGN
   CHAPTER 14 - AUDIT DATA MODEL
   FILE 04 - AUDIT FUNCTIONS
   ============================================================ */


/* ============================================================
   FUNCTION: CREATE AUDIT EVENT
   ============================================================ */

CREATE OR REPLACE FUNCTION audit.create_audit_event
(
    p_event_time TIMESTAMPTZ,
    p_actor_type VARCHAR(30),
    p_actor_id VARCHAR(100),
    p_action VARCHAR(50),
    p_event_type VARCHAR(100),
    p_entity_schema VARCHAR(63),
    p_entity_table VARCHAR(63),
    p_entity_id VARCHAR(100),
    p_source_system VARCHAR(100),
    p_channel VARCHAR(50),
    p_request_id VARCHAR(100),
    p_correlation_id VARCHAR(100),
    p_session_id VARCHAR(100),
    p_business_transaction_id VARCHAR(100),
    p_outcome VARCHAR(20),
    p_reason_code VARCHAR(100),
    p_ip_address INET,
    p_user_agent TEXT,
    p_metadata JSONB
)
RETURNS TABLE
(
    audit_event_id BIGINT,
    audit_event_time TIMESTAMPTZ
)
LANGUAGE plpgsql
AS $$
BEGIN

    RETURN QUERY

    INSERT INTO audit.audit_event
    (
        event_time,
        actor_type,
        actor_id,
        action,
        event_type,
        entity_schema,
        entity_table,
        entity_id,
        source_system,
        channel,
        request_id,
        correlation_id,
        session_id,
        business_transaction_id,
        outcome,
        reason_code,
        ip_address,
        user_agent,
        metadata
    )
    VALUES
    (
        COALESCE(p_event_time, CURRENT_TIMESTAMP),
        p_actor_type,
        p_actor_id,
        p_action,
        p_event_type,
        p_entity_schema,
        p_entity_table,
        p_entity_id,
        p_source_system,
        p_channel,
        p_request_id,
        p_correlation_id,
        p_session_id,
        p_business_transaction_id,
        COALESCE(p_outcome, 'SUCCESS'),
        p_reason_code,
        p_ip_address,
        p_user_agent,
        p_metadata
    )
    RETURNING
        audit_event.audit_event_id,
        audit_event.event_time;

END;
$$;


/* ============================================================
   FUNCTION: CREATE AUDIT CHANGE
   ============================================================ */

CREATE OR REPLACE FUNCTION audit.create_audit_change
(
    p_audit_event_id BIGINT,
    p_audit_event_time TIMESTAMPTZ,
    p_column_name VARCHAR(63),
    p_old_value JSONB,
    p_new_value JSONB,
    p_data_type VARCHAR(50),
    p_change_type VARCHAR(20)
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_audit_change_id BIGINT;
BEGIN

    INSERT INTO audit.audit_change
    (
        audit_event_id,
        audit_event_time,
        column_name,
        old_value,
        new_value,
        data_type,
        change_type
    )
    VALUES
    (
        p_audit_event_id,
        p_audit_event_time,
        p_column_name,
        p_old_value,
        p_new_value,
        p_data_type,
        p_change_type
    )
    RETURNING audit_change.audit_change_id
    INTO v_audit_change_id;

    RETURN v_audit_change_id;

END;
$$;