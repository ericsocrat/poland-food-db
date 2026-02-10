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
OFF_SEARCH_URL = "https://world.openfoodfacts.org/api/v2/search"
OFF_PRODUCT_URL = "https://world.openfoodfacts.org/api/v2/product/{ean}.json"
USER_AGENT = "poland-food-db/1.0 (https://github.com/ericsocrat/poland-food-db)"
PAGE_SIZE = 50
REQUEST_DELAY = 1.0  # seconds between requests
REQUEST_TIMEOUT = 90  # seconds (OFF API can be slow)
MAX_RETRIES = 3


def _get_json(session: requests.Session, url: str, params: dict) -> dict | None:
    """GET with retry on timeout / server error.

    Handles HTTP errors, connection failures, timeouts, and malformed JSON
    responses.  Returns ``None`` after exhausting retries so callers can
    gracefully degrade.
    """
    for attempt in range(MAX_RETRIES + 1):
        try:
            resp = session.get(url, params=params, timeout=REQUEST_TIMEOUT)
            resp.raise_for_status()
            return resp.json()
        except (ValueError, KeyError) as exc:
            # json.JSONDecodeError is a subclass of ValueError — catches
            # malformed responses (e.g. HTML error pages returned as 200).
            logger.warning("Malformed JSON from %s: %s", url, exc)
            return None
        except (requests.RequestException, TimeoutError, ConnectionError) as exc:
            if attempt < MAX_RETRIES:
                wait = REQUEST_DELAY * (attempt + 1) * 2
                logger.debug(
                    "Retry %d for %s: %s (wait %.0fs)", attempt + 1, url, exc, wait
                )
                time.sleep(wait)
                continue
            logger.warning("Request failed after %d retries: %s", MAX_RETRIES, exc)
            return None


def _session() -> requests.Session:
    """Return a reusable requests session with the correct User-Agent."""
    s = requests.Session()
    s.headers.update({"User-Agent": USER_AGENT})
    return s


# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------


def _search_by_tags(
    session: requests.Session,
    off_tags: list[str],
    seen_codes: set[str],
    results: list[dict],
    max_results: int,
) -> None:
    """Phase 1: search OFF by category tags (mutates *results* and *seen_codes*)."""
    for tag in off_tags:
        if len(results) >= max_results:
            return
        page = 1
        while len(results) < max_results:
            params: dict[str, Any] = {
                "categories_tags_en": tag,
                "countries_tags_en": "poland",
                "page": page,
                "page_size": PAGE_SIZE,
            }
            data = _get_json(session, OFF_SEARCH_URL, params)
            if data is None:
                break
            products = data.get("products", [])
            if not products:
                break
            _collect_products(products, seen_codes, results, max_results)
            if page * PAGE_SIZE >= int(data.get("count", 0)):
                break
            page += 1
            time.sleep(REQUEST_DELAY)
        time.sleep(REQUEST_DELAY)


def _search_by_terms(
    session: requests.Session,
    search_terms: list[str],
    seen_codes: set[str],
    results: list[dict],
    max_results: int,
) -> None:
    """Phase 2: fall back to keyword search (mutates *results* and *seen_codes*)."""
    for term in search_terms:
        if len(results) >= max_results:
            return
        page = 1
        while len(results) < max_results:
            params: dict[str, Any] = {
                "search_terms": term,
                "countries_tags_en": "poland",
                "page": page,
                "page_size": PAGE_SIZE,
            }
            data = _get_json(session, OFF_SEARCH_URL, params)
            if data is None:
                break
            products = data.get("products", [])
            if not products:
                break
            _collect_products(products, seen_codes, results, max_results)
            if page * PAGE_SIZE >= int(data.get("count", 0)):
                break
            page += 1
            time.sleep(REQUEST_DELAY)
        time.sleep(REQUEST_DELAY)


def _collect_products(
    products: list[dict],
    seen_codes: set[str],
    results: list[dict],
    max_results: int,
) -> None:
    """Append unseen products to *results* (mutates both collections)."""
    for p in products:
        code = p.get("code", "")
        if code and code not in seen_codes:
            seen_codes.add(code)
            results.append(p)
            if len(results) >= max_results:
                return


def search_polish_products(
    category: str,
    max_results: int = 50,
) -> list[dict]:
    """Search Open Food Facts for Polish products in *category*.

    Uses a two-phase strategy:

    1. **Tag search** — query by OFF category tags (most reliable).
    2. **Term search** — fall back to keyword search terms if tag search
       didn't find enough results.

    Both phases filter by ``countries_tags=en:poland`` and rate-limit to
    one request per second.

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

    # Phase 1: Search by OFF category tags
    _search_by_tags(session, off_tags, seen_codes, results, max_results)

    # Phase 2: Fall back to keyword search if needed
    if len(results) < max_results:
        _search_by_terms(session, search_terms, seen_codes, results, max_results)

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
    data = _get_json(session, url, {})
    if data is None:
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


# ---------------------------------------------------------------------------
# Quality filters — ensure products are genuinely from the Polish market
# ---------------------------------------------------------------------------

# Require that ≥50% of product_name characters are Latin/Polish/digit/punctuation.
_LATIN_RE = re.compile(
    r"[a-zA-ZąćęłńóśźżĄĆĘŁŃÓŚŹŻäöüÄÖÜéèêëàâîôùûçÉ0-9\s\-'.,&/!()#+%]"
)

# Known Polish retailers (for market-relevance scoring)
POLISH_RETAILERS: set[str] = {
    "biedronka",
    "lidl",
    "żabka",
    "zabka",
    "kaufland",
    "auchan",
    "carrefour",
    "netto",
    "dino",
    "stokrotka",
    "intermarché",
    "intermarche",
    "makro",
    "selgros",
    "polo market",
    "lewiatan",
    "groszek",
    "freshmarket",
    "piotr i paweł",
    "spar",
    "hebe",
    "rossmann",
    "tesco",
    "e.leclerc",
}

# Common brand normalisations
_BRAND_LAYS = "Lay's"
_BRAND_NESTLE = "Nestlé"

_BRAND_NORMALISE: dict[str, str] = {
    "lays": _BRAND_LAYS,
    "lay's": _BRAND_LAYS,
    "pringles": "Pringles",
    "doritos": "Doritos",
    "cheetos": "Cheetos",
    "nestle": _BRAND_NESTLE,
    "nestlé": _BRAND_NESTLE,
    "danone": "Danone",
    "intersnack-poland": "Intersnack",
}


def _is_latin_name(name: str) -> bool:
    """Return True if at least 50% of the name's characters are Latin/Polish."""
    if not name:
        return False
    latin_count = sum(1 for c in name if _LATIN_RE.match(c))
    return latin_count / len(name) >= 0.5


def _normalise_brand(brand: str) -> str:
    """Normalise common brand name variants."""
    key = brand.lower().strip()
    return _BRAND_NORMALISE.get(key, brand.strip())


def polish_market_score(product: dict) -> int:
    """Score how likely a product is genuinely sold in Poland.

    Higher scores indicate stronger Polish market presence:
      +3  EAN starts with 590 (Polish GS1 prefix)
      +2  Product name contains Polish characters (ą, ć, ę, ł, ń, ó, ś, ź, ż)
      +1  Store availability mentions a known Polish retailer
      +1  OFF completeness ≥ 0.5
    """
    score = 0
    ean = product.get("ean", "")
    if ean.startswith("590"):
        score += 3

    name = product.get("product_name", "")
    if re.search(r"[ąćęłńóśźżĄĆĘŁŃÓŚŹŻ]", name):
        score += 2

    stores = (product.get("store_availability") or "").lower()
    if any(r in stores for r in POLISH_RETAILERS):
        score += 1

    try:
        completeness = float(product.get("_completeness", 0))
    except (ValueError, TypeError):
        completeness = 0.0
    if completeness >= 0.5:
        score += 1

    return score


def _detect_prep_method(categories_tags: list[str], product_name: str) -> str | None:
    """Infer prep_method from OFF category tags and product name.

    Checks for common preparation methods in order of specificity.
    Returns ``None`` when no method can be inferred (caller decides
    whether to fall back to ``'not-applicable'``).
    """
    combined = " ".join(categories_tags) + " " + product_name.lower()

    # Order matters: check more specific terms first
    _PREP_PATTERNS: list[tuple[str, str]] = [
        (r"\bfried\b|\bfrying\b|\bdeep[- ]?fried\b|\bsmażon", "fried"),
        (r"\bsmoked\b|\bsmoking\b|\bwędzon", "smoked"),
        (r"\broasted\b|\broast\b|\bpieczony\b|\bpieczon", "roasted"),
        (r"\bsteamed\b|\bsteaming\b|\bna parze\b", "steamed"),
        (r"\bgrilled\b|\bgrill\b|\bgrillowany\b", "grilled"),
        (r"\bbaked\b|\bbaking\b|\bwypiekany\b", "baked"),
        (r"\bmarinated\b|\bmarynowany\b", "marinated"),
        (r"\bpasteurized\b|\bpasteryzowany\b|\bUHT\b", "pasteurized"),
        (r"\bfermented\b|\bfermentowany\b|\bkiszony\b", "fermented"),
        (r"\bdried\b|\bsuszony\b|\bdehydrated\b", "dried"),
        (r"\braw\b|\bsurowy\b", "raw"),
    ]

    for pattern, method in _PREP_PATTERNS:
        if re.search(pattern, combined, re.IGNORECASE):
            return method
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

    # Reject names that are predominantly non-Latin (e.g. Cyrillic, Arabic)
    if not _is_latin_name(product_name):
        return None

    # Brand — take the first if comma-separated, then normalise
    brands_raw = off_product.get("brands", "")
    brand = brands_raw.split(",")[0].strip() if brands_raw else "Unknown"
    if not brand:
        brand = "Unknown"
    brand = _normalise_brand(brand)

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

    # Ingredients text (raw)
    ingredients_raw = (off_product.get("ingredients_text") or "").strip() or None

    # NOVA & Nutri-Score
    nova_tags = off_product.get("nova_groups_tags", [])
    nova = None
    if nova_tags:
        nova_raw = nova_tags[0].split(":")[-1]  # e.g. "4-ultra-processed..."
        digit = nova_raw.split("-")[0] if "-" in nova_raw else nova_raw
        if digit in ("1", "2", "3", "4"):
            nova = digit

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
        # Ingredients
        "ingredients_raw": ingredients_raw,
        # OFF metadata (used by validator)
        "_completeness": off_product.get("completeness", 0),
        "_has_image": bool(off_product.get("image_url")),
    }
