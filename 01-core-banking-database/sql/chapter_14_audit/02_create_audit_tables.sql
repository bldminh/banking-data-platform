/* ============================================================
   PROJECT 01 - BANKING DATABASE DESIGN
   CHAPTER 14 - AUDIT DATA MODEL
   FILE 02 - CREATE AUDIT TABLES
   ============================================================ */


/* ============================================================
   1. AUDIT EVENT
   ------------------------------------------------------------
   Event-level audit record.

   Answers:
   - Who?
   - What?
   - When?
   - Which entity?
   - From where?
   - Which request?
   - Which correlation?
   - Success / failure / denied?
   ============================================================ */

CREATE TABLE IF NOT EXISTS audit.audit_event
(
    audit_event_id BIGINT GENERATED ALWAYS AS IDENTITY,

    event_time TIMESTAMPTZ NOT NULL
        DEFAULT CURRENT_TIMESTAMP,

    actor_type VARCHAR(30) NOT NULL,

    actor_id VARCHAR(100),

    action VARCHAR(50) NOT NULL,

    event_type VARCHAR(100) NOT NULL,

    entity_schema VARCHAR(63) NOT NULL,

    entity_table VARCHAR(63) NOT NULL,

    entity_id VARCHAR(100) NOT NULL,

    source_system VARCHAR(100),

    channel VARCHAR(50),

    request_id VARCHAR(100),

    correlation_id VARCHAR(100),

    session_id VARCHAR(100),

    business_transaction_id VARCHAR(100),

    outcome VARCHAR(20) NOT NULL
        DEFAULT 'SUCCESS',

    reason_code VARCHAR(100),

    ip_address INET,

    user_agent TEXT,

    metadata JSONB,

    created_at TIMESTAMPTZ NOT NULL
        DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_audit_event
        PRIMARY KEY (audit_event_id, event_time),

    CONSTRAINT chk_audit_actor_type
        CHECK (
            actor_type IN
            (
                'USER',
                'EMPLOYEE',
                'SYSTEM',
                'SERVICE',
                'BATCH',
                'API',
                'CUSTOMER',
                'UNKNOWN'
            )
        ),

    CONSTRAINT chk_audit_outcome
        CHECK (
            outcome IN
            (
                'SUCCESS',
                'FAILURE',
                'DENIED'
            )
        )
)
PARTITION BY RANGE (event_time);


/* ============================================================
   2. AUDIT CHANGE
   ------------------------------------------------------------
   Field-level change history.

   One audit_event can have multiple audit_change records.

   Example:

       audit_event
           |
           +-- status
           |     ACTIVE -> BLOCKED
           |
           +-- daily_limit
                 50M -> 30M
   ============================================================ */

CREATE TABLE IF NOT EXISTS audit.audit_change
(
    audit_change_id BIGINT GENERATED ALWAYS AS IDENTITY,

    audit_event_id BIGINT NOT NULL,

    audit_event_time TIMESTAMPTZ NOT NULL,

    column_name VARCHAR(63) NOT NULL,

    old_value JSONB,

    new_value JSONB,

    data_type VARCHAR(50),

    change_type VARCHAR(20) NOT NULL,

    created_at TIMESTAMPTZ NOT NULL
        DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_audit_change
        PRIMARY KEY (audit_change_id),

    CONSTRAINT fk_audit_change_event
        FOREIGN KEY
        (
            audit_event_id,
            audit_event_time
        )
        REFERENCES audit.audit_event
        (
            audit_event_id,
            event_time
        )
        ON DELETE RESTRICT,

    CONSTRAINT chk_audit_change_type
        CHECK (
            change_type IN
            (
                'ADDED',
                'MODIFIED',
                'REMOVED'
            )
        )
);