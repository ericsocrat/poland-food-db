"""Open Food Facts API client for the poland-food-db pipeline.

Searches and fetches Polish product data, normalises it into the project
schema, and respects the OFF API rate-limit guidelines.
"""

from __future__ import annotations

import logging
import re
import time
from typing import Any

import requests

from pipeline.categories import CATEGORY_SEARCH_TERMS, DB_TO_OFF_TAGS, resolve_category

logger = logging.getLogger(__name__)

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------
OFF_SEARCH_URL = "https://world.openfoodfacts.org/cgi/search.pl"
OFF_PRODUCT_URL = "https://world.openfoodfacts.org/api/v2/product/{ean}.json"
USER_AGENT = "poland-food-db/1.0 (https://github.com/ericsocrat/poland-food-db)"
PAGE_SIZE = 50
REQUEST_DELAY = 1.0  # seconds between requests


def _session() -> requests.Session:
    """Return a reusable requests session with the correct User-Agent."""
    s = requests.Session()
    s.headers.update({"User-Agent": USER_AGENT})
    return s


# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------


def search_polish_products(
    category: str,
    max_results: int = 50,
) -> list[dict]:
    """Search Open Food Facts for Polish products in *category*.

    Uses the OFF search endpoint filtered by ``countries_tags=en:poland`` and
    iterates through search terms defined in ``CATEGORY_SEARCH_TERMS``.
    Rate-limits to one request per second.

    Parameters
    ----------
    category:
        Database category name (e.g. ``"Dairy"``, ``"Chips"``).
    max_results:
        Maximum number of raw product dicts to return.

    Returns
    -------
    list[dict]
        Raw OFF product dicts (un-normalised).
    """
    search_terms = CATEGORY_SEARCH_TERMS.get(category, [category.lower()])
    off_tags = DB_TO_OFF_TAGS.get(category, [])
    seen_codes: set[str] = set()
    results: list[dict] = []
    session = _session()

    for term in search_terms:
        if len(results) >= max_results:
            break

        page = 1
        while len(results) < max_results:
            params: dict[str, Any] = {
                "search_terms": term,
                "countries_tags": "en:poland",
                "search_simple": 1,
                "action": "process",
                "json": 1,
                "page": page,
                "page_size": PAGE_SIZE,
            }
            # Add category tag filter if we have OFF tags for this category
            if off_tags:
                params["tagtype_0"] = "categories"
                params["tag_contains_0"] = "contains"
                params["tag_0"] = off_tags[0]
            try:
                resp = session.get(OFF_SEARCH_URL, params=params, timeout=30)
                resp.raise_for_status()
                data = resp.json()
            except requests.RequestException as exc:
                logger.warning(
                    "OFF search failed for term=%r page=%d: %s", term, page, exc
                )
                break

            products = data.get("products", [])
            if not products:
                break

            for p in products:
                code = p.get("code", "")
                if code and code not in seen_codes:
                    seen_codes.add(code)
                    results.append(p)
                    if len(results) >= max_results:
                        break

            # Stop if we've exhausted the result set
            total = int(data.get("count", 0))
            if page * PAGE_SIZE >= total:
                break

            page += 1
            time.sleep(REQUEST_DELAY)

        time.sleep(REQUEST_DELAY)

    return results[:max_results]


def fetch_product_by_ean(ean: str) -> dict | None:
    """Fetch a single product from OFF by its EAN barcode.

    Parameters
    ----------
    ean:
        EAN-13 barcode string.

    Returns
    -------
    dict | None
        The raw OFF product dict, or *None* on failure / not found.
    """
    session = _session()
    url = OFF_PRODUCT_URL.format(ean=ean)
    try:
        resp = session.get(url, timeout=30)
        resp.raise_for_status()
        data = resp.json()
    except requests.RequestException as exc:
        logger.warning("OFF fetch failed for EAN %s: %s", ean, exc)
        return None

    if data.get("status") != 1:
        return None

    return data.get("product")


# ---------------------------------------------------------------------------
# Extraction / normalisation
# ---------------------------------------------------------------------------


def _round1(value: Any, default: str = "0") -> str:
    """Round a numeric value to 1 decimal place and return as string."""
    if value is None:
        return default
    try:
        return str(round(float(value), 1))
    except (ValueError, TypeError):
        return default


def _clean_text(text: str | None) -> str:
    """Escape single quotes for SQL and strip whitespace."""
    if not text:
        return ""
    return text.strip().replace("'", "''")


def _detect_prep_method(categories_tags: list[str], product_name: str) -> str | None:
    """Infer prep_method from OFF category tags and product name."""
    combined = " ".join(categories_tags) + " " + product_name.lower()
    if re.search(r"\bfried\b", combined):
        return "fried"
    if re.search(r"\bbaked\b", combined):
        return "baked"
    return None


def _detect_controversies(off_product: dict) -> str:
    """Check ingredient text for palm oil."""
    ingredients = (off_product.get("ingredients_text") or "").lower()
    if "palm oil" in ingredients or "huile de palme" in ingredients:
        return "palm oil"
    return "none"


def extract_product_data(off_product: dict) -> dict | None:
    """Normalise a raw OFF product dict into the poland-food-db schema.

    Returns *None* when the product is missing essential nutrition data
    (calories, fat, or protein).

    Parameters
    ----------
    off_product:
        A single product dict as returned by the OFF API.

    Returns
    -------
    dict | None
        Normalised product dict ready for validation and SQL generation.
    """
    nutriments = off_product.get("nutriments", {})

    # Required fields — skip if any of these are missing
    calories_raw = nutriments.get("energy-kcal_100g")
    fat_raw = nutriments.get("fat_100g")
    protein_raw = nutriments.get("proteins_100g")
    if calories_raw is None or fat_raw is None or protein_raw is None:
        return None

    # Product name
    product_name = (
        off_product.get("product_name")
        or off_product.get("abbreviated_product_name")
        or ""
    ).strip()
    if not product_name:
        return None

    # Brand — take the first if comma-separated
    brands_raw = off_product.get("brands", "")
    brand = brands_raw.split(",")[0].strip() if brands_raw else "Unknown"
    if not brand:
        brand = "Unknown"

    # EAN
    ean = off_product.get("code", "")

    # Category resolution
    categories_tags: list[str] = off_product.get("categories_tags", [])
    category = resolve_category(categories_tags)

    # Prep method & controversies
    prep_method = _detect_prep_method(categories_tags, product_name)
    controversies = _detect_controversies(off_product)

    # Store availability
    store_availability = off_product.get("stores") or None

    # NOVA & Nutri-Score
    nova_tags = off_product.get("nova_groups_tags", [])
    if nova_tags:
        nova_raw = nova_tags[0].split(":")[-1]  # e.g. "4-ultra-processed..."
        nova = nova_raw.split("-")[0] if "-" in nova_raw else nova_raw
    else:
        nova = None

    nutriscore_raw = off_product.get("nutriscore_grade")
    nutri_score_label = nutriscore_raw.upper() if nutriscore_raw else None

    return {
        "product_name": product_name,
        "brand": brand,
        "ean": ean,
        "category": category,
        "product_type": "Grocery",
        "prep_method": prep_method,
        "controversies": controversies,
        "store_availability": store_availability,
        # Nutrition (per 100 g)
        "calories": _round1(calories_raw),
        "total_fat_g": _round1(fat_raw),
        "saturated_fat_g": _round1(nutriments.get("saturated-fat_100g")),
        "trans_fat_g": _round1(nutriments.get("trans-fat_100g"), "0"),
        "carbs_g": _round1(nutriments.get("carbohydrates_100g")),
        "sugars_g": _round1(nutriments.get("sugars_100g")),
        "fibre_g": _round1(nutriments.get("fiber_100g"), "0"),
        "protein_g": _round1(protein_raw),
        "salt_g": _round1(nutriments.get("salt_100g")),
        # Scores / classifications
        "additives_count": off_product.get("additives_n", 0) or 0,
        "nova_classification": nova,
        "nutri_score_label": nutri_score_label,
        # OFF metadata (used by validator)
        "_completeness": off_product.get("completeness", 0),
        "_has_image": bool(off_product.get("image_url")),
    }
