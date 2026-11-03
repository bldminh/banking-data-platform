-- ==========================================================
-- FILE: 06_loan_tables.sql
-- DOMAIN: LOAN
-- PROJECT: BANKING DATA PLATFORM
-- ==========================================================

-- ==========================================================
-- LOAN MASTER
-- ==========================================================

CREATE TABLE loan.loan
(
    loan_id BIGSERIAL PRIMARY KEY,

    loan_number VARCHAR(30) NOT NULL,

    customer_id BIGINT NOT NULL,

    account_id BIGINT NOT NULL,

    loan_type_code VARCHAR(20) NOT NULL,

    loan_status_code VARCHAR(20) NOT NULL,

    principal_amount NUMERIC(18,2) NOT NULL,

    interest_rate NUMERIC(8,4) NOT NULL,

    loan_term_month INTEGER NOT NULL,

    outstanding_principal NUMERIC(18,2) NOT NULL,

    outstanding_interest NUMERIC(18,2) NOT NULL DEFAULT 0,

    disbursement_date DATE,

    maturity_date DATE,

    approved_date DATE,

    closed_date DATE,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    updated_at TIMESTAMP,

    created_by VARCHAR(100) DEFAULT 'SYSTEM',

    updated_by VARCHAR(100)
);

-- ==========================================================
-- UNIQUE
-- ==========================================================

ALTER TABLE loan.loan
ADD CONSTRAINT uk_loan_number
UNIQUE(loan_number);

-- ==========================================================
-- FK
-- ==========================================================

ALTER TABLE loan.loan
ADD CONSTRAINT fk_loan_customer
FOREIGN KEY(customer_id)
REFERENCES customer.customer(customer_id);

ALTER TABLE loan.loan
ADD CONSTRAINT fk_loan_account
FOREIGN KEY(account_id)
REFERENCES account.account(account_id);

ALTER TABLE loan.loan
ADD CONSTRAINT fk_loan_type
FOREIGN KEY(loan_type_code)
REFERENCES ref.loan_type(loan_type_code);

ALTER TABLE loan.loan
ADD CONSTRAINT fk_loan_status
FOREIGN KEY(loan_status_code)
REFERENCES ref.loan_status(loan_status_code);

-- ==========================================================
-- CHECK
-- ==========================================================

ALTER TABLE loan.loan
ADD CONSTRAINT chk_loan_amount
CHECK(principal_amount > 0);

ALTER TABLE loan.loan
ADD CONSTRAINT chk_interest_rate
CHECK(interest_rate >= 0);

ALTER TABLE loan.loan
ADD CONSTRAINT chk_outstanding_principal
CHECK(outstanding_principal >= 0);

ALTER TABLE loan.loan
ADD CONSTRAINT chk_outstanding_interest
CHECK(outstanding_interest >= 0);

ALTER TABLE loan.loan
ADD CONSTRAINT chk_loan_term
CHECK(loan_term_month > 0);

-- ==========================================================
-- COMMENT
-- ==========================================================

COMMENT ON TABLE loan.loan
IS 'Loan master table';



-- ==========================================================
-- LOAN DISBURSEMENT
-- ==========================================================

CREATE TABLE loan.loan_disbursement
(
    disbursement_id BIGSERIAL PRIMARY KEY,

    loan_id BIGINT NOT NULL,

    disbursement_amount NUMERIC(18,2) NOT NULL,

    disbursement_date TIMESTAMP NOT NULL,

    destination_account_id BIGINT NOT NULL,

    remarks VARCHAR(500),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE loan.loan_disbursement
ADD CONSTRAINT fk_disbursement_loan
FOREIGN KEY(loan_id)
REFERENCES loan.loan(loan_id);

ALTER TABLE loan.loan_disbursement
ADD CONSTRAINT fk_disbursement_account
FOREIGN KEY(destination_account_id)
REFERENCES account.account(account_id);

ALTER TABLE loan.loan_disbursement
ADD CONSTRAINT chk_disbursement_amount
CHECK(disbursement_amount > 0);

COMMENT ON TABLE loan.loan_disbursement
IS 'Loan disbursement history';



-- ==========================================================
-- LOAN REPAYMENT
-- ==========================================================

CREATE TABLE loan.loan_repayment
(
    repayment_id BIGSERIAL PRIMARY KEY,

    loan_id BIGINT NOT NULL,

    repayment_account_id BIGINT NOT NULL,

    repayment_amount NUMERIC(18,2) NOT NULL,

    principal_paid NUMERIC(18,2) NOT NULL,

    interest_paid NUMERIC(18,2) NOT NULL,

    repayment_datetime TIMESTAMP NOT NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE loan.loan_repayment
ADD CONSTRAINT fk_repayment_loan
FOREIGN KEY(loan_id)
REFERENCES loan.loan(loan_id);

ALTER TABLE loan.loan_repayment
ADD CONSTRAINT fk_repayment_account
FOREIGN KEY(repayment_account_id)
REFERENCES account.account(account_id);

ALTER TABLE loan.loan_repayment
ADD CONSTRAINT chk_repayment_amount
CHECK(repayment_amount > 0);

ALTER TABLE loan.loan_repayment
ADD CONSTRAINT chk_principal_paid
CHECK(principal_paid >= 0);

ALTER TABLE loan.loan_repayment
ADD CONSTRAINT chk_interest_paid
CHECK(interest_paid >= 0);

COMMENT ON TABLE loan.loan_repayment
IS 'Loan repayment transactions';



-- ==========================================================
-- LOAN SCHEDULE
-- ==========================================================

CREATE TABLE loan.loan_schedule
(
    schedule_id BIGSERIAL PRIMARY KEY,

    loan_id BIGINT NOT NULL,

    installment_no INTEGER NOT NULL,

    due_date DATE NOT NULL,

    principal_due NUMERIC(18,2) NOT NULL,

    interest_due NUMERIC(18,2) NOT NULL,

    total_due NUMERIC(18,2) NOT NULL,

    paid_amount NUMERIC(18,2) DEFAULT 0,

    is_paid BOOLEAN NOT NULL DEFAULT FALSE,

    payment_date DATE,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE loan.loan_schedule
ADD CONSTRAINT fk_schedule_loan
FOREIGN KEY(loan_id)
REFERENCES loan.loan(loan_id);

ALTER TABLE loan.loan_schedule
ADD CONSTRAINT chk_installment_no
CHECK(installment_no > 0);

ALTER TABLE loan.loan_schedule
ADD CONSTRAINT chk_total_due
CHECK(total_due >= 0);

COMMENT ON TABLE loan.loan_schedule
IS 'Loan repayment schedule';



-- ==========================================================
-- LOAN STATUS HISTORY
-- ==========================================================

CREATE TABLE loan.loan_status_history
(
    history_id BIGSERIAL PRIMARY KEY,

    loan_id BIGINT NOT NULL,

    old_status_code VARCHAR(20),

    new_status_code VARCHAR(20) NOT NULL,

    change_reason VARCHAR(500),

    changed_by VARCHAR(100),

    changed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE loan.loan_status_history
ADD CONSTRAINT fk_loan_history_loan
FOREIGN KEY(loan_id)
REFERENCES loan.loan(loan_id);

ALTER TABLE loan.loan_status_history
ADD CONSTRAINT fk_loan_history_old_status
FOREIGN KEY(old_status_code)
REFERENCES ref.loan_status(loan_status_code);

ALTER TABLE loan.loan_status_history
ADD CONSTRAINT fk_loan_history_new_status
FOREIGN KEY(new_status_code)
REFERENCES ref.loan_status(loan_status_code);

COMMENT ON TABLE loan.loan_status_history
IS 'Loan status history';