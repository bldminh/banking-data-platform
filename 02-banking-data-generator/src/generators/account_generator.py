# ==========================================================
# PROJECT: Banking Data Platform
# FILE   : account_generator.py
# DOMAIN : Account
# ==========================================================

import random
from datetime import date, timedelta
from decimal import Decimal
from typing import Dict, List, Optional

from src.cache.reference_cache import ReferenceCache
from src.repositories.account_repository import AccountRepository

from config.generator_config import (
    ACCOUNT_PER_CUSTOMER_MIN,
    ACCOUNT_PER_CUSTOMER_MAX,
    ACCOUNT_TYPE_WEIGHTS,
    ACCOUNT_STATUS_WEIGHTS,
    ACCOUNT_CURRENCY_WEIGHTS,
    FOREIGN_CURRENCY_WEIGHTS,
    OVERDRAFT_PROBABILITY,
    ACCOUNT_LIMIT_PROBABILITY,
    BALANCE_BUCKETS,
    ACCOUNT_LIMITS,
    GENERATED_BY,
)


class AccountGenerator:

    # ======================================================
    # INIT
    # ======================================================

    def __init__(self):
        self.account_records: List[Dict] = []
        self.balance_records: List[Dict] = []
        self.limit_records: List[Dict] = []
        self.status_history_records: List[Dict] = []

        self.generated_account_numbers: List[str] = []
        self.account_id_map: Dict[str, int] = {}

        self.customer_records = []
        self.branch_ids: List[int] = []

        self.max_account_number_suffix = 0

    # ======================================================
    # REFERENCE HELPERS
    # ======================================================

    @staticmethod
    def _get_reference_codes(
        table_name: str,
        code_column: str
    ) -> List[str]:

        dataframe = ReferenceCache.get(table_name)

        if dataframe is None:
            raise ValueError(
                f"Reference data not loaded: ref.{table_name}"
            )

        if dataframe.empty:
            raise ValueError(
                f"Reference data is empty: ref.{table_name}"
            )

        if code_column not in dataframe.columns:
            raise ValueError(
                f"Column '{code_column}' not found "
                f"in ref.{table_name}"
            )

        return dataframe[code_column].dropna().astype(str).tolist()


    @classmethod
    def _validate_reference_codes(cls):

        account_types = set(
            cls._get_reference_codes(
                "account_type",
                "account_type_code"
            )
        )

        account_statuses = set(
            cls._get_reference_codes(
                "account_status",
                "account_status_code"
            )
        )

        currencies = set(
            cls._get_reference_codes(
                "currency",
                "currency_code"
            )
        )

        configured_types = set(
            ACCOUNT_TYPE_WEIGHTS.keys()
        )

        configured_statuses = set(
            ACCOUNT_STATUS_WEIGHTS.keys()
        )

        configured_currencies = set(
            ACCOUNT_CURRENCY_WEIGHTS.keys()
        )

        foreign_currencies = set(
            FOREIGN_CURRENCY_WEIGHTS.keys()
        )

        missing_types = configured_types - account_types

        if missing_types:
            raise ValueError(
                "Configured account types do not exist "
                f"in ref.account_type: {missing_types}"
            )

        missing_statuses = (
            configured_statuses - account_statuses
        )

        if missing_statuses:
            raise ValueError(
                "Configured account statuses do not exist "
                f"in ref.account_status: {missing_statuses}"
            )

        missing_currencies = (
            configured_currencies - currencies
        )

        if missing_currencies:
            raise ValueError(
                "Configured currencies do not exist "
                f"in ref.currency: {missing_currencies}"
            )

        missing_foreign = (
            foreign_currencies - currencies
        )

        if missing_foreign:
            raise ValueError(
                "Configured foreign currencies do not exist "
                f"in ref.currency: {missing_foreign}"
            )


    # ======================================================
    # WEIGHTED RANDOM
    # ======================================================

    @staticmethod
    def _weighted_choice(
        weights: Dict[str, float]
    ) -> str:

        if not weights:
            raise ValueError(
                "Weight configuration cannot be empty."
            )

        keys = list(weights.keys())
        values = list(weights.values())

        if any(weight < 0 for weight in values):
            raise ValueError(
                "Weights cannot be negative."
            )

        total = sum(values)

        if total <= 0:
            raise ValueError(
                "Weight total must be greater than zero."
            )

        return random.choices(
            keys,
            weights=values,
            k=1
        )[0]


    # ======================================================
    # ACCOUNT TYPE
    # ======================================================

    def _generate_account_type(self) -> str:

        return self._weighted_choice(
            ACCOUNT_TYPE_WEIGHTS
        )


    # ======================================================
    # ACCOUNT STATUS
    # ======================================================

    def _generate_account_status(self) -> str:

        return self._weighted_choice(
            ACCOUNT_STATUS_WEIGHTS
        )


    # ======================================================
    # CURRENCY
    # ======================================================

    def _generate_currency(
        self,
        account_type: str
    ) -> str:

        if account_type == "FOREIGN":
            return self._weighted_choice(
                FOREIGN_CURRENCY_WEIGHTS
            )

        return self._weighted_choice(
            ACCOUNT_CURRENCY_WEIGHTS
        )


    # ======================================================
    # ACCOUNT NUMBER
    # ======================================================

    def _next_account_number(self) -> str:

        self.max_account_number_suffix += 1

        return (
            f"ACC"
            f"{self.max_account_number_suffix:012d}"
        )


    # ======================================================
    # OPEN DATE
    # ======================================================

    @staticmethod
    def _generate_open_date(
        customer_since_date: date
    ) -> date:

        today = date.today()

        if customer_since_date > today:
            raise ValueError(
                "customer_since_date cannot be in the future."
            )

        days_available = (
            today - customer_since_date
        ).days

        if days_available == 0:
            return customer_since_date

        random_days = random.randint(
            0,
            days_available
        )

        return customer_since_date + timedelta(
            days=random_days
        )


    # ======================================================
    # CLOSE DATE
    # ======================================================

    @staticmethod
    def _generate_close_date(
        open_date: date,
        status: str
    ) -> Optional[date]:

        if status != "CLOSED":
            return None

        today = date.today()

        if open_date >= today:
            return open_date

        days_available = (
            today - open_date
        ).days

        random_days = random.randint(
            0,
            days_available
        )

        return open_date + timedelta(
            days=random_days
        )


    # ======================================================
    # OVERDRAFT
    # ======================================================

    @staticmethod
    def _generate_overdraft(
        account_type: str
    ):

        probability = OVERDRAFT_PROBABILITY.get(
            account_type,
            0.0
        )

        allowed = (
            random.random() < probability
        )

        if not allowed:
            return False, Decimal("0.00")

        # Synthetic overdraft limits.
        limits = [
            5_000_000,
            10_000_000,
            20_000_000,
            50_000_000,
            100_000_000,
        ]

        limit = Decimal(
            str(random.choice(limits))
        )

        return True, limit


    # ======================================================
    # BALANCE
    # ======================================================

    @staticmethod
    def _generate_balance():

        bucket = AccountGenerator._weighted_choice(
            {
                name: config["weight"]
                for name, config
                in BALANCE_BUCKETS.items()
            }
        )

        config = BALANCE_BUCKETS[bucket]

        amount = random.randint(
            config["min"],
            config["max"]
        )

        return Decimal(str(amount))


    # ======================================================
    # HOLD / AVAILABLE BALANCE
    # ======================================================

    @staticmethod
    def _generate_balance_details(
        current_balance: Decimal
    ):

        if current_balance <= 0:
            return (
                Decimal("0.00"),
                Decimal("0.00")
            )

        # Most accounts have no hold.
        if random.random() < 0.90:
            hold_amount = Decimal("0.00")
        else:
            max_hold = int(
                current_balance * Decimal("0.20")
            )

            if max_hold <= 0:
                hold_amount = Decimal("0.00")
            else:
                hold_amount = Decimal(
                    str(
                        random.randint(
                            0,
                            max_hold
                        )
                    )
                )

        available_balance = (
            current_balance - hold_amount
        )

        if available_balance < 0:
            available_balance = Decimal("0.00")

        return (
            available_balance,
            hold_amount
        )


    # ======================================================
    # ACCOUNT LIMIT
    # ======================================================

    @staticmethod
    def _generate_account_limit(
        open_date: date
    ) -> Optional[Dict]:

        if (
            random.random()
            > ACCOUNT_LIMIT_PROBABILITY
        ):
            return None

        effective_date = open_date

        # Most generated accounts have active limits.
        expiry_date = None

        if random.random() < 0.05:
            max_days = 365

            expiry_date = (
                effective_date
                + timedelta(
                    days=random.randint(
                        30,
                        max_days
                    )
                )
            )

        transfer_limit = Decimal(
            str(
                random.randint(
                    ACCOUNT_LIMITS[
                        "daily_transfer"
                    ]["min"],
                    ACCOUNT_LIMITS[
                        "daily_transfer"
                    ]["max"]
                )
            )
        )

        withdrawal_limit = Decimal(
            str(
                random.randint(
                    ACCOUNT_LIMITS[
                        "daily_withdrawal"
                    ]["min"],
                    ACCOUNT_LIMITS[
                        "daily_withdrawal"
                    ]["max"]
                )
            )
        )

        qr_limit = Decimal(
            str(
                random.randint(
                    ACCOUNT_LIMITS[
                        "daily_qr"
                    ]["min"],
                    ACCOUNT_LIMITS[
                        "daily_qr"
                    ]["max"]
                )
            )
        )

        return {
            "daily_transfer_limit": transfer_limit,
            "daily_withdrawal_limit": withdrawal_limit,
            "daily_qr_limit": qr_limit,
            "effective_date": effective_date,
            "expiry_date": expiry_date,
        }


    # ======================================================
    # STATUS HISTORY
    # ======================================================

    @staticmethod
    def _generate_status_history(
        status: str
    ) -> Dict:

        return {
            "old_status_code": None,
            "new_status_code": status,
            "change_reason": "Account opened",
            "changed_by": GENERATED_BY,
        }


    # ======================================================
    # VALIDATION - MASTER
    # ======================================================

    @staticmethod
    def _validate_account_record(
        record: Dict,
        customer_since_date: date
    ):

        required_fields = [
            "account_number",
            "customer_id",
            "account_type_code",
            "currency_code",
            "account_status_code",
            "open_date",
            "overdraft_allowed",
            "overdraft_limit",
        ]

        for field in required_fields:

            if (
                field not in record
                or record[field] is None
            ):
                raise ValueError(
                    f"Required field missing: {field}"
                )

        if record["open_date"] < customer_since_date:
            raise ValueError(
                "Account open_date cannot be before "
                "customer_since_date."
            )

        if record["open_date"] > date.today():
            raise ValueError(
                "Account open_date cannot be in the future."
            )

        close_date = record["close_date"]

        if (
            close_date is not None
            and close_date < record["open_date"]
        ):
            raise ValueError(
                "Account close_date cannot be before "
                "open_date."
            )

        if record["overdraft_limit"] < 0:
            raise ValueError(
                "overdraft_limit cannot be negative."
            )

        if (
            not record["overdraft_allowed"]
            and record["overdraft_limit"]
            != Decimal("0.00")
        ):
            raise ValueError(
                "overdraft_limit must be zero "
                "when overdraft is disabled."
            )


    # ======================================================
    # VALIDATION - BALANCE
    # ======================================================

    @staticmethod
    def _validate_balance_record(
        record: Dict
    ):

        current_balance = record[
            "current_balance"
        ]

        available_balance = record[
            "available_balance"
        ]

        hold_amount = record[
            "hold_amount"
        ]

        if current_balance < 0:
            raise ValueError(
                "current_balance cannot be negative."
            )

        if available_balance < 0:
            raise ValueError(
                "available_balance cannot be negative."
            )

        if hold_amount < 0:
            raise ValueError(
                "hold_amount cannot be negative."
            )

        if available_balance > current_balance:
            raise ValueError(
                "available_balance cannot exceed "
                "current_balance."
            )


    # ======================================================
    # VALIDATION - LIMIT
    # ======================================================

    @staticmethod
    def _validate_limit_record(
        record: Dict
    ):

        for field in [
            "daily_transfer_limit",
            "daily_withdrawal_limit",
            "daily_qr_limit",
        ]:

            value = record[field]

            if (
                value is not None
                and value < 0
            ):
                raise ValueError(
                    f"{field} cannot be negative."
                )

        effective_date = record[
            "effective_date"
        ]

        expiry_date = record[
            "expiry_date"
        ]

        if (
            expiry_date is not None
            and expiry_date < effective_date
        ):
            raise ValueError(
                "expiry_date cannot be before "
                "effective_date."
            )


    # ======================================================
    # GENERATE
    # ======================================================

    def generate(
        self,
        customer_count: Optional[int] = None
    ):

        print()
        print("=" * 60)
        print("ACCOUNT GENERATOR")
        print("=" * 60)

        # --------------------------------------------------
        # Reference validation
        # --------------------------------------------------

        print()
        print("Validating account reference data...")

        self._validate_reference_codes()

        print("[PASS] account_type")
        print("[PASS] account_status")
        print("[PASS] currency")

        # --------------------------------------------------
        # Customer loading
        # --------------------------------------------------

        print()
        print("Loading customers...")

        self.customer_records = (
            AccountRepository.get_customer_records(
                limit=customer_count
            )
        )

        if self.customer_records.empty:
            raise ValueError(
                "No customers found in customer.customer."
            )

        print(
            f"[OK] Loaded "
            f"{len(self.customer_records)} customers."
        )

        # --------------------------------------------------
        # Branch loading
        # --------------------------------------------------

        print()
        print("Loading branches...")

        self.branch_ids = (
            AccountRepository.get_branch_ids()
        )

        if not self.branch_ids:
            raise ValueError(
                "No branches found in channel.branch."
            )

        print(
            f"[OK] Loaded "
            f"{len(self.branch_ids)} branches."
        )

        # --------------------------------------------------
        # Account number
        # --------------------------------------------------

        self.max_account_number_suffix = (
            AccountRepository
            .get_max_account_number_suffix()
        )

        print(
            "[INFO] Current max account number suffix: "
            f"{self.max_account_number_suffix}"
        )

        # --------------------------------------------------
        # Generate
        # --------------------------------------------------

        print()
        print(
            f"Generating accounts for "
            f"{len(self.customer_records)} customers..."
        )

        for customer in (
            self.customer_records
            .itertuples(index=False)
        ):

            customer_id = int(
                customer.customer_id
            )

            customer_since_date = (
                customer.customer_since_date
            )

            account_count = random.randint(
                ACCOUNT_PER_CUSTOMER_MIN,
                ACCOUNT_PER_CUSTOMER_MAX
            )

            for _ in range(account_count):

                account_number = (
                    self._next_account_number()
                )

                account_type = (
                    self._generate_account_type()
                )

                currency_code = (
                    self._generate_currency(
                        account_type
                    )
                )

                status = (
                    self._generate_account_status()
                )

                open_date = (
                    self._generate_open_date(
                        customer_since_date
                    )
                )

                close_date = (
                    self._generate_close_date(
                        open_date,
                        status
                    )
                )

                overdraft_allowed, overdraft_limit = (
                    self._generate_overdraft(
                        account_type
                    )
                )

                branch_id = random.choice(
                    self.branch_ids
                )

                account_record = {
                    "account_number": account_number,
                    "customer_id": customer_id,
                    "account_type_code": account_type,
                    "currency_code": currency_code,
                    "account_status_code": status,
                    "branch_id": branch_id,
                    "open_date": open_date,
                    "close_date": close_date,
                    "overdraft_allowed": overdraft_allowed,
                    "overdraft_limit": overdraft_limit,
                    "created_by": GENERATED_BY,
                }

                self._validate_account_record(
                    account_record,
                    customer_since_date
                )

                self.account_records.append(
                    account_record
                )

                self.generated_account_numbers.append(
                    account_number
                )

        print(
            f"[OK] Generated "
            f"{len(self.account_records)} accounts."
        )

        # --------------------------------------------------
        # Insert account master
        # --------------------------------------------------

        print()
        print("Saving account master...")

        AccountRepository.insert_many(
            "account",
            self.account_records
        )

        print(
            f"[OK] Inserted "
            f"{len(self.account_records)} account records."
        )

        # --------------------------------------------------
        # Retrieve real account IDs
        # --------------------------------------------------

        print()
        print("Resolving generated account IDs...")

        self.account_id_map = (
            AccountRepository
            .get_ids_by_account_numbers(
                self.generated_account_numbers
            )
        )

        if (
            len(self.account_id_map)
            != len(self.generated_account_numbers)
        ):
            raise ValueError(
                "Unable to resolve all generated "
                "account IDs."
            )

        print(
            f"[OK] Resolved "
            f"{len(self.account_id_map)} account IDs."
        )

        # --------------------------------------------------
        # Generate child records
        # --------------------------------------------------

        print()
        print("Generating account balances...")

        for account_record in self.account_records:

            account_number = (
                account_record[
                    "account_number"
                ]
            )

            account_id = (
                self.account_id_map[
                    account_number
                ]
            )

            current_balance = (
                self._generate_balance()
            )

            (
                available_balance,
                hold_amount
            ) = self._generate_balance_details(
                current_balance
            )

            balance_record = {
                "account_id": account_id,
                "current_balance": current_balance,
                "available_balance": available_balance,
                "hold_amount": hold_amount,
            }

            self._validate_balance_record(
                balance_record
            )

            self.balance_records.append(
                balance_record
            )

        AccountRepository.insert_many(
            "account_balance",
            self.balance_records
        )

        print(
            f"[OK] Inserted "
            f"{len(self.balance_records)} "
            f"balance records."
        )

        # --------------------------------------------------
        # Account limits
        # --------------------------------------------------

        print()
        print("Generating account limits...")

        for account_record in self.account_records:

            account_number = (
                account_record[
                    "account_number"
                ]
            )

            account_id = (
                self.account_id_map[
                    account_number
                ]
            )

            limit_record = (
                self._generate_account_limit(
                    account_record["open_date"]
                )
            )

            if limit_record is None:
                continue

            limit_record["account_id"] = (
                account_id
            )

            self._validate_limit_record(
                limit_record
            )

            self.limit_records.append(
                limit_record
            )

        if self.limit_records:

            AccountRepository.insert_many(
                "account_limit",
                self.limit_records
            )

        print(
            f"[OK] Inserted "
            f"{len(self.limit_records)} "
            f"account limit records."
        )

        # --------------------------------------------------
        # Status history
        # --------------------------------------------------

        print()
        print(
            "Generating account status history..."
        )

        for account_record in self.account_records:

            account_number = (
                account_record[
                    "account_number"
                ]
            )

            account_id = (
                self.account_id_map[
                    account_number
                ]
            )

            history = (
                self._generate_status_history(
                    account_record[
                        "account_status_code"
                    ]
                )
            )

            history["account_id"] = account_id

            self.status_history_records.append(
                history
            )

        AccountRepository.insert_many(
            "account_status_history",
            self.status_history_records
        )

        print(
            f"[OK] Inserted "
            f"{len(self.status_history_records)} "
            f"status history records."
        )

        print()
        print("=" * 60)
        print("ACCOUNT GENERATION COMPLETED")
        print("=" * 60)

        return {
            "accounts": len(
                self.account_records
            ),
            "balances": len(
                self.balance_records
            ),
            "limits": len(
                self.limit_records
            ),
            "status_history": len(
                self.status_history_records
            ),
        }


    # ======================================================
    # VALIDATE GENERATED DATA
    # ======================================================

    def validate(self) -> bool:

        print()
        print("=" * 60)
        print("ACCOUNT GENERATOR VALIDATION")
        print("=" * 60)

        # --------------------------------------------------
        # Master
        # --------------------------------------------------

        account_numbers = [
            record["account_number"]
            for record in self.account_records
        ]

        if len(account_numbers) != len(
            set(account_numbers)
        ):
            raise ValueError(
                "Duplicate account_number detected "
                "inside generated dataset."
            )

        # --------------------------------------------------
        # Balance
        # --------------------------------------------------

        for record in self.balance_records:

            self._validate_balance_record(
                record
            )

        # --------------------------------------------------
        # Limits
        # --------------------------------------------------

        for record in self.limit_records:

            self._validate_limit_record(
                record
            )

        # --------------------------------------------------
        # Status history
        # --------------------------------------------------

        if len(
            self.status_history_records
        ) != len(
            self.account_records
        ):
            raise ValueError(
                "Every account must have exactly "
                "one initial status history record."
            )

        print(
            "[PASS] Account numbers are unique."
        )

        print(
            "[PASS] Account master validation."
        )

        print(
            "[PASS] Account balance validation."
        )

        print(
            "[PASS] Account limit validation."
        )

        print(
            "[PASS] Account status history validation."
        )

        print()
        print(
            "Account validation completed."
        )

        return True