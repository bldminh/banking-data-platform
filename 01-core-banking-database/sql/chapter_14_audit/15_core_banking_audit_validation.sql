/* ============================================================
   PROJECT 01 - BANKING DATABASE DESIGN
   CHAPTER 14 - AUDIT DATA MODEL

   FILE 15
   CORE BANKING AUDIT VALIDATION

   PURPOSE
   ------------------------------------------------------------
   Perform end-to-end validation of the Core Banking Audit
   Data Model after all audit triggers have been attached.

   COVERED DOMAINS

       customer
       account
       txn
       loan
       card

   VALIDATION AREAS

       1. Audit schema existence
       2. Audit table existence
       3. Audit trigger coverage
       4. INSERT / UPDATE / DELETE coverage
       5. Generic trigger function usage
       6. Entity ID mapping
       7. Audit event structure
       8. Audit change structure
       9. Orphan audit change detection
      10. Masking function existence
      11. Sensitive-column masking readiness
      12. Overall audit coverage
      13. Final PASS / CHECK_REQUIRED summary

   IMPORTANT
   ------------------------------------------------------------
   This file is READ-ONLY validation.

   It does NOT:
       - insert business data
       - update business data
       - delete business data
       - create triggers
       - modify audit data

   ============================================================ */


/* ============================================================
   0. START
   ============================================================ */

SELECT
    '==================================================' AS section,
    'CORE BANKING AUDIT VALIDATION STARTED' AS message,
    CURRENT_TIMESTAMP AS validation_time;


/* ============================================================
   1. CHECK AUDIT SCHEMA
   ============================================================ */

SELECT
    'AUDIT_SCHEMA' AS validation_name,
    CASE
        WHEN EXISTS
        (
            SELECT 1
            FROM information_schema.schemata
            WHERE schema_name = 'audit'
        )
        THEN 'PASS'
        ELSE 'FAIL'
    END AS validation_status;


/* ============================================================
   2. CHECK REQUIRED AUDIT TABLES
   ------------------------------------------------------------
   Expected core audit tables:

       audit.audit_event
       audit.audit_change
   ============================================================ */

SELECT
    expected.table_name,
    CASE
        WHEN EXISTS
        (
            SELECT 1
            FROM information_schema.tables t
            WHERE t.table_schema = 'audit'
              AND t.table_name = expected.table_name
        )
        THEN 'PASS'
        ELSE 'FAIL'
    END AS validation_status
FROM
(
    VALUES
        ('audit_event'),
        ('audit_change')
) AS expected(table_name)
ORDER BY
    expected.table_name;


/* ============================================================
   3. CHECK AUDIT TABLE COLUMNS
   ------------------------------------------------------------ */


/* ------------------------------------------------------------
   audit.audit_event
   ------------------------------------------------------------ */

SELECT
    'audit.audit_event' AS table_name,
    COUNT(*) AS column_count,
    CASE
        WHEN COUNT(*) > 0
        THEN 'PASS'
        ELSE 'FAIL'
    END AS validation_status
FROM information_schema.columns
WHERE table_schema = 'audit'
  AND table_name = 'audit_event';


/* ------------------------------------------------------------
   audit.audit_change
   ------------------------------------------------------------ */

SELECT
    'audit.audit_change' AS table_name,
    COUNT(*) AS column_count,
    CASE
        WHEN COUNT(*) > 0
        THEN 'PASS'
        ELSE 'FAIL'
    END AS validation_status
FROM information_schema.columns
WHERE table_schema = 'audit'
  AND table_name = 'audit_change';


/* ============================================================
   4. EXPECTED CORE BANKING AUDIT COVERAGE
   ------------------------------------------------------------
   Business tables covered by Chapter 14.
   ============================================================ */

DROP TABLE IF EXISTS tmp_expected_audit_tables;

CREATE TEMP TABLE tmp_expected_audit_tables
(
    domain_name      VARCHAR(50),
    table_schema     VARCHAR(50),
    table_name       VARCHAR(100),
    entity_id_column VARCHAR(100)
);


/* ------------------------------------------------------------
   CUSTOMER DOMAIN
   ------------------------------------------------------------ */

INSERT INTO tmp_expected_audit_tables
(
    domain_name,
    table_schema,
    table_name,
    entity_id_column
)
VALUES
    ('customer', 'customer', 'customer', 'customer_id'),
    ('customer', 'customer', 'customer_address', 'address_id'),
    ('customer', 'customer', 'customer_contact', 'contact_id'),
    ('customer', 'customer', 'customer_employment', 'employment_id'),
    ('customer', 'customer', 'customer_beneficiary', 'beneficiary_id'),
    ('customer', 'customer', 'customer_kyc', 'kyc_id');


/* ------------------------------------------------------------
   ACCOUNT DOMAIN
   ------------------------------------------------------------ */

INSERT INTO tmp_expected_audit_tables
(
    domain_name,
    table_schema,
    table_name,
    entity_id_column
)
VALUES
    ('account', 'account', 'account', 'account_id'),
    ('account', 'account', 'account_balance', 'account_id'),
    ('account', 'account', 'account_limit', 'limit_id'),
    ('account', 'account', 'account_status_history', 'history_id');


/* ------------------------------------------------------------
   TRANSACTION DOMAIN
   ------------------------------------------------------------ */

INSERT INTO tmp_expected_audit_tables
(
    domain_name,
    table_schema,
    table_name,
    entity_id_column
)
VALUES
    ('transaction', 'txn', 'transaction', 'transaction_id'),
    ('transaction', 'txn', 'transaction_status_history', 'history_id');


/* ------------------------------------------------------------
   LOAN DOMAIN
   ------------------------------------------------------------ */

INSERT INTO tmp_expected_audit_tables
(
    domain_name,
    table_schema,
    table_name,
    entity_id_column
)
VALUES
    ('loan', 'loan', 'loan', 'loan_id'),
    ('loan', 'loan', 'loan_disbursement', 'disbursement_id'),
    ('loan', 'loan', 'loan_repayment', 'repayment_id'),
    ('loan', 'loan', 'loan_schedule', 'schedule_id'),
    ('loan', 'loan', 'loan_status_history', 'history_id');


/* ------------------------------------------------------------
   CARD DOMAIN
   ------------------------------------------------------------ */

INSERT INTO tmp_expected_audit_tables
(
    domain_name,
    table_schema,
    table_name,
    entity_id_column
)
VALUES
    ('card', 'card', 'card', 'card_id'),
    ('card', 'card', 'card_limit', 'card_limit_id'),
    ('card', 'card', 'card_status_history', 'history_id');


/* ============================================================
   5. TOTAL EXPECTED TABLE COUNT
   ------------------------------------------------------------
   Expected:

       Customer       = 6
       Account        = 4
       Transaction    = 2
       Loan           = 5
       Card           = 3

       TOTAL          = 20
   ============================================================ */

SELECT
    'EXPECTED_AUDIT_TABLE_COUNT' AS validation_name,
    COUNT(*) AS expected_table_count,
    CASE
        WHEN COUNT(*) = 20
        THEN 'PASS'
        ELSE 'CHECK_REQUIRED'
    END AS validation_status
FROM tmp_expected_audit_tables;


/* ============================================================
   6. CHECK BUSINESS TABLE EXISTENCE
   ============================================================ */

SELECT
    domain_name,
    table_schema,
    table_name,
    entity_id_column,
    CASE
        WHEN EXISTS
        (
            SELECT 1
            FROM information_schema.tables t
            WHERE t.table_schema = e.table_schema
              AND t.table_name = e.table_name
        )
        THEN 'PASS'
        ELSE 'FAIL'
    END AS business_table_status
FROM tmp_expected_audit_tables e
ORDER BY
    domain_name,
    table_schema,
    table_name;


/* ============================================================
   7. CHECK AUDIT TRIGGER EXISTENCE
   ============================================================ */

SELECT
    domain_name,
    table_schema,
    table_name,
    CASE
        WHEN EXISTS
        (
            SELECT 1
            FROM information_schema.triggers t
            WHERE t.event_object_schema = e.table_schema
              AND t.event_object_table = e.table_name
              AND t.trigger_name LIKE 'trg_audit_%'
        )
        THEN 'PASS'
        ELSE 'FAIL'
    END AS audit_trigger_status
FROM tmp_expected_audit_tables e
ORDER BY
    domain_name,
    table_schema,
    table_name;


/* ============================================================
   8. CHECK INSERT / UPDATE / DELETE COVERAGE
   ------------------------------------------------------------
   Every business table should have:

       INSERT
       UPDATE
       DELETE
   ============================================================ */

SELECT
    e.domain_name,
    e.table_schema,
    e.table_name,

    CASE
        WHEN EXISTS
        (
            SELECT 1
            FROM information_schema.triggers t
            WHERE t.event_object_schema = e.table_schema
              AND t.event_object_table = e.table_name
              AND t.event_manipulation = 'INSERT'
              AND t.trigger_name LIKE 'trg_audit_%'
        )
        THEN 'PASS'
        ELSE 'FAIL'
    END AS insert_audit,

    CASE
        WHEN EXISTS
        (
            SELECT 1
            FROM information_schema.triggers t
            WHERE t.event_object_schema = e.table_schema
              AND t.event_object_table = e.table_name
              AND t.event_manipulation = 'UPDATE'
              AND t.trigger_name LIKE 'trg_audit_%'
        )
        THEN 'PASS'
        ELSE 'FAIL'
    END AS update_audit,

    CASE
        WHEN EXISTS
        (
            SELECT 1
            FROM information_schema.triggers t
            WHERE t.event_object_schema = e.table_schema
              AND t.event_object_table = e.table_name
              AND t.event_manipulation = 'DELETE'
              AND t.trigger_name LIKE 'trg_audit_%'
        )
        THEN 'PASS'
        ELSE 'FAIL'
    END AS delete_audit

FROM tmp_expected_audit_tables e
ORDER BY
    e.domain_name,
    e.table_schema,
    e.table_name;


/* ============================================================
   9. COUNT ALL AUDIT TRIGGER EVENTS
   ------------------------------------------------------------
   Expected:

       20 tables
       × 3 operations
       = 60 trigger-event rows
   ============================================================ */

SELECT
    'TOTAL_AUDIT_TRIGGER_EVENTS' AS validation_name,
    COUNT(*) AS trigger_event_count,
    CASE
        WHEN COUNT(*) = 60
        THEN 'PASS'
        ELSE 'CHECK_REQUIRED'
    END AS validation_status
FROM information_schema.triggers t
JOIN tmp_expected_audit_tables e
    ON e.table_schema = t.event_object_schema
   AND e.table_name = t.event_object_table
WHERE t.trigger_name LIKE 'trg_audit_%';


/* ============================================================
   10. CHECK GENERIC AUDIT TRIGGER FUNCTION
   ============================================================ */

SELECT
    n.nspname AS schema_name,
    c.relname AS table_name,
    t.tgname AS trigger_name,
    p.proname AS trigger_function,
    CASE
        WHEN p.proname = 'generic_audit_trigger'
        THEN 'PASS'
        ELSE 'CHECK_REQUIRED'
    END AS validation_status
FROM pg_trigger t
JOIN pg_class c
    ON c.oid = t.tgrelid
JOIN pg_namespace n
    ON n.oid = c.relnamespace
JOIN pg_proc p
    ON p.oid = t.tgfoid
JOIN tmp_expected_audit_tables e
    ON e.table_schema = n.nspname
   AND e.table_name = c.relname
WHERE t.tgname LIKE 'trg_audit_%'
  AND NOT t.tgisinternal
ORDER BY
    n.nspname,
    c.relname,
    t.tgname;


/* ============================================================
   11. CHECK ENTITY ID COLUMNS
   ------------------------------------------------------------
   Verify that expected entity ID columns exist in each
   business table.
   ============================================================ */

SELECT
    e.domain_name,
    e.table_schema,
    e.table_name,
    e.entity_id_column,
    CASE
        WHEN EXISTS
        (
            SELECT 1
            FROM information_schema.columns c
            WHERE c.table_schema = e.table_schema
              AND c.table_name = e.table_name
              AND c.column_name = e.entity_id_column
        )
        THEN 'PASS'
        ELSE 'FAIL'
    END AS entity_id_status
FROM tmp_expected_audit_tables e
ORDER BY
    e.domain_name,
    e.table_schema,
    e.table_name;


/* ============================================================
   12. CHECK PRIMARY KEY
   ------------------------------------------------------------
   Entity ID columns should normally correspond to the
   primary key for the Core Banking tables.
   ============================================================ */

SELECT
    e.domain_name,
    e.table_schema,
    e.table_name,
    e.entity_id_column,
    CASE
        WHEN EXISTS
        (
            SELECT 1
            FROM information_schema.table_constraints tc
            JOIN information_schema.key_column_usage kcu
                ON kcu.constraint_name = tc.constraint_name
               AND kcu.table_schema = tc.table_schema
               AND kcu.table_name = tc.table_name
            WHERE tc.constraint_type = 'PRIMARY KEY'
              AND tc.table_schema = e.table_schema
              AND tc.table_name = e.table_name
              AND kcu.column_name = e.entity_id_column
        )
        THEN 'PASS'
        ELSE 'CHECK_REQUIRED'
    END AS entity_id_primary_key_status
FROM tmp_expected_audit_tables e
ORDER BY
    e.domain_name,
    e.table_schema,
    e.table_name;


/* ============================================================
   13. AUDIT EVENT TABLE STATISTICS
   ============================================================ */

SELECT
    COUNT(*) AS total_audit_events,
    COUNT(DISTINCT event_type) AS distinct_event_types,
    COUNT(DISTINCT entity_schema || '.' || entity_table)
        AS audited_business_tables,
    MIN(event_time) AS first_event_time,
    MAX(event_time) AS last_event_time
FROM audit.audit_event;


/* ============================================================
   14. AUDIT CHANGE TABLE STATISTICS
   ============================================================ */

SELECT
    COUNT(*) AS total_audit_changes,
    COUNT(DISTINCT column_name) AS distinct_columns_audited
FROM audit.audit_change;


/* ============================================================
   15. AUDIT EVENTS BY DOMAIN
   ------------------------------------------------------------ */

SELECT
    entity_schema,
    entity_table,
    COUNT(*) AS audit_event_count
FROM audit.audit_event
GROUP BY
    entity_schema,
    entity_table
ORDER BY
    entity_schema,
    entity_table;


/* ============================================================
   16. AUDIT EVENTS BY ACTION
   ------------------------------------------------------------ */

SELECT
    action,
    COUNT(*) AS event_count
FROM audit.audit_event
GROUP BY
    action
ORDER BY
    action;


/* ============================================================
   17. AUDIT EVENTS BY EVENT TYPE
   ------------------------------------------------------------ */

SELECT
    event_type,
    COUNT(*) AS event_count
FROM audit.audit_event
GROUP BY
    event_type
ORDER BY
    event_type;


/* ============================================================
   18. CHECK FOR ORPHAN AUDIT CHANGES
   ------------------------------------------------------------
   Every audit_change must reference an existing audit_event.
   ============================================================ */

SELECT
    COUNT(*) AS orphan_audit_change_count,
    CASE
        WHEN COUNT(*) = 0
        THEN 'PASS'
        ELSE 'FAIL'
    END AS validation_status
FROM audit.audit_change c
LEFT JOIN audit.audit_event e
    ON e.audit_event_id = c.audit_event_id
WHERE e.audit_event_id IS NULL;


/* ============================================================
   19. CHECK AUDIT EVENT WITH NO CHANGES
   ------------------------------------------------------------
   For UPDATE events, audit_change rows are normally expected.

   INSERT / DELETE may depend on implementation.

   This query identifies events that currently have no
   corresponding audit_change rows.
   ============================================================ */

SELECT
    e.audit_event_id,
    e.event_time,
    e.event_type,
    e.action,
    e.entity_schema,
    e.entity_table,
    e.entity_id
FROM audit.audit_event e
LEFT JOIN audit.audit_change c
    ON c.audit_event_id = e.audit_event_id
WHERE c.audit_event_id IS NULL
ORDER BY
    e.audit_event_id DESC
LIMIT 100;


/* ============================================================
   20. CHECK DUPLICATE AUDIT EVENT IDs
   ============================================================ */

SELECT
    audit_event_id,
    COUNT(*) AS duplicate_count
FROM audit.audit_event
GROUP BY
    audit_event_id
HAVING COUNT(*) > 1
ORDER BY
    audit_event_id;


/* ============================================================
   21. CHECK NULL CORE AUDIT FIELDS
   ------------------------------------------------------------
   Core fields expected to be populated.
   ============================================================ */

SELECT
    COUNT(*) FILTER (WHERE audit_event_id IS NULL)
        AS null_audit_event_id,

    COUNT(*) FILTER (WHERE event_time IS NULL)
        AS null_event_time,

    COUNT(*) FILTER (WHERE event_type IS NULL)
        AS null_event_type,

    COUNT(*) FILTER (WHERE entity_schema IS NULL)
        AS null_entity_schema,

    COUNT(*) FILTER (WHERE entity_table IS NULL)
        AS null_entity_table,

    COUNT(*) FILTER (WHERE entity_id IS NULL)
        AS null_entity_id
FROM audit.audit_event;


/* ============================================================
   22. CHECK AUDIT CHANGE CORE FIELDS
   ============================================================ */

SELECT
    COUNT(*) FILTER (WHERE audit_event_id IS NULL)
        AS null_audit_event_id,

    COUNT(*) FILTER (WHERE column_name IS NULL)
        AS null_column_name,

    COUNT(*) FILTER (WHERE change_type IS NULL)
        AS null_change_type
FROM audit.audit_change;


/* ============================================================
   23. CHECK MASKING FUNCTION
   ------------------------------------------------------------
   Search for masking-related functions in audit schema.
   ============================================================ */

SELECT
    n.nspname AS schema_name,
    p.proname AS function_name,
    pg_get_function_identity_arguments(p.oid)
        AS function_arguments
FROM pg_proc p
JOIN pg_namespace n
    ON n.oid = p.pronamespace
WHERE n.nspname = 'audit'
  AND
  (
      p.proname ILIKE '%mask%'
      OR p.proname ILIKE '%audit%'
  )
ORDER BY
    p.proname;


/* ============================================================
   24. CHECK EXPECTED MASKING FUNCTION
   ------------------------------------------------------------
   Expected function:

       audit.mask_audit_value
   ============================================================ */

SELECT
    'audit.mask_audit_value' AS validation_name,
    CASE
        WHEN EXISTS
        (
            SELECT 1
            FROM pg_proc p
            JOIN pg_namespace n
                ON n.oid = p.pronamespace
            WHERE n.nspname = 'audit'
              AND p.proname = 'mask_audit_value'
        )
        THEN 'PASS'
        ELSE 'CHECK_REQUIRED'
    END AS validation_status;


/* ============================================================
   25. CHECK SENSITIVE COLUMNS IN BUSINESS TABLES
   ------------------------------------------------------------
   These columns require masking / protection in audit.

   CUSTOMER

       national_id
       passport_no

   CARD

       card_number
       cvv_hash
       pin_hash
   ============================================================ */

DROP TABLE IF EXISTS tmp_sensitive_columns;

CREATE TEMP TABLE tmp_sensitive_columns
(
    table_schema VARCHAR(50),
    table_name   VARCHAR(100),
    column_name  VARCHAR(100)
);

INSERT INTO tmp_sensitive_columns
(
    table_schema,
    table_name,
    column_name
)
VALUES
    ('customer', 'customer', 'national_id'),
    ('customer', 'customer', 'passport_no'),
    ('card', 'card', 'card_number'),
    ('card', 'card', 'cvv_hash'),
    ('card', 'card', 'pin_hash');


/* ============================================================
   26. VERIFY SENSITIVE COLUMNS EXIST
   ============================================================ */

SELECT
    s.table_schema,
    s.table_name,
    s.column_name,
    CASE
        WHEN EXISTS
        (
            SELECT 1
            FROM information_schema.columns c
            WHERE c.table_schema = s.table_schema
              AND c.table_name = s.table_name
              AND c.column_name = s.column_name
        )
        THEN 'PASS'
        ELSE 'NOT_PRESENT'
    END AS column_status
FROM tmp_sensitive_columns s
ORDER BY
    s.table_schema,
    s.table_name,
    s.column_name;


/* ============================================================
   27. SEARCH AUDIT CHANGES FOR SENSITIVE COLUMN NAMES
   ------------------------------------------------------------
   This is a RED FLAG report.

   If rows are returned, inspect them carefully.

   It does NOT automatically mean masking failed, because
   implementations may retain the column name while masking
   only the value.
   ============================================================ */

SELECT
    c.audit_event_id,
    e.event_time,
    e.entity_schema,
    e.entity_table,
    e.entity_id,
    c.column_name,
    c.old_value,
    c.new_value,
    c.change_type
FROM audit.audit_change c
JOIN audit.audit_event e
    ON e.audit_event_id = c.audit_event_id
WHERE
       (
           e.entity_schema = 'customer'
           AND e.entity_table = 'customer'
           AND c.column_name IN
           (
               'national_id',
               'passport_no'
           )
       )
    OR (
           e.entity_schema = 'card'
           AND e.entity_table = 'card'
           AND c.column_name IN
           (
               'card_number',
               'cvv_hash',
               'pin_hash'
           )
       )
ORDER BY
    e.audit_event_id DESC
LIMIT 100;


/* ============================================================
   28. CHECK FOR POSSIBLE RAW SENSITIVE VALUES
   ------------------------------------------------------------
   This is a structural inspection only.

   We check whether sensitive-column audit records exist.

   Manual review of old_value / new_value is still required
   because the exact masking implementation may vary.
   ============================================================ */

SELECT
    e.entity_schema,
    e.entity_table,
    c.column_name,
    COUNT(*) AS audit_change_count
FROM audit.audit_change c
JOIN audit.audit_event e
    ON e.audit_event_id = c.audit_event_id
WHERE
       (
           e.entity_schema = 'customer'
           AND e.entity_table = 'customer'
           AND c.column_name IN
           (
               'national_id',
               'passport_no'
           )
       )
    OR (
           e.entity_schema = 'card'
           AND e.entity_table = 'card'
           AND c.column_name IN
           (
               'card_number',
               'cvv_hash',
               'pin_hash'
           )
       )
GROUP BY
    e.entity_schema,
    e.entity_table,
    c.column_name
ORDER BY
    e.entity_schema,
    e.entity_table,
    c.column_name;


/* ============================================================
   29. CHECK ACCOUNT NUMBER AUDIT PRESENCE
   ------------------------------------------------------------
   account_number is sensitive banking information.

   This report identifies whether it is currently being
   audited, so that masking policy can be reviewed.
   ============================================================ */

SELECT
    e.entity_schema,
    e.entity_table,
    c.column_name,
    COUNT(*) AS audit_change_count
FROM audit.audit_change c
JOIN audit.audit_event e
    ON e.audit_event_id = c.audit_event_id
WHERE e.entity_schema = 'account'
  AND e.entity_table = 'account'
  AND c.column_name = 'account_number'
GROUP BY
    e.entity_schema,
    e.entity_table,
    c.column_name;


/* ============================================================
   30. DOMAIN COVERAGE SUMMARY
   ============================================================ */

SELECT
    domain_name,
    COUNT(*) AS expected_tables,

    COUNT(*) FILTER
    (
        WHERE EXISTS
        (
            SELECT 1
            FROM information_schema.triggers t
            WHERE t.event_object_schema = e.table_schema
              AND t.event_object_table = e.table_name
              AND t.trigger_name LIKE 'trg_audit_%'
        )
    ) AS audited_tables,

    CASE
        WHEN COUNT(*) =
             COUNT(*) FILTER
             (
                 WHERE EXISTS
                 (
                     SELECT 1
                     FROM information_schema.triggers t
                     WHERE t.event_object_schema = e.table_schema
                       AND t.event_object_table = e.table_name
                       AND t.trigger_name LIKE 'trg_audit_%'
                 )
             )
        THEN 'PASS'
        ELSE 'FAIL'
    END AS coverage_status

FROM tmp_expected_audit_tables e
GROUP BY
    domain_name
ORDER BY
    domain_name;


/* ============================================================
   31. DETAILED TRIGGER COVERAGE REPORT
   ============================================================ */

SELECT
    e.domain_name,
    e.table_schema,
    e.table_name,

    COUNT(DISTINCT t.event_manipulation)
        AS covered_operations,

    CASE
        WHEN COUNT(DISTINCT t.event_manipulation) = 3
        THEN 'PASS'
        ELSE 'CHECK_REQUIRED'
    END AS operation_coverage_status

FROM tmp_expected_audit_tables e

LEFT JOIN information_schema.triggers t
    ON t.event_object_schema = e.table_schema
   AND t.event_object_table = e.table_name
   AND t.trigger_name LIKE 'trg_audit_%'

GROUP BY
    e.domain_name,
    e.table_schema,
    e.table_name

ORDER BY
    e.domain_name,
    e.table_schema,
    e.table_name;


/* ============================================================
   32. LIST ALL CORE BANKING AUDIT TRIGGERS
   ============================================================ */

SELECT
    n.nspname AS table_schema,
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
JOIN tmp_expected_audit_tables e
    ON e.table_schema = n.nspname
   AND e.table_name = c.relname
WHERE t.tgname LIKE 'trg_audit_%'
  AND NOT t.tgisinternal
ORDER BY
    n.nspname,
    c.relname,
    t.tgname;


/* ============================================================
   33. FINAL CORE BANKING AUDIT SCORECARD
   ============================================================ */

WITH checks AS
(
    /* --------------------------------------------------------
       Check 1: audit schema
       -------------------------------------------------------- */

    SELECT
        'Audit schema exists' AS check_name,
        EXISTS
        (
            SELECT 1
            FROM information_schema.schemata
            WHERE schema_name = 'audit'
        ) AS passed

    UNION ALL

    /* --------------------------------------------------------
       Check 2: audit_event
       -------------------------------------------------------- */

    SELECT
        'audit.audit_event exists',
        EXISTS
        (
            SELECT 1
            FROM information_schema.tables
            WHERE table_schema = 'audit'
              AND table_name = 'audit_event'
        )

    UNION ALL

    /* --------------------------------------------------------
       Check 3: audit_change
       -------------------------------------------------------- */

    SELECT
        'audit.audit_change exists',
        EXISTS
        (
            SELECT 1
            FROM information_schema.tables
            WHERE table_schema = 'audit'
              AND table_name = 'audit_change'
        )

    UNION ALL

    /* --------------------------------------------------------
       Check 4: 20 expected tables have audit triggers
       -------------------------------------------------------- */

    SELECT
        '20 business tables have audit triggers',
        (
            SELECT COUNT(*) = 20
            FROM tmp_expected_audit_tables e
            WHERE EXISTS
            (
                SELECT 1
                FROM information_schema.triggers t
                WHERE t.event_object_schema = e.table_schema
                  AND t.event_object_table = e.table_name
                  AND t.trigger_name LIKE 'trg_audit_%'
            )
        )

    UNION ALL

    /* --------------------------------------------------------
       Check 5: 60 trigger-event rows
       -------------------------------------------------------- */

    SELECT
        '60 INSERT/UPDATE/DELETE trigger events configured',
        (
            SELECT COUNT(*) = 60
            FROM information_schema.triggers t
            JOIN tmp_expected_audit_tables e
                ON e.table_schema = t.event_object_schema
               AND e.table_name = t.event_object_table
            WHERE t.trigger_name LIKE 'trg_audit_%'
        )

    UNION ALL

    /* --------------------------------------------------------
       Check 6: generic trigger function exists
       -------------------------------------------------------- */

    SELECT
        'Generic audit trigger function exists',
        EXISTS
        (
            SELECT 1
            FROM pg_proc p
            JOIN pg_namespace n
                ON n.oid = p.pronamespace
            WHERE n.nspname = 'audit'
              AND p.proname = 'generic_audit_trigger'
        )

    UNION ALL

    /* --------------------------------------------------------
       Check 7: masking function exists
       -------------------------------------------------------- */

    SELECT
        'Audit masking function exists',
        EXISTS
        (
            SELECT 1
            FROM pg_proc p
            JOIN pg_namespace n
                ON n.oid = p.pronamespace
            WHERE n.nspname = 'audit'
              AND p.proname = 'mask_audit_value'
        )

    UNION ALL

    /* --------------------------------------------------------
       Check 8: no orphan audit changes
       -------------------------------------------------------- */

    SELECT
        'No orphan audit_change records',
        NOT EXISTS
        (
            SELECT 1
            FROM audit.audit_change c
            LEFT JOIN audit.audit_event e
                ON e.audit_event_id = c.audit_event_id
            WHERE e.audit_event_id IS NULL
        )

    UNION ALL

    /* --------------------------------------------------------
       Check 9: no duplicate audit event IDs
       -------------------------------------------------------- */

    SELECT
        'No duplicate audit_event_id values',
        NOT EXISTS
        (
            SELECT 1
            FROM audit.audit_event
            GROUP BY audit_event_id
            HAVING COUNT(*) > 1
        )
)

SELECT
    check_name,
    CASE
        WHEN passed
        THEN 'PASS'
        ELSE 'FAIL'
    END AS status
FROM checks
ORDER BY
    check_name;


/* ============================================================
   34. FINAL RESULT
   ============================================================ */

WITH final_checks AS
(
    SELECT
        EXISTS
        (
            SELECT 1
            FROM information_schema.schemata
            WHERE schema_name = 'audit'
        ) AS check_schema,

        EXISTS
        (
            SELECT 1
            FROM information_schema.tables
            WHERE table_schema = 'audit'
              AND table_name = 'audit_event'
        ) AS check_event_table,

        EXISTS
        (
            SELECT 1
            FROM information_schema.tables
            WHERE table_schema = 'audit'
              AND table_name = 'audit_change'
        ) AS check_change_table,

        (
            SELECT COUNT(*) = 20
            FROM tmp_expected_audit_tables e
            WHERE EXISTS
            (
                SELECT 1
                FROM information_schema.triggers t
                WHERE t.event_object_schema = e.table_schema
                  AND t.event_object_table = e.table_name
                  AND t.trigger_name LIKE 'trg_audit_%'
            )
        ) AS check_table_coverage,

        (
            SELECT COUNT(*) = 60
            FROM information_schema.triggers t
            JOIN tmp_expected_audit_tables e
                ON e.table_schema = t.event_object_schema
               AND e.table_name = t.event_object_table
            WHERE t.trigger_name LIKE 'trg_audit_%'
        ) AS check_trigger_coverage,

        EXISTS
        (
            SELECT 1
            FROM pg_proc p
            JOIN pg_namespace n
                ON n.oid = p.pronamespace
            WHERE n.nspname = 'audit'
              AND p.proname = 'generic_audit_trigger'
        ) AS check_generic_trigger,

        EXISTS
        (
            SELECT 1
            FROM pg_proc p
            JOIN pg_namespace n
                ON n.oid = p.pronamespace
            WHERE n.nspname = 'audit'
              AND p.proname = 'mask_audit_value'
        ) AS check_masking,

        NOT EXISTS
        (
            SELECT 1
            FROM audit.audit_change c
            LEFT JOIN audit.audit_event e
                ON e.audit_event_id = c.audit_event_id
            WHERE e.audit_event_id IS NULL
        ) AS check_orphan_changes,

        NOT EXISTS
        (
            SELECT 1
            FROM audit.audit_event
            GROUP BY audit_event_id
            HAVING COUNT(*) > 1
        ) AS check_duplicate_events
)

SELECT
    CASE
        WHEN
            check_schema
            AND check_event_table
            AND check_change_table
            AND check_table_coverage
            AND check_trigger_coverage
            AND check_generic_trigger
            AND check_masking
            AND check_orphan_changes
            AND check_duplicate_events
        THEN 'PASS'
        ELSE 'CHECK_REQUIRED'
    END AS final_audit_validation_status,

    (
        check_schema::int
        + check_event_table::int
        + check_change_table::int
        + check_table_coverage::int
        + check_trigger_coverage::int
        + check_generic_trigger::int
        + check_masking::int
        + check_orphan_changes::int
        + check_duplicate_events::int
    ) AS passed_checks,

    9 AS total_checks
FROM final_checks;


/* ============================================================
   35. END
   ============================================================ */

SELECT
    '==================================================' AS section,
    'CORE BANKING AUDIT VALIDATION COMPLETED' AS message,
    CURRENT_TIMESTAMP AS validation_time;