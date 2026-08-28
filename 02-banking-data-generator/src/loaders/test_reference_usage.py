from src.loaders.reference_loader import ReferenceLoader
from src.cache.reference_cache import ReferenceCache

loader = ReferenceLoader()

loader.load_all()

currency_df = ReferenceCache.get(
    "currency"
)

print(currency_df.head())