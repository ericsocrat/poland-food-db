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
    "en:tortilla-chips": "Chips",
    "en:corn-chips": "Chips",
    # Dairy
    "en:dairy": "Dairy",
    "en:dairies": "Dairy",
    "en:milks": "Dairy",
    "en:yogurts": "Dairy",
    "en:cheeses": "Dairy",
    "en:butters": "Dairy",
    "en:creams": "Dairy",
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
    "en:energy-drinks": "Drinks",
    "en:non-alcoholic-beverages": "Drinks",
    # Meat
    "en:meats": "Meat",
    "en:sausages": "Meat",
    "en:hams": "Meat",
    "en:cold-cuts": "Meat",
    "en:pork": "Meat",
    "en:poultry": "Meat",
    # Sweets
    "en:chocolates": "Sweets",
    "en:candies": "Sweets",
    "en:biscuits": "Sweets",
    "en:confectioneries": "Sweets",
    # Canned Goods
    "en:canned-foods": "Canned Goods",
    "en:canned-vegetables": "Canned Goods",
    "en:canned-fruits": "Canned Goods",
    "en:canned-fish": "Canned Goods",
    # Sauces (specific subtypes first — broad parent searched last)
    "en:tomato-sauces": "Sauces",
    "en:pasta-sauces": "Sauces",
    "en:pestos": "Sauces",
    "en:salad-dressings": "Sauces",
    "en:hot-sauces": "Sauces",
    "en:barbecue-sauces": "Sauces",
    "en:soy-sauces": "Sauces",
    "en:curry-sauces": "Sauces",
    "en:cooking-sauces": "Sauces",
    "en:sauces": "Sauces",
    # Condiments (specific subtypes only — en:condiments is too broad on OFF)
    "en:ketchups": "Condiments",
    "en:ketchup": "Condiments",
    "en:tomato-ketchup": "Condiments",
    "en:mustards": "Condiments",
    "en:mayonnaises": "Condiments",
    # Snacks (broad — see BROAD_CATEGORIES)
    "en:snacks": "Snacks",
    "en:salty-snacks": "Snacks",
    "en:appetizers": "Snacks",
    "en:crackers": "Snacks",
    "en:pretzels": "Snacks",
    "en:popcorn": "Snacks",
    "en:rice-cakes": "Snacks",
    "en:corn-snacks": "Snacks",
    "en:breadsticks": "Snacks",
    "en:extruded-snacks": "Snacks",
    "en:puffed-rice-cakes": "Snacks",
    # Nuts, Seeds & Legumes
    "en:nuts": "Nuts, Seeds & Legumes",
    "en:seeds": "Nuts, Seeds & Legumes",
    "en:legumes": "Nuts, Seeds & Legumes",
    "en:dried-fruits": "Nuts, Seeds & Legumes",
    # Baby
    "en:baby-foods": "Baby",
    "en:baby-milks": "Baby",
    "en:infant-formulas": "Baby",
    "en:baby-cereals": "Baby",
    "en:baby-meals": "Baby",
    # Alcohol
    "en:alcoholic-beverages": "Alcohol",
    "en:beers": "Alcohol",
    "en:wines": "Alcohol",
    "en:spirits": "Alcohol",
    "en:ciders": "Alcohol",
    "en:liqueurs": "Alcohol",
    "en:meads": "Alcohol",
    # Frozen & Prepared
    "en:frozen-foods": "Frozen & Prepared",
    "en:frozen-pizzas": "Frozen & Prepared",
    # Breakfast & Grain-Based
    "en:granolas": "Breakfast & Grain-Based",
    "en:crispbreads": "Breakfast & Grain-Based",
    "en:pancakes": "Breakfast & Grain-Based",
    "en:flat-breads": "Breakfast & Grain-Based",
    # Instant & Frozen
    "en:instant-noodles": "Instant & Frozen",
    "en:instant-soups": "Instant & Frozen",
    # Plant-Based & Alternatives (broad — see BROAD_CATEGORIES)
    "en:plant-based-foods": "Plant-Based & Alternatives",
    "en:plant-based-foods-and-beverages": "Plant-Based & Alternatives",
    "en:meat-alternatives": "Plant-Based & Alternatives",
    "en:tofu": "Plant-Based & Alternatives",
    "en:soy-milks": "Plant-Based & Alternatives",
    "en:oat-milks": "Plant-Based & Alternatives",
    "en:almond-milks": "Plant-Based & Alternatives",
    "en:rice-milks": "Plant-Based & Alternatives",
    "en:plant-based-milk-alternatives": "Plant-Based & Alternatives",
    # Seafood & Fish
    "en:seafood": "Seafood & Fish",
    "en:fish": "Seafood & Fish",
    "en:smoked-fish": "Seafood & Fish",
    "en:smoked-salmon": "Seafood & Fish",
    "en:sardines": "Seafood & Fish",
    "en:herrings": "Seafood & Fish",
    "en:mackerels": "Seafood & Fish",
    "en:tunas": "Seafood & Fish",
}

# Broad categories that should yield to more specific ones during resolution.
# Example: a product tagged [en:snacks, en:chips] should resolve to "Chips"
# rather than "Snacks".
BROAD_CATEGORIES: set[str] = {
    "Snacks",
    "Plant-Based & Alternatives",
    "Drinks",  # yields to Alcohol (en:beverages is parent of en:alcoholic-beverages)
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
    "Snacks": [
        "crackers",
        "pretzels",
        "popcorn",
        "rice cakes",
        "granola bar",
        "rice wafers",
        "corn sticks",
        "breadsticks",
        "paluszki",
        "extruded snacks",
    ],
    "Seafood & Fish": [
        "fish",
        "tuna",
        "salmon",
        "sardine",
        "herring",
        "mackerel",
        "cod",
        "trout",
        "pangasius",
        "shrimp",
        "crab sticks",
    ],
    "Baby": [
        "baby food",
        "baby formula",
        "baby snack",
        "bobovita",
        "gerber",
        "hipp baby",
        "baby cereal",
        "baby milk",
    ],
    "Alcohol": [
        "beer",
        "wine",
        "vodka",
        "whisky",
        "piwo",
        "lager",
        "ale",
        "cider",
        "liqueur",
    ],
    "Sauces": [
        "pasta sauce",
        "tomato sauce",
        "pesto",
        "dressing",
        "barbecue sauce",
        "soy sauce",
        "curry sauce",
        "cooking sauce",
        "teriyaki",
    ],
    "Frozen & Prepared": ["frozen pizza", "frozen meals", "pierogi"],
    "Instant & Frozen": ["instant noodles", "cup noodles", "instant soup"],
    "Breakfast & Grain-Based": [
        "granola",
        "pancake",
        "waffle",
        "porridge",
        "oatmeal",
        "crispbread",
        "corn flakes",
        "cereal bar",
        "muesli bar",
    ],
    "Plant-Based & Alternatives": [
        "soy milk",
        "tofu",
        "plant-based",
        "vegan",
        "oat milk",
        "almond milk",
        "coconut milk",
        "veggie burger",
        "tempeh",
        "seitan",
    ],
    "Nuts, Seeds & Legumes": ["peanuts", "almonds", "walnuts", "sunflower seeds"],
}

# Reverse lookup: DB category → list of OFF tags
DB_TO_OFF_TAGS: dict[str, list[str]] = {}
for _tag, _cat in OFF_TO_DB_CATEGORY.items():
    DB_TO_OFF_TAGS.setdefault(_cat, []).append(_tag)


def resolve_category(off_categories_tags: list[str]) -> str | None:
    """Return the best matching database category for a list of OFF tags.

    When multiple tags match, specific categories (e.g. ``"Chips"``) are
    preferred over broad parent categories (e.g. ``"Snacks"``).

    Parameters
    ----------
    off_categories_tags:
        The ``categories_tags`` list from an OFF product record.

    Returns
    -------
    str | None
        The matched database category, or *None* if no mapping exists.
    """
    resolved: list[str] = []
    for tag in off_categories_tags:
        cat = OFF_TO_DB_CATEGORY.get(tag)
        if cat and cat not in resolved:
            resolved.append(cat)

    if not resolved:
        return None

    # OFF lists tags from broadest to most specific, so prefer the
    # *last* non-broad category; this ensures e.g. ketchup → Condiments
    # (not Sauces) and chips → Chips (not Snacks).
    specific = [c for c in resolved if c not in BROAD_CATEGORIES]
    if specific:
        return specific[-1]
    return resolved[-1]
