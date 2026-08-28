/* ============================================================
   PROJECT 01 - BANKING DATABASE DESIGN
   CHAPTER 14 - AUDIT DATA MODEL
   FILE 03 - CREATE AUDIT INDEXES
   ============================================================ */


/* ============================================================
   AUDIT EVENT
   ============================================================ */


/* Query theo thời gian */

CREATE INDEX IF NOT EXISTS idx_audit_event_time
ON audit.audit_event
(
    event_time DESC
);


/* Query lịch sử của một entity */

CREATE INDEX IF NOT EXISTS idx_audit_event_entity
ON audit.audit_event
(
    entity_schema,
    entity_table,
    entity_id,
    event_time DESC
);


/* Query theo actor */

CREATE INDEX IF NOT EXISTS idx_audit_event_actor
ON audit.audit_event
(
    actor_type,
    actor_id,
    event_time DESC
);


/* Distributed tracing */

CREATE INDEX IF NOT EXISTS idx_audit_event_correlation
ON audit.audit_event
(
    correlation_id
);


/* API request tracing */

CREATE INDEX IF NOT EXISTS idx_audit_event_request
ON audit.audit_event
(
    request_id
);


/* Business transaction tracing */

CREATE INDEX IF NOT EXISTS idx_audit_event_business_transaction
ON audit.audit_event
(
    business_transaction_id
);


/* Query theo event type */

CREATE INDEX IF NOT EXISTS idx_audit_event_type
ON audit.audit_event
(
    event_type,
    event_time DESC
);


/* Query theo outcome */

CREATE INDEX IF NOT EXISTS idx_audit_event_outcome
ON audit.audit_event
(
    outcome,
    event_time DESC
);


/* ============================================================
   AUDIT CHANGE
   ============================================================ */


/* Join audit_event -> audit_change */

CREATE INDEX IF NOT EXISTS idx_audit_change_event
ON audit.audit_change
(
    audit_event_id,
    audit_event_time
);


/* Field-level audit investigation */

CREATE INDEX IF NOT EXISTS idx_audit_change_column
ON audit.audit_change
(
    column_name,
    created_at DESC
);