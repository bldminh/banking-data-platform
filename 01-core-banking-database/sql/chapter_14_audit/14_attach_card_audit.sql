/* ============================================================
   PROJECT 01 - BANKING DATABASE DESIGN
   CHAPTER 14 - AUDIT DATA MODEL

   FILE 14
   ATTACH CARD AUDIT

   PURPOSE
   ------------------------------------------------------------
   Enable automatic auditing for Card Domain.

   TABLES

       card.card
       card.card_limit
       card.card_status_history

   AUDIT OPERATIONS

       INSERT
       UPDATE
       DELETE

   ENTITY ID

       card.card
           -> card_id

       card.card_limit
           -> card_limit_id

       card.card_status_history
           -> history_id

   DEPENDENCIES

       09_create_generic_audit_trigger.sql
       09A_add_masking_support.sql
       09B_patch_generic_trigger_for_masking.sql
       10_attach_customer_audit.sql
       11_attach_account_audit.sql
       12_attach_transaction_audit.sql
       13_attach_loan_audit.sql

   ============================================================ */


/* ============================================================
   1. SAFETY
   ------------------------------------------------------------
   Remove existing audit triggers if they already exist.

   This makes the script safely re-runnable.
   ============================================================ */


/* ------------------------------------------------------------
   CARD
   ------------------------------------------------------------ */

DROP TRIGGER IF EXISTS trg_audit_card
ON card.card;


/* ------------------------------------------------------------
   CARD LIMIT
   ------------------------------------------------------------ */

DROP TRIGGER IF EXISTS trg_audit_card_limit
ON card.card_limit;


/* ------------------------------------------------------------
   CARD STATUS HISTORY
   ------------------------------------------------------------ */

DROP TRIGGER IF EXISTS trg_audit_card_status_history
ON card.card_status_history;


/* ============================================================
   2. CARD MASTER AUDIT
   ============================================================ */

CREATE TRIGGER trg_audit_card
AFTER INSERT OR UPDATE OR DELETE
ON card.card
FOR EACH ROW
EXECUTE FUNCTION audit.generic_audit_trigger
(
    'card_id'
);


/* ============================================================
   3. CARD LIMIT AUDIT
   ============================================================ */

CREATE TRIGGER trg_audit_card_limit
AFTER INSERT OR UPDATE OR DELETE
ON card.card_limit
FOR EACH ROW
EXECUTE FUNCTION audit.generic_audit_trigger
(
    'card_limit_id'
);


/* ============================================================
   4. CARD STATUS HISTORY AUDIT
   ============================================================ */

CREATE TRIGGER trg_audit_card_status_history
AFTER INSERT OR UPDATE OR DELETE
ON card.card_status_history
FOR EACH ROW
EXECUTE FUNCTION audit.generic_audit_trigger
(
    'history_id'
);


/* ============================================================
   5. VALIDATION
   ------------------------------------------------------------
   Display all audit triggers attached to Card Domain.
   ============================================================ */

SELECT
    event_object_schema,
    event_object_table,
    trigger_name,
    action_timing,
    event_manipulation
FROM information_schema.triggers
WHERE event_object_schema = 'card'
ORDER BY
    event_object_table,
    trigger_name,
    event_manipulation;


/* ============================================================
   6. VALIDATION
   ------------------------------------------------------------
   Count Card Domain audit triggers.
   ============================================================ */

SELECT
    COUNT(*) AS card_audit_trigger_count
FROM information_schema.triggers
WHERE event_object_schema = 'card'
  AND trigger_name LIKE 'trg_audit_%';


/* ============================================================
   7. VALIDATION
   ------------------------------------------------------------
   Expected:

       3 tables
       × 3 operations
       = 9 trigger-event rows

   ============================================================ */

SELECT
    event_object_table,
    trigger_name,
    event_manipulation
FROM information_schema.triggers
WHERE event_object_schema = 'card'
  AND trigger_name LIKE 'trg_audit_%'
ORDER BY
    event_object_table,
    event_manipulation;


/* ============================================================
   8. VALIDATION
   ------------------------------------------------------------
   Verify trigger exists on card.card.
   ============================================================ */

SELECT
    tgname AS trigger_name,
    tgrelid::regclass AS table_name
FROM pg_trigger
WHERE tgrelid = 'card.card'::regclass
  AND NOT tgisinternal
ORDER BY
    tgname;


/* ============================================================
   9. VALIDATION
   ------------------------------------------------------------
   Verify trigger exists on card.card_limit.
   ============================================================ */

SELECT
    tgname AS trigger_name,
    tgrelid::regclass AS table_name
FROM pg_trigger
WHERE tgrelid = 'card.card_limit'::regclass
  AND NOT tgisinternal
ORDER BY
    tgname;


/* ============================================================
   10. VALIDATION
   ------------------------------------------------------------
   Verify trigger exists on card.card_status_history.
   ============================================================ */

SELECT
    tgname AS trigger_name,
    tgrelid::regclass AS table_name
FROM pg_trigger
WHERE tgrelid = 'card.card_status_history'::regclass
  AND NOT tgisinternal
ORDER BY
    tgname;


/* ============================================================
   11. VALIDATION
   ------------------------------------------------------------
   Confirm that all expected Card tables have audit enabled.
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
        ('card', 'card'),
        ('card', 'card_limit'),
        ('card', 'card_status_history')
) AS expected(table_schema, table_name)
ORDER BY
    expected.table_name;


/* ============================================================
   12. VALIDATION
   ------------------------------------------------------------
   Verify all Card audit triggers use the generic audit
   trigger function.
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
WHERE n.nspname = 'card'
  AND t.tgname LIKE 'trg_audit_%'
  AND NOT t.tgisinternal
ORDER BY
    c.relname,
    t.tgname;


/* ============================================================
   13. FINAL SUMMARY
   ------------------------------------------------------------
   Expected number of audit trigger-event rows:

       3 tables × 3 operations = 9

   ============================================================ */

SELECT
    'Card Domain Audit' AS validation_name,
    COUNT(*) AS trigger_event_count,
    CASE
        WHEN COUNT(*) = 9
        THEN 'PASS'
        ELSE 'CHECK_REQUIRED'
    END AS validation_status
FROM information_schema.triggers
WHERE event_object_schema = 'card'
  AND trigger_name LIKE 'trg_audit_%';