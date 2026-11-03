-- ==========================================================
-- FILE: 02_reference_tables.sql
-- DOMAIN: REFERENCE DATA
-- PROJECT: BANKING DATA PLATFORM
-- ==========================================================

-- ==========================================================
-- COUNTRY
-- ==========================================================

CREATE TABLE ref.country
(
    country_code VARCHAR(3) PRIMARY KEY,
    country_name VARCHAR(100) NOT NULL
);

INSERT INTO ref.country VALUES
('VNM','Vietnam'),
('USA','United States'),
('SGP','Singapore'),
('JPN','Japan'),
('KOR','South Korea');



-- ==========================================================
-- CURRENCY
-- ==========================================================

CREATE TABLE ref.currency
(
    currency_code VARCHAR(3) PRIMARY KEY,
    currency_name VARCHAR(100) NOT NULL
);

INSERT INTO ref.currency VALUES
('VND','Vietnam Dong'),
('USD','US Dollar'),
('EUR','Euro'),
('JPY','Japanese Yen'),
('SGD','Singapore Dollar');



-- ==========================================================
-- CUSTOMER TYPE
-- ==========================================================

CREATE TABLE ref.customer_type
(
    customer_type_code VARCHAR(20) PRIMARY KEY,
    customer_type_name VARCHAR(100) NOT NULL
);

INSERT INTO ref.customer_type VALUES
('INDIVIDUAL','Individual'),
('CORPORATE','Corporate');



-- ==========================================================
-- CUSTOMER STATUS
-- ==========================================================

CREATE TABLE ref.customer_status
(
    customer_status_code VARCHAR(20) PRIMARY KEY,
    customer_status_name VARCHAR(100) NOT NULL
);

INSERT INTO ref.customer_status VALUES
('ACTIVE','Active'),
('INACTIVE','Inactive'),
('BLOCKED','Blocked'),
('CLOSED','Closed');



-- ==========================================================
-- KYC STATUS
-- ==========================================================

CREATE TABLE ref.kyc_status
(
    kyc_status_code VARCHAR(20) PRIMARY KEY,
    kyc_status_name VARCHAR(100) NOT NULL
);

INSERT INTO ref.kyc_status VALUES
('PENDING','Pending'),
('VERIFIED','Verified'),
('REJECTED','Rejected'),
('EXPIRED','Expired');



-- ==========================================================
-- EDUCATION LEVEL
-- ==========================================================

CREATE TABLE ref.education_level
(
    education_level_code VARCHAR(20) PRIMARY KEY,
    education_level_name VARCHAR(100) NOT NULL
);

INSERT INTO ref.education_level VALUES
('HIGH_SCHOOL','High School'),
('COLLEGE','College'),
('BACHELOR','Bachelor'),
('MASTER','Master'),
('DOCTORATE','Doctorate');



-- ==========================================================
-- RISK LEVEL
-- ==========================================================

CREATE TABLE ref.risk_level
(
    risk_level_code VARCHAR(20) PRIMARY KEY,
    risk_level_name VARCHAR(100) NOT NULL
);

INSERT INTO ref.risk_level VALUES
('LOW','Low Risk'),
('MEDIUM','Medium Risk'),
('HIGH','High Risk'),
('VERY_HIGH','Very High Risk');



-- ==========================================================
-- ACCOUNT TYPE
-- ==========================================================

CREATE TABLE ref.account_type
(
    account_type_code VARCHAR(20) PRIMARY KEY,
    account_type_name VARCHAR(100) NOT NULL
);

INSERT INTO ref.account_type VALUES
('SAVINGS','Savings Account'),
('CURRENT','Current Account'),
('PAYROLL','Payroll Account'),
('FOREIGN','Foreign Currency Account');



-- ==========================================================
-- ACCOUNT STATUS
-- ==========================================================

CREATE TABLE ref.account_status
(
    account_status_code VARCHAR(20) PRIMARY KEY,
    account_status_name VARCHAR(100) NOT NULL
);

INSERT INTO ref.account_status VALUES
('ACTIVE','Active'),
('DORMANT','Dormant'),
('BLOCKED','Blocked'),
('CLOSED','Closed');



-- ==========================================================
-- CARD TYPE
-- ==========================================================

CREATE TABLE ref.card_type
(
    card_type_code VARCHAR(20) PRIMARY KEY,
    card_type_name VARCHAR(100) NOT NULL
);

INSERT INTO ref.card_type VALUES
('DEBIT','Debit Card'),
('CREDIT','Credit Card'),
('VIRTUAL','Virtual Card');



-- ==========================================================
-- CARD BRAND
-- ==========================================================

CREATE TABLE ref.card_brand
(
    card_brand_code VARCHAR(20) PRIMARY KEY,
    card_brand_name VARCHAR(100) NOT NULL
);

INSERT INTO ref.card_brand VALUES
('VISA','Visa'),
('MASTERCARD','MasterCard'),
('JCB','JCB'),
('AMEX','American Express'),
('UNIONPAY','UnionPay');



-- ==========================================================
-- CARD STATUS
-- ==========================================================

CREATE TABLE ref.card_status
(
    card_status_code VARCHAR(20) PRIMARY KEY,
    card_status_name VARCHAR(100) NOT NULL
);

INSERT INTO ref.card_status VALUES
('REQUESTED','Requested'),
('ISSUED','Issued'),
('ACTIVATED','Activated'),
('ACTIVE','Active'),
('BLOCKED','Blocked'),
('EXPIRED','Expired'),
('CLOSED','Closed');



-- ==========================================================
-- LOAN TYPE
-- ==========================================================

CREATE TABLE ref.loan_type
(
    loan_type_code VARCHAR(20) PRIMARY KEY,
    loan_type_name VARCHAR(100) NOT NULL
);

INSERT INTO ref.loan_type VALUES
('HOME','Home Loan'),
('CAR','Car Loan'),
('PERSONAL','Personal Loan'),
('BUSINESS','Business Loan');



-- ==========================================================
-- LOAN STATUS
-- ==========================================================

CREATE TABLE ref.loan_status
(
    loan_status_code VARCHAR(20) PRIMARY KEY,
    loan_status_name VARCHAR(100) NOT NULL
);

INSERT INTO ref.loan_status VALUES
('APPLICATION','Application'),
('APPROVED','Approved'),
('DISBURSED','Disbursed'),
('ACTIVE','Active'),
('OVERDUE','Overdue'),
('DEFAULTED','Defaulted'),
('PAID_OFF','Paid Off'),
('CLOSED','Closed');



-- ==========================================================
-- TRANSACTION TYPE
-- ==========================================================

CREATE TABLE ref.transaction_type
(
    transaction_type_code VARCHAR(30) PRIMARY KEY,
    transaction_type_name VARCHAR(100) NOT NULL
);

INSERT INTO ref.transaction_type VALUES
('DEPOSIT','Deposit'),
('WITHDRAWAL','Withdrawal'),
('TRANSFER','Transfer'),
('INTEREST','Interest'),
('LOAN_PAYMENT','Loan Payment'),
('CARD_PAYMENT','Card Payment'),
('ATM_WITHDRAWAL','ATM Withdrawal'),
('POS_PAYMENT','POS Payment'),
('QR_PAYMENT','QR Payment'),
('SALARY','Salary'),
('FEE','Fee'),
('TAX','Tax');



-- ==========================================================
-- TRANSACTION STATUS
-- ==========================================================

CREATE TABLE ref.transaction_status
(
    transaction_status_code VARCHAR(30) PRIMARY KEY,
    transaction_status_name VARCHAR(100) NOT NULL
);

INSERT INTO ref.transaction_status VALUES
('PENDING','Pending'),
('SUCCESS','Success'),
('FAILED','Failed'),
('REVERSED','Reversed');



-- ==========================================================
-- TRANSACTION CHANNEL
-- ==========================================================

CREATE TABLE ref.transaction_channel
(
    transaction_channel_code VARCHAR(30) PRIMARY KEY,
    transaction_channel_name VARCHAR(100) NOT NULL
);

INSERT INTO ref.transaction_channel VALUES
('BRANCH','Branch'),
('ATM','ATM'),
('POS','POS'),
('IB','Internet Banking'),
('MB','Mobile Banking'),
('API','API Gateway');



-- ==========================================================
-- BRANCH STATUS
-- ==========================================================

CREATE TABLE ref.branch_status
(
    branch_status_code VARCHAR(20) PRIMARY KEY,
    branch_status_name VARCHAR(100) NOT NULL
);

INSERT INTO ref.branch_status VALUES
('ACTIVE','Active'),
('INACTIVE','Inactive'),
('CLOSED','Closed');



-- ==========================================================
-- EMPLOYEE STATUS
-- ==========================================================

CREATE TABLE ref.employee_status
(
    employee_status_code VARCHAR(20) PRIMARY KEY,
    employee_status_name VARCHAR(100) NOT NULL
);

INSERT INTO ref.employee_status VALUES
('ACTIVE','Active'),
('ON_LEAVE','On Leave'),
('TERMINATED','Terminated');



-- ==========================================================
-- MERCHANT STATUS
-- ==========================================================

CREATE TABLE ref.merchant_status
(
    merchant_status_code VARCHAR(20) PRIMARY KEY,
    merchant_status_name VARCHAR(100) NOT NULL
);

INSERT INTO ref.merchant_status VALUES
('ACTIVE','Active'),
('SUSPENDED','Suspended'),
('CLOSED','Closed');



-- ==========================================================
-- ATM STATUS
-- ==========================================================

CREATE TABLE ref.atm_status
(
    atm_status_code VARCHAR(20) PRIMARY KEY,
    atm_status_name VARCHAR(100) NOT NULL
);

INSERT INTO ref.atm_status VALUES
('ACTIVE','Active'),
('OUT_OF_SERVICE','Out Of Service'),
('MAINTENANCE','Maintenance');



-- ==========================================================
-- POS STATUS
-- ==========================================================

CREATE TABLE ref.pos_status
(
    pos_status_code VARCHAR(20) PRIMARY KEY,
    pos_status_name VARCHAR(100) NOT NULL
);

INSERT INTO ref.pos_status VALUES
('ACTIVE','Active'),
('OFFLINE','Offline'),
('DISABLED','Disabled');



-- ==========================================================
-- COUNTRY RISK RATING
-- ==========================================================

CREATE TABLE ref.country_risk_rating
(
    country_code VARCHAR(3) PRIMARY KEY,
    risk_level_code VARCHAR(20) NOT NULL,

    CONSTRAINT fk_country_risk_country
        FOREIGN KEY(country_code)
        REFERENCES ref.country(country_code),

    CONSTRAINT fk_country_risk_level
        FOREIGN KEY(risk_level_code)
        REFERENCES ref.risk_level(risk_level_code)
);

INSERT INTO ref.country_risk_rating VALUES
('VNM','LOW'),
('SGP','LOW'),
('JPN','LOW'),
('KOR','LOW'),
('USA','MEDIUM');