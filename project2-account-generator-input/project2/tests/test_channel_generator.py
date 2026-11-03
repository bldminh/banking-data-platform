from src.loaders.reference_loader import ReferenceLoader
from src.validators.reference_validator import ReferenceValidator
from src.generators.channel_generator import ChannelGenerator


def main():

    print()
    print("=" * 60)
    print("PROJECT 2 - CHANNEL GENERATOR TEST")
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
    # Generate channel data
    # =========================================================

    print()
    print("[STEP 3] Generating channel data...")

    generator = ChannelGenerator()

    generator.generate_all(
        branch_count=20,
        employee_count=100,
        atm_count=50,
        merchant_count=100,
        pos_terminal_count=200
    )

    print()
    print("=" * 60)
    print("CHANNEL GENERATOR TEST COMPLETED")
    print("=" * 60)


if __name__ == "__main__":
    main()