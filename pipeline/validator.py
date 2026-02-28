"""Cross-validation layer for Open Food Facts product data.

Validates fetched products against category reference ranges derived from
Polish government nutritional data (IŻŻ / NCEZ), performs EAN-13
checksum verification, detects attribute contradictions between
ingredient-derived flags and declared allergens, and flags nutrition
values that violate absolute physical caps or per-category plausibility
ranges.
"""

from __future__ import annotations

# ---------------------------------------------------------------------------
# Allergen tag sets used for contradiction detection
# ---------------------------------------------------------------------------

#: Allergens that indicate animal-derived ingredients — contradicts vegan
ANIMAL_ALLERGEN_TAGS: frozenset[str] = frozenset(
    {
        "en:milk",
        "en:eggs",
        "en:fish",
        "en:crustaceans",
        "en:molluscs",
    }
)

#: Allergens that indicate meat / fish / seafood — contradicts vegetarian
MEAT_FISH_ALLERGEN_TAGS: frozenset[str] = frozenset(
    {
        "en:fish",
        "en:crustaceans",
        "en:molluscs",
    }
)


# ---------------------------------------------------------------------------
# Category reference ranges (per 100 g) — plausible, not strict limits
# ---------------------------------------------------------------------------
CATEGORY_RANGES: dict[str, dict[str, tuple[float, float]]] = {
    "Chips": {"calories": (400, 600), "total_fat_g": (20, 40), "salt_g": (0.5, 3.0)},
    "Dairy": {"calories": (30, 400), "total_fat_g": (0, 35), "protein_g": (2, 30)},
    "Bread": {"calories": (180, 320), "total_fat_g": (0.5, 10), "fibre_g": (1, 15)},
    "Drinks": {"calories": (0, 80), "total_fat_g": (0, 5), "sugars_g": (0, 15)},
    "Cereals": {"calories": (300, 450), "total_fat_g": (1, 20), "sugars_g": (0, 40)},
    "Sweets": {"calories": (300, 600), "total_fat_g": (5, 40), "sugars_g": (20, 80)},
    "Meat": {"calories": (100, 400), "total_fat_g": (3, 35), "protein_g": (10, 30)},
    "Canned Goods": {"calories": (15, 300), "total_fat_g": (0, 25), "salt_g": (0, 3)},
    "Condiments": {"calories": (10, 700), "total_fat_g": (0, 80), "salt_g": (0.5, 10)},
    "Snacks": {"calories": (300, 600), "total_fat_g": (5, 40), "salt_g": (0.3, 3.0)},
    "Seafood & Fish": {
        "calories": (50, 300),
        "total_fat_g": (0.5, 25),
        "protein_g": (10, 30),
    },
    "Baby": {"calories": (30, 200), "total_fat_g": (0, 10), "salt_g": (0, 0.5)},
    "Alcohol": {"calories": (20, 300), "total_fat_g": (0, 5), "sugars_g": (0, 30)},
    "Sauces": {"calories": (20, 400), "total_fat_g": (0, 40), "salt_g": (0.5, 8)},
    "Frozen & Prepared": {
        "calories": (80, 350),
        "total_fat_g": (2, 20),
        "salt_g": (0.3, 3),
    },
    "Instant & Frozen": {
        "calories": (50, 400),
        "total_fat_g": (1, 25),
        "salt_g": (0.5, 5),
    },
    "Breakfast & Grain-Based": {
        "calories": (200, 450),
        "total_fat_g": (1, 20),
        "sugars_g": (0, 35),
    },
    "Plant-Based & Alternatives": {
        "calories": (30, 350),
        "total_fat_g": (0, 25),
        "protein_g": (2, 25),
    },
    "Nuts, Seeds & Legumes": {
        "calories": (200, 650),
        "total_fat_g": (5, 55),
        "protein_g": (5, 30),
    },
}


# ---------------------------------------------------------------------------
# Absolute nutrition caps (per 100 g) — no food can exceed these
# ---------------------------------------------------------------------------

#: Hard upper limits based on physical constraints.  A value above any of
#: these is certainly wrong data (e.g. vandalism on Open Food Facts).
ABSOLUTE_CAPS: dict[str, float] = {
    "calories": 900,           # Pure fat ≈ 900 kcal
    "total_fat_g": 100,        # Can't exceed 100 g per 100 g
    "saturated_fat_g": 100,
    "carbs_g": 100,
    "sugars_g": 100,
    "protein_g": 100,
    "fibre_g": 100,
    "salt_g": 50,              # Pure salt is extreme
    "trans_fat_g": 100,
}


# ---------------------------------------------------------------------------
# EAN checksum (EAN-8 / EAN-13)
# ---------------------------------------------------------------------------


def validate_ean_checksum(ean: str | None) -> bool:
    """Validate an EAN-8 or EAN-13 barcode using the Modulo-10 algorithm.

    Parameters
    ----------
    ean:
        The barcode string (should be 8 or 13 digits), or *None*.

    Returns
    -------
    bool
        *True* if the checksum is valid, *False* otherwise.
    """
    if not ean or not ean.isdigit() or len(ean) not in (8, 13):
        return False

    digits = [int(d) for d in ean]
    payload = digits[:-1]
    total = sum(d * (3 if i % 2 == 0 else 1) for i, d in enumerate(reversed(payload)))
    check = (10 - (total % 10)) % 10
    return check == digits[-1]


# ---------------------------------------------------------------------------
# Nutrition anomaly detection (absolute caps + category ranges)
# ---------------------------------------------------------------------------


def check_nutrition_anomalies(
    product: dict,
    category: str,
) -> tuple[list[str], list[str]]:
    """Validate nutrition values against absolute caps and category ranges.

    Absolute cap violations are **errors** (block import).  Category
    range violations are **warnings** (log but allow import).

    Parameters
    ----------
    product:
        A normalised product dict (nutrition values as strings).
    category:
        The database category name.

    Returns
    -------
    tuple[list[str], list[str]]
        ``(errors, warnings)`` — errors block import, warnings are logged.
    """
    errors: list[str] = []
    warnings: list[str] = []
    name = product.get("product_name", "unknown")

    # 1. Absolute caps — hard block
    for field, cap in ABSOLUTE_CAPS.items():
        raw = product.get(field)
        if raw is None:
            continue
        try:
            val = float(raw)
        except (ValueError, TypeError):
            continue
        if val > cap:
            errors.append(
                f"BLOCKED: {field}={val} exceeds absolute cap of {cap} "
                f"for '{name}'"
            )

    # 2. Category-specific ranges — soft warning
    cat_ranges = CATEGORY_RANGES.get(category, {})
    for field, (lo, hi) in cat_ranges.items():
        raw = product.get(field)
        if raw is None:
            continue
        try:
            val = float(raw)
        except (ValueError, TypeError):
            continue
        # Flag if value is more than 50% below low or 50% above high
        if val < lo * 0.5 or val > hi * 1.5:
            warnings.append(
                f"ANOMALY: {field}={val} outside expected range "
                f"({lo}–{hi}) for category '{category}', "
                f"product '{name}'"
            )

    return errors, warnings


# ---------------------------------------------------------------------------
# Nutrition range checks
# ---------------------------------------------------------------------------


def check_nutrition_ranges(product: dict, category: str) -> list[str]:
    """Check each nutrition field against expected ranges for *category*.

    Parameters
    ----------
    product:
        A normalised product dict (values are strings).
    category:
        The database category name.

    Returns
    -------
    list[str]
        Human-readable warning messages for values outside range.
    """
    ranges = CATEGORY_RANGES.get(category)
    if not ranges:
        return []

    warnings: list[str] = []
    for field, (lo, hi) in ranges.items():
        raw = product.get(field)
        if raw is None:
            continue
        try:
            val = float(raw)
        except (ValueError, TypeError):
            continue
        if val < lo or val > hi:
            warnings.append(
                f"{field}={val} outside expected range [{lo}–{hi}] for {category}"
            )

    # Calorie back-calculation: protein×4 + carbs×4 + fat×9 should be
    # within 35% of stated calories (excludes alcohol calories, fibre, etc.)
    if category not in ("Alcohol", "Drinks", "Condiments", "Sauces"):
        try:
            cal = float(product.get("calories") or 0)
            fat = float(product.get("total_fat_g") or 0)
            carb = float(product.get("carbs_g") or 0)
            prot = float(product.get("protein_g") or 0)
            calc = prot * 4 + carb * 4 + fat * 9
            if cal > 50 and abs(cal - calc) > cal * 0.35:
                warnings.append(
                    f"calorie back-calculation mismatch: stated={cal}, "
                    f"calculated={calc:.0f} (>{35}% deviation)"
                )
        except (ValueError, TypeError):
            pass

    return warnings


# ---------------------------------------------------------------------------
# Attribute contradiction checks
# ---------------------------------------------------------------------------


def check_attribute_contradictions(product: dict) -> list[str]:
    """Detect contradictions between ingredient-derived attributes and allergens.

    Checks for logical inconsistencies such as a product claiming to be
    vegan while declaring animal-derived allergens (milk, eggs, etc.).

    Parameters
    ----------
    product:
        A normalised product dict.  Expected keys:

        * ``allergen_tags`` — comma-separated allergen tag string
          (e.g. ``"en:milk, en:eggs"``) or list of tag strings.
        * ``vegan_status`` — ``'yes'``, ``'no'``, ``'maybe'``, or *None*.
        * ``vegetarian_status`` — same values.

    Returns
    -------
    list[str]
        Human-readable warning messages for each detected contradiction.
    """
    warnings: list[str] = []

    # Parse allergen tags into a set
    raw_tags = product.get("allergen_tags", "")
    if isinstance(raw_tags, list):
        allergen_set = {t.strip() for t in raw_tags if t}
    elif isinstance(raw_tags, str) and raw_tags.strip():
        allergen_set = {t.strip() for t in raw_tags.split(",")}
    else:
        allergen_set = set()

    vegan = product.get("vegan_status")
    vegetarian = product.get("vegetarian_status")

    # 1. Vegan + animal allergens
    animal_hits = allergen_set & ANIMAL_ALLERGEN_TAGS
    if vegan == "yes" and animal_hits:
        warnings.append(
            f"vegan_status is 'yes' but product declares animal allergens: "
            f"{', '.join(sorted(animal_hits))}"
        )

    # 2. Vegetarian + meat/fish allergens
    meat_hits = allergen_set & MEAT_FISH_ALLERGEN_TAGS
    if vegetarian == "yes" and meat_hits:
        warnings.append(
            f"vegetarian_status is 'yes' but product declares meat/fish allergens: "
            f"{', '.join(sorted(meat_hits))}"
        )

    # 3. Logical impossibility: vegan but not vegetarian
    if vegan == "yes" and vegetarian == "no":
        warnings.append(
            "vegan_status is 'yes' but vegetarian_status is 'no' — "
            "all vegan products must also be vegetarian"
        )

    return warnings


# ---------------------------------------------------------------------------
# Main validation entry point
# ---------------------------------------------------------------------------


def validate_product(product: dict, category: str) -> dict:
    """Validate a normalised product and annotate it with confidence + warnings.

    The returned dict is a **copy** of *product* with these extra keys:

    * ``validation_warnings`` — list of warning strings
    * ``anomaly_errors`` — list of blocking error strings (absolute cap violations)
    * ``anomaly_warnings`` — list of anomaly warning strings (category range)
    * ``confidence`` — ``'verified'`` or ``'estimated'``

    Parameters
    ----------
    product:
        A normalised product dict from ``off_client.extract_product_data``.
    category:
        The database category name.

    Returns
    -------
    dict
        Annotated product dict.
    """
    result = dict(product)
    warnings: list[str] = []

    # EAN check
    ean = product.get("ean", "")
    ean_valid = validate_ean_checksum(ean)
    if ean and not ean_valid:
        warnings.append(f"EAN {ean} fails checksum validation")

    # Nutrition anomaly detection (absolute caps + category ranges)
    anomaly_errors, anomaly_warnings = check_nutrition_anomalies(product, category)
    result["anomaly_errors"] = anomaly_errors
    result["anomaly_warnings"] = anomaly_warnings
    warnings.extend(anomaly_warnings)

    # Nutrition range check (existing soft range checks)
    range_warnings = check_nutrition_ranges(product, category)
    warnings.extend(range_warnings)

    # Attribute contradiction check
    contradiction_warnings = check_attribute_contradictions(product)
    warnings.extend(contradiction_warnings)

    # Image URL validation
    for img_key in ("image_front_url", "image_ingredients_url", "image_nutrition_url"):
        url = product.get(img_key)
        if url and not url.startswith("https://"):
            warnings.append(f"{img_key} is not HTTPS: {url[:80]}")

    result["validation_warnings"] = warnings

    # Confidence assignment
    try:
        completeness = float(product.get("_completeness", 0))
    except (ValueError, TypeError):
        completeness = 0.0
    has_image = product.get("_has_image", False)

    if anomaly_errors:
        confidence = "estimated"
    elif len(warnings) >= 2:
        confidence = "estimated"
    elif completeness >= 0.5 and ean_valid:
        confidence = "verified"
    elif completeness < 0.5 or not has_image:
        confidence = "estimated"
    else:
        confidence = "verified"

    result["confidence"] = confidence
    return result
