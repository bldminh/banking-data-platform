from sqlalchemy import text

from src.common.db_connection import engine


class CustomerRepository:

    # ============================================================
    # INSERT MANY
    # ============================================================

    @staticmethod
    def insert_many(
        schema_name,
        table_name,
        records
    ):

        if not records:
            return

        columns = list(
            records[0].keys()
        )

        column_sql = ", ".join(
            columns
        )

        values_sql = ", ".join(
            f":{column}"
            for column in columns
        )

        query = text(
            f"""
            INSERT INTO {schema_name}.{table_name}
            (
                {column_sql}
            )
            VALUES
            (
                {values_sql}
            )
            """
        )

        with engine.begin() as connection:

            connection.execute(
                query,
                records
            )

    # ============================================================
    # COUNT
    # ============================================================

    @staticmethod
    def count_rows(
        schema_name,
        table_name
    ):

        query = text(
            f"""
            SELECT COUNT(*)
            FROM {schema_name}.{table_name}
            """
        )

        with engine.connect() as connection:

            result = connection.execute(
                query
            )

            return result.scalar()

    # ============================================================
    # GET ALL IDS
    # ============================================================

    @staticmethod
    def get_ids(
        schema_name,
        table_name,
        id_column
    ):

        query = text(
            f"""
            SELECT {id_column}
            FROM {schema_name}.{table_name}
            ORDER BY {id_column}
            """
        )

        with engine.connect() as connection:

            rows = connection.execute(
                query
            ).fetchall()

        return [
            row[0]
            for row in rows
        ]

    # ============================================================
    # GET LATEST IDS
    # ============================================================

    @staticmethod
    def get_latest_ids(
        schema_name,
        table_name,
        id_column,
        count
    ):

        if count <= 0:
            return []

        query = text(
            f"""
            SELECT {id_column}
            FROM {schema_name}.{table_name}
            ORDER BY {id_column} DESC
            LIMIT :count
            """
        )

        with engine.connect() as connection:

            rows = connection.execute(
                query,
                {
                    "count": count
                }
            ).fetchall()

        ids = [
            row[0]
            for row in rows
        ]

        ids.reverse()

        return ids

    # ============================================================
    # GET MAX ID
    # ============================================================

    @staticmethod
    def get_max_id(
        schema_name,
        table_name,
        id_column
    ):

        query = text(
            f"""
            SELECT MAX({id_column})
            FROM {schema_name}.{table_name}
            """
        )

        with engine.connect() as connection:

            result = connection.execute(
                query
            )

            value = result.scalar()

        return value or 0

    # ============================================================
    # GET MAX NUMERIC SUFFIX
    #
    # Example:
    #
    # customer_code:
    # CUS000000001
    # CUS000000002
    # CUS001000000
    #
    # Returns:
    # 1000000
    #
    # Used for generating business identifiers independently
    # from the database primary key.
    # ============================================================

    @staticmethod
    def get_max_numeric_suffix(
        schema_name,
        table_name,
        column_name,
        prefix=None
    ):

        if prefix:

            query = text(
                f"""
                SELECT
                    COALESCE(
                        MAX(
                            CAST(
                                SUBSTRING(
                                    {column_name}
                                    FROM '[0-9]+$'
                                ) AS BIGINT
                            )
                        ),
                        0
                    )
                FROM {schema_name}.{table_name}
                WHERE {column_name} LIKE :prefix
                """
            )

            params = {
                "prefix": f"{prefix}%"
            }

        else:

            query = text(
                f"""
                SELECT
                    COALESCE(
                        MAX(
                            CAST(
                                SUBSTRING(
                                    {column_name}
                                    FROM '[0-9]+$'
                                ) AS BIGINT
                            )
                        ),
                        0
                    )
                FROM {schema_name}.{table_name}
                """
            )

            params = {}

        with engine.connect() as connection:

            result = connection.execute(
                query,
                params
            )

            value = result.scalar()

        return int(
            value or 0
        )