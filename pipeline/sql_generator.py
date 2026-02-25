"""SQL file generator for the poland-food-db pipeline.

Generates the 5-file SQL pattern used by every category pipeline:

1. ``PIPELINE__{cat}__01_insert_products.sql``
2. ``PIPELINE__{cat}__03_add_nutrition.sql``
3. ``PIPELINE__{cat}__04_scoring.sql``
4. ``PIPELINE__{cat}__05_source_provenance.sql``
5. ``PIPELINE__{cat}__06_add_images.sql``
"""

from __future__ import annotations

import datetime
from pathlib import Path

from pipeline.utils import slug as _slug

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------


def _sql_text(value: str | None) -> str:
    """Wrap a value in single quotes, escaping internal apostrophes.

    Returns the SQL literal ``null`` when *value* is ``None``.
    Also normalises Unicode curly quotes (U+2018, U+2019) to straight
    apostrophes so SQL literals never contain invisible encoding surprises.
    """
    if value is None:
        return "null"
    s = str(value)
    # Normalise Unicode curly single-quotes to ASCII apostrophe
    s = s.replace("\u2019", "'").replace("\u2018", "'")
    return "'" + s.replace("'", "''") + "'"


def _sql_num(value: str | float | int | None) -> str:
    """Return a bare numeric literal or ``null``.

    Strips non-numeric characters (except ``-`` and ``.``) so values like
    ``"12.5 g"`` become ``12.5``.
    """
    if value is None:
        return "null"
    s = str(value).strip()
    if not s:
        return "null"
    # Strip trailing units / whitespace
    cleaned = ""
    for ch in s:
        if ch in "0123456789.-":
            cleaned += ch
        elif cleaned:
            break
    if not cleaned or cleaned in (".", "-", "-."):
        return "null"
    return cleaned


def _sql_null_or_text(value: str | None) -> str:
    """Return ``null`` for None / empty, otherwise a quoted text literal."""
    if not value:
        return "null"
    return _sql_text(value)


# Recognised Polish retail chains, ordered by market presence.
_POLISH_CHAINS = [
    "Biedronka",
    "Lidl",
    "Żabka",
    "Kaufland",
    "Auchan",
    "Dino",
    "Carrefour",
    "Netto",
    "Stokrotka",
    "Tesco",
    "Lewiatan",
    "Aldi",
    "Penny",
    "Selgros",
    "Delikatesy Centrum",
    "Dealz",
    "Ikea",
    "Rossmann",
]


def _normalize_store(raw: str | None) -> str | None:
    """Extract the primary Polish chain from a raw OFF store string.

    Returns ``None`` when no recognised Polish chain is found.
    """
    if not raw:
        return None
    low = raw.lower()
    for chain in _POLISH_CHAINS:
        if chain.lower() in low:
            return chain
    return None


# ---------------------------------------------------------------------------
# Individual file generators
# ---------------------------------------------------------------------------


def _gen_01_insert_products(
    category: str, products: list[dict], today: str, country: str = "PL"
) -> str:
    """Generate file 01 — insert_products.sql."""
    lines: list[str] = []

    # Values rows
    for i, p in enumerate(products):
        brand = _sql_text(p["brand"])
        name = _sql_text(p["product_name"])
        ean = _sql_text(p.get("ean") or "")
        product_type = _sql_text(p.get("product_type", "Grocery"))
        prep = _sql_null_or_text(p.get("prep_method"))
        store = _sql_null_or_text(_normalize_store(p.get("store_availability")))
        controversies = _sql_text(p.get("controversies", "none"))

        comma = "," if i < len(products) - 1 else ""
        lines.append(
            f"  ({_sql_text(country)}, {brand}, {product_type}, {_sql_text(category)}, "
            f"{name}, {prep}, {store}, {controversies}, {ean}){comma}"
        )

    values_block = "\n".join(lines)

    # Product names for deprecation block
    name_literals = ", ".join(_sql_text(p["product_name"]) for p in products)

    # EAN list for cross-category release
    eans_with_values = [p.get("ean", "") for p in products if p.get("ean")]
    ean_release_block = ""
    if eans_with_values:
        ean_literals = ", ".join(_sql_text(e) for e in eans_with_values)
        ean_release_block = f"""
-- 0b. Release EANs across ALL categories to prevent unique constraint conflicts
update products set ean = null
where ean in ({ean_literals})
  and ean is not null;
"""

    return f"""\
-- PIPELINE ({category}): insert products
-- Source: Open Food Facts API (automated pipeline)
-- Generated: {today}

-- 0a. DEPRECATE old products in this category & release their EANs
update products
set is_deprecated = true, ean = null
where country = {_sql_text(country)}
  and category = {_sql_text(category)}
  and is_deprecated is not true;
{ean_release_block}
-- 1. INSERT products
insert into products (country, brand, product_type, category, product_name, prep_method, store_availability, controversies, ean)
values
{values_block}
on conflict (country, brand, product_name) do update set
  category = excluded.category,
  ean = excluded.ean,
  product_type = excluded.product_type,
  store_availability = excluded.store_availability,
  controversies = excluded.controversies,
  prep_method = excluded.prep_method,
  is_deprecated = false;

-- 2. DEPRECATE removed products
update products
set is_deprecated = true, deprecated_reason = 'Removed from pipeline batch'
where country = {_sql_text(country)} and category = {_sql_text(category)}
  and is_deprecated is not true
  and product_name not in ({name_literals});
"""


def _gen_03_add_nutrition(
    category: str, products: list[dict], country: str = "PL"
) -> str:
    """Generate file 03 — add_nutrition.sql."""
    nutrition_lines: list[str] = []
    for i, p in enumerate(products):
        brand = _sql_text(p["brand"])
        name = _sql_text(p["product_name"])
        vals = ", ".join(
            _sql_num(p[k])
            for k in (
                "calories",
                "total_fat_g",
                "saturated_fat_g",
                "trans_fat_g",
                "carbs_g",
                "sugars_g",
                "fibre_g",
                "protein_g",
                "salt_g",
            )
        )
        comma = "," if i < len(products) - 1 else ""
        nutrition_lines.append(f"    ({brand}, {name}, {vals}){comma}")

    nutrition_block = "\n".join(nutrition_lines)

    return f"""\
-- PIPELINE ({category}): add nutrition facts
-- Source: Open Food Facts verified per-100g data

-- 1) Remove existing
delete from nutrition_facts
where product_id in (
  select p.product_id
  from products p
  where p.country = {_sql_text(country)} and p.category = {_sql_text(category)}
    and p.is_deprecated is not true
);

-- 2) Insert
insert into nutrition_facts
  (product_id, calories, total_fat_g, saturated_fat_g, trans_fat_g,
   carbs_g, sugars_g, fibre_g, protein_g, salt_g)
select
  p.product_id,
  d.calories, d.total_fat_g, d.saturated_fat_g, d.trans_fat_g,
  d.carbs_g, d.sugars_g, d.fibre_g, d.protein_g, d.salt_g
from (
  values
{nutrition_block}
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = {_sql_text(country)} and p.brand = d.brand and p.product_name = d.product_name
  and p.category = {_sql_text(category)} and p.is_deprecated is not true
on conflict (product_id) do update set
  calories = excluded.calories,
  total_fat_g = excluded.total_fat_g,
  saturated_fat_g = excluded.saturated_fat_g,
  trans_fat_g = excluded.trans_fat_g,
  carbs_g = excluded.carbs_g,
  sugars_g = excluded.sugars_g,
  fibre_g = excluded.fibre_g,
  protein_g = excluded.protein_g,
  salt_g = excluded.salt_g;
"""


def _gen_04_scoring(
    category: str, products: list[dict], today: str, country: str = "PL"
) -> str:
    """Generate file 04 — scoring.sql."""

    # (additives_count and ingredients_raw are now derived from
    #  product_ingredient + ingredient_ref junction at query time;
    #  no INSERT/UPDATE to ingredients table needed.)

    # Nutri-Score values
    ns_lines: list[str] = []
    for i, p in enumerate(products):
        ns = p.get("nutri_score_label")
        comma = "," if i < len(products) - 1 else ""
        ns_lines.append(
            f"    ({_sql_text(p['brand'])}, {_sql_text(p['product_name'])}, "
            f"{_sql_null_or_text(ns)}){comma}"
        )
    nutriscore_block = "\n".join(ns_lines)

    # NOVA values
    nova_lines: list[str] = []
    for i, p in enumerate(products):
        nova_raw = p.get("nova_classification") or ""
        nova = nova_raw if nova_raw in ("1", "2", "3", "4") else "4"
        comma = "," if i < len(products) - 1 else ""
        nova_lines.append(
            f"    ({_sql_text(p['brand'])}, {_sql_text(p['product_name'])}, "
            f"{_sql_text(nova)}){comma}"
        )
    nova_block = "\n".join(nova_lines)

    scoring_sql = f"""\
-- PIPELINE ({category}): scoring
-- Generated: {today}

-- 2. Nutri-Score
update products p set
  nutri_score_label = d.ns
from (
  values
{nutriscore_block}
) as d(brand, product_name, ns)
where p.country = {_sql_text(country)} and p.brand = d.brand and p.product_name = d.product_name;

-- 3. NOVA classification
update products p set
  nova_classification = d.nova
from (
  values
{nova_block}
) as d(brand, product_name, nova)
where p.country = {_sql_text(country)} and p.brand = d.brand and p.product_name = d.product_name;

-- 0/1/4/5. Score category (concern defaults, unhealthiness, flags, confidence)
CALL score_category({_sql_text(category)}, 100, {_sql_text(country)});
"""

    return scoring_sql


def _gen_05_source_provenance(
    category: str, products: list[dict], today: str, country: str = "PL"
) -> str:
    """Generate file 05 — source provenance.

    Updates ``products`` with source URL, EAN, and type for every
    product in the category.
    """
    # Build (brand, product_name, ean, source_url) values
    prov_lines: list[str] = []

    for i, p in enumerate(products):
        brand = _sql_text(p["brand"])
        name = _sql_text(p["product_name"])
        ean = p.get("ean") or ""
        comma = "," if i < len(products) - 1 else ""

        # Source URL: if we have an EAN, link to the OFF product page
        if ean:
            source_url = _sql_text(f"https://world.openfoodfacts.org/product/{ean}")
            source_ean = _sql_text(ean)
        else:
            source_url = "null"
            source_ean = "null"

        prov_lines.append(f"    ({brand}, {name}, {source_url}, {source_ean}){comma}")

    prov_block = "\n".join(prov_lines)

    return f"""\
-- PIPELINE ({category}): source provenance
-- Generated: {today}

-- 1. Update source info on products
UPDATE products p SET
  source_type = 'off_api',
  source_url = d.source_url,
  source_ean = d.source_ean
FROM (
  VALUES
{prov_block}
) AS d(brand, product_name, source_url, source_ean)
WHERE p.country = {_sql_text(country)} AND p.brand = d.brand
  AND p.product_name = d.product_name
  AND p.category = {_sql_text(category)} AND p.is_deprecated IS NOT TRUE;
"""


def _gen_06_add_images(
    category: str, products: list[dict], today: str, country: str = "PL"
) -> str:
    """Generate file 06 — add product images.

    Inserts image URLs from the OFF API into the ``product_images`` table.
    Each product can have up to 3 images: front, ingredients, nutrition_label.
    """
    # Gather products that have image URLs
    image_rows: list[str] = []
    for p in products:
        ean = p.get("ean") or ""
        if not ean:
            continue

        brand = _sql_text(p["brand"])
        name = _sql_text(p["product_name"])

        # Try each image type
        for off_key, image_type in [
            ("image_front_url", "front"),
            ("image_ingredients_url", "ingredients"),
            ("image_nutrition_url", "nutrition_label"),
        ]:
            url = p.get(off_key)
            if not url or not url.startswith("https://"):
                continue

            is_primary = "true" if image_type == "front" else "false"
            off_id = _sql_text(f"{image_type}_{ean}")
            alt = _sql_text(f"{image_type.replace('_', ' ').title()} — EAN {ean}")

            image_rows.append(
                f"    ({brand}, {name}, {_sql_text(url)}, 'off_api', "
                f"{_sql_text(image_type)}, {is_primary}, {alt}, {off_id})"
            )

    if not image_rows:
        return f"""\
-- PIPELINE ({category}): add product images
-- Generated: {today}

-- No product images available from OFF API for this category.
"""

    image_block = ",\n".join(image_rows)

    return f"""\
-- PIPELINE ({category}): add product images
-- Source: Open Food Facts API image URLs
-- Generated: {today}

-- 1. Remove existing OFF images for this category
DELETE FROM product_images
WHERE source = 'off_api'
  AND product_id IN (
    SELECT p.product_id FROM products p
    WHERE p.country = {_sql_text(country)} AND p.category = {_sql_text(category)}
      AND p.is_deprecated IS NOT TRUE
  );

-- 2. Insert images
INSERT INTO product_images
  (product_id, url, source, image_type, is_primary, alt_text, off_image_id)
SELECT
  p.product_id, d.url, d.source, d.image_type, d.is_primary, d.alt_text, d.off_image_id
FROM (
  VALUES
{image_block}
) AS d(brand, product_name, url, source, image_type, is_primary, alt_text, off_image_id)
JOIN products p ON p.country = {_sql_text(country)} AND p.brand = d.brand AND p.product_name = d.product_name
  AND p.category = {_sql_text(category)} AND p.is_deprecated IS NOT TRUE
ON CONFLICT (off_image_id) WHERE off_image_id IS NOT NULL DO UPDATE SET
  url = EXCLUDED.url,
  image_type = EXCLUDED.image_type,
  is_primary = EXCLUDED.is_primary,
  alt_text = EXCLUDED.alt_text;
"""


# ---------------------------------------------------------------------------
# Public entry point
# ---------------------------------------------------------------------------


def generate_pipeline(
    category: str,
    products: list[dict],
    output_dir: str,
    country: str = "PL",
) -> list[Path]:
    """Generate 4 SQL pipeline files for *category* in *country*.

    Parameters
    ----------
    category:
        Database category name (e.g. ``"Dairy"``).
    products:
        List of validated, normalised product dicts.
    output_dir:
        Directory to write the SQL files into.
    country:
        ISO 3166-1 alpha-2 country code (default ``"PL"``).

    Returns
    -------
    list[Path]
        Paths of the four generated files.
    """
    out = Path(output_dir)
    out.mkdir(parents=True, exist_ok=True)

    slug = _slug(category)
    today = datetime.date.today().isoformat()

    files: list[Path] = []

    # 01 — insert products
    path01 = out / f"PIPELINE__{slug}__01_insert_products.sql"
    path01.write_text(
        _gen_01_insert_products(category, products, today, country), encoding="utf-8"
    )
    files.append(path01)

    # 03 — add nutrition
    path03 = out / f"PIPELINE__{slug}__03_add_nutrition.sql"
    path03.write_text(
        _gen_03_add_nutrition(category, products, country), encoding="utf-8"
    )
    files.append(path03)

    # 04 — scoring
    path04 = out / f"PIPELINE__{slug}__04_scoring.sql"
    path04.write_text(
        _gen_04_scoring(category, products, today, country), encoding="utf-8"
    )
    files.append(path04)

    # 05 — source provenance
    path05 = out / f"PIPELINE__{slug}__05_source_provenance.sql"
    path05.write_text(
        _gen_05_source_provenance(category, products, today, country), encoding="utf-8"
    )
    files.append(path05)

    # 06 — add images
    path06 = out / f"PIPELINE__{slug}__06_add_images.sql"
    path06.write_text(
        _gen_06_add_images(category, products, today, country), encoding="utf-8"
    )
    files.append(path06)

    return files
