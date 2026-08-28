INSERT INTO customer.customer
(
    customer_id,
    customer_code,
    national_id,
    first_name,
    last_name,
    full_name,
    date_of_birth,
    customer_status_code,
    risk_level_code,
    customer_since_date,
    created_at,
    created_by
)
VALUES
(
    999999,
    'CUST_AUDIT_TEST',
    '123456789012',
    'AUDIT',
    'TEST',
    'AUDIT TEST',
    DATE '1990-01-01',
    'ACTIVE',
    'LOW',
    CURRENT_DATE,
    CURRENT_TIMESTAMP,
    'AUDIT_TEST'
);