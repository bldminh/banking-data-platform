/* ============================================================
   PROJECT 01 - BANKING DATABASE DESIGN
   CHAPTER 14 - AUDIT DATA MODEL

   FILE 12
   ATTACH TRANSACTION AUDIT

   PURPOSE
   ------------------------------------------------------------
   Enable automatic auditing for Transaction Domain.

   TABLES

       txn.transaction
       txn.transaction_status_history

   AUDIT OPERATIONS

       INSERT
       UPDATE
       DELETE

   ENTITY ID

       txn.transaction
           -> transaction_id

       txn.transaction_status_history
           -> history_id

   DEPENDENCIES

       09_create_generic_audit_trigger.sql
       09A_add_masking_support.sql
       09B_patch_generic_trigger_for_masking.sql

   ============================================================ */


/* ============================================================
   1. SAFETY
   ------------------------------------------------------------
   Remove existing audit triggers if they already exist.

   This makes the script safely re-runnable.
   ============================================================ */


/* ------------------------------------------------------------
   TRANSACTION
   ------------------------------------------------------------ */

DROP TRIGGER IF EXISTS trg_audit_transaction
ON txn.transaction;


/* ------------------------------------------------------------
   TRANSACTION STATUS HISTORY
   ------------------------------------------------------------ */

DROP TRIGGER IF EXISTS trg_audit_transaction_status_history
ON txn.transaction_status_history;


/* ============================================================
   2. TRANSACTION MASTER AUDIT
   ============================================================ */

CREATE TRIGGER trg_audit_transaction
AFTER INSERT OR UPDATE OR DELETE
ON txn.transaction
FOR EACH ROW
EXECUTE FUNCTION audit.generic_audit_trigger
(
    'transaction_id'
);


/* ============================================================
   3. TRANSACTION STATUS HISTORY AUDIT
   ============================================================ */

CREATE TRIGGER trg_audit_transaction_status_history
AFTER INSERT OR UPDATE OR DELETE
ON txn.transaction_status_history
FOR EACH ROW
EXECUTE FUNCTION audit.generic_audit_trigger
(
    'history_id'
);


/* ============================================================
   4. VALIDATION
   ------------------------------------------------------------
   Display all audit triggers attached to Transaction Domain.
   ============================================================ */

SELECT
    event_object_schema,
    event_object_table,
    trigger_name,
    action_timing,
    event_manipulation
FROM information_schema.triggers
WHERE event_object_schema = 'txn'
ORDER BY
    event_object_table,
    trigger_name,
    event_manipulation;


/* ============================================================
   5. VALIDATION
   ------------------------------------------------------------
   Count Transaction Domain audit triggers.
   ============================================================ */

SELECT
    COUNT(*) AS transaction_audit_trigger_count
FROM information_schema.triggers
WHERE event_object_schema = 'txn'
  AND trigger_name LIKE 'trg_audit_%';


/* ============================================================
   6. VALIDATION
   ------------------------------------------------------------
   Expected result:

       2 tables
       × 3 operations
       = 6 trigger-event rows

   ============================================================ */

SELECT
    event_object_table,
    trigger_name,
    event_manipulation
FROM information_schema.triggers
WHERE event_object_schema = 'txn'
  AND trigger_name LIKE 'trg_audit_%'
ORDER BY
    event_object_table,
    event_manipulation;


/* ============================================================
   7. VALIDATION
   ------------------------------------------------------------
   Verify trigger exists on txn.transaction.
   ============================================================ */

SELECT
    tgname AS trigger_name,
    tgrelid::regclass AS table_name
FROM pg_trigger
WHERE tgrelid = 'txn.transaction'::regclass
  AND NOT tgisinternal
ORDER BY
    tgname;


/* ============================================================
   8. VALIDATION
   ------------------------------------------------------------
   Verify trigger exists on
   txn.transaction_status_history.
   ============================================================ */

SELECT
    tgname AS trigger_name,
    tgrelid::regclass AS table_name
FROM pg_trigger
WHERE tgrelid = 'txn.transaction_status_history'::regclass
  AND NOT tgisinternal
ORDER BY
    tgname;


/* ============================================================
   9. VALIDATION
   ------------------------------------------------------------
   Confirm that both expected tables have audit triggers.
   ============================================================ */

SELECT
    expected.table_schema,
    expected.table_name,
    CASE
        WHEN EXISTS
        (
            SELECT 1
            FROM information_schema.triggers t
            WHERE t.event_object_schema = expected.table_schema
              AND t.event_object_table = expected.table_name
              AND t.trigger_name LIKE 'trg_audit_%'
        )
        THEN 'AUDIT_ENABLED'
        ELSE 'AUDIT_NOT_ENABLED'
    END AS audit_status
FROM
(
    VALUES
        ('txn', 'transaction'),
        ('txn', 'transaction_status_history')
) AS expected(table_schema, table_name)
ORDER BY
    expected.table_name;


/* ============================================================
   10. VALIDATION
   ------------------------------------------------------------
   Verify trigger functions.
   ============================================================ */

SELECT
    n.nspname AS schema_name,
    c.relname AS table_name,
    t.tgname AS trigger_name,
    p.proname AS trigger_function
FROM pg_trigger t
JOIN pg_class c
    ON c.oid = t.tgrelid
JOIN pg_namespace n
    ON n.oid = c.relnamespace
JOIN pg_proc p
    ON p.oid = t.tgfoid
WHERE n.nspname = 'txn'
  AND t.tgname LIKE 'trg_audit_%'
  AND NOT t.tgisinternal
ORDER BY
    c.relname,
    t.tgname;