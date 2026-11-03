# ==========================================================
# PROJECT: Banking Data Platform
# FILE   : account_repository.py
# DOMAIN : Account
# ==========================================================

from typing import List, Dict, Any

import pandas as pd
from sqlalchemy import text

from src.common.db_connection import engine


class AccountRepository:

    # ======================================================
    # CUSTOMER
    # ======================================================

    @staticmethod
    def get_customer_records(limit: int = None) -> pd.DataFrame:
        """
        Load real customer IDs and customer_since_date
        from PostgreSQL.

        Account Generator must never invent customer_id.
        """

        query = """
            SELECT
                customer_id,
                customer_code,
                customer_since_date
            FROM customer.customer
            ORDER BY customer_id
        """

        if limit is not None:
            query += f"\nLIMIT {int(limit)}"

        return pd.read_sql(text(query), engine)


    # ======================================================
    # BRANCH
    # ======================================================

    @staticmethod
    def get_branch_ids() -> List[int]:
        """
        Return existing branch IDs from channel.branch.

        Account.account.branch_id is nullable and currently
        has no FK constraint to channel.branch.
        """

        query = text("""
            SELECT branch_id
            FROM channel.branch
            ORDER BY branch_id
        """)

        with engine.connect() as connection:
            rows = connection.execute(query).fetchall()

        return [int(row[0]) for row in rows]


    # ======================================================
    # ACCOUNT NUMBER
    # ======================================================

    @staticmethod
    def get_max_account_number_suffix() -> int:
        """
        Find the largest numeric suffix in account_number.

        Expected format:
            ACC000000000001
            ACC000000000002
            ...
        """

        query = text("""
            SELECT COALESCE(
                MAX(
                    CAST(
                        SUBSTRING(
                            account_number
                            FROM '[0-9]+$'
                        ) AS BIGINT
                    )
                ),
                0
            )
            FROM account.account
            WHERE account_number ~ '[0-9]+$'
        """)

        with engine.connect() as connection:
            result = connection.execute(query).scalar()

        return int(result or 0)


    # ======================================================
    # ACCOUNT INSERT
    # ======================================================

    @staticmethod
    def insert_many(
        table_name: str,
        records: List[Dict[str, Any]]
    ) -> None:
        """
        Batch insert records into account schema.

        table_name is restricted to known Account tables
        to avoid accidental SQL injection through dynamic
        table names.
        """

        if not records:
            return

        allowed_tables = {
            "account",
            "account_balance",
            "account_limit",
            "account_status_history",
        }

        if table_name not in allowed_tables:
            raise ValueError(
                f"Invalid account table: {table_name}"
            )

        columns = list(records[0].keys())

        column_sql = ", ".join(columns)
        values_sql = ", ".join(
            f":{column}" for column in columns
        )

        query = text(f"""
            INSERT INTO account.{table_name}
            ({column_sql})
            VALUES ({values_sql})
        """)

        with engine.begin() as connection:
            connection.execute(query, records)


    # ======================================================
    # ACCOUNT IDs
    # ======================================================

    @staticmethod
    def get_ids_by_account_numbers(
        account_numbers: List[str]
    ) -> Dict[str, int]:
        """
        Retrieve generated account_id values using the
        unique account_number.

        This avoids relying on "latest IDs", which is unsafe
        under concurrent inserts.
        """

        if not account_numbers:
            return {}

        query = text("""
            SELECT
                account_id,
                account_number
            FROM account.account
            WHERE account_number = ANY(:account_numbers)
        """)

        with engine.connect() as connection:
            rows = connection.execute(
                query,
                {
                    "account_numbers": account_numbers
                }
            ).fetchall()

        return {
            row.account_number: int(row.account_id)
            for row in rows
        }


    # ======================================================
    # COUNT
    # ======================================================

    @staticmethod
    def count_rows(
        table_name: str
    ) -> int:

        allowed_tables = {
            "account",
            "account_balance",
            "account_limit",
            "account_status_history",
        }

        if table_name not in allowed_tables:
            raise ValueError(
                f"Invalid account table: {table_name}"
            )

        query = text(
            f"SELECT COUNT(*) FROM account.{table_name}"
        )

        with engine.connect() as connection:
            return int(connection.execute(query).scalar())


    # ======================================================
    # ACCOUNT EXISTENCE
    # ======================================================

    @staticmethod
    def account_exists(
        account_number: str
    ) -> bool:

        query = text("""
            SELECT EXISTS (
                SELECT 1
                FROM account.account
                WHERE account_number = :account_number
            )
        """)

        with engine.connect() as connection:
            return bool(
                connection.execute(
                    query,
                    {
                        "account_number": account_number
                    }
                ).scalar()
            )