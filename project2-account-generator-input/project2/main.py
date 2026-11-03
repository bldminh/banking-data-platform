from src.loaders.reference_loader import ReferenceLoader
from src.validators.reference_validator import ReferenceValidator
from src.generators.channel_generator import ChannelGenerator


def main():

    print()
    print("=" * 60)
    print("BANKING DATA GENERATOR")
    print("=" * 60)

    # =========================================================
    # 1. Load Reference
    # =========================================================

    loader = ReferenceLoader()

    loader.load_all()

    # =========================================================
    # 2. Validate Reference
    # =========================================================

    ReferenceValidator.validate()

    # =========================================================
    # 3. Generate Channel
    # =========================================================

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
    print("PROJECT 2 - CHANNEL GENERATOR COMPLETED")
    print("=" * 60)


if __name__ == "__main__":
    main()