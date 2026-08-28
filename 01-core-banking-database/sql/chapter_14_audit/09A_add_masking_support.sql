/* ============================================================
   PROJECT 01 - BANKING DATABASE DESIGN
   CHAPTER 14 - AUDIT DATA MODEL

   FILE 09A
   ADD MASKING SUPPORT

   PURPOSE
   ------------------------------------------------------------
   Protect sensitive customer/card information when writing
   audit records.

   Business data remains unchanged.

   Only audit values are masked.

   CURRENTLY SUPPORTED

       national_id
       passport_no
       card_number
       cvv_hash
       pin_hash

   ============================================================ */


/* ============================================================
   FUNCTION
   MASK NATIONAL ID

   Example

       012345678901

   becomes

       ********8901
   ============================================================ */

CREATE OR REPLACE FUNCTION audit.mask_national_id
(
    p_value TEXT
)
RETURNS TEXT
LANGUAGE plpgsql
IMMUTABLE
AS $$
BEGIN

    IF p_value IS NULL THEN
        RETURN NULL;
    END IF;

    IF length(p_value) <= 4 THEN
        RETURN '****';
    END IF;

    RETURN repeat('*', length(p_value) - 4)
           || right(p_value, 4);

END;
$$;


/* ============================================================
   FUNCTION
   MASK PASSPORT
   ============================================================ */

CREATE OR REPLACE FUNCTION audit.mask_passport_no
(
    p_value TEXT
)
RETURNS TEXT
LANGUAGE plpgsql
IMMUTABLE
AS $$
BEGIN

    IF p_value IS NULL THEN
        RETURN NULL;
    END IF;

    IF length(p_value) <= 4 THEN
        RETURN '****';
    END IF;

    RETURN repeat('*', length(p_value) - 4)
           || right(p_value, 4);

END;
$$;


/* ============================================================
   FUNCTION
   MASK CARD NUMBER

   Example

       9704001234567890

   becomes

       9704********7890
   ============================================================ */

CREATE OR REPLACE FUNCTION audit.mask_card_number
(
    p_value TEXT
)
RETURNS TEXT
LANGUAGE plpgsql
IMMUTABLE
AS $$
BEGIN

    IF p_value IS NULL THEN
        RETURN NULL;
    END IF;

    IF length(p_value) < 8 THEN
        RETURN '********';
    END IF;

    RETURN left(p_value, 4)
           || repeat('*', length(p_value) - 8)
           || right(p_value, 4);

END;
$$;


/* ============================================================
   FUNCTION
   MASK HASH VALUE

   Used for:

       cvv_hash
       pin_hash

   Never expose hash values in audit logs.
   ============================================================ */

CREATE OR REPLACE FUNCTION audit.mask_hash_value
(
    p_value TEXT
)
RETURNS TEXT
LANGUAGE plpgsql
IMMUTABLE
AS $$
BEGIN

    IF p_value IS NULL THEN
        RETURN NULL;
    END IF;

    RETURN '[PROTECTED]';

END;
$$;


/* ============================================================
   FUNCTION
   GENERIC COLUMN MASKER

   Returns masked JSONB value.

   ============================================================ */

CREATE OR REPLACE FUNCTION audit.mask_audit_value
(
    p_column_name TEXT,
    p_value JSONB
)
RETURNS JSONB
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE

    v_text TEXT;

BEGIN

    IF p_value IS NULL THEN
        RETURN NULL;
    END IF;

    v_text := trim(both '"' from p_value::TEXT);

    CASE lower(p_column_name)

        WHEN 'national_id' THEN

            RETURN to_jsonb(
                audit.mask_national_id(v_text)
            );

        WHEN 'passport_no' THEN

            RETURN to_jsonb(
                audit.mask_passport_no(v_text)
            );

        WHEN 'card_number' THEN

            RETURN to_jsonb(
                audit.mask_card_number(v_text)
            );

        WHEN 'cvv_hash' THEN

            RETURN to_jsonb(
                audit.mask_hash_value(v_text)
            );

        WHEN 'pin_hash' THEN

            RETURN to_jsonb(
                audit.mask_hash_value(v_text)
            );

        ELSE

            RETURN p_value;

    END CASE;

END;
$$;


/* ============================================================
   VALIDATION TESTS
   ============================================================ */

SELECT
    audit.mask_national_id('012345678901')
        AS national_id_masked;

SELECT
    audit.mask_passport_no('B123456789')
        AS passport_masked;

SELECT
    audit.mask_card_number('9704001234567890')
        AS card_masked;

SELECT
    audit.mask_hash_value('abcdef123456')
        AS hash_masked;

SELECT
    audit.mask_audit_value(
        'national_id',
        '"012345678901"'::JSONB
    ) AS generic_mask_test;


-- Sau khi chạy file này

-- Kiểm tra:
-- SELECT audit.mask_national_id('012345678901');

-- SELECT audit.mask_passport_no('B123456789');

-- SELECT audit.mask_card_number('9704001234567890');