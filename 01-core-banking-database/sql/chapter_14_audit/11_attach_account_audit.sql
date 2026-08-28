/* ============================================================
   PROJECT 01 - BANKING DATABASE DESIGN
   CHAPTER 14 - AUDIT DATA MODEL

   FILE 11
   ATTACH ACCOUNT AUDIT

   PURPOSE
   ------------------------------------------------------------
   Enable automatic auditing for Account Domain.

   TABLES

       account.account
       account.account_balance
       account.account_limit
       account.account_status_history

   AUDIT OPERATIONS

       INSERT
       UPDATE
       DELETE

   ENTITY ID

       account.account
           -> account_id

       account.account_balance
           -> account_id

       account.account_limit
           -> limit_id

       account.account_status_history
           -> history_id

   DEPENDENCIES

       01_create_audit_schema.sql
       02_create_audit_tables.sql
       02B_create_audit_partitions.sql
       03_create_audit_indexes.sql
       04_create_audit_functions.sql
       05_create_audit_triggers.sql
       09_create_generic_audit_trigger.sql
       09A_add_masking_support.sql
       09B_patch_generic_trigger_for_masking.sql
       10_attach_customer_audit.sql

   ============================================================ */


/* ============================================================
   1. SAFETY
   ------------------------------------------------------------
   Remove existing audit triggers if they already exist.

   This makes the script re-runnable.
   ============================================================ */


/* ------------------------------------------------------------
   ACCOUNT
   ------------------------------------------------------------ */

DROP TRIGGER IF EXISTS trg_audit_account
ON account.account;


/* ------------------------------------------------------------
   ACCOUNT BALANCE
   ------------------------------------------------------------ */

DROP TRIGGER IF EXISTS trg_audit_account_balance
ON account.account_balance;


/* ------------------------------------------------------------
   ACCOUNT LIMIT
   ------------------------------------------------------------ */

DROP TRIGGER IF EXISTS trg_audit_account_limit
ON account.account_limit;


/* ------------------------------------------------------------
   ACCOUNT STATUS HISTORY
   ------------------------------------------------------------ */

DROP TRIGGER IF EXISTS trg_audit_account_status_history
ON account.account_status_history;


/* ============================================================
   2. ACCOUNT MASTER AUDIT
   ============================================================ */

CREATE TRIGGER trg_audit_account
AFTER INSERT OR UPDATE OR DELETE
ON account.account
FOR EACH ROW
EXECUTE FUNCTION audit.generic_audit_trigger
(
    'account_id'
);


/* ============================================================
   3. ACCOUNT BALANCE AUDIT
   ============================================================ */

CREATE TRIGGER trg_audit_account_balance
AFTER INSERT OR UPDATE OR DELETE
ON account.account_balance
FOR EACH ROW
EXECUTE FUNCTION audit.generic_audit_trigger
(
    'account_id'
);


/* ============================================================
   4. ACCOUNT LIMIT AUDIT
   ============================================================ */

CREATE TRIGGER trg_audit_account_limit
AFTER INSERT OR UPDATE OR DELETE
ON account.account_limit
FOR EACH ROW
EXECUTE FUNCTION audit.generic_audit_trigger
(
    'limit_id'
);


/* ============================================================
   5. ACCOUNT STATUS HISTORY AUDIT
   ============================================================ */

CREATE TRIGGER trg_audit_account_status_history
AFTER INSERT OR UPDATE OR DELETE
ON account.account_status_history
FOR EACH ROW
EXECUTE FUNCTION audit.generic_audit_trigger
(
    'history_id'
);


/* ============================================================
   6. VALIDATION
   ------------------------------------------------------------
   Display all audit triggers attached to Account Domain.
   ============================================================ */

SELECT
    event_object_schema,
    event_object_table,
    trigger_name,
    action_timing,
    event_manipulation
FROM information_schema.triggers
WHERE event_object_schema = 'account'
ORDER BY
    event_object_table,
    trigger_name,
    event_manipulation;


/* ============================================================
   7. VALIDATION
   ------------------------------------------------------------
   Count Account Domain audit triggers.
   ============================================================ */

SELECT
    COUNT(*) AS account_audit_trigger_count
FROM information_schema.triggers
WHERE event_object_schema = 'account'
  AND trigger_name LIKE 'trg_audit_%';


/* ============================================================
   8. VALIDATION
   ------------------------------------------------------------
   Expected:

       4 tables
       × 3 operations
       = 12 trigger-event rows

   ============================================================ */

SELECT
    event_object_table,
    trigger_name,
    event_manipulation
FROM information_schema.triggers
WHERE event_object_schema = 'account'
  AND trigger_name LIKE 'trg_audit_%'
ORDER BY
    event_object_table,
    event_manipulation;


/* ============================================================
   9. VALIDATION
   ------------------------------------------------------------
   Verify trigger exists on account.account.
   ============================================================ */

SELECT
    tgname AS trigger_name,
    tgrelid::regclass AS table_name
FROM pg_trigger
WHERE tgrelid = 'account.account'::regclass
  AND NOT tgisinternal
ORDER BY tgname;


/* ============================================================
   10. VALIDATION
   ------------------------------------------------------------
   Verify trigger exists on account.account_balance.
   ============================================================ */

SELECT
    tgname AS trigger_name,
    tgrelid::regclass AS table_name
FROM pg_trigger
WHERE tgrelid = 'account.account_balance'::regclass
  AND NOT tgisinternal
ORDER BY tgname;


/* ============================================================
   11. VALIDATION
   ------------------------------------------------------------
   Verify trigger exists on account.account_limit.
   ============================================================ */

SELECT
    tgname AS trigger_name,
    tgrelid::regclass AS table_name
FROM pg_trigger
WHERE tgrelid = 'account.account_limit'::regclass
  AND NOT tgisinternal
ORDER BY tgname;


/* ============================================================
   12. VALIDATION
   ------------------------------------------------------------
   Verify trigger exists on account.account_status_history.
   ============================================================ */

SELECT
    tgname AS trigger_name,
    tgrelid::regclass AS table_name
FROM pg_trigger
WHERE tgrelid = 'account.account_status_history'::regclass
  AND NOT tgisinternal
ORDER BY tgname;



-- test
-- SELECT
--     event_object_table,
--     trigger_name,
--     event_manipulation
-- FROM information_schema.triggers
-- WHERE event_object_schema = 'account'
--   AND trigger_name LIKE 'trg_audit_%'
-- ORDER BY
--     event_object_table,
--     event_manipulation;
