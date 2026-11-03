from src.repositories.reference_repository import ReferenceRepository
from src.cache.reference_cache import ReferenceCache


class ReferenceLoader:

    TABLES = [
        "account_status",
        "account_type",
        "atm_status",
        "branch_status",
        "card_brand",
        "card_status",
        "card_type",
        "country",
        "country_risk_rating",
        "currency",
        "customer_status",
        "customer_type",
        "education_level",
        "employee_status",
        "kyc_status",
        "loan_status",
        "loan_type",
        "merchant_status",
        "pos_status",
        "risk_level",
        "transaction_channel",
        "transaction_status",
        "transaction_type",
    ]

    def load_all(self):

        print("=" * 60)
        print("LOADING REFERENCE DATA")
        print("=" * 60)

        for table_name in self.TABLES:

            dataframe = ReferenceRepository.load_table(
                "ref",
                table_name
            )

            if dataframe.empty:

                raise ValueError(
                    f"Reference table is empty: "
                    f"ref.{table_name}"
                )

            ReferenceCache.set(
                table_name,
                dataframe
            )

            print(
                f"[OK] ref.{table_name:<30} "
                f"rows={len(dataframe)}"
            )

        print()
        print("Reference loading completed.")