"""Cross-validation layer for Open Food Facts product data.

Validates fetched products against category reference ranges derived from
Polish government nutritional data (IŻŻ / NCEZ) and performs EAN-13
checksum verification.
"""

from __future__ import annotations


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
# EAN-13 checksum
# ---------------------------------------------------------------------------


def validate_ean_checksum(ean: str) -> bool:
    """Validate an EAN-13 barcode using the Modulo-10 algorithm.

    Parameters
    ----------
    ean:
        The barcode string (should be 13 digits for EAN-13).

    Returns
    -------
    bool
        *True* if the checksum is valid, *False* otherwise.
    """
    if not ean or not ean.isdigit() or len(ean) != 13:
        return False

    digits = [int(d) for d in ean]
    total = sum(d * (1 if i % 2 == 0 else 3) for i, d in enumerate(digits[:12]))
    check = (10 - (total % 10)) % 10
    return check == digits[12]


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
    return warnings


# ---------------------------------------------------------------------------
# Main validation entry point
# ---------------------------------------------------------------------------


def validate_product(product: dict, category: str) -> dict:
    """Validate a normalised product and annotate it with confidence + warnings.

    The returned dict is a **copy** of *product* with two extra keys:

    * ``validation_warnings`` — list of warning strings
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

    # Nutrition range check
    range_warnings = check_nutrition_ranges(product, category)
    warnings.extend(range_warnings)

    result["validation_warnings"] = warnings

    # Confidence assignment
    try:
        completeness = float(product.get("_completeness", 0))
    except (ValueError, TypeError):
        completeness = 0.0
    has_image = product.get("_has_image", False)

    if len(warnings) >= 2:
        confidence = "estimated"
    elif completeness >= 0.5 and ean_valid:
        confidence = "verified"
    elif completeness < 0.5 or not has_image:
        confidence = "estimated"
    else:
        confidence = "verified"

    result["confidence"] = confidence
    return result
