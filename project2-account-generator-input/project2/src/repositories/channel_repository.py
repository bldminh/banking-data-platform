from sqlalchemy import text

from src.common.db_connection import engine


class ChannelRepository:

    @staticmethod
    def insert_many(
        schema_name,
        table_name,
        records
    ):

        if not records:
            return

        columns = list(records[0].keys())

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

            result = connection.execute(query)

            return result.scalar()

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

            rows = connection.execute(query).fetchall()

        return [
            row[0]
            for row in rows
        ]