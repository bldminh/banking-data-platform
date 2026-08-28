-- ==========================================================
-- FILE: 05_card_tables.sql
-- DOMAIN: CARD
-- PROJECT: BANKING DATA PLATFORM
-- ==========================================================

-- ==========================================================
-- CARD MASTER
-- ==========================================================

CREATE TABLE card.card
(
    card_id BIGSERIAL PRIMARY KEY,

    card_number VARCHAR(32) NOT NULL,

    account_id BIGINT NOT NULL,

    customer_id BIGINT NOT NULL,

    card_type_code VARCHAR(20) NOT NULL,

    card_brand_code VARCHAR(20),

    card_status_code VARCHAR(20) NOT NULL,

    issue_date DATE NOT NULL,

    expiry_date DATE NOT NULL,

    activation_date DATE,

    cardholder_name VARCHAR(200) NOT NULL,

    cvv_hash VARCHAR(255),

    pin_hash VARCHAR(255),

    pin_retry_count INTEGER NOT NULL DEFAULT 0,

    credit_limit NUMERIC(18,2),

    outstanding_amount NUMERIC(18,2) DEFAULT 0,

    is_virtual BOOLEAN NOT NULL DEFAULT FALSE,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    updated_at TIMESTAMP,

    created_by VARCHAR(100) DEFAULT 'SYSTEM',

    updated_by VARCHAR(100)
);

-- ==========================================================
-- UNIQUE
-- ==========================================================

ALTER TABLE card.card
ADD CONSTRAINT uk_card_number
UNIQUE(card_number);

-- ==========================================================
-- FK
-- ==========================================================

ALTER TABLE card.card
ADD CONSTRAINT fk_card_account
FOREIGN KEY(account_id)
REFERENCES account.account(account_id);

ALTER TABLE card.card
ADD CONSTRAINT fk_card_customer
FOREIGN KEY(customer_id)
REFERENCES customer.customer(customer_id);

ALTER TABLE card.card
ADD CONSTRAINT fk_card_type
FOREIGN KEY(card_type_code)
REFERENCES ref.card_type(card_type_code);

ALTER TABLE card.card
ADD CONSTRAINT fk_card_brand
FOREIGN KEY(card_brand_code)
REFERENCES ref.card_brand(card_brand_code);

ALTER TABLE card.card
ADD CONSTRAINT fk_card_status
FOREIGN KEY(card_status_code)
REFERENCES ref.card_status(card_status_code);

-- ==========================================================
-- CHECK
-- ==========================================================

ALTER TABLE card.card
ADD CONSTRAINT chk_pin_retry
CHECK(pin_retry_count >= 0);

ALTER TABLE card.card
ADD CONSTRAINT chk_credit_limit
CHECK(
    credit_limit IS NULL
    OR credit_limit >= 0
);

ALTER TABLE card.card
ADD CONSTRAINT chk_outstanding
CHECK(
    outstanding_amount >= 0
);

ALTER TABLE card.card
ADD CONSTRAINT chk_expiry_date
CHECK(
    expiry_date > issue_date
);

-- ==========================================================
-- COMMENT
-- ==========================================================

COMMENT ON TABLE card.card
IS 'Card master table';



-- ==========================================================
-- CARD LIMIT
-- ==========================================================

CREATE TABLE card.card_limit
(
    card_limit_id BIGSERIAL PRIMARY KEY,

    card_id BIGINT NOT NULL,

    daily_purchase_limit NUMERIC(18,2),

    daily_atm_limit NUMERIC(18,2),

    daily_online_limit NUMERIC(18,2),

    daily_contactless_limit NUMERIC(18,2),

    effective_date DATE NOT NULL,

    expiry_date DATE,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ==========================================================
-- FK
-- ==========================================================

ALTER TABLE card.card_limit
ADD CONSTRAINT fk_card_limit_card
FOREIGN KEY(card_id)
REFERENCES card.card(card_id);

-- ==========================================================
-- CHECK
-- ==========================================================

ALTER TABLE card.card_limit
ADD CONSTRAINT chk_purchase_limit
CHECK(
    daily_purchase_limit IS NULL
    OR daily_purchase_limit >= 0
);

ALTER TABLE card.card_limit
ADD CONSTRAINT chk_atm_limit
CHECK(
    daily_atm_limit IS NULL
    OR daily_atm_limit >= 0
);

ALTER TABLE card.card_limit
ADD CONSTRAINT chk_online_limit
CHECK(
    daily_online_limit IS NULL
    OR daily_online_limit >= 0
);

ALTER TABLE card.card_limit
ADD CONSTRAINT chk_contactless_limit
CHECK(
    daily_contactless_limit IS NULL
    OR daily_contactless_limit >= 0
);

-- ==========================================================
-- COMMENT
-- ==========================================================

COMMENT ON TABLE card.card_limit
IS 'Card transaction limit configuration';



-- ==========================================================
-- CARD STATUS HISTORY
-- ==========================================================

CREATE TABLE card.card_status_history
(
    history_id BIGSERIAL PRIMARY KEY,

    card_id BIGINT NOT NULL,

    old_status_code VARCHAR(20),

    new_status_code VARCHAR(20) NOT NULL,

    change_reason VARCHAR(500),

    changed_by VARCHAR(100),

    changed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ==========================================================
-- FK
-- ==========================================================

ALTER TABLE card.card_status_history
ADD CONSTRAINT fk_card_history_card
FOREIGN KEY(card_id)
REFERENCES card.card(card_id);

ALTER TABLE card.card_status_history
ADD CONSTRAINT fk_card_history_old_status
FOREIGN KEY(old_status_code)
REFERENCES ref.card_status(card_status_code);

ALTER TABLE card.card_status_history
ADD CONSTRAINT fk_card_history_new_status
FOREIGN KEY(new_status_code)
REFERENCES ref.card_status(card_status_code);

-- ==========================================================
-- COMMENT
-- ==========================================================

COMMENT ON TABLE card.card_status_history
IS 'Card status change history';