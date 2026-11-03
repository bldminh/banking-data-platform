# ==========================================================
# PROJECT: Banking Data Platform
# FILE   : generator_config.py
# DOMAIN : Generator Configuration
# ==========================================================


# ==========================================================
# CUSTOMER
# ==========================================================

CUSTOMER_COUNT = 100000


# ==========================================================
# ACCOUNT
# ==========================================================

ACCOUNT_PER_CUSTOMER_MIN = 1
ACCOUNT_PER_CUSTOMER_MAX = 3


# Account type distribution
ACCOUNT_TYPE_WEIGHTS = {
    "SAVINGS": 0.50,
    "CURRENT": 0.30,
    "PAYROLL": 0.15,
    "FOREIGN": 0.05,
}


# Account status distribution
ACCOUNT_STATUS_WEIGHTS = {
    "ACTIVE": 0.90,
    "DORMANT": 0.05,
    "BLOCKED": 0.03,
    "CLOSED": 0.02,
}


# Currency distribution for normal retail accounts
ACCOUNT_CURRENCY_WEIGHTS = {
    "VND": 0.90,
    "USD": 0.05,
    "EUR": 0.02,
    "JPY": 0.015,
    "SGD": 0.015,
}


# Foreign currency distribution
FOREIGN_CURRENCY_WEIGHTS = {
    "USD": 0.55,
    "EUR": 0.20,
    "JPY": 0.15,
    "SGD": 0.10,
}


# Overdraft probability by account type
OVERDRAFT_PROBABILITY = {
    "SAVINGS": 0.00,
    "CURRENT": 0.30,
    "PAYROLL": 0.05,
    "FOREIGN": 0.10,
}


# Account limit probability
ACCOUNT_LIMIT_PROBABILITY = 0.95


# Balance distribution
BALANCE_BUCKETS = {
    "LOW": {
        "weight": 0.70,
        "min": 100_000,
        "max": 10_000_000,
    },
    "MEDIUM": {
        "weight": 0.20,
        "min": 10_000_001,
        "max": 100_000_000,
    },
    "HIGH": {
        "weight": 0.08,
        "min": 100_000_001,
        "max": 1_000_000_000,
    },
    "VERY_HIGH": {
        "weight": 0.02,
        "min": 1_000_000_001,
        "max": 10_000_000_000,
    },
}


# Daily account limits
ACCOUNT_LIMITS = {
    "daily_transfer": {
        "min": 10_000_000,
        "max": 500_000_000,
    },
    "daily_withdrawal": {
        "min": 5_000_000,
        "max": 200_000_000,
    },
    "daily_qr": {
        "min": 5_000_000,
        "max": 100_000_000,
    },
}


# ==========================================================
# CARD
# ==========================================================

CARD_PER_ACCOUNT_MIN = 0
CARD_PER_ACCOUNT_MAX = 2


# ==========================================================
# LOAN
# ==========================================================

LOAN_RATIO = 0.15


# ==========================================================
# TRANSACTION
# ==========================================================

TRANSACTION_COUNT = 500000


# ==========================================================
# GENERATOR METADATA
# ==========================================================

GENERATED_BY = "DATA_GENERATOR"