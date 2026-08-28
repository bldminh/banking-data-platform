from src.loaders.reference_loader import ReferenceLoader
from src.validators.reference_validator import ReferenceValidator
from src.generators.customer_generator import CustomerGenerator


def main():

    print()
    print("=" * 60)
    print("PROJECT 2 - CUSTOMER GENERATOR TEST")
    print("=" * 60)

    # =========================================================
    # STEP 1
    # Load reference data
    # =========================================================

    print()
    print("[STEP 1] Loading reference data...")

    loader = ReferenceLoader()

    loader.load_all()

    # =========================================================
    # STEP 2
    # Validate reference data
    # =========================================================

    print()
    print("[STEP 2] Validating reference data...")

    ReferenceValidator.validate()

    # =========================================================
    # STEP 3
    # Generate customer data
    # =========================================================

    print()
    print("[STEP 3] Generating customer data...")

    generator = CustomerGenerator()

    generator.generate_all(
        customer_count=1000
    )

    print()
    print("=" * 60)
    print("CUSTOMER GENERATOR TEST COMPLETED")
    print("=" * 60)


if __name__ == "__main__":
    main()