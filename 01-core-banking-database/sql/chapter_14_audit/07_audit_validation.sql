/* ============================================================
   PROJECT 01 - BANKING DATABASE DESIGN
   CHAPTER 14 - AUDIT DATA MODEL
   FILE 07 - AUDIT VALIDATION
   ============================================================ */


/* ============================================================
   TEST 01
   Check schemas
   ============================================================ */

SELECT
    schema_name
FROM information_schema.schemata
WHERE schema_name = 'audit';


/* ============================================================
   TEST 02
   Check audit tables
   ============================================================ */

SELECT
    table_schema,
    table_name
FROM information_schema.tables
WHERE table_schema = 'audit'
ORDER BY table_name;


/* ============================================================
   TEST 03
   Count audit events
   ============================================================ */

SELECT
    COUNT(*) AS audit_event_count
FROM audit.audit_event;


/* ============================================================
   TEST 04
   Count audit changes
   ============================================================ */

SELECT
    COUNT(*) AS audit_change_count
FROM audit.audit_change;


/* ============================================================
   TEST 05
   Show audit events
   ============================================================ */

SELECT
    audit_event_id,
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
    outcome,
    reason_code
FROM audit.audit_event
ORDER BY event_time DESC;


/* ============================================================
   TEST 06
   Show field-level changes
   ============================================================ */

SELECT
    e.audit_event_id,
    e.event_time,
    e.event_type,
    e.entity_schema,
    e.entity_table,
    e.entity_id,
    c.column_name,
    c.old_value,
    c.new_value,
    c.change_type
FROM audit.audit_event e
JOIN audit.audit_change c
    ON c.audit_event_id = e.audit_event_id
   AND c.audit_event_time = e.event_time
ORDER BY e.event_time DESC;


/* ============================================================
   TEST 07
   Trace a specific entity
   ============================================================ */

SELECT
    audit_event_id,
    event_time,
    actor_type,
    actor_id,
    event_type,
    action,
    outcome,
    reason_code
FROM audit.audit_event
WHERE entity_schema = 'account'
  AND entity_table = 'account'
  AND entity_id = '1001'
ORDER BY event_time DESC;


/* ============================================================
   TEST 08
   Trace employee activity
   ============================================================ */

SELECT
    event_time,
    actor_type,
    actor_id,
    event_type,
    entity_schema,
    entity_table,
    entity_id,
    outcome
FROM audit.audit_event
WHERE actor_type = 'EMPLOYEE'
  AND actor_id = '1025'
ORDER BY event_time DESC;


/* ============================================================
   TEST 09
   Trace correlation
   ============================================================ */

SELECT
    event_time,
    event_type,
    entity_schema,
    entity_table,
    entity_id,
    source_system,
    outcome
FROM audit.audit_event
WHERE correlation_id = 'CORR-000001'
ORDER BY event_time;


/* ============================================================
   TEST 10
   Check denied events
   ============================================================ */

SELECT
    event_time,
    actor_type,
    actor_id,
    event_type,
    entity_table,
    entity_id,
    outcome,
    reason_code
FROM audit.audit_event
WHERE outcome = 'DENIED'
ORDER BY event_time DESC;


/* ============================================================
   TEST 11
   Check invalid outcomes
   ============================================================ */

SELECT *
FROM audit.audit_event
WHERE outcome NOT IN
(
    'SUCCESS',
    'FAILURE',
    'DENIED'
);


/* ============================================================
   TEST 12
   Check missing mandatory fields
   ============================================================ */

SELECT *
FROM audit.audit_event
WHERE event_time IS NULL
   OR actor_type IS NULL
   OR action IS NULL
   OR event_type IS NULL
   OR entity_schema IS NULL
   OR entity_table IS NULL
   OR entity_id IS NULL
   OR outcome IS NULL;


/* ============================================================
   TEST 13
   Check audit changes without parent event
   ============================================================ */

SELECT
    c.*
FROM audit.audit_change c
LEFT JOIN audit.audit_event e
    ON e.audit_event_id = c.audit_event_id
   AND e.event_time = c.audit_event_time
WHERE e.audit_event_id IS NULL;


/* ============================================================
   TEST 14
   Check modified changes
   ============================================================ */

SELECT *
FROM audit.audit_change
WHERE change_type = 'MODIFIED'
  AND (
        old_value IS NULL
        OR new_value IS NULL
      );


/* ============================================================
   TEST 15
   Partition information
   ============================================================ */

SELECT
    parent.relname AS parent_table,
    child.relname AS partition_name
FROM pg_inherits
JOIN pg_class parent
    ON pg_inherits.inhparent = parent.oid
JOIN pg_class child
    ON pg_inherits.inhrelid = child.oid
WHERE parent.relname = 'audit_event';