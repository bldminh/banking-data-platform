import random

from datetime import date, datetime, timedelta
from dateutil.relativedelta import relativedelta

from faker import Faker

from src.cache.reference_cache import ReferenceCache
from src.repositories.customer_repository import CustomerRepository


class CustomerGenerator:

    def __init__(self):

        self.fake = Faker("en_US")

        # Keep generated customer IDs
        self.customer_ids = []

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

        return random.choice(
            values
        )

    def _get_country_codes(self):

        return self._get_reference_codes(
            "country",
            "country_code"
        )

    # ============================================================
    # DATE HELPERS
    # ============================================================

    def _random_date_between(
        self,
        start_date,
        end_date
    ):

        return self.fake.date_between(
            start_date=start_date,
            end_date=end_date
        )

    # ============================================================
    # CUSTOMER NUMBER HELPERS
    # ============================================================

    def _generate_customer_code(
        self,
        number
    ):

        return f"CUS{number:09d}"

    def _generate_national_id(
        self,
        number
    ):

        # 12-digit synthetic national ID
        return f"{number:012d}"

    def _generate_passport_no(
        self,
        number
    ):

        return f"P{number:08d}"

    # ============================================================
    # CUSTOMER
    # ============================================================

    def generate_customers(
        self,
        count
    ):

        if count <= 0:
            return []

        print()
        print(
            f"Generating {count} customers..."
        )

        # --------------------------------------------------------
        # IMPORTANT
        #
        # customer_id is a database primary key.
        #
        # customer_code / national_id / passport_no are
        # business identifiers.
        #
        # They must NOT depend on customer_id.
        # --------------------------------------------------------

        max_customer_code_number = (
            CustomerRepository.get_max_numeric_suffix(
                "customer",
                "customer",
                "customer_code",
                prefix="CUS"
            )
        )

        max_national_id_number = (
            CustomerRepository.get_max_numeric_suffix(
                "customer",
                "customer",
                "national_id"
            )
        )

        max_passport_number = (
            CustomerRepository.get_max_numeric_suffix(
                "customer",
                "customer",
                "passport_no",
                prefix="P"
            )
        )

        records = []

        today = date.today()

        # --------------------------------------------------------
        # Customer master
        # --------------------------------------------------------

        for index in range(count):

            # ----------------------------------------------------
            # Independent business identifiers
            # ----------------------------------------------------

            customer_code_number = (
                max_customer_code_number
                + index
                + 1
            )

            national_id_number = (
                max_national_id_number
                + index
                + 1
            )

            passport_number = (
                max_passport_number
                + index
                + 1
            )

            # ----------------------------------------------------
            # Name
            # ----------------------------------------------------

            first_name = (
                self.fake.first_name()
            )

            middle_name = (
                self.fake.first_name()
                if random.random() < 0.70
                else None
            )

            last_name = (
                self.fake.last_name()
            )

            name_parts = [
                first_name,
                middle_name,
                last_name
            ]

            full_name = " ".join(
                part
                for part in name_parts
                if part
            )

            # ----------------------------------------------------
            # Date of birth
            # ----------------------------------------------------

            # Age: 18–75
            date_of_birth = (
                self.fake.date_of_birth(
                    minimum_age=18,
                    maximum_age=75
                )
            )

            # ----------------------------------------------------
            # Customer since date
            # ----------------------------------------------------

            earliest_customer_date = (
                date_of_birth
                + relativedelta(years=18)
            )

            customer_since_date = (
                self._random_date_between(
                    earliest_customer_date,
                    today
                )
            )

            # ----------------------------------------------------
            # Income
            # ----------------------------------------------------

            monthly_income = (
                round(
                    random.uniform(
                        5_000_000,
                        150_000_000
                    ),
                    2
                )
                if random.random() < 0.85
                else None
            )

            # ----------------------------------------------------
            # Customer record
            # ----------------------------------------------------

            record = {

                "customer_code":
                    self._generate_customer_code(
                        customer_code_number
                    ),

                "national_id":
                    self._generate_national_id(
                        national_id_number
                    ),

                "passport_no":
                    (
                        self._generate_passport_no(
                            passport_number
                        )
                        if random.random() < 0.25
                        else None
                    ),

                "first_name":
                    first_name,

                "middle_name":
                    middle_name,

                "last_name":
                    last_name,

                "full_name":
                    full_name,

                "date_of_birth":
                    date_of_birth,

                "gender_code":
                    random.choice(
                        [
                            "M",
                            "F"
                        ]
                    ),

                "nationality_code":
                    random.choice(
                        self._get_country_codes()
                    ),

                "marital_status_code":
                    random.choice(
                        [
                            "SINGLE",
                            "MARRIED",
                            "DIVORCED"
                        ]
                    ),

                "occupation_code":
                    random.choice(
                        [
                            "EMPLOYEE",
                            "MANAGER",
                            "BUSINESS",
                            "PROFESSIONAL",
                            "SELF_EMPLOYED",
                            "STUDENT",
                            "RETIRED"
                        ]
                    ),

                "monthly_income":
                    monthly_income,

                "customer_status_code":
                    self._random_reference_code(
                        "customer_status",
                        "customer_status_code"
                    ),

                "risk_level_code":
                    self._random_reference_code(
                        "risk_level",
                        "risk_level_code"
                    ),

                "customer_since_date":
                    customer_since_date,

                "created_at":
                    datetime.now(),

                "updated_at":
                    None,

                "created_by":
                    "DATA_GENERATOR",

                "updated_by":
                    None,
            }

            records.append(
                record
            )

        # --------------------------------------------------------
        # Insert customers
        # --------------------------------------------------------

        CustomerRepository.insert_many(
            "customer",
            "customer",
            records
        )

        # --------------------------------------------------------
        # Retrieve actual database IDs
        # --------------------------------------------------------

        self.customer_ids = (
            CustomerRepository.get_latest_ids(
                "customer",
                "customer",
                "customer_id",
                count
            )
        )

        if len(self.customer_ids) != count:

            raise RuntimeError(
                "Customer ID retrieval failed. "
                f"Expected {count} IDs, "
                f"but received "
                f"{len(self.customer_ids)}."
            )

        print(
            f"[OK] Generated {count} customers."
        )

        return records

    # ============================================================
    # CONTACT
    # ============================================================

    def generate_contacts(
        self,
        customer_ids
    ):

        if not customer_ids:
            return []

        print()
        print(
            "Generating customer contacts..."
        )

        records = []

        for customer_id in customer_ids:

            # Every customer gets a mobile phone
            phone_record = {

                "customer_id":
                    customer_id,

                "contact_type":
                    "PHONE",

                "contact_value":
                    self.fake.phone_number(),

                "is_primary":
                    True,

                "is_verified":
                    random.random() < 0.85,

                "created_at":
                    datetime.now(),
            }

            records.append(
                phone_record
            )

            # Most customers also get an email
            if random.random() < 0.90:

                email_record = {

                    "customer_id":
                        customer_id,

                    "contact_type":
                        "EMAIL",

                    "contact_value":
                        self.fake.email(),

                    "is_primary":
                        False,

                    "is_verified":
                        random.random() < 0.75,

                    "created_at":
                        datetime.now(),
                }

                records.append(
                    email_record
                )

        CustomerRepository.insert_many(
            "customer",
            "customer_contact",
            records
        )

        print(
            f"[OK] Generated "
            f"{len(records)} customer contacts."
        )

        return records

    # ============================================================
    # ADDRESS
    # ============================================================

    def generate_addresses(
        self,
        customer_ids
    ):

        if not customer_ids:
            return []

        print()
        print(
            "Generating customer addresses..."
        )

        country_codes = (
            self._get_country_codes()
        )

        records = []

        for customer_id in customer_ids:

            address_count = (
                random.choices(
                    [1, 2],
                    weights=[0.75, 0.25],
                    k=1
                )[0]
            )

            for address_index in range(
                address_count
            ):

                address_type = (
                    "PERMANENT"
                    if address_index == 0
                    else "MAILING"
                )

                record = {

                    "customer_id":
                        customer_id,

                    "address_type":
                        address_type,

                    "address_line_1":
                        self.fake.street_address(),

                    "address_line_2":
                        (
                            self.fake.secondary_address()
                            if random.random() < 0.30
                            else None
                        ),

                    "city":
                        self.fake.city(),

                    "province":
                        self.fake.state(),

                    "postal_code":
                        self.fake.postcode(),

                    "country_code":
                        random.choice(
                            country_codes
                        ),

                    "is_primary":
                        address_index == 0,

                    "created_at":
                        datetime.now(),
                }

                records.append(
                    record
                )

        CustomerRepository.insert_many(
            "customer",
            "customer_address",
            records
        )

        print(
            f"[OK] Generated "
            f"{len(records)} customer addresses."
        )

        return records

    # ============================================================
    # EMPLOYMENT
    # ============================================================

    def generate_employments(
        self,
        customer_ids
    ):

        if not customer_ids:
            return []

        print()
        print(
            "Generating customer employment..."
        )

        records = []

        job_titles = [

            "Software Engineer",
            "Data Analyst",
            "Data Engineer",
            "Accountant",
            "Financial Analyst",
            "Sales Manager",
            "Marketing Specialist",
            "Operations Manager",
            "Teacher",
            "Doctor",
            "Business Owner",
            "Consultant",
            "Administrative Officer",
            "Bank Officer",
        ]

        for customer_id in customer_ids:

            # Some customers can have no employment record
            if random.random() > 0.90:
                continue

            annual_income = (
                round(
                    random.uniform(
                        60_000_000,
                        1_800_000_000
                    ),
                    2
                )
            )

            employment_start_date = (
                self.fake.date_between(
                    start_date="-20y",
                    end_date="today"
                )
            )

            record = {

                "customer_id":
                    customer_id,

                "company_name":
                    self.fake.company(),

                "job_title":
                    random.choice(
                        job_titles
                    ),

                "occupation_code":
                    random.choice(
                        [
                            "EMPLOYEE",
                            "MANAGER",
                            "BUSINESS",
                            "PROFESSIONAL",
                            "SELF_EMPLOYED"
                        ]
                    ),

                "annual_income":
                    annual_income,

                "employment_start_date":
                    employment_start_date,

                "created_at":
                    datetime.now(),
            }

            records.append(
                record
            )

        CustomerRepository.insert_many(
            "customer",
            "customer_employment",
            records
        )

        print(
            f"[OK] Generated "
            f"{len(records)} employment records."
        )

        return records

    # ============================================================
    # KYC
    # ============================================================

    def generate_kyc(
        self,
        customer_ids
    ):

        if not customer_ids:
            return []

        print()
        print(
            "Generating customer KYC..."
        )

        records = []

        verification_channels = [

            "BRANCH",
            "MOBILE_APP",
            "WEB",
            "VIDEO_KYC",
        ]

        for customer_id in customer_ids:

            kyc_date = (
                self.fake.date_between(
                    start_date="-3y",
                    end_date="today"
                )
            )

            expiry_date = (
                kyc_date
                + timedelta(
                    days=random.choice(
                        [
                            365,
                            730,
                            1095
                        ]
                    )
                )
            )

            record = {

                "customer_id":
                    customer_id,

                "kyc_status_code":
                    self._random_reference_code(
                        "kyc_status",
                        "kyc_status_code"
                    ),

                "kyc_date":
                    kyc_date,

                "expiry_date":
                    expiry_date,

                "verification_channel":
                    random.choice(
                        verification_channels
                    ),

                "verified_by":
                    (
                        f"KYC{random.randint(1000, 9999)}"
                    ),

                "remarks":
                    None,

                "created_at":
                    datetime.now(),
            }

            records.append(
                record
            )

        CustomerRepository.insert_many(
            "customer",
            "customer_kyc",
            records
        )

        print(
            f"[OK] Generated "
            f"{len(records)} KYC records."
        )

        return records

    # ============================================================
    # BENEFICIARY
    # ============================================================

    def generate_beneficiaries(
        self,
        customer_ids
    ):

        if not customer_ids:
            return []

        print()
        print(
            "Generating customer beneficiaries..."
        )

        records = []

        banks = [

            "ABC Digital Bank",
            "Global Commercial Bank",
            "National Banking Corporation",
            "Asia Financial Bank",
            "United Retail Bank",
            "Metro Commercial Bank",
        ]

        for customer_id in customer_ids:

            beneficiary_count = (
                random.choices(
                    [0, 1, 2],
                    weights=[0.20, 0.60, 0.20],
                    k=1
                )[0]
            )

            for _ in range(
                beneficiary_count
            ):

                first_name = (
                    self.fake.first_name()
                )

                last_name = (
                    self.fake.last_name()
                )

                beneficiary_name = (
                    f"{first_name} {last_name}"
                )

                record = {

                    "customer_id":
                        customer_id,

                    "beneficiary_name":
                        beneficiary_name,

                    "beneficiary_account":
                        (
                            f"{random.randint(100000000000, 999999999999)}"
                        ),

                    "beneficiary_bank":
                        random.choice(
                            banks
                        ),

                    "nickname":
                        (
                            self.fake.first_name()
                            if random.random() < 0.50
                            else None
                        ),

                    "created_at":
                        datetime.now(),
                }

                records.append(
                    record
                )

        CustomerRepository.insert_many(
            "customer",
            "customer_beneficiary",
            records
        )

        print(
            f"[OK] Generated "
            f"{len(records)} beneficiary records."
        )

        return records

    # ============================================================
    # FULL GENERATION
    # ============================================================

    def generate_all(
        self,
        customer_count=10
    ):

        print()
        print("=" * 60)
        print("CUSTOMER GENERATOR")
        print("=" * 60)

        # --------------------------------------------------------
        # 1. Customer master
        # --------------------------------------------------------

        self.generate_customers(
            customer_count
        )

        # --------------------------------------------------------
        # 2. Contact
        # --------------------------------------------------------

        self.generate_contacts(
            self.customer_ids
        )

        # --------------------------------------------------------
        # 3. Address
        # --------------------------------------------------------

        self.generate_addresses(
            self.customer_ids
        )

        # --------------------------------------------------------
        # 4. Employment
        # --------------------------------------------------------

        self.generate_employments(
            self.customer_ids
        )

        # --------------------------------------------------------
        # 5. KYC
        # --------------------------------------------------------

        self.generate_kyc(
            self.customer_ids
        )

        # --------------------------------------------------------
        # 6. Beneficiary
        # --------------------------------------------------------

        self.generate_beneficiaries(
            self.customer_ids
        )

        print()
        print("=" * 60)
        print("CUSTOMER GENERATION COMPLETED")
        print("=" * 60)

        return self.customer_ids