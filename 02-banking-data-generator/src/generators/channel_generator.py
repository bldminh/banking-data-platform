import random

from datetime import date, datetime

from faker import Faker

from src.cache.reference_cache import ReferenceCache
from src.repositories.channel_repository import ChannelRepository


class ChannelGenerator:

    def __init__(self):

        self.fake = Faker("en_US")

        # Keep generated IDs
        self.branch_ids = []
        self.merchant_ids = []

    # ============================================================
    # REFERENCE HELPERS
    # ============================================================

    def _get_reference_dataframe(
        self,
        table_name
    ):

        dataframe = ReferenceCache.get(
            table_name
        )

        if dataframe is None:

            raise RuntimeError(
                f"Reference data not loaded: "
                f"ref.{table_name}"
            )

        if dataframe.empty:

            raise RuntimeError(
                f"Reference table is empty: "
                f"ref.{table_name}"
            )

        return dataframe

    def _get_reference_codes(
        self,
        table_name,
        code_column
    ):

        dataframe = self._get_reference_dataframe(
            table_name
        )

        if code_column not in dataframe.columns:

            raise RuntimeError(
                f"Column '{code_column}' "
                f"does not exist in ref.{table_name}"
            )

        values = (
            dataframe[code_column]
            .dropna()
            .tolist()
        )

        if not values:

            raise RuntimeError(
                f"No values found in "
                f"ref.{table_name}.{code_column}"
            )

        return values

    def _random_reference_code(
        self,
        table_name,
        code_column
    ):

        values = self._get_reference_codes(
            table_name,
            code_column
        )

        return random.choice(values)

    def _get_country_codes(self):

        dataframe = self._get_reference_dataframe(
            "country"
        )

        if "country_code" not in dataframe.columns:

            raise RuntimeError(
                "ref.country.country_code "
                "does not exist."
            )

        values = (
            dataframe["country_code"]
            .dropna()
            .tolist()
        )

        if not values:

            raise RuntimeError(
                "ref.country has no country_code."
            )

        return values

    # ============================================================
    # DATE HELPERS
    # ============================================================

    def _random_date_between(self, start_year, end_year):
        start_date = date(start_year, 1, 1)
        end_date = date(end_year, 12, 31)

        return self.fake.date_between(
            start_date=start_date,
            end_date=end_date
        )

    # ============================================================
    # BRANCH
    # ============================================================

    def generate_branches(
        self,
        count
    ):

        print()
        print(
            f"Generating {count} branches..."
        )

        existing_count = (
            ChannelRepository.count_rows(
                "channel",
                "branch"
            )
        )

        country_codes = (
            self._get_country_codes()
        )

        records = []

        for index in range(count):

            number = (
                existing_count
                + index
                + 1
            )

            record = {

                "branch_code":
                    f"BR{number:06d}",

                "branch_name":
                    f"{self.fake.city()} Branch",

                "address_line_1":
                    self.fake.street_address(),

                "city":
                    self.fake.city(),

                "province":
                    self.fake.state(),

                "country_code":
                    random.choice(
                        country_codes
                    ),

                "phone_number":
                    self.fake.phone_number(),

                "email":
                    self.fake.company_email(),

                "opened_date":
                    self._random_date_between(
                        2012,
                        2025
                    ),

                "branch_status_code":
                    self._random_reference_code(
                        "branch_status",
                        "branch_status_code"
                    ),

                "created_at":
                    datetime.now(),

                "updated_at":
                    None,

                "created_by":
                    "DATA_GENERATOR",

                "updated_by":
                    None,
            }

            records.append(record)

        ChannelRepository.insert_many(
            "channel",
            "branch",
            records
        )

        self.branch_ids = (
            ChannelRepository.get_ids(
                "channel",
                "branch",
                "branch_id"
            )
        )

        print(
            f"[OK] Generated {count} branches."
        )

        return records

    # ============================================================
    # EMPLOYEE
    # ============================================================

    def generate_employees(
        self,
        count
    ):

        if not self.branch_ids:

            raise RuntimeError(
                "Branch IDs are not available."
            )

        print()
        print(
            f"Generating {count} employees..."
        )

        existing_count = (
            ChannelRepository.count_rows(
                "channel",
                "employee"
            )
        )

        records = []

        positions = [
            "Teller",
            "Branch Manager",
            "Relationship Manager",
            "Customer Service Officer",
            "Loan Officer",
            "Operations Officer",
            "Financial Advisor",
        ]

        for index in range(count):

            number = (
                existing_count
                + index
                + 1
            )

            first_name = (
                self.fake.first_name()
            )

            last_name = (
                self.fake.last_name()
            )

            record = {

                "employee_code":
                    f"EMP{number:08d}",

                "branch_id":
                    random.choice(
                        self.branch_ids
                    ),

                "first_name":
                    first_name,

                "last_name":
                    last_name,

                "email":
                    self.fake.unique.email(),

                "phone_number":
                    self.fake.phone_number(),

                "position_title":
                    random.choice(
                        positions
                    ),

                "hire_date":
                    self._random_date_between(
                        2015,
                        2025
                    ),

                "employee_status_code":
                    self._random_reference_code(
                        "employee_status",
                        "employee_status_code"
                    ),

                "created_at":
                    datetime.now(),

                "updated_at":
                    None,

                "created_by":
                    "DATA_GENERATOR",

                "updated_by":
                    None,
            }

            records.append(record)

        ChannelRepository.insert_many(
            "channel",
            "employee",
            records
        )

        print(
            f"[OK] Generated {count} employees."
        )

        return records

    # ============================================================
    # ATM
    # ============================================================

    def generate_atms(
        self,
        count
    ):

        if not self.branch_ids:

            raise RuntimeError(
                "Branch IDs are not available."
            )

        print()
        print(
            f"Generating {count} ATMs..."
        )

        existing_count = (
            ChannelRepository.count_rows(
                "channel",
                "atm"
            )
        )

        records = []

        for index in range(count):

            number = (
                existing_count
                + index
                + 1
            )

            record = {

                "atm_code":
                    f"ATM{number:08d}",

                "branch_id":
                    random.choice(
                        self.branch_ids
                    ),

                "atm_name":
                    f"ATM-{number:08d}",

                "latitude":
                    round(
                        random.uniform(
                            8.0,
                            23.5
                        ),
                        6
                    ),

                "longitude":
                    round(
                        random.uniform(
                            102.0,
                            109.5
                        ),
                        6
                    ),

                "install_date":
                    self._random_date_between(
                        2015,
                        2025
                    ),

                "cash_level":
                    round(
                        random.uniform(
                            50_000_000,
                            500_000_000
                        ),
                        2
                    ),

                "atm_status_code":
                    self._random_reference_code(
                        "atm_status",
                        "atm_status_code"
                    ),

                "created_at":
                    datetime.now(),

                "updated_at":
                    None,

                "created_by":
                    "DATA_GENERATOR",

                "updated_by":
                    None,
            }

            records.append(record)

        ChannelRepository.insert_many(
            "channel",
            "atm",
            records
        )

        print(
            f"[OK] Generated {count} ATMs."
        )

        return records

    # ============================================================
    # MERCHANT
    # ============================================================

    def generate_merchants(
        self,
        count
    ):

        print()
        print(
            f"Generating {count} merchants..."
        )

        existing_count = (
            ChannelRepository.count_rows(
                "channel",
                "merchant"
            )
        )

        country_codes = (
            self._get_country_codes()
        )

        records = []

        merchant_types = [
            "RETAIL",
            "RESTAURANT",
            "HOTEL",
            "SUPERMARKET",
            "E_COMMERCE",
            "SERVICE",
        ]

        merchant_category_codes = [
            "5411",
            "5812",
            "5814",
            "5311",
            "5912",
            "5999",
            "7011",
            "5541",
            "5691",
            "5732",
        ]

        for index in range(count):

            number = (
                existing_count
                + index
                + 1
            )

            record = {

                "merchant_code":
                    f"MER{number:08d}",

                "merchant_name":
                    self.fake.company(),

                "merchant_category_code":
                    random.choice(
                        merchant_category_codes
                    ),

                "merchant_type_code":
                    random.choice(
                        merchant_types
                    ),

                "tax_code":
                    str(
                        random.randint(
                            1000000000,
                            9999999999
                        )
                    ),

                "address_line_1":
                    self.fake.street_address(),

                "city":
                    self.fake.city(),

                "province":
                    self.fake.state(),

                "country_code":
                    random.choice(
                        country_codes
                    ),

                "phone_number":
                    self.fake.phone_number(),

                "email":
                    self.fake.company_email(),

                "merchant_status_code":
                    self._random_reference_code(
                        "merchant_status",
                        "merchant_status_code"
                    ),

                "created_at":
                    datetime.now(),

                "updated_at":
                    None,

                "created_by":
                    "DATA_GENERATOR",

                "updated_by":
                    None,
            }

            records.append(record)

        ChannelRepository.insert_many(
            "channel",
            "merchant",
            records
        )

        self.merchant_ids = (
            ChannelRepository.get_ids(
                "channel",
                "merchant",
                "merchant_id"
            )
        )

        print(
            f"[OK] Generated {count} merchants."
        )

        return records

    # ============================================================
    # POS TERMINAL
    # ============================================================

    def generate_pos_terminals(
        self,
        count
    ):

        if not self.merchant_ids:

            raise RuntimeError(
                "Merchant IDs are not available."
            )

        print()
        print(
            f"Generating {count} POS terminals..."
        )

        existing_count = (
            ChannelRepository.count_rows(
                "channel",
                "pos_terminal"
            )
        )

        records = []

        for index in range(count):

            number = (
                existing_count
                + index
                + 1
            )

            record = {

                "pos_terminal_code":
                    f"POS{number:08d}",

                "merchant_id":
                    random.choice(
                        self.merchant_ids
                    ),

                "terminal_serial_no":
                    f"SN{number:012d}",

                "install_date":
                    self._random_date_between(
                        2016,
                        2025
                    ),

                "pos_status_code":
                    self._random_reference_code(
                        "pos_status",
                        "pos_status_code"
                    ),

                "created_at":
                    datetime.now(),

                "updated_at":
                    None,

                "created_by":
                    "DATA_GENERATOR",

                "updated_by":
                    None,
            }

            records.append(record)

        ChannelRepository.insert_many(
            "channel",
            "pos_terminal",
            records
        )

        print(
            f"[OK] Generated {count} POS terminals."
        )

        return records

    # ============================================================
    # FULL GENERATION
    # ============================================================

    def generate_all(
        self,
        branch_count=20,
        employee_count=100,
        atm_count=50,
        merchant_count=100,
        pos_terminal_count=200
    ):

        print()
        print("=" * 60)
        print("CHANNEL GENERATOR")
        print("=" * 60)

        # --------------------------------------------------------
        # 1. Branch
        # --------------------------------------------------------

        self.generate_branches(
            branch_count
        )

        # --------------------------------------------------------
        # 2. Employee
        # --------------------------------------------------------

        self.generate_employees(
            employee_count
        )

        # --------------------------------------------------------
        # 3. ATM
        # --------------------------------------------------------

        self.generate_atms(
            atm_count
        )

        # --------------------------------------------------------
        # 4. Merchant
        # --------------------------------------------------------

        self.generate_merchants(
            merchant_count
        )

        # --------------------------------------------------------
        # 5. POS Terminal
        # --------------------------------------------------------

        self.generate_pos_terminals(
            pos_terminal_count
        )

        print()
        print("=" * 60)
        print("CHANNEL GENERATION COMPLETED")
        print("=" * 60)