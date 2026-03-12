"""Category mapping between Open Food Facts tags and tryvit categories."""

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
CAT_OILS = "Oils & Vinegars"
CAT_SPREADS = "Spreads & Dips"
CAT_PASTA_RICE = "Pasta & Rice"
CAT_SOUPS = "Soups"
CAT_COFFEE_TEA = "Coffee & Tea"
CAT_FROZEN_VEG = "Frozen Vegetables"
CAT_READY_MEALS = "Ready Meals"
CAT_DESSERTS = "Desserts & Ice Cream"
CAT_SPICES = "Spices & Seasonings"

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
    "en:chili-sauces": CAT_SAUCES,
    "en:tartar-sauces": CAT_SAUCES,
    "en:worcestershire-sauces": CAT_SAUCES,
    "en:garlic-sauces": CAT_SAUCES,
    "en:salsas": CAT_SAUCES,
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
    "en:cereal-bars": CAT_SNACKS,
    "en:energy-bars": CAT_SNACKS,
    "en:fruit-bars": CAT_SNACKS,
    "en:protein-bars": CAT_SNACKS,
    "en:snacks-for-children": CAT_SNACKS,
    "en:dried-products": CAT_SNACKS,
    "en:trail-mixes": CAT_SNACKS,
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
    "en:baby-desserts": CAT_BABY,
    "en:baby-snacks": CAT_BABY,
    "en:baby-juices": CAT_BABY,
    "en:toddler-foods": CAT_BABY,
    "en:growing-up-milks": CAT_BABY,
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
    "en:mueslis": CAT_BREAKFAST,
    "en:oat-flakes": CAT_BREAKFAST,
    "en:porridges": CAT_BREAKFAST,
    "en:breakfast-biscuits": CAT_BREAKFAST,
    "en:jams": CAT_BREAKFAST,
    "en:honeys": CAT_BREAKFAST,
    "en:spreads": CAT_BREAKFAST,
    "en:chocolate-spreads": CAT_BREAKFAST,
    "en:peanut-butters": CAT_BREAKFAST,
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
    "en:soy-yogurts": CAT_PLANT,
    "en:veggie-burgers": CAT_PLANT,
    "en:hummus": CAT_PLANT,
    "en:falafel": CAT_PLANT,
    "en:tempeh": CAT_PLANT,
    "en:seitan": CAT_PLANT,
    "en:coconut-milks": CAT_PLANT,
    # Seafood & Fish
    "en:seafood": CAT_SEAFOOD,
    "en:fish": CAT_SEAFOOD,
    "en:smoked-fish": CAT_SEAFOOD,
    "en:smoked-salmon": CAT_SEAFOOD,
    "en:sardines": CAT_SEAFOOD,
    "en:herrings": CAT_SEAFOOD,
    "en:mackerels": CAT_SEAFOOD,
    "en:tunas": CAT_SEAFOOD,
    # Oils & Vinegars
    "en:olive-oils": CAT_OILS,
    "en:sunflower-oils": CAT_OILS,
    "en:rapeseed-oils": CAT_OILS,
    "en:colza-oils": CAT_OILS,
    "en:vinegars": CAT_OILS,
    "en:balsamic-vinegars": CAT_OILS,
    "en:vegetable-oils": CAT_OILS,
    "en:cooking-oils": CAT_OILS,
    "en:seed-oils": CAT_OILS,
    # Spreads & Dips
    "en:dips": CAT_SPREADS,
    "en:pates": CAT_SPREADS,
    "en:tapenades": CAT_SPREADS,
    "en:guacamole": CAT_SPREADS,
    "en:tzatzikis": CAT_SPREADS,
    # Pasta & Rice
    "en:pastas": CAT_PASTA_RICE,
    "en:pasta": CAT_PASTA_RICE,
    "en:rice": CAT_PASTA_RICE,
    "en:noodles": CAT_PASTA_RICE,
    "en:couscous": CAT_PASTA_RICE,
    "en:egg-noodles": CAT_PASTA_RICE,
    "en:rice-noodles": CAT_PASTA_RICE,
    "en:spaghetti": CAT_PASTA_RICE,
    "en:penne": CAT_PASTA_RICE,
    "en:fusilli": CAT_PASTA_RICE,
    "en:macaroni": CAT_PASTA_RICE,
    "en:bulgur": CAT_PASTA_RICE,
    "en:quinoa": CAT_PASTA_RICE,
    # Soups
    "en:soups": CAT_SOUPS,
    "en:bouillons": CAT_SOUPS,
    "en:broths": CAT_SOUPS,
    "en:cream-soups": CAT_SOUPS,
    "en:vegetable-soups": CAT_SOUPS,
    "en:soup-mixes": CAT_SOUPS,
    # Coffee & Tea
    "en:coffees": CAT_COFFEE_TEA,
    "en:instant-coffees": CAT_COFFEE_TEA,
    "en:ground-coffees": CAT_COFFEE_TEA,
    "en:coffee-beans": CAT_COFFEE_TEA,
    "en:teas": CAT_COFFEE_TEA,
    "en:green-teas": CAT_COFFEE_TEA,
    "en:herbal-teas": CAT_COFFEE_TEA,
    "en:black-teas": CAT_COFFEE_TEA,
    "en:rooibos": CAT_COFFEE_TEA,
    "en:mate": CAT_COFFEE_TEA,
    "en:coffee-capsules": CAT_COFFEE_TEA,
    "en:coffee-pads": CAT_COFFEE_TEA,
    # Frozen Vegetables
    "en:frozen-vegetables": CAT_FROZEN_VEG,
    "en:frozen-fruits": CAT_FROZEN_VEG,
    "en:frozen-berries": CAT_FROZEN_VEG,
    "en:frozen-mixed-vegetables": CAT_FROZEN_VEG,
    "en:frozen-spinach": CAT_FROZEN_VEG,
    "en:frozen-peas": CAT_FROZEN_VEG,
    "en:frozen-broccoli": CAT_FROZEN_VEG,
    "en:frozen-corn": CAT_FROZEN_VEG,
    # Ready Meals
    "en:meals": CAT_READY_MEALS,
    "en:prepared-meals": CAT_READY_MEALS,
    "en:meal-kits": CAT_READY_MEALS,
    "en:microwaveable-meals": CAT_READY_MEALS,
    "en:ready-meals": CAT_READY_MEALS,
    "en:tv-dinners": CAT_READY_MEALS,
    "en:bento": CAT_READY_MEALS,
    "en:lunch-boxes": CAT_READY_MEALS,
    # Desserts & Ice Cream
    "en:desserts": CAT_DESSERTS,
    "en:ice-creams": CAT_DESSERTS,
    "en:puddings": CAT_DESSERTS,
    "en:gelato": CAT_DESSERTS,
    "en:sorbets": CAT_DESSERTS,
    "en:frozen-desserts": CAT_DESSERTS,
    "en:panna-cotta": CAT_DESSERTS,
    "en:mousse": CAT_DESSERTS,
    "en:tiramisu": CAT_DESSERTS,
    "en:creme-brulee": CAT_DESSERTS,
    "en:ice-cream-bars": CAT_DESSERTS,
    "en:ice-cream-cones": CAT_DESSERTS,
    # Spices & Seasonings
    "en:spices": CAT_SPICES,
    "en:seasonings": CAT_SPICES,
    "en:herbs": CAT_SPICES,
    "en:dried-herbs": CAT_SPICES,
    "en:pepper": CAT_SPICES,
    "en:salt": CAT_SPICES,
    "en:curry-powders": CAT_SPICES,
    "en:paprika": CAT_SPICES,
    "en:cinnamon": CAT_SPICES,
    "en:seasoning-mixes": CAT_SPICES,
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
        "cereal bar",
        "protein bar",
        "energy bar",
        "fruit bar",
        "trail mix",
        "snack bar",
        "baton",
        "chrupki",
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
        "śledź",
        "łosoś",
        "dorsz",
        "tuńczyk",
        "mintaj",
        "surimi",
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
        "aptamil",
        "bebilon",
        "nan optipro",
        "infant",
        "toddler",
        "nutrilon",
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
        "rum",
        "gin",
        "tequila",
        "mead",
        "miód pitny",
        "wino",
        "craft beer",
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
        "worcestershire",
        "tartar sauce",
        "garlic sauce",
        "chili sauce",
        "sos",
        "salsa",
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
        "muesli",
        "jam",
        "honey",
        "peanut butter",
        "chocolate spread",
        "nutella",
        "płatki owsiane",
        "kasza",
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
        "soy yogurt",
        "vegan cheese",
        "plant milk",
        "hummus",
        "falafel",
        "vegan sausage",
    ],
    CAT_NUTS: ["peanuts", "almonds", "walnuts", "sunflower seeds"],
    CAT_OILS: [
        "olive oil",
        "sunflower oil",
        "rapeseed oil",
        "canola oil",
        "coconut oil",
        "vegetable oil",
        "cooking oil",
        "vinegar",
        "balsamic vinegar",
        "apple cider vinegar",
        "wine vinegar",
        "spray oil",
        "olej",
        "ocet",
    ],
    CAT_SPREADS: [
        "hummus",
        "guacamole",
        "pate",
        "tapenade",
        "dip",
        "tzatziki",
        "cream cheese spread",
        "bean dip",
        "salsa dip",
        "cheese spread",
        "pasztet",
    ],
    CAT_PASTA_RICE: [
        "pasta",
        "rice",
        "noodles",
        "makaron",
        "ryż",
        "kasza",
    ],
    CAT_SOUPS: [
        "soup",
        "broth",
        "bouillon",
        "zupa",
        "bulion",
        "rosół",
    ],
    CAT_COFFEE_TEA: [
        "coffee",
        "tea",
        "kawa",
        "herbata",
        "Kaffee",
        "Tee",
    ],
    CAT_FROZEN_VEG: [
        "frozen vegetables",
        "mrożone warzywa",
        "frozen fruits",
    ],
    CAT_READY_MEALS: [
        "ready meal",
        "danie gotowe",
        "meal kit",
    ],
    CAT_DESSERTS: [
        "dessert",
        "ice cream",
        "lody",
        "deser",
    ],
    CAT_SPICES: [
        "spice",
        "seasoning",
        "przyprawa",
        "zioła",
    ],
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
