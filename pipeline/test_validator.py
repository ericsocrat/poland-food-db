"""Tests for pipeline.validator — comprehensive coverage for all validation functions.

Covers: EAN checksum, nutrition ranges, attribute contradiction detection,
and the main validate_product entry point.
"""

from __future__ import annotations

import pytest

from pipeline.validator import (
    ANIMAL_ALLERGEN_TAGS,
    MEAT_FISH_ALLERGEN_TAGS,
    check_attribute_contradictions,
    check_nutrition_ranges,
    validate_ean_checksum,
    validate_product,
)


# ═══════════════════════════════════════════════════════════════════════════
# EAN checksum
# ═══════════════════════════════════════════════════════════════════════════


class TestValidateEanChecksum:
    """Tests for validate_ean_checksum()."""

    def test_valid_ean13(self) -> None:
        assert validate_ean_checksum("5901234123457") is True

    def test_invalid_ean13_wrong_check_digit(self) -> None:
        assert validate_ean_checksum("5901234123450") is False

    def test_valid_ean8(self) -> None:
        assert validate_ean_checksum("96385074") is True

    def test_invalid_ean8(self) -> None:
        assert validate_ean_checksum("96385079") is False

    def test_empty_string(self) -> None:
        assert validate_ean_checksum("") is False

    def test_non_digit(self) -> None:
        assert validate_ean_checksum("590123412345A") is False

    def test_wrong_length(self) -> None:
        assert validate_ean_checksum("12345") is False

    def test_none_value(self) -> None:
        assert validate_ean_checksum(None) is False


# ═══════════════════════════════════════════════════════════════════════════
# Nutrition ranges
# ═══════════════════════════════════════════════════════════════════════════


class TestCheckNutritionRanges:
    """Tests for check_nutrition_ranges()."""

    def test_within_range(self) -> None:
        product = {"calories": "500", "total_fat_g": "30", "salt_g": "1.5"}
        assert check_nutrition_ranges(product, "Chips") == []

    def test_above_range(self) -> None:
        product = {"calories": "700"}
        warnings = check_nutrition_ranges(product, "Chips")
        assert len(warnings) == 1
        assert "calories=700.0" in warnings[0]

    def test_below_range(self) -> None:
        product = {"calories": "10"}
        warnings = check_nutrition_ranges(product, "Chips")
        assert len(warnings) == 1
        assert "outside expected range" in warnings[0]

    def test_unknown_category(self) -> None:
        product = {"calories": "999"}
        assert check_nutrition_ranges(product, "UnknownCategory") == []

    def test_missing_field(self) -> None:
        product = {"something_else": "42"}
        assert check_nutrition_ranges(product, "Chips") == []

    def test_non_numeric_value(self) -> None:
        product = {"calories": "N/A"}
        assert check_nutrition_ranges(product, "Chips") == []

    def test_none_value(self) -> None:
        product = {"calories": None}
        assert check_nutrition_ranges(product, "Chips") == []


# ═══════════════════════════════════════════════════════════════════════════
# Attribute contradictions
# ═══════════════════════════════════════════════════════════════════════════


class TestCheckAttributeContradictions:
    """Tests for check_attribute_contradictions()."""

    def test_no_contradiction_vegan_no_allergens(self) -> None:
        product = {"vegan_status": "yes", "vegetarian_status": "yes", "allergen_tags": ""}
        assert check_attribute_contradictions(product) == []

    def test_vegan_with_milk_allergen(self) -> None:
        product = {
            "vegan_status": "yes",
            "vegetarian_status": "yes",
            "allergen_tags": "en:milk",
        }
        warnings = check_attribute_contradictions(product)
        assert len(warnings) == 1
        assert "vegan_status" in warnings[0]
        assert "en:milk" in warnings[0]

    def test_vegan_with_multiple_animal_allergens(self) -> None:
        product = {
            "vegan_status": "yes",
            "vegetarian_status": "yes",
            "allergen_tags": "en:milk, en:eggs, en:gluten",
        }
        warnings = check_attribute_contradictions(product)
        # Should have exactly one vegan contradiction warning
        vegan_warns = [w for w in warnings if "vegan_status" in w]
        assert len(vegan_warns) == 1
        assert "en:eggs" in vegan_warns[0]
        assert "en:milk" in vegan_warns[0]

    def test_vegetarian_with_fish_allergen(self) -> None:
        product = {
            "vegan_status": "no",
            "vegetarian_status": "yes",
            "allergen_tags": "en:fish",
        }
        warnings = check_attribute_contradictions(product)
        assert len(warnings) == 1
        assert "vegetarian_status" in warnings[0]
        assert "en:fish" in warnings[0]

    def test_vegetarian_with_crustaceans(self) -> None:
        product = {
            "vegan_status": "no",
            "vegetarian_status": "yes",
            "allergen_tags": "en:crustaceans",
        }
        warnings = check_attribute_contradictions(product)
        assert any("en:crustaceans" in w for w in warnings)

    def test_vegan_and_vegetarian_contradiction_with_fish(self) -> None:
        """Fish is both animal (vegan) and meat/fish (vegetarian)."""
        product = {
            "vegan_status": "yes",
            "vegetarian_status": "yes",
            "allergen_tags": "en:fish",
        }
        warnings = check_attribute_contradictions(product)
        # Both vegan and vegetarian should have warnings
        assert any("vegan_status" in w for w in warnings)
        assert any("vegetarian_status" in w for w in warnings)

    def test_no_contradiction_when_not_vegan(self) -> None:
        product = {
            "vegan_status": "no",
            "vegetarian_status": "no",
            "allergen_tags": "en:milk, en:eggs",
        }
        assert check_attribute_contradictions(product) == []

    def test_no_contradiction_when_maybe(self) -> None:
        product = {
            "vegan_status": "maybe",
            "vegetarian_status": "maybe",
            "allergen_tags": "en:milk",
        }
        assert check_attribute_contradictions(product) == []

    def test_logical_impossibility_vegan_not_vegetarian(self) -> None:
        product = {
            "vegan_status": "yes",
            "vegetarian_status": "no",
            "allergen_tags": "",
        }
        warnings = check_attribute_contradictions(product)
        assert len(warnings) == 1
        assert "all vegan products must also be vegetarian" in warnings[0]

    def test_allergen_tags_as_list(self) -> None:
        product = {
            "vegan_status": "yes",
            "vegetarian_status": "yes",
            "allergen_tags": ["en:milk", "en:gluten"],
        }
        warnings = check_attribute_contradictions(product)
        assert any("en:milk" in w for w in warnings)

    def test_empty_product(self) -> None:
        assert check_attribute_contradictions({}) == []

    def test_none_statuses(self) -> None:
        product = {
            "vegan_status": None,
            "vegetarian_status": None,
            "allergen_tags": "en:milk",
        }
        assert check_attribute_contradictions(product) == []

    def test_non_animal_allergens_no_contradiction(self) -> None:
        """Gluten is an allergen but not animal-derived."""
        product = {
            "vegan_status": "yes",
            "vegetarian_status": "yes",
            "allergen_tags": "en:gluten, en:soybeans, en:celery",
        }
        assert check_attribute_contradictions(product) == []

    def test_allergen_tags_with_extra_whitespace(self) -> None:
        product = {
            "vegan_status": "yes",
            "vegetarian_status": "yes",
            "allergen_tags": "  en:milk , en:gluten  ",
        }
        warnings = check_attribute_contradictions(product)
        assert any("en:milk" in w for w in warnings)


# ═══════════════════════════════════════════════════════════════════════════
# Tag constants
# ═══════════════════════════════════════════════════════════════════════════


class TestAllergenTagConstants:
    """Verify the allergen tag sets are correct."""

    def test_animal_tags_are_superset_of_meat_fish(self) -> None:
        assert MEAT_FISH_ALLERGEN_TAGS <= ANIMAL_ALLERGEN_TAGS

    def test_animal_tags_contain_expected(self) -> None:
        for tag in ("en:milk", "en:eggs", "en:fish", "en:crustaceans", "en:molluscs"):
            assert tag in ANIMAL_ALLERGEN_TAGS

    def test_meat_fish_tags_contain_expected(self) -> None:
        for tag in ("en:fish", "en:crustaceans", "en:molluscs"):
            assert tag in MEAT_FISH_ALLERGEN_TAGS

    def test_meat_fish_does_not_include_dairy_eggs(self) -> None:
        assert "en:milk" not in MEAT_FISH_ALLERGEN_TAGS
        assert "en:eggs" not in MEAT_FISH_ALLERGEN_TAGS


# ═══════════════════════════════════════════════════════════════════════════
# Main validate_product entry point
# ═══════════════════════════════════════════════════════════════════════════


class TestValidateProduct:
    """Tests for validate_product() — integration of all checks."""

    def test_clean_product(self) -> None:
        product = {
            "ean": "5901234123457",
            "calories": "500",
            "total_fat_g": "30",
            "salt_g": "1.5",
            "_completeness": "0.8",
            "_has_image": True,
            "vegan_status": "yes",
            "vegetarian_status": "yes",
            "allergen_tags": "",
        }
        result = validate_product(product, "Chips")
        assert result["validation_warnings"] == []
        assert result["confidence"] == "verified"

    def test_product_with_ean_failure_and_contradiction(self) -> None:
        product = {
            "ean": "1234567890000",
            "vegan_status": "yes",
            "vegetarian_status": "yes",
            "allergen_tags": "en:milk",
            "_completeness": "0.9",
        }
        result = validate_product(product, "Chips")
        warnings = result["validation_warnings"]
        # Should have both EAN and contradiction warnings
        assert any("EAN" in w for w in warnings)
        assert any("vegan_status" in w for w in warnings)

    def test_product_with_all_warning_types(self) -> None:
        product = {
            "ean": "1234567890000",
            "calories": "999",
            "vegan_status": "yes",
            "vegetarian_status": "no",
            "allergen_tags": "en:milk, en:fish",
            "_completeness": "0.1",
        }
        result = validate_product(product, "Chips")
        warnings = result["validation_warnings"]
        # EAN + nutrition + vegan contradiction + logical impossibility = 4
        assert len(warnings) >= 4
        assert result["confidence"] == "estimated"

    def test_contradiction_warnings_included_in_result(self) -> None:
        product = {
            "ean": "5901234123457",
            "vegan_status": "yes",
            "vegetarian_status": "yes",
            "allergen_tags": "en:eggs",
            "_completeness": "0.8",
            "_has_image": True,
        }
        result = validate_product(product, "Chips")
        assert any("vegan_status" in w for w in result["validation_warnings"])

    def test_original_product_not_mutated(self) -> None:
        product = {
            "ean": "5901234123457",
            "vegan_status": "yes",
            "allergen_tags": "en:milk",
        }
        original_keys = set(product.keys())
        validate_product(product, "Chips")
        assert set(product.keys()) == original_keys
