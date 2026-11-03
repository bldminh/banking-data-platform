-- ==========================================================
-- FILE: 04_account_tables.sql
-- DOMAIN: ACCOUNT
-- PROJECT: BANKING DATA PLATFORM
-- ==========================================================

-- ==========================================================
-- ACCOUNT MASTER
-- ==========================================================

CREATE TABLE account.account
(
    account_id BIGSERIAL PRIMARY KEY,

    account_number VARCHAR(30) NOT NULL,

    customer_id BIGINT NOT NULL,

    account_type_code VARCHAR(20) NOT NULL,

    currency_code VARCHAR(3) NOT NULL,

    account_status_code VARCHAR(20) NOT NULL,

    branch_id BIGINT,

    open_date DATE NOT NULL,

    close_date DATE,

    overdraft_allowed BOOLEAN NOT NULL DEFAULT FALSE,

    overdraft_limit NUMERIC(18,2) NOT NULL DEFAULT 0,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    updated_at TIMESTAMP,

    created_by VARCHAR(100) DEFAULT 'SYSTEM',

    updated_by VARCHAR(100)
);

-- ==========================================================
-- UNIQUE
-- ==========================================================

ALTER TABLE account.account
ADD CONSTRAINT uk_account_number
UNIQUE(account_number);

-- ==========================================================
-- FOREIGN KEYS
-- ==========================================================

ALTER TABLE account.account
ADD CONSTRAINT fk_account_customer
FOREIGN KEY(customer_id)
REFERENCES customer.customer(customer_id);

ALTER TABLE account.account
ADD CONSTRAINT fk_account_type
FOREIGN KEY(account_type_code)
REFERENCES ref.account_type(account_type_code);

ALTER TABLE account.account
ADD CONSTRAINT fk_account_currency
FOREIGN KEY(currency_code)
REFERENCES ref.currency(currency_code);

ALTER TABLE account.account
ADD CONSTRAINT fk_account_status
FOREIGN KEY(account_status_code)
REFERENCES ref.account_status(account_status_code);

-- ==========================================================
-- CHECK CONSTRAINTS
-- ==========================================================

ALTER TABLE account.account
ADD CONSTRAINT chk_account_overdraft_limit
CHECK(overdraft_limit >= 0);

ALTER TABLE account.account
ADD CONSTRAINT chk_account_close_date
CHECK(
    close_date IS NULL
    OR close_date >= open_date
);

-- ==========================================================
-- COMMENT
-- ==========================================================

COMMENT ON TABLE account.account
IS 'Account master information';



-- ==========================================================
-- ACCOUNT BALANCE
-- ==========================================================

CREATE TABLE account.account_balance
(
    account_id BIGINT PRIMARY KEY,

    current_balance NUMERIC(18,2) NOT NULL DEFAULT 0,

    available_balance NUMERIC(18,2) NOT NULL DEFAULT 0,

    hold_amount NUMERIC(18,2) NOT NULL DEFAULT 0,

    last_transaction_datetime TIMESTAMP,

    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ==========================================================
-- FK
-- ==========================================================

ALTER TABLE account.account_balance
ADD CONSTRAINT fk_balance_account
FOREIGN KEY(account_id)
REFERENCES account.account(account_id);

-- ==========================================================
-- CHECK
-- ==========================================================

ALTER TABLE account.account_balance
ADD CONSTRAINT chk_current_balance
CHECK(current_balance >= 0);

ALTER TABLE account.account_balance
ADD CONSTRAINT chk_available_balance
CHECK(available_balance >= 0);

ALTER TABLE account.account_balance
ADD CONSTRAINT chk_hold_amount
CHECK(hold_amount >= 0);

-- ==========================================================
-- COMMENT
-- ==========================================================

COMMENT ON TABLE account.account_balance
IS 'Current account balance';



-- ==========================================================
-- ACCOUNT LIMIT
-- ==========================================================

CREATE TABLE account.account_limit
(
    limit_id BIGSERIAL PRIMARY KEY,

    account_id BIGINT NOT NULL,

    daily_transfer_limit NUMERIC(18,2),

    daily_withdrawal_limit NUMERIC(18,2),

    daily_qr_limit NUMERIC(18,2),

    effective_date DATE NOT NULL,

    expiry_date DATE,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ==========================================================
-- FK
-- ==========================================================

ALTER TABLE account.account_limit
ADD CONSTRAINT fk_limit_account
FOREIGN KEY(account_id)
REFERENCES account.account(account_id);

-- ==========================================================
-- CHECK
-- ==========================================================

ALTER TABLE account.account_limit
ADD CONSTRAINT chk_transfer_limit
CHECK(
    daily_transfer_limit IS NULL
    OR daily_transfer_limit >= 0
);

ALTER TABLE account.account_limit
ADD CONSTRAINT chk_withdrawal_limit
CHECK(
    daily_withdrawal_limit IS NULL
    OR daily_withdrawal_limit >= 0
);

ALTER TABLE account.account_limit
ADD CONSTRAINT chk_qr_limit
CHECK(
    daily_qr_limit IS NULL
    OR daily_qr_limit >= 0
);

-- ==========================================================
-- COMMENT
-- ==========================================================

COMMENT ON TABLE account.account_limit
IS 'Account transaction limits';



-- ==========================================================
-- ACCOUNT STATUS HISTORY
-- ==========================================================

CREATE TABLE account.account_status_history
(
    history_id BIGSERIAL PRIMARY KEY,

    account_id BIGINT NOT NULL,

    old_status_code VARCHAR(20),

    new_status_code VARCHAR(20) NOT NULL,

    change_reason VARCHAR(500),

    changed_by VARCHAR(100),

    changed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ==========================================================
-- FK
-- ==========================================================

ALTER TABLE account.account_status_history
ADD CONSTRAINT fk_account_status_history_account
FOREIGN KEY(account_id)
REFERENCES account.account(account_id);

ALTER TABLE account.account_status_history
ADD CONSTRAINT fk_account_status_history_old
FOREIGN KEY(old_status_code)
REFERENCES ref.account_status(account_status_code);

ALTER TABLE account.account_status_history
ADD CONSTRAINT fk_account_status_history_new
FOREIGN KEY(new_status_code)
REFERENCES ref.account_status(account_status_code);

-- ==========================================================
-- COMMENT
-- ==========================================================

COMMENT ON TABLE account.account_status_history
IS 'Account status change history';