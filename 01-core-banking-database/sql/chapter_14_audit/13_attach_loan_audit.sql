/* ============================================================
   PROJECT 01 - BANKING DATABASE DESIGN
   CHAPTER 14 - AUDIT DATA MODEL

   FILE 13
   ATTACH LOAN AUDIT

   PURPOSE
   ------------------------------------------------------------
   Enable automatic auditing for Loan Domain.

   TABLES

       loan.loan
       loan.loan_disbursement
       loan.loan_repayment
       loan.loan_schedule
       loan.loan_status_history

   AUDIT OPERATIONS

       INSERT
       UPDATE
       DELETE

   ENTITY ID

       loan.loan
           -> loan_id

       loan.loan_disbursement
           -> disbursement_id

       loan.loan_repayment
           -> repayment_id

       loan.loan_schedule
           -> schedule_id

       loan.loan_status_history
           -> history_id

   DEPENDENCIES

       09_create_generic_audit_trigger.sql
       09A_add_masking_support.sql
       09B_patch_generic_trigger_for_masking.sql
       10_attach_customer_audit.sql
       11_attach_account_audit.sql
       12_attach_transaction_audit.sql

   ============================================================ */


/* ============================================================
   1. SAFETY
   ------------------------------------------------------------
   Remove existing audit triggers if they already exist.

   This makes the script safely re-runnable.
   ============================================================ */


/* ------------------------------------------------------------
   LOAN
   ------------------------------------------------------------ */

DROP TRIGGER IF EXISTS trg_audit_loan
ON loan.loan;


/* ------------------------------------------------------------
   LOAN DISBURSEMENT
   ------------------------------------------------------------ */

DROP TRIGGER IF EXISTS trg_audit_loan_disbursement
ON loan.loan_disbursement;


/* ------------------------------------------------------------
   LOAN REPAYMENT
   ------------------------------------------------------------ */

DROP TRIGGER IF EXISTS trg_audit_loan_repayment
ON loan.loan_repayment;


/* ------------------------------------------------------------
   LOAN SCHEDULE
   ------------------------------------------------------------ */

DROP TRIGGER IF EXISTS trg_audit_loan_schedule
ON loan.loan_schedule;


/* ------------------------------------------------------------
   LOAN STATUS HISTORY
   ------------------------------------------------------------ */

DROP TRIGGER IF EXISTS trg_audit_loan_status_history
ON loan.loan_status_history;


/* ============================================================
   2. LOAN MASTER AUDIT
   ============================================================ */

CREATE TRIGGER trg_audit_loan
AFTER INSERT OR UPDATE OR DELETE
ON loan.loan
FOR EACH ROW
EXECUTE FUNCTION audit.generic_audit_trigger
(
    'loan_id'
);


/* ============================================================
   3. LOAN DISBURSEMENT AUDIT
   ============================================================ */

CREATE TRIGGER trg_audit_loan_disbursement
AFTER INSERT OR UPDATE OR DELETE
ON loan.loan_disbursement
FOR EACH ROW
EXECUTE FUNCTION audit.generic_audit_trigger
(
    'disbursement_id'
);


/* ============================================================
   4. LOAN REPAYMENT AUDIT
   ============================================================ */

CREATE TRIGGER trg_audit_loan_repayment
AFTER INSERT OR UPDATE OR DELETE
ON loan.loan_repayment
FOR EACH ROW
EXECUTE FUNCTION audit.generic_audit_trigger
(
    'repayment_id'
);


/* ============================================================
   5. LOAN SCHEDULE AUDIT
   ============================================================ */

CREATE TRIGGER trg_audit_loan_schedule
AFTER INSERT OR UPDATE OR DELETE
ON loan.loan_schedule
FOR EACH ROW
EXECUTE FUNCTION audit.generic_audit_trigger
(
    'schedule_id'
);


/* ============================================================
   6. LOAN STATUS HISTORY AUDIT
   ============================================================ */

CREATE TRIGGER trg_audit_loan_status_history
AFTER INSERT OR UPDATE OR DELETE
ON loan.loan_status_history
FOR EACH ROW
EXECUTE FUNCTION audit.generic_audit_trigger
(
    'history_id'
);


/* ============================================================
   7. VALIDATION
   ------------------------------------------------------------
   Display all audit triggers attached to Loan Domain.
   ============================================================ */

SELECT
    event_object_schema,
    event_object_table,
    trigger_name,
    action_timing,
    event_manipulation
FROM information_schema.triggers
WHERE event_object_schema = 'loan'
ORDER BY
    event_object_table,
    trigger_name,
    event_manipulation;


/* ============================================================
   8. VALIDATION
   ------------------------------------------------------------
   Count Loan Domain audit triggers.
   ============================================================ */

SELECT
    COUNT(*) AS loan_audit_trigger_count
FROM information_schema.triggers
WHERE event_object_schema = 'loan'
  AND trigger_name LIKE 'trg_audit_%';


/* ============================================================
   9. VALIDATION
   ------------------------------------------------------------
   Expected:

       5 tables
       × 3 operations
       = 15 trigger-event rows

   ============================================================ */

SELECT
    event_object_table,
    trigger_name,
    event_manipulation
FROM information_schema.triggers
WHERE event_object_schema = 'loan'
  AND trigger_name LIKE 'trg_audit_%'
ORDER BY
    event_object_table,
    event_manipulation;


/* ============================================================
   10. VALIDATION
   ------------------------------------------------------------
   Verify trigger exists on loan.loan.
   ============================================================ */

SELECT
    tgname AS trigger_name,
    tgrelid::regclass AS table_name
FROM pg_trigger
WHERE tgrelid = 'loan.loan'::regclass
  AND NOT tgisinternal
ORDER BY
    tgname;


/* ============================================================
   11. VALIDATION
   ------------------------------------------------------------
   Verify trigger exists on loan.loan_disbursement.
   ============================================================ */

SELECT
    tgname AS trigger_name,
    tgrelid::regclass AS table_name
FROM pg_trigger
WHERE tgrelid = 'loan.loan_disbursement'::regclass
  AND NOT tgisinternal
ORDER BY
    tgname;


/* ============================================================
   12. VALIDATION
   ------------------------------------------------------------
   Verify trigger exists on loan.loan_repayment.
   ============================================================ */

SELECT
    tgname AS trigger_name,
    tgrelid::regclass AS table_name
FROM pg_trigger
WHERE tgrelid = 'loan.loan_repayment'::regclass
  AND NOT tgisinternal
ORDER BY
    tgname;


/* ============================================================
   13. VALIDATION
   ------------------------------------------------------------
   Verify trigger exists on loan.loan_schedule.
   ============================================================ */

SELECT
    tgname AS trigger_name,
    tgrelid::regclass AS table_name
FROM pg_trigger
WHERE tgrelid = 'loan.loan_schedule'::regclass
  AND NOT tgisinternal
ORDER BY
    tgname;


/* ============================================================
   14. VALIDATION
   ------------------------------------------------------------
   Verify trigger exists on
   loan.loan_status_history.
   ============================================================ */

SELECT
    tgname AS trigger_name,
    tgrelid::regclass AS table_name
FROM pg_trigger
WHERE tgrelid = 'loan.loan_status_history'::regclass
  AND NOT tgisinternal
ORDER BY
    tgname;


/* ============================================================
   15. VALIDATION
   ------------------------------------------------------------
   Confirm that all expected Loan tables have audit enabled.
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
        ('loan', 'loan'),
        ('loan', 'loan_disbursement'),
        ('loan', 'loan_repayment'),
        ('loan', 'loan_schedule'),
        ('loan', 'loan_status_history')
) AS expected(table_schema, table_name)
ORDER BY
    expected.table_name;


/* ============================================================
   16. VALIDATION
   ------------------------------------------------------------
   Verify all Loan audit triggers use the generic audit
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
WHERE n.nspname = 'loan'
  AND t.tgname LIKE 'trg_audit_%'
  AND NOT t.tgisinternal
ORDER BY
    c.relname,
    t.tgname;


/* ============================================================
   17. FINAL SUMMARY
   ------------------------------------------------------------
   Expected number of audit trigger-event rows:

       5 tables × 3 operations = 15

   ============================================================ */

SELECT
    'Loan Domain Audit' AS validation_name,
    COUNT(*) AS trigger_event_count,
    CASE
        WHEN COUNT(*) = 15
        THEN 'PASS'
        ELSE 'CHECK_REQUIRED'
    END AS validation_status
FROM information_schema.triggers
WHERE event_object_schema = 'loan'
  AND trigger_name LIKE 'trg_audit_%';