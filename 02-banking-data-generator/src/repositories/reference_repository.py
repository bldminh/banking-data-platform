import pandas as pd

from sqlalchemy import text

from src.common.db_connection import engine


class ReferenceRepository:

    @staticmethod
    def load_table(
        schema_name,
        table_name
    ):

        query = text(
            f"""
            SELECT *
            FROM {schema_name}.{table_name}
            """
        )

        return pd.read_sql(
            query,
            engine
        )