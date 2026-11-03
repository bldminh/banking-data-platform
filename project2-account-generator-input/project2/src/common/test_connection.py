from sqlalchemy import text
from database import engine

with engine.connect() as conn:

    result = conn.execute(
        text("select current_database();")
    )

    for row in result:
        print(row[0])