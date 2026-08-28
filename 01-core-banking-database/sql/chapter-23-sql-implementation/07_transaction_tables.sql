-- ==========================================================
-- FILE: 07_transaction_tables.sql
-- DOMAIN: TRANSACTION
-- PROJECT: BANKING DATA PLATFORM
-- ==========================================================

-- ==========================================================
-- TRANSACTION MASTER
-- ==========================================================

CREATE TABLE txn.transaction
(
    transaction_id BIGSERIAL PRIMARY KEY,

    transaction_reference VARCHAR(50) NOT NULL,

    transaction_type_code VARCHAR(30) NOT NULL,

    transaction_status_code VARCHAR(30) NOT NULL,

    transaction_channel_code VARCHAR(30) NOT NULL,

    source_account_id BIGINT,

    destination_account_id BIGINT,

    card_id BIGINT,

    loan_id BIGINT,

    merchant_id BIGINT,

    atm_id BIGINT,

    amount NUMERIC(18,2) NOT NULL,

    fee_amount NUMERIC(18,2) NOT NULL DEFAULT 0,

    currency_code VARCHAR(3) NOT NULL,

    transaction_datetime TIMESTAMP NOT NULL,

    description VARCHAR(500),

    external_reference VARCHAR(100),

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ==========================================================
-- UNIQUE
-- ==========================================================

ALTER TABLE txn.transaction
ADD CONSTRAINT uk_transaction_reference
UNIQUE(transaction_reference);

-- ==========================================================
-- FOREIGN KEYS
-- ==========================================================

ALTER TABLE txn.transaction
ADD CONSTRAINT fk_txn_type
FOREIGN KEY(transaction_type_code)
REFERENCES ref.transaction_type(transaction_type_code);

ALTER TABLE txn.transaction
ADD CONSTRAINT fk_txn_status
FOREIGN KEY(transaction_status_code)
REFERENCES ref.transaction_status(transaction_status_code);

ALTER TABLE txn.transaction
ADD CONSTRAINT fk_txn_channel
FOREIGN KEY(transaction_channel_code)
REFERENCES ref.transaction_channel(transaction_channel_code);

ALTER TABLE txn.transaction
ADD CONSTRAINT fk_txn_source_account
FOREIGN KEY(source_account_id)
REFERENCES account.account(account_id);

ALTER TABLE txn.transaction
ADD CONSTRAINT fk_txn_destination_account
FOREIGN KEY(destination_account_id)
REFERENCES account.account(account_id);

ALTER TABLE txn.transaction
ADD CONSTRAINT fk_txn_card
FOREIGN KEY(card_id)
REFERENCES card.card(card_id);

ALTER TABLE txn.transaction
ADD CONSTRAINT fk_txn_loan
FOREIGN KEY(loan_id)
REFERENCES loan.loan(loan_id);

ALTER TABLE txn.transaction
ADD CONSTRAINT fk_txn_currency
FOREIGN KEY(currency_code)
REFERENCES ref.currency(currency_code);

-- merchant và atm sẽ được bổ sung sau khi tạo bảng channel

-- ==========================================================
-- CHECK CONSTRAINTS
-- ==========================================================

ALTER TABLE txn.transaction
ADD CONSTRAINT chk_txn_amount
CHECK(amount > 0);

ALTER TABLE txn.transaction
ADD CONSTRAINT chk_txn_fee
CHECK(fee_amount >= 0);

ALTER TABLE txn.transaction
ADD CONSTRAINT chk_source_destination
CHECK(
    source_account_id IS NULL
    OR destination_account_id IS NULL
    OR source_account_id <> destination_account_id
);

-- ==========================================================
-- COMMENT
-- ==========================================================

COMMENT ON TABLE txn.transaction
IS 'Financial transaction master table';

COMMENT ON COLUMN txn.transaction.transaction_reference
IS 'Unique transaction reference number';

COMMENT ON COLUMN txn.transaction.amount
IS 'Transaction amount';

COMMENT ON COLUMN txn.transaction.transaction_datetime
IS 'Transaction timestamp';



-- ==========================================================
-- TRANSACTION STATUS HISTORY
-- ==========================================================

CREATE TABLE txn.transaction_status_history
(
    history_id BIGSERIAL PRIMARY KEY,

    transaction_id BIGINT NOT NULL,

    old_status_code VARCHAR(30),

    new_status_code VARCHAR(30) NOT NULL,

    change_reason VARCHAR(500),

    changed_by VARCHAR(100),

    changed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ==========================================================
-- FK
-- ==========================================================

ALTER TABLE txn.transaction_status_history
ADD CONSTRAINT fk_txn_history_transaction
FOREIGN KEY(transaction_id)
REFERENCES txn.transaction(transaction_id);

ALTER TABLE txn.transaction_status_history
ADD CONSTRAINT fk_txn_history_old_status
FOREIGN KEY(old_status_code)
REFERENCES ref.transaction_status(transaction_status_code);

ALTER TABLE txn.transaction_status_history
ADD CONSTRAINT fk_txn_history_new_status
FOREIGN KEY(new_status_code)
REFERENCES ref.transaction_status(transaction_status_code);

-- ==========================================================
-- COMMENT
-- ==========================================================

COMMENT ON TABLE txn.transaction_status_history
IS 'Transaction status history';