from sqlalchemy import text

from src.common.db_connection import engine


def run_check(engine, title, sql):

    with engine.connect() as conn:

        result = conn.execute(text(sql))
        count = result.scalar()

        if count == 0:
            print(f"[PASS] {title}")
        else:
            print(f"[FAIL] {title} -> rows={count}")


def main():

    print()
    print("=" * 60)
    print("ACCOUNT DATA QUALITY CHECK")
    print("=" * 60)

    #engine = get_engine()

    checks = [

        (
            "Orphan account -> customer",
            """
            SELECT COUNT(*)
            FROM account.account a
            LEFT JOIN customer.customer c
                ON a.customer_id = c.customer_id
            WHERE c.customer_id IS NULL
            """
        ),

        (
            "Orphan balance -> account",
            """
            SELECT COUNT(*)
            FROM account.account_balance b
            LEFT JOIN account.account a
                ON b.account_id = a.account_id
            WHERE a.account_id IS NULL
            """
        ),

        (
            "Orphan limit -> account",
            """
            SELECT COUNT(*)
            FROM account.account_limit l
            LEFT JOIN account.account a
                ON l.account_id = a.account_id
            WHERE a.account_id IS NULL
            """
        ),

        (
            "Orphan status history -> account",
            """
            SELECT COUNT(*)
            FROM account.account_status_history h
            LEFT JOIN account.account a
                ON h.account_id = a.account_id
            WHERE a.account_id IS NULL
            """
        ),

        (
            "Duplicate account number",
            """
            SELECT COUNT(*)
            FROM
            (
                SELECT account_number
                FROM account.account
                GROUP BY account_number
                HAVING COUNT(*) > 1
            ) x
            """
        ),

        (
            "Invalid account_type_code",
            """
            SELECT COUNT(*)
            FROM account.account a
            LEFT JOIN ref.account_type r
                ON a.account_type_code =
                   r.account_type_code
            WHERE r.account_type_code IS NULL
            """
        ),

        (
            "Invalid account_status_code",
            """
            SELECT COUNT(*)
            FROM account.account a
            LEFT JOIN ref.account_status r
                ON a.account_status_code =
                   r.account_status_code
            WHERE r.account_status_code IS NULL
            """
        ),

        (
            "Invalid currency_code",
            """
            SELECT COUNT(*)
            FROM account.account a
            LEFT JOIN ref.currency r
                ON a.currency_code =
                   r.currency_code
            WHERE r.currency_code IS NULL
            """
        ),

        (
            "Balance equation violation",
            """
            SELECT COUNT(*)
            FROM account.account_balance
            WHERE ROUND(
                    available_balance
                    + hold_amount,
                    2
                  )
                  <>
                  ROUND(
                    current_balance,
                    2
                  )
            """
        ),

        (
            "Closed account without close_date",
            """
            SELECT COUNT(*)
            FROM account.account
            WHERE account_status_code = 'CLOSED'
            AND close_date IS NULL
            """
        ),

        (
            "Non-closed account with close_date",
            """
            SELECT COUNT(*)
            FROM account.account
            WHERE account_status_code <> 'CLOSED'
            AND close_date IS NOT NULL
            """
        ),

        (
            "Negative overdraft limit",
            """
            SELECT COUNT(*)
            FROM account.account
            WHERE overdraft_limit < 0
            """
        ),

        (
            "Overdraft inconsistency",
            """
            SELECT COUNT(*)
            FROM account.account
            WHERE overdraft_allowed = FALSE
            AND overdraft_limit > 0
            """
        ),

        (
            "Account open date before customer since date",
            """
            SELECT COUNT(*)
            FROM account.account a
            JOIN customer.customer c
                ON a.customer_id = c.customer_id
            WHERE a.open_date
                  < c.customer_since_date
            """
        )
    ]

    for title, sql in checks:
        run_check(engine, title, sql)

    print()
    print("=" * 60)
    print("ACCOUNT DATA QUALITY COMPLETED")
    print("=" * 60)


if __name__ == "__main__":
    main()