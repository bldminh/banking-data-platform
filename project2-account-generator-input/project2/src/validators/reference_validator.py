from src.cache.reference_cache import ReferenceCache


class ReferenceValidator:

    @staticmethod
    def validate():

        print()
        print("=" * 60)
        print("VALIDATING REFERENCE DATA")
        print("=" * 60)

        if not ReferenceCache.data:

            raise RuntimeError(
                "Reference cache is empty."
            )

        for table_name, dataframe in ReferenceCache.data.items():

            if dataframe is None:
                raise ValueError(
                    f"Reference data is None: "
                    f"{table_name}"
                )

            if dataframe.empty:
                raise ValueError(
                    f"Reference data is empty: "
                    f"{table_name}"
                )

            print(
                f"[PASS] {table_name:<30} "
                f"rows={len(dataframe)}"
            )

        print()
        print("Reference validation completed.")