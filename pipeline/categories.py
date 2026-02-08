"""Category mapping between Open Food Facts tags and poland-food-db categories."""

from __future__ import annotations

# ---------------------------------------------------------------------------
# OFF category tag  →  our database category
# ---------------------------------------------------------------------------
OFF_TO_DB_CATEGORY: dict[str, str] = {
    # Chips
    "en:chips": "Chips",
    "en:crisps": "Chips",
    "en:potato-chips": "Chips",
    # Dairy
    "en:dairy": "Dairy",
    "en:milks": "Dairy",
    "en:yogurts": "Dairy",
    "en:cheeses": "Dairy",
    # Bread
    "en:breads": "Bread",
    # Cereals
    "en:cereals": "Cereals",
    "en:breakfast-cereals": "Cereals",
    # Drinks
    "en:beverages": "Drinks",
    "en:sodas": "Drinks",
    "en:juices": "Drinks",
    "en:waters": "Drinks",
    # Meat
    "en:meats": "Meat",
    "en:sausages": "Meat",
    # Sweets
    "en:chocolates": "Sweets",
    "en:candies": "Sweets",
    "en:biscuits": "Sweets",
    # Canned Goods
    "en:canned-foods": "Canned Goods",
    "en:canned-vegetables": "Canned Goods",
    # Sauces
    "en:sauces": "Sauces",
    # Condiments
    "en:ketchups": "Condiments",
    "en:mustards": "Condiments",
    "en:mayonnaises": "Condiments",
    # Snacks
    "en:snacks": "Snacks",
    # Nuts, Seeds & Legumes
    "en:nuts": "Nuts, Seeds & Legumes",
    "en:seeds": "Nuts, Seeds & Legumes",
    # Baby
    "en:baby-foods": "Baby",
    # Alcohol
    "en:alcoholic-beverages": "Alcohol",
    "en:beers": "Alcohol",
    "en:wines": "Alcohol",
    # Frozen & Prepared
    "en:frozen-foods": "Frozen & Prepared",
    # Instant & Frozen
    "en:instant-noodles": "Instant & Frozen",
    # Plant-Based & Alternatives
    "en:plant-based-foods": "Plant-Based & Alternatives",
    # Seafood & Fish
    "en:seafood": "Seafood & Fish",
    "en:fish": "Seafood & Fish",
}

# ---------------------------------------------------------------------------
# Search terms used when querying the OFF API for each database category
# ---------------------------------------------------------------------------
CATEGORY_SEARCH_TERMS: dict[str, list[str]] = {
    "Chips": ["chips", "crisps", "potato chips"],
    "Dairy": ["milk", "yogurt", "cheese", "kefir", "butter", "cream"],
    "Bread": ["bread", "rolls", "baguette", "toast"],
    "Cereals": ["cereals", "muesli", "cornflakes", "oatmeal"],
    "Drinks": ["cola", "juice", "soda", "energy drink", "water"],
    "Meat": ["sausage", "ham", "bacon", "kabanos", "pate"],
    "Sweets": ["chocolate", "candy", "wafer", "biscuit", "praline"],
    "Canned Goods": ["canned", "preserves", "konserwa"],
    "Condiments": ["ketchup", "mustard", "mayonnaise", "vinegar", "sauce"],
    "Snacks": ["crackers", "pretzels", "popcorn", "rice cakes", "granola bar"],
    "Seafood & Fish": ["fish", "tuna", "salmon", "sardine", "herring"],
    "Baby": ["baby food", "baby formula", "baby snack"],
    "Alcohol": ["beer", "wine", "vodka", "whisky"],
    "Sauces": ["pasta sauce", "tomato sauce", "pesto", "dressing"],
    "Frozen & Prepared": ["frozen pizza", "frozen meals", "pierogi"],
    "Instant & Frozen": ["instant noodles", "cup noodles", "instant soup"],
    "Breakfast & Grain-Based": ["granola", "pancake", "waffle", "porridge"],
    "Plant-Based & Alternatives": ["soy milk", "tofu", "plant-based", "vegan"],
    "Nuts, Seeds & Legumes": ["peanuts", "almonds", "walnuts", "sunflower seeds"],
}

# Reverse lookup: DB category → list of OFF tags
DB_TO_OFF_TAGS: dict[str, list[str]] = {}
for _tag, _cat in OFF_TO_DB_CATEGORY.items():
    DB_TO_OFF_TAGS.setdefault(_cat, []).append(_tag)


def resolve_category(off_categories_tags: list[str]) -> str | None:
    """Return the first matching database category for a list of OFF tags.

    Parameters
    ----------
    off_categories_tags:
        The ``categories_tags`` list from an OFF product record.

    Returns
    -------
    str | None
        The matched database category, or *None* if no mapping exists.
    """
    for tag in off_categories_tags:
        if tag in OFF_TO_DB_CATEGORY:
            return OFF_TO_DB_CATEGORY[tag]
    return None
