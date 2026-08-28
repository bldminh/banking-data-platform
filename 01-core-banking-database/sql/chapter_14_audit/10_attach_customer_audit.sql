/* ============================================================
   PROJECT 01 - BANKING DATABASE DESIGN
   CHAPTER 14 - AUDIT DATA MODEL

   FILE 10
   ATTACH CUSTOMER AUDIT

   PURPOSE
   ------------------------------------------------------------
   Enable automatic auditing for Customer Domain.

   TABLES

       customer.customer
       customer.customer_address
       customer.customer_contact
       customer.customer_employment
       customer.customer_beneficiary
       customer.customer_kyc

   ============================================================ */


/* ============================================================
   SAFETY
   DROP EXISTING TRIGGERS
   ============================================================ */


/* customer.customer */

DROP TRIGGER IF EXISTS trg_audit_customer
ON customer.customer;


/* customer.customer_address */

DROP TRIGGER IF EXISTS trg_audit_customer_address
ON customer.customer_address;


/* customer.customer_contact */

DROP TRIGGER IF EXISTS trg_audit_customer_contact
ON customer.customer_contact;


/* customer.customer_employment */

DROP TRIGGER IF EXISTS trg_audit_customer_employment
ON customer.customer_employment;


/* customer.customer_beneficiary */

DROP TRIGGER IF EXISTS trg_audit_customer_beneficiary
ON customer.customer_beneficiary;


/* customer.customer_kyc */

DROP TRIGGER IF EXISTS trg_audit_customer_kyc
ON customer.customer_kyc;



/* ============================================================
   CUSTOMER MASTER
   ============================================================ */

CREATE TRIGGER trg_audit_customer
AFTER INSERT OR UPDATE OR DELETE
ON customer.customer
FOR EACH ROW
EXECUTE FUNCTION audit.generic_audit_trigger
(
    'customer_id'
);



/* ============================================================
   CUSTOMER ADDRESS
   ============================================================ */

CREATE TRIGGER trg_audit_customer_address
AFTER INSERT OR UPDATE OR DELETE
ON customer.customer_address
FOR EACH ROW
EXECUTE FUNCTION audit.generic_audit_trigger
(
    'address_id'
);



/* ============================================================
   CUSTOMER CONTACT
   ============================================================ */

CREATE TRIGGER trg_audit_customer_contact
AFTER INSERT OR UPDATE OR DELETE
ON customer.customer_contact
FOR EACH ROW
EXECUTE FUNCTION audit.generic_audit_trigger
(
    'contact_id'
);



/* ============================================================
   CUSTOMER EMPLOYMENT
   ============================================================ */

CREATE TRIGGER trg_audit_customer_employment
AFTER INSERT OR UPDATE OR DELETE
ON customer.customer_employment
FOR EACH ROW
EXECUTE FUNCTION audit.generic_audit_trigger
(
    'employment_id'
);



/* ============================================================
   CUSTOMER BENEFICIARY
   ============================================================ */

CREATE TRIGGER trg_audit_customer_beneficiary
AFTER INSERT OR UPDATE OR DELETE
ON customer.customer_beneficiary
FOR EACH ROW
EXECUTE FUNCTION audit.generic_audit_trigger
(
    'beneficiary_id'
);



/* ============================================================
   CUSTOMER KYC
   ============================================================ */

CREATE TRIGGER trg_audit_customer_kyc
AFTER INSERT OR UPDATE OR DELETE
ON customer.customer_kyc
FOR EACH ROW
EXECUTE FUNCTION audit.generic_audit_trigger
(
    'kyc_id'
);



/* ============================================================
   VALIDATION 01
   SHOW CUSTOMER DOMAIN TRIGGERS
   ============================================================ */

SELECT
    event_object_schema,
    event_object_table,
    trigger_name,
    action_timing,
    event_manipulation
FROM information_schema.triggers
WHERE event_object_schema = 'customer'
ORDER BY
    event_object_table,
    trigger_name;



/* ============================================================
   VALIDATION 02
   COUNT TRIGGERS
   ============================================================ */

SELECT
    COUNT(*) AS customer_audit_trigger_count
FROM information_schema.triggers
WHERE event_object_schema = 'customer'
AND trigger_name LIKE 'trg_audit_%';



/* ============================================================
   VALIDATION 03
   LIST TABLES WITH AUDIT ENABLED
   ============================================================ */

SELECT
    event_object_table,
    trigger_name
FROM information_schema.triggers
WHERE event_object_schema = 'customer'
AND trigger_name LIKE 'trg_audit_%'
ORDER BY event_object_table;


-- Sau khi chạy file 10
-- SELECT
--     event_object_table,
--     trigger_name
-- FROM information_schema.triggers
-- WHERE event_object_schema = 'customer'
-- ORDER BY event_object_table;


-- UPDATE customer.customer
-- SET full_name = 'TEST AUDIT CUSTOMER'
-- WHERE customer_id = 1;


-- SELECT
--     audit_event_id,
--     event_time,
--     event_type,
--     entity_schema,
--     entity_table,
--     entity_id
-- FROM audit.audit_event
-- ORDER BY audit_event_id DESC
-- LIMIT 10;



-- SELECT
--     column_name,
--     old_value,
--     new_value
-- FROM audit.audit_change
-- ORDER BY audit_change_id DESC
-- LIMIT 20;



-- UPDATE customer.customer
-- SET national_id = '012345678901'
-- WHERE customer_id = 1;



-- SELECT
--     column_name,
--     old_value,
--     new_value
-- FROM audit.audit_change
-- WHERE column_name = 'national_id'
-- ORDER BY audit_change_id DESC;