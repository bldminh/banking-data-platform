/* ============================================================
   PROJECT 01 - BANKING DATABASE DESIGN
   CHAPTER 14 - AUDIT DATA MODEL
   FILE 05 - AUDIT TRIGGER FRAMEWORK
   ============================================================ */


/*
   IMPORTANT

   Chapter 14 focuses on the audit data model.

   Automatic triggers on core banking tables will be enabled
   only after verifying the exact physical schema from
   Project 1 - Round 1.

   Do NOT attach generic triggers blindly to every table.
*/


/* ============================================================
   OPTIONAL FUTURE TRIGGER FUNCTION
   ============================================================ */

CREATE OR REPLACE FUNCTION audit.set_audit_context
(
    p_actor_type VARCHAR,
    p_actor_id VARCHAR,
    p_source_system VARCHAR,
    p_channel VARCHAR,
    p_request_id VARCHAR,
    p_correlation_id VARCHAR
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN

    PERFORM set_config(
        'audit.actor_type',
        COALESCE(p_actor_type, 'UNKNOWN'),
        TRUE
    );

    PERFORM set_config(
        'audit.actor_id',
        COALESCE(p_actor_id, ''),
        TRUE
    );

    PERFORM set_config(
        'audit.source_system',
        COALESCE(p_source_system, ''),
        TRUE
    );

    PERFORM set_config(
        'audit.channel',
        COALESCE(p_channel, ''),
        TRUE
    );

    PERFORM set_config(
        'audit.request_id',
        COALESCE(p_request_id, ''),
        TRUE
    );

    PERFORM set_config(
        'audit.correlation_id',
        COALESCE(p_correlation_id, ''),
        TRUE
    );

END;
$$;