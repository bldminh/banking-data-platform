/* ============================================================
   PROJECT 01 - BANKING DATABASE DESIGN
   CHAPTER 14 - AUDIT DATA MODEL
   FILE 06 - INSERT AUDIT TEST DATA
   ============================================================ */


/* ============================================================
   TEST CASE 01
   ------------------------------------------------------------
   Employee blocks an account
   ============================================================ */

DO $$
DECLARE
    v_event_id BIGINT;
    v_event_time TIMESTAMPTZ;
BEGIN

    SELECT
        audit_event_id,
        audit_event_time
    INTO
        v_event_id,
        v_event_time
    FROM audit.create_audit_event
    (
        CURRENT_TIMESTAMP,
        'EMPLOYEE',
        '1025',
        'UPDATE',
        'ACCOUNT_BLOCKED',
        'account',
        'account',
        '1001',
        'branch-banking',
        'BRANCH',
        'REQ-000001',
        'CORR-000001',
        'SESSION-000001',
        'TXN-000001',
        'SUCCESS',
        'FRAUD_REVIEW',
        '192.168.1.100'::INET,
        'Banking Workstation',
        '{"branch_code":"HN001"}'::JSONB
    );

    PERFORM audit.create_audit_change
    (
        v_event_id,
        v_event_time,
        'status',
        '"ACTIVE"'::JSONB,
        '"BLOCKED"'::JSONB,
        'VARCHAR',
        'MODIFIED'
    );

END;
$$;


/* ============================================================
   TEST CASE 02
   ------------------------------------------------------------
   Customer updates email
   ============================================================ */

DO $$
DECLARE
    v_event_id BIGINT;
    v_event_time TIMESTAMPTZ;
BEGIN

    SELECT
        audit_event_id,
        audit_event_time
    INTO
        v_event_id,
        v_event_time
    FROM audit.create_audit_event
    (
        CURRENT_TIMESTAMP,
        'CUSTOMER',
        '10001',
        'UPDATE',
        'CUSTOMER_UPDATED',
        'customer',
        'customer',
        '10001',
        'mobile-banking',
        'MOBILE_APP',
        'REQ-000002',
        'CORR-000002',
        'SESSION-000002',
        NULL,
        'SUCCESS',
        'CUSTOMER_REQUEST',
        NULL,
        'Mobile App',
        '{"application_version":"1.0.0"}'::JSONB
    );

    PERFORM audit.create_audit_change
    (
        v_event_id,
        v_event_time,
        'email',
        '"old@example.com"'::JSONB,
        '"new@example.com"'::JSONB,
        'VARCHAR',
        'MODIFIED'
    );

END;
$$;


/* ============================================================
   TEST CASE 03
   ------------------------------------------------------------
   Loan approval
   ============================================================ */

DO $$
DECLARE
    v_event_id BIGINT;
    v_event_time TIMESTAMPTZ;
BEGIN

    SELECT
        audit_event_id,
        audit_event_time
    INTO
        v_event_id,
        v_event_time
    FROM audit.create_audit_event
    (
        CURRENT_TIMESTAMP,
        'EMPLOYEE',
        '2005',
        'APPROVE',
        'LOAN_APPROVED',
        'loan',
        'loan',
        '5001',
        'loan-system',
        'BRANCH',
        'REQ-000003',
        'CORR-000003',
        'SESSION-000003',
        NULL,
        'SUCCESS',
        'CREDIT_APPROVAL',
        '192.168.1.101'::INET,
        'Banking Workstation',
        '{"branch_code":"HN002"}'::JSONB
    );

END;
$$;


/* ============================================================
   TEST CASE 04
   ------------------------------------------------------------
   Unauthorized account closure
   ============================================================ */

DO $$
BEGIN

    PERFORM audit.create_audit_event
    (
        CURRENT_TIMESTAMP,
        'EMPLOYEE',
        '3001',
        'CLOSE',
        'ACCOUNT_CLOSED',
        'account',
        'account',
        '1002',
        'branch-banking',
        'BRANCH',
        'REQ-000004',
        'CORR-000004',
        'SESSION-000004',
        NULL,
        'DENIED',
        'INSUFFICIENT_PERMISSION',
        '192.168.1.102'::INET,
        'Banking Workstation',
        '{"required_role":"ACCOUNT_MANAGER"}'::JSONB
    );

END;
$$;


/* ============================================================
   TEST CASE 05
   ------------------------------------------------------------
   Transaction reversal
   ============================================================ */

DO $$
DECLARE
    v_event_id BIGINT;
    v_event_time TIMESTAMPTZ;
BEGIN

    SELECT
        audit_event_id,
        audit_event_time
    INTO
        v_event_id,
        v_event_time
    FROM audit.create_audit_event
    (
        CURRENT_TIMESTAMP,
        'SYSTEM',
        'payment-service',
        'UPDATE',
        'TRANSACTION_REVERSED',
        'txn',
        'transaction',
        '88888',
        'payment-service',
        'API',
        'REQ-000005',
        'CORR-000005',
        'SESSION-000005',
        'TXN-88888',
        'SUCCESS',
        'CUSTOMER_DISPUTE',
        NULL,
        'API',
        '{"service_version":"2.1.0"}'::JSONB
    );

    PERFORM audit.create_audit_change
    (
        v_event_id,
        v_event_time,
        'status',
        '"COMPLETED"'::JSONB,
        '"REVERSED"'::JSONB,
        'VARCHAR',
        'MODIFIED'
    );

END;
$$;