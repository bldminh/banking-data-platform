-- ==========================================================
-- FILE: 08_channel_tables.sql
-- DOMAIN: CHANNEL
-- PROJECT: BANKING DATA PLATFORM
-- ==========================================================

-- ==========================================================
-- BRANCH
-- ==========================================================

CREATE TABLE channel.branch
(
    branch_id BIGSERIAL PRIMARY KEY,

    branch_code VARCHAR(20) NOT NULL,

    branch_name VARCHAR(200) NOT NULL,

    address_line_1 VARCHAR(500),

    city VARCHAR(100),

    province VARCHAR(100),

    country_code VARCHAR(3) NOT NULL,

    phone_number VARCHAR(50),

    email VARCHAR(200),

    opened_date DATE,

    branch_status_code VARCHAR(20) NOT NULL,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    updated_at TIMESTAMP,

    created_by VARCHAR(100) DEFAULT 'SYSTEM',

    updated_by VARCHAR(100)
);

ALTER TABLE channel.branch
ADD CONSTRAINT uk_branch_code
UNIQUE(branch_code);

ALTER TABLE channel.branch
ADD CONSTRAINT fk_branch_country
FOREIGN KEY(country_code)
REFERENCES ref.country(country_code);

ALTER TABLE channel.branch
ADD CONSTRAINT fk_branch_status
FOREIGN KEY(branch_status_code)
REFERENCES ref.branch_status(branch_status_code);

COMMENT ON TABLE channel.branch
IS 'Bank branch master table';



-- ==========================================================
-- EMPLOYEE
-- ==========================================================

CREATE TABLE channel.employee
(
    employee_id BIGSERIAL PRIMARY KEY,

    employee_code VARCHAR(30) NOT NULL,

    branch_id BIGINT NOT NULL,

    first_name VARCHAR(100) NOT NULL,

    last_name VARCHAR(100) NOT NULL,

    email VARCHAR(200),

    phone_number VARCHAR(50),

    position_title VARCHAR(100),

    hire_date DATE,

    employee_status_code VARCHAR(20) NOT NULL,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    updated_at TIMESTAMP,

    created_by VARCHAR(100) DEFAULT 'SYSTEM',

    updated_by VARCHAR(100)
);

ALTER TABLE channel.employee
ADD CONSTRAINT uk_employee_code
UNIQUE(employee_code);

ALTER TABLE channel.employee
ADD CONSTRAINT fk_employee_branch
FOREIGN KEY(branch_id)
REFERENCES channel.branch(branch_id);

ALTER TABLE channel.employee
ADD CONSTRAINT fk_employee_status
FOREIGN KEY(employee_status_code)
REFERENCES ref.employee_status(employee_status_code);

COMMENT ON TABLE channel.employee
IS 'Bank employee master table';



-- ==========================================================
-- MERCHANT
-- ==========================================================

CREATE TABLE channel.merchant
(
    merchant_id BIGSERIAL PRIMARY KEY,

    merchant_code VARCHAR(30) NOT NULL,

    merchant_name VARCHAR(300) NOT NULL,

    merchant_category_code VARCHAR(10),

    merchant_type_code VARCHAR(30),

    tax_code VARCHAR(50),

    address_line_1 VARCHAR(500),

    city VARCHAR(100),

    province VARCHAR(100),

    country_code VARCHAR(3),

    phone_number VARCHAR(50),

    email VARCHAR(200),

    merchant_status_code VARCHAR(20) NOT NULL,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    updated_at TIMESTAMP,

    created_by VARCHAR(100) DEFAULT 'SYSTEM',

    updated_by VARCHAR(100)
);

ALTER TABLE channel.merchant
ADD CONSTRAINT uk_merchant_code
UNIQUE(merchant_code);

ALTER TABLE channel.merchant
ADD CONSTRAINT fk_merchant_country
FOREIGN KEY(country_code)
REFERENCES ref.country(country_code);

ALTER TABLE channel.merchant
ADD CONSTRAINT fk_merchant_status
FOREIGN KEY(merchant_status_code)
REFERENCES ref.merchant_status(merchant_status_code);

COMMENT ON TABLE channel.merchant
IS 'Merchant master table';



-- ==========================================================
-- ATM
-- ==========================================================

CREATE TABLE channel.atm
(
    atm_id BIGSERIAL PRIMARY KEY,

    atm_code VARCHAR(30) NOT NULL,

    branch_id BIGINT NOT NULL,

    atm_name VARCHAR(200),

    latitude NUMERIC(12,8),

    longitude NUMERIC(12,8),

    install_date DATE,

    cash_level NUMERIC(18,2),

    atm_status_code VARCHAR(20) NOT NULL,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    updated_at TIMESTAMP,

    created_by VARCHAR(100) DEFAULT 'SYSTEM',

    updated_by VARCHAR(100)
);

ALTER TABLE channel.atm
ADD CONSTRAINT uk_atm_code
UNIQUE(atm_code);

ALTER TABLE channel.atm
ADD CONSTRAINT fk_atm_branch
FOREIGN KEY(branch_id)
REFERENCES channel.branch(branch_id);

ALTER TABLE channel.atm
ADD CONSTRAINT fk_atm_status
FOREIGN KEY(atm_status_code)
REFERENCES ref.atm_status(atm_status_code);

ALTER TABLE channel.atm
ADD CONSTRAINT chk_atm_cash_level
CHECK (
    cash_level IS NULL
    OR cash_level >= 0
);

COMMENT ON TABLE channel.atm
IS 'ATM machine master table';



-- ==========================================================
-- POS TERMINAL
-- ==========================================================

CREATE TABLE channel.pos_terminal
(
    pos_terminal_id BIGSERIAL PRIMARY KEY,

    pos_terminal_code VARCHAR(30) NOT NULL,

    merchant_id BIGINT NOT NULL,

    terminal_serial_no VARCHAR(100),

    install_date DATE,

    pos_status_code VARCHAR(20) NOT NULL,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    updated_at TIMESTAMP,

    created_by VARCHAR(100) DEFAULT 'SYSTEM',

    updated_by VARCHAR(100)
);

ALTER TABLE channel.pos_terminal
ADD CONSTRAINT uk_pos_terminal_code
UNIQUE(pos_terminal_code);

ALTER TABLE channel.pos_terminal
ADD CONSTRAINT fk_pos_terminal_merchant
FOREIGN KEY(merchant_id)
REFERENCES channel.merchant(merchant_id);

ALTER TABLE channel.pos_terminal
ADD CONSTRAINT fk_pos_status
FOREIGN KEY(pos_status_code)
REFERENCES ref.pos_status(pos_status_code);

COMMENT ON TABLE channel.pos_terminal
IS 'POS terminal master table';