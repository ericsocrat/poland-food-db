"""Category mapping between Open Food Facts tags and poland-food-db categories."""

from __future__ import annotations

# ---------------------------------------------------------------------------
# Category name constants (avoids duplicated string literals)
# ---------------------------------------------------------------------------
CAT_CHIPS = "Chips"
CAT_DAIRY = "Dairy"
CAT_BREAD = "Bread"
CAT_CEREALS = "Cereals"
CAT_DRINKS = "Drinks"
CAT_MEAT = "Meat"
CAT_SWEETS = "Sweets"
CAT_CANNED = "Canned Goods"
CAT_SAUCES = "Sauces"
CAT_CONDIMENTS = "Condiments"
CAT_SNACKS = "Snacks"
CAT_NUTS = "Nuts, Seeds & Legumes"
CAT_BABY = "Baby"
CAT_ALCOHOL = "Alcohol"
CAT_FROZEN = "Frozen & Prepared"
CAT_BREAKFAST = "Breakfast & Grain-Based"
CAT_INSTANT = "Instant & Frozen"
CAT_PLANT = "Plant-Based & Alternatives"
CAT_SEAFOOD = "Seafood & Fish"

# ---------------------------------------------------------------------------
# OFF category tag  →  our database category
# ---------------------------------------------------------------------------
OFF_TO_DB_CATEGORY: dict[str, str] = {
    # Chips
    "en:chips": CAT_CHIPS,
    "en:crisps": CAT_CHIPS,
    "en:potato-chips": CAT_CHIPS,
    "en:tortilla-chips": CAT_CHIPS,
    "en:corn-chips": CAT_CHIPS,
    # Dairy
    "en:dairy": CAT_DAIRY,
    "en:dairies": CAT_DAIRY,
    "en:milks": CAT_DAIRY,
    "en:yogurts": CAT_DAIRY,
    "en:cheeses": CAT_DAIRY,
    "en:butters": CAT_DAIRY,
    "en:creams": CAT_DAIRY,
    # Bread
    "en:breads": CAT_BREAD,
    # Cereals
    "en:cereals": CAT_CEREALS,
    "en:breakfast-cereals": CAT_CEREALS,
    # Drinks
    "en:beverages": CAT_DRINKS,
    "en:sodas": CAT_DRINKS,
    "en:juices": CAT_DRINKS,
    "en:waters": CAT_DRINKS,
    "en:energy-drinks": CAT_DRINKS,
    "en:non-alcoholic-beverages": CAT_DRINKS,
    # Meat
    "en:meats": CAT_MEAT,
    "en:sausages": CAT_MEAT,
    "en:hams": CAT_MEAT,
    "en:cold-cuts": CAT_MEAT,
    "en:pork": CAT_MEAT,
    "en:poultry": CAT_MEAT,
    # Sweets
    "en:chocolates": CAT_SWEETS,
    "en:candies": CAT_SWEETS,
    "en:biscuits": CAT_SWEETS,
    "en:confectioneries": CAT_SWEETS,
    # Canned Goods
    "en:canned-foods": CAT_CANNED,
    "en:canned-vegetables": CAT_CANNED,
    "en:canned-fruits": CAT_CANNED,
    "en:canned-fish": CAT_CANNED,
    # Sauces (specific subtypes first — broad parent searched last)
    "en:tomato-sauces": CAT_SAUCES,
    "en:pasta-sauces": CAT_SAUCES,
    "en:pestos": CAT_SAUCES,
    "en:salad-dressings": CAT_SAUCES,
    "en:hot-sauces": CAT_SAUCES,
    "en:barbecue-sauces": CAT_SAUCES,
    "en:soy-sauces": CAT_SAUCES,
    "en:curry-sauces": CAT_SAUCES,
    "en:cooking-sauces": CAT_SAUCES,
    "en:sauces": CAT_SAUCES,
    # Condiments (specific subtypes only — en:condiments is too broad on OFF)
    "en:ketchups": CAT_CONDIMENTS,
    "en:ketchup": CAT_CONDIMENTS,
    "en:tomato-ketchup": CAT_CONDIMENTS,
    "en:mustards": CAT_CONDIMENTS,
    "en:mayonnaises": CAT_CONDIMENTS,
    # Snacks (broad — see BROAD_CATEGORIES)
    "en:snacks": CAT_SNACKS,
    "en:salty-snacks": CAT_SNACKS,
    "en:appetizers": CAT_SNACKS,
    "en:crackers": CAT_SNACKS,
    "en:pretzels": CAT_SNACKS,
    "en:popcorn": CAT_SNACKS,
    "en:rice-cakes": CAT_SNACKS,
    "en:corn-snacks": CAT_SNACKS,
    "en:breadsticks": CAT_SNACKS,
    "en:extruded-snacks": CAT_SNACKS,
    "en:puffed-rice-cakes": CAT_SNACKS,
    # Nuts, Seeds & Legumes
    "en:nuts": CAT_NUTS,
    "en:seeds": CAT_NUTS,
    "en:legumes": CAT_NUTS,
    "en:dried-fruits": CAT_NUTS,
    # Baby
    "en:baby-foods": CAT_BABY,
    "en:baby-milks": CAT_BABY,
    "en:infant-formulas": CAT_BABY,
    "en:baby-cereals": CAT_BABY,
    "en:baby-meals": CAT_BABY,
    # Alcohol
    "en:alcoholic-beverages": CAT_ALCOHOL,
    "en:beers": CAT_ALCOHOL,
    "en:wines": CAT_ALCOHOL,
    "en:spirits": CAT_ALCOHOL,
    "en:ciders": CAT_ALCOHOL,
    "en:liqueurs": CAT_ALCOHOL,
    "en:meads": CAT_ALCOHOL,
    # Frozen & Prepared
    "en:frozen-foods": CAT_FROZEN,
    "en:frozen-pizzas": CAT_FROZEN,
    # Breakfast & Grain-Based
    "en:granolas": CAT_BREAKFAST,
    "en:crispbreads": CAT_BREAKFAST,
    "en:pancakes": CAT_BREAKFAST,
    "en:flat-breads": CAT_BREAKFAST,
    # Instant & Frozen
    "en:instant-noodles": CAT_INSTANT,
    "en:instant-soups": CAT_INSTANT,
    # Plant-Based & Alternatives (broad — see BROAD_CATEGORIES)
    "en:plant-based-foods": CAT_PLANT,
    "en:plant-based-foods-and-beverages": CAT_PLANT,
    "en:meat-alternatives": CAT_PLANT,
    "en:tofu": CAT_PLANT,
    "en:soy-milks": CAT_PLANT,
    "en:oat-milks": CAT_PLANT,
    "en:almond-milks": CAT_PLANT,
    "en:rice-milks": CAT_PLANT,
    "en:plant-based-milk-alternatives": CAT_PLANT,
    # Seafood & Fish
    "en:seafood": CAT_SEAFOOD,
    "en:fish": CAT_SEAFOOD,
    "en:smoked-fish": CAT_SEAFOOD,
    "en:smoked-salmon": CAT_SEAFOOD,
    "en:sardines": CAT_SEAFOOD,
    "en:herrings": CAT_SEAFOOD,
    "en:mackerels": CAT_SEAFOOD,
    "en:tunas": CAT_SEAFOOD,
}

# Broad categories that should yield to more specific ones during resolution.
# Example: a product tagged [en:snacks, en:chips] should resolve to "Chips"
# rather than "Snacks".
BROAD_CATEGORIES: set[str] = {
    CAT_SNACKS,
    CAT_PLANT,
    CAT_DRINKS,  # yields to Alcohol (en:beverages is parent of en:alcoholic-beverages)
}

# ---------------------------------------------------------------------------
# Search terms used when querying the OFF API for each database category
# ---------------------------------------------------------------------------
CATEGORY_SEARCH_TERMS: dict[str, list[str]] = {
    CAT_CHIPS: ["chips", "crisps", "potato chips"],
    CAT_DAIRY: ["milk", "yogurt", "cheese", "kefir", "butter", "cream"],
    CAT_BREAD: ["bread", "rolls", "baguette", "toast"],
    CAT_CEREALS: ["cereals", "muesli", "cornflakes", "oatmeal"],
    CAT_DRINKS: ["cola", "juice", "soda", "energy drink", "water"],
    CAT_MEAT: ["sausage", "ham", "bacon", "kabanos", "pate"],
    CAT_SWEETS: ["chocolate", "candy", "wafer", "biscuit", "praline"],
    CAT_CANNED: ["canned", "preserves", "konserwa"],
    CAT_CONDIMENTS: ["ketchup", "mustard", "mayonnaise", "vinegar", "sauce"],
    CAT_SNACKS: [
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
    CAT_SEAFOOD: [
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
    CAT_BABY: [
        "baby food",
        "baby formula",
        "baby snack",
        "bobovita",
        "gerber",
        "hipp baby",
        "baby cereal",
        "baby milk",
    ],
    CAT_ALCOHOL: [
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
    CAT_SAUCES: [
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
    CAT_FROZEN: ["frozen pizza", "frozen meals", "pierogi"],
    CAT_INSTANT: ["instant noodles", "cup noodles", "instant soup"],
    CAT_BREAKFAST: [
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
    CAT_PLANT: [
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
    CAT_NUTS: ["peanuts", "almonds", "walnuts", "sunflower seeds"],
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
