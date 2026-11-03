# ==========================================================
# PROJECT: Banking Data Platform
# FILE   : test_account_generator.py
# DOMAIN : Account
# ==========================================================

from src.loaders.reference_loader import ReferenceLoader
from src.validators.reference_validator import ReferenceValidator
from src.generators.account_generator import AccountGenerator
from src.repositories.account_repository import AccountRepository


def main():

    print()
    print("=" * 60)
    print("PROJECT 2 - ACCOUNT GENERATOR TEST")
    print("=" * 60)

    # ======================================================
    # STEP 1 - LOAD REFERENCE
    # ======================================================

    print()
    print("[STEP 1] Loading reference data...")

    loader = ReferenceLoader()
    loader.load_all()

    # ======================================================
    # STEP 2 - VALIDATE REFERENCE
    # ======================================================

    print()
    print("[STEP 2] Validating reference data...")

    # validator = ReferenceValidator()
    # validator.validate_all()
    validator = ReferenceValidator()
    validator.validate()

    # ======================================================
    # STEP 3 - ACCOUNT GENERATION
    # ======================================================

    print()
    print(
        "[STEP 3] Generating account data..."
    )

    generator = AccountGenerator()

    result = generator.generate(
        customer_count=100
    )

    # ======================================================
    # STEP 4 - GENERATED DATA VALIDATION
    # ======================================================

    print()
    print(
        "[STEP 4] Validating generated "
        "account data..."
    )

    assert generator.validate() is True

    # ======================================================
    # STEP 5 - DATABASE COUNTS
    # ======================================================

    print()
    print(
        "[STEP 5] Checking database row counts..."
    )

    account_count = (
        AccountRepository.count_rows(
            "account"
        )
    )

    balance_count = (
        AccountRepository.count_rows(
            "account_balance"
        )
    )

    limit_count = (
        AccountRepository.count_rows(
            "account_limit"
        )
    )

    history_count = (
        AccountRepository.count_rows(
            "account_status_history"
        )
    )

    print(
        f"[INFO] account.account "
        f"rows={account_count}"
    )

    print(
        f"[INFO] account.account_balance "
        f"rows={balance_count}"
    )

    print(
        f"[INFO] account.account_limit "
        f"rows={limit_count}"
    )

    print(
        f"[INFO] account.account_status_history "
        f"rows={history_count}"
    )

    # ======================================================
    # STEP 6 - BASIC ASSERTIONS
    # ======================================================

    assert result["accounts"] > 0

    assert (
        result["accounts"]
        == result["balances"]
    )

    assert (
        result["accounts"]
        == result["status_history"]
    )

    assert (
        account_count
        >= result["accounts"]
    )

    assert (
        balance_count
        >= result["balances"]
    )

    assert (
        history_count
        >= result["status_history"]
    )

    print()
    print("=" * 60)
    print("ACCOUNT GENERATOR TEST COMPLETED")
    print("=" * 60)


if __name__ == "__main__":
    main()