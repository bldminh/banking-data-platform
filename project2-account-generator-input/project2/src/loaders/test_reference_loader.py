from src.loaders.reference_loader import ReferenceLoader
from src.validators.reference_validator import ReferenceValidator

loader = ReferenceLoader()

loader.load_all()

ReferenceValidator.validate()