-- ==========================================================
-- PROJECT : Banking Data Platform
-- FILE    : 03_customer_tables.sql
-- DOMAIN  : Customer
-- ==========================================================

-- ==========================================================
-- CUSTOMER
-- ==========================================================

CREATE TABLE customer.customer
(
    customer_id BIGSERIAL PRIMARY KEY,

    customer_code VARCHAR(30) NOT NULL,

    national_id VARCHAR(20) NOT NULL,

    passport_no VARCHAR(30),

    first_name VARCHAR(100) NOT NULL,

    middle_name VARCHAR(100),

    last_name VARCHAR(100) NOT NULL,

    full_name VARCHAR(300) NOT NULL,

    date_of_birth DATE NOT NULL,

    gender_code VARCHAR(10),

    nationality_code VARCHAR(3),

    marital_status_code VARCHAR(20),

    occupation_code VARCHAR(20),

    monthly_income NUMERIC(18,2),

    customer_status_code VARCHAR(20) NOT NULL,

    risk_level_code VARCHAR(20) NOT NULL,

    customer_since_date DATE NOT NULL,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    updated_at TIMESTAMP,

    created_by VARCHAR(100) DEFAULT 'SYSTEM',

    updated_by VARCHAR(100)
);

-- UNIQUE

ALTER TABLE customer.customer
ADD CONSTRAINT uk_customer_code
UNIQUE(customer_code);

ALTER TABLE customer.customer
ADD CONSTRAINT uk_customer_national_id
UNIQUE(national_id);

-- FK

ALTER TABLE customer.customer
ADD CONSTRAINT fk_customer_nationality
FOREIGN KEY(nationality_code)
REFERENCES ref.country(country_code);

ALTER TABLE customer.customer
ADD CONSTRAINT fk_customer_status
FOREIGN KEY(customer_status_code)
REFERENCES ref.customer_status(customer_status_code);

ALTER TABLE customer.customer
ADD CONSTRAINT fk_customer_risk
FOREIGN KEY(risk_level_code)
REFERENCES ref.risk_level(risk_level_code);

-- CHECK

ALTER TABLE customer.customer
ADD CONSTRAINT chk_customer_income
CHECK(monthly_income IS NULL OR monthly_income >= 0);

COMMENT ON TABLE customer.customer
IS 'Customer master table';



-- ==========================================================
-- CUSTOMER CONTACT
-- ==========================================================

CREATE TABLE customer.customer_contact
(
    contact_id BIGSERIAL PRIMARY KEY,

    customer_id BIGINT NOT NULL,

    contact_type VARCHAR(20) NOT NULL,

    contact_value VARCHAR(255) NOT NULL,

    is_primary BOOLEAN DEFAULT FALSE,

    is_verified BOOLEAN DEFAULT FALSE,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE customer.customer_contact
ADD CONSTRAINT fk_contact_customer
FOREIGN KEY(customer_id)
REFERENCES customer.customer(customer_id);

COMMENT ON TABLE customer.customer_contact
IS 'Customer contact information';



-- ==========================================================
-- CUSTOMER ADDRESS
-- ==========================================================

CREATE TABLE customer.customer_address
(
    address_id BIGSERIAL PRIMARY KEY,

    customer_id BIGINT NOT NULL,

    address_type VARCHAR(30),

    address_line_1 VARCHAR(500),

    address_line_2 VARCHAR(500),

    city VARCHAR(100),

    province VARCHAR(100),

    postal_code VARCHAR(20),

    country_code VARCHAR(3),

    is_primary BOOLEAN DEFAULT FALSE,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE customer.customer_address
ADD CONSTRAINT fk_address_customer
FOREIGN KEY(customer_id)
REFERENCES customer.customer(customer_id);

ALTER TABLE customer.customer_address
ADD CONSTRAINT fk_address_country
FOREIGN KEY(country_code)
REFERENCES ref.country(country_code);

COMMENT ON TABLE customer.customer_address
IS 'Customer address';



-- ==========================================================
-- CUSTOMER KYC
-- ==========================================================

CREATE TABLE customer.customer_kyc
(
    kyc_id BIGSERIAL PRIMARY KEY,

    customer_id BIGINT NOT NULL,

    kyc_status_code VARCHAR(20) NOT NULL,

    kyc_date DATE NOT NULL,

    expiry_date DATE,

    verification_channel VARCHAR(50),

    verified_by VARCHAR(100),

    remarks VARCHAR(500),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE customer.customer_kyc
ADD CONSTRAINT fk_kyc_customer
FOREIGN KEY(customer_id)
REFERENCES customer.customer(customer_id);

ALTER TABLE customer.customer_kyc
ADD CONSTRAINT fk_kyc_status
FOREIGN KEY(kyc_status_code)
REFERENCES ref.kyc_status(kyc_status_code);

COMMENT ON TABLE customer.customer_kyc
IS 'Customer KYC information';



-- ==========================================================
-- CUSTOMER EMPLOYMENT
-- ==========================================================

CREATE TABLE customer.customer_employment
(
    employment_id BIGSERIAL PRIMARY KEY,

    customer_id BIGINT NOT NULL,

    company_name VARCHAR(300),

    job_title VARCHAR(200),

    occupation_code VARCHAR(20),

    annual_income NUMERIC(18,2),

    employment_start_date DATE,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE customer.customer_employment
ADD CONSTRAINT fk_employment_customer
FOREIGN KEY(customer_id)
REFERENCES customer.customer(customer_id);

ALTER TABLE customer.customer_employment
ADD CONSTRAINT chk_annual_income
CHECK(
    annual_income IS NULL
    OR annual_income >= 0
);

COMMENT ON TABLE customer.customer_employment
IS 'Customer employment information';



-- ==========================================================
-- CUSTOMER BENEFICIARY
-- ==========================================================

CREATE TABLE customer.customer_beneficiary
(
    beneficiary_id BIGSERIAL PRIMARY KEY,

    customer_id BIGINT NOT NULL,

    beneficiary_name VARCHAR(300) NOT NULL,

    beneficiary_account VARCHAR(50) NOT NULL,

    beneficiary_bank VARCHAR(200),

    nickname VARCHAR(100),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE customer.customer_beneficiary
ADD CONSTRAINT fk_beneficiary_customer
FOREIGN KEY(customer_id)
REFERENCES customer.customer(customer_id);

COMMENT ON TABLE customer.customer_beneficiary
IS 'Saved beneficiary accounts';