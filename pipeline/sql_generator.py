"""SQL file generator for the poland-food-db pipeline.

Generates the 4-file SQL pattern used by every category pipeline:

1. ``PIPELINE__{cat}__01_insert_products.sql``
2. ``PIPELINE__{cat}__02_add_servings.sql``
3. ``PIPELINE__{cat}__03_add_nutrition.sql``
4. ``PIPELINE__{cat}__04_scoring.sql``
"""

from __future__ import annotations

import datetime
import logging
from pathlib import Path

logger = logging.getLogger(__name__)


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------


def _sql_text(value: str | None) -> str:
    """Wrap a value in single quotes, escaping internal apostrophes.

    Returns the SQL literal ``null`` when *value* is ``None``.
    """
    if value is None:
        return "null"
    return "'" + str(value).replace("'", "''") + "'"


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


def _slug(category: str) -> str:
    """Convert a category name to a filesystem-safe slug.

    ``'Nuts, Seeds & Legumes'`` → ``'nuts-seeds'``
    """
    return (
        category.lower()
        .replace("&", "")
        .replace(",", "")
        .replace("  ", " ")
        .strip()
        .replace(" ", "-")
    )


# ---------------------------------------------------------------------------
# Individual file generators
# ---------------------------------------------------------------------------


def _gen_01_insert_products(category: str, products: list[dict], today: str) -> str:
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
            f"  ('PL', {brand}, {product_type}, {_sql_text(category)}, "
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
where country = 'PL'
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
where country = 'PL' and category = {_sql_text(category)}
  and is_deprecated is not true
  and product_name not in ({name_literals});
"""


def _gen_02_add_servings(category: str) -> str:
    """Generate file 02 — add_servings.sql."""
    return f"""\
-- PIPELINE ({category}): add servings
insert into servings (product_id, serving_basis, serving_amount_g_ml)
select p.product_id, 'per 100 g', 100
from products p
left join servings s on s.product_id = p.product_id and s.serving_basis = 'per 100 g'
where p.country='PL' and p.category={_sql_text(category)}
  and p.is_deprecated is not true
  and s.serving_id is null;
"""


def _gen_03_add_nutrition(category: str, products: list[dict]) -> str:
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
where (product_id, serving_id) in (
  select p.product_id, s.serving_id
  from products p
  join servings s on s.product_id = p.product_id and s.serving_basis = 'per 100 g'
  where p.country = 'PL' and p.category = {_sql_text(category)}
    and p.is_deprecated is not true
);

-- 2) Insert
insert into nutrition_facts
  (product_id, serving_id, calories, total_fat_g, saturated_fat_g, trans_fat_g,
   carbs_g, sugars_g, fibre_g, protein_g, salt_g)
select
  p.product_id, s.serving_id,
  d.calories, d.total_fat_g, d.saturated_fat_g, d.trans_fat_g,
  d.carbs_g, d.sugars_g, d.fibre_g, d.protein_g, d.salt_g
from (
  values
{nutrition_block}
) as d(brand, product_name, calories, total_fat_g, saturated_fat_g, trans_fat_g,
       carbs_g, sugars_g, fibre_g, protein_g, salt_g)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
  and p.category = {_sql_text(category)} and p.is_deprecated is not true
join servings s on s.product_id = p.product_id and s.serving_basis = 'per 100 g'
on conflict (product_id, serving_id) do update set
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


def _gen_04_scoring(category: str, products: list[dict], today: str) -> str:
    """Generate file 04 — scoring.sql."""

    # Additives values
    add_lines: list[str] = []
    for i, p in enumerate(products):
        comma = "," if i < len(products) - 1 else ""
        add_lines.append(
            f"    ({_sql_text(p['brand'])}, {_sql_text(p['product_name'])}, "
            f"{_sql_num(p.get('additives_count', 0))}){comma}"
        )
    additives_block = "\n".join(add_lines)

    # Ingredients-raw values (where available from OFF)
    raw_lines: list[str] = []
    for i, p in enumerate(products):
        raw = p.get("ingredients_raw")
        if raw:
            comma = "," if i < len(products) - 1 else ""
            raw_lines.append(
                f"    ({_sql_text(p['brand'])}, {_sql_text(p['product_name'])}, "
                f"{_sql_text(raw)}){comma}"
            )
    # Fix trailing commas — re-join without trailing comma on last entry
    if raw_lines:
        raw_lines = [
            l.rstrip(",") if i == len(raw_lines) - 1 else l
            for i, l in enumerate(raw_lines)
        ]
    ingredients_raw_block = "\n".join(raw_lines) if raw_lines else ""

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

-- 0. ENSURE rows in scores & ingredients
insert into scores (product_id)
select p.product_id
from products p
left join scores sc on sc.product_id = p.product_id
where p.country = 'PL' and p.category = {_sql_text(category)}
  and p.is_deprecated is not true
  and sc.product_id is null;

insert into ingredients (product_id)
select p.product_id
from products p
left join ingredients i on i.product_id = p.product_id
where p.country = 'PL' and p.category = {_sql_text(category)}
  and p.is_deprecated is not true
  and i.product_id is null;

-- 1. Additives count
update ingredients i set
  additives_count = d.cnt
from (
  values
{additives_block}
) as d(brand, product_name, cnt)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
where i.product_id = p.product_id;
"""

    # Conditionally add ingredients_raw section
    if ingredients_raw_block:
        scoring_sql += f"""
-- 1b. Ingredients raw text (from OFF)
update ingredients i set
  ingredients_raw = d.raw_text
from (
  values
{ingredients_raw_block}
) as d(brand, product_name, raw_text)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
where i.product_id = p.product_id;
"""

    scoring_sql += f"""
-- 2. COMPUTE unhealthiness_score (v3.2 — 9 factors)
update scores sc set
  unhealthiness_score = compute_unhealthiness_v32(
      nf.saturated_fat_g,
      nf.sugars_g,
      nf.salt_g,
      nf.calories,
      nf.trans_fat_g,
      i.additives_count,
      p.prep_method,
      p.controversies,
      sc.ingredient_concern_score
  ),
  scored_at       = CURRENT_DATE,
  scoring_version = 'v3.2'
from products p
join servings sv on sv.product_id = p.product_id and sv.serving_basis = 'per 100 g'
join nutrition_facts nf on nf.product_id = p.product_id and nf.serving_id = sv.serving_id
left join ingredients i on i.product_id = p.product_id
where p.product_id = sc.product_id
  and p.country = 'PL' and p.category = {_sql_text(category)}
  and p.is_deprecated is not true;

-- 3. Nutri-Score
update scores sc set
  nutri_score_label = d.ns
from (
  values
{nutriscore_block}
) as d(brand, product_name, ns)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
where p.product_id = sc.product_id;

-- 4. NOVA + processing risk
update scores sc set
  nova_classification = d.nova,
  processing_risk = case d.nova
    when '4' then 'High'
    when '3' then 'Moderate'
    when '2' then 'Low'
    when '1' then 'Low'
    else 'Unknown'
  end
from (
  values
{nova_block}
) as d(brand, product_name, nova)
join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name
where p.product_id = sc.product_id;

-- 5. Health-risk flags
update scores sc set
  high_salt_flag = case when nf.salt_g >= 1.5 then 'YES' else 'NO' end,
  high_sugar_flag = case when nf.sugars_g >= 5.0 then 'YES' else 'NO' end,
  high_sat_fat_flag = case when nf.saturated_fat_g >= 5.0 then 'YES' else 'NO' end,
  high_additive_load = case when coalesce(i.additives_count, 0) >= 5 then 'YES' else 'NO' end,
  data_completeness_pct = 100
from products p
join servings sv on sv.product_id = p.product_id and sv.serving_basis = 'per 100 g'
join nutrition_facts nf on nf.product_id = p.product_id and nf.serving_id = sv.serving_id
left join ingredients i on i.product_id = p.product_id
where p.product_id = sc.product_id
  and p.country = 'PL' and p.category = {_sql_text(category)}
  and p.is_deprecated is not true;

-- 6. SET confidence level
update scores sc set
  confidence = assign_confidence(sc.data_completeness_pct, 'openfoodfacts')
from products p
where p.product_id = sc.product_id
  and p.country = 'PL' and p.category = {_sql_text(category)}
  and p.is_deprecated is not true;
"""

    return scoring_sql


# ---------------------------------------------------------------------------
# Public entry point
# ---------------------------------------------------------------------------


def generate_pipeline(
    category: str,
    products: list[dict],
    output_dir: str,
) -> list[Path]:
    """Generate 4 SQL pipeline files for *category*.

    Parameters
    ----------
    category:
        Database category name (e.g. ``"Dairy"``).
    products:
        List of validated, normalised product dicts.
    output_dir:
        Directory to write the SQL files into.

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
        _gen_01_insert_products(category, products, today), encoding="utf-8"
    )
    files.append(path01)

    # 02 — add servings
    path02 = out / f"PIPELINE__{slug}__02_add_servings.sql"
    path02.write_text(_gen_02_add_servings(category), encoding="utf-8")
    files.append(path02)

    # 03 — add nutrition
    path03 = out / f"PIPELINE__{slug}__03_add_nutrition.sql"
    path03.write_text(_gen_03_add_nutrition(category, products), encoding="utf-8")
    files.append(path03)

    # 04 — scoring
    path04 = out / f"PIPELINE__{slug}__04_scoring.sql"
    path04.write_text(_gen_04_scoring(category, products, today), encoding="utf-8")
    files.append(path04)

    return files
