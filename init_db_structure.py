from pathlib import Path
from datetime import datetime

BASE = Path("db")

folders = [
    BASE / "migrations",
    BASE / "pipelines" / "chips",
    BASE / "pipelines" / "zabka",
    BASE / "pipelines" / "cereals",
    BASE / "pipelines" / "drinks",
    BASE / "views",
    BASE / "qa",
]

for f in folders:
    f.mkdir(parents=True, exist_ok=True)

today = datetime.utcnow().strftime("%Y%m%d")

templates = {
    BASE / "migrations" / f"{today}__products_identity.sql":
        "-- MIGRATION: products.product_id identity + sequence sync\n",
    BASE / "migrations" / f"{today}__servings_identity.sql":
        "-- MIGRATION: servings.serving_id identity + sequence sync\n",
    BASE / "views" / "VIEW__master_product_view.sql":
        "-- VIEW: master product view\n",
    BASE / "qa" / "QA__null_checks.sql":
        "-- QA: null checks\n",
    BASE / "pipelines" / "chips" / "PIPELINE__chips__01_insert_products.sql":
        "-- PIPELINE (CHIPS): insert products (UPSERT)\n",
    BASE / "pipelines" / "chips" / "PIPELINE__chips__02_add_servings.sql":
        "-- PIPELINE (CHIPS): add servings\n",
    BASE / "pipelines" / "chips" / "PIPELINE__chips__03_add_nutrition.sql":
        "-- PIPELINE (CHIPS): add nutrition facts\n",
    BASE / "pipelines" / "chips" / "PIPELINE__chips__04_scoring.sql":
        "-- PIPELINE (CHIPS): scoring updates\n",
    BASE / "pipelines" / "zabka" / "PIPELINE__zabka__01_insert_products.sql":
        "-- PIPELINE (ZABKA): insert products (UPSERT)\n",
    BASE / "pipelines" / "zabka" / "PIPELINE__zabka__02_add_servings.sql":
        "-- PIPELINE (ZABKA): add servings\n",
    BASE / "pipelines" / "zabka" / "PIPELINE__zabka__03_add_nutrition.sql":
        "-- PIPELINE (ZABKA): add nutrition facts\n",
    BASE / "pipelines" / "zabka" / "PIPELINE__zabka__04_scoring.sql":
        "-- PIPELINE (ZABKA): scoring updates\n",
    BASE / "pipelines" / "zabka" / "PIPELINE__zabka__05_personal_lenses.sql":
        "-- PIPELINE (ZABKA): personal lenses update\n",
}

for path, content in templates.items():
    if not path.exists():
        path.write_text(content, encoding="utf-8")

print("DB structure created.")
