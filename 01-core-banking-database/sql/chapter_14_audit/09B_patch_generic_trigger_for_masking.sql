/* ============================================================
   PROJECT 01 - BANKING DATABASE DESIGN
   CHAPTER 14 - AUDIT DATA MODEL

   FILE 09B
   PATCH GENERIC AUDIT TRIGGER FOR MASKING

   PURPOSE
   ------------------------------------------------------------
   Ensure all audit values pass through masking layer before
   being stored in audit.audit_change.

   Requires:

       09_create_generic_audit_trigger.sql
       09A_add_masking_support.sql

   ============================================================ */


/* ============================================================
   PATCH
   WRITE COLUMN CHANGE
   ============================================================ */

CREATE OR REPLACE FUNCTION audit.write_column_change
(
    p_audit_event_id BIGINT,
    p_audit_event_time TIMESTAMPTZ,
    p_column_name TEXT,
    p_old_value JSONB,
    p_new_value JSONB
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE

    v_change_type VARCHAR(20);

    v_old_value JSONB;
    v_new_value JSONB;

BEGIN

    /* --------------------------------------------------------
       MASK OLD VALUE
       -------------------------------------------------------- */

    v_old_value :=
        audit.mask_audit_value(
            p_column_name,
            p_old_value
        );

    /* --------------------------------------------------------
       MASK NEW VALUE
       -------------------------------------------------------- */

    v_new_value :=
        audit.mask_audit_value(
            p_column_name,
            p_new_value
        );

    /* --------------------------------------------------------
       DETERMINE CHANGE TYPE
       -------------------------------------------------------- */

    IF v_old_value IS NULL
       AND v_new_value IS NOT NULL
    THEN

        v_change_type := 'ADDED';

    ELSIF v_old_value IS NOT NULL
          AND v_new_value IS NULL
    THEN

        v_change_type := 'REMOVED';

    ELSE

        v_change_type := 'MODIFIED';

    END IF;

    /* --------------------------------------------------------
       WRITE AUDIT CHANGE
       -------------------------------------------------------- */

    PERFORM audit.create_audit_change
    (
        p_audit_event_id,
        p_audit_event_time,
        p_column_name,
        v_old_value,
        v_new_value,
        NULL,
        v_change_type
    );

END;
$$;


/* ============================================================
   VALIDATION 01
   MASK NATIONAL ID
   ============================================================ */

SELECT
    audit.mask_audit_value(
        'national_id',
        '"012345678901"'::JSONB
    ) AS masked_national_id;


/* ============================================================
   VALIDATION 02
   MASK PASSPORT
   ============================================================ */

SELECT
    audit.mask_audit_value(
        'passport_no',
        '"B123456789"'::JSONB
    ) AS masked_passport;


/* ============================================================
   VALIDATION 03
   MASK CARD NUMBER
   ============================================================ */

SELECT
    audit.mask_audit_value(
        'card_number',
        '"9704001234567890"'::JSONB
    ) AS masked_card;


/* ============================================================
   VALIDATION 04
   MASK PIN HASH
   ============================================================ */

SELECT
    audit.mask_audit_value(
        'pin_hash',
        '"ABCDEF123456"'::JSONB
    ) AS masked_pin;


/* ============================================================
   VALIDATION 05
   NON-SENSITIVE VALUE
   ============================================================ */

SELECT
    audit.mask_audit_value(
        'customer_status_code',
        '"ACTIVE"'::JSONB
    ) AS non_sensitive_value;


/* ============================================================
   FUNCTION CHECK
   ============================================================ */

SELECT
    routine_schema,
    routine_name
FROM information_schema.routines
WHERE routine_schema = 'audit'
  AND routine_name = 'write_column_change';


-- test
-- SELECT audit.mask_audit_value(
--     'national_id',
--     '"012345678901"'::JSONB
-- );

-- SELECT audit.mask_audit_value(
--     'card_number',
--     '"9704001234567890"'::JSONB
-- );
