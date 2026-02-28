"""Tests for pipeline.validator — comprehensive coverage for all validation functions.

Covers: EAN checksum, nutrition ranges, nutrition anomaly detection,
attribute contradiction detection, and the main validate_product entry point.
"""

from __future__ import annotations

from pipeline.validator import (
    ABSOLUTE_CAPS,
    ANIMAL_ALLERGEN_TAGS,
    MEAT_FISH_ALLERGEN_TAGS,
    check_attribute_contradictions,
    check_nutrition_anomalies,
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
        product = {
            "calories": "500",
            "total_fat_g": "30",
            "carbs_g": "50",
            "protein_g": "7",
            "salt_g": "1.5",
        }
        assert check_nutrition_ranges(product, "Chips") == []

    def test_above_range(self) -> None:
        product = {
            "calories": "700",
            "total_fat_g": "40",
            "carbs_g": "60",
            "protein_g": "10",
        }
        warnings = check_nutrition_ranges(product, "Chips")
        assert any("calories=700.0" in w for w in warnings)

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
# Nutrition anomaly detection
# ═══════════════════════════════════════════════════════════════════════════


class TestCheckNutritionAnomalies:
    """Tests for check_nutrition_anomalies() — absolute cap + category range checks."""

    def test_within_caps_no_errors(self) -> None:
        product = {"calories": "500", "total_fat_g": "30", "salt_g": "1.5"}
        errors, warnings = check_nutrition_anomalies(product, "Chips")
        assert errors == []

    def test_exceeds_absolute_cap_calories(self) -> None:
        product = {"calories": "950"}
        errors, warnings = check_nutrition_anomalies(product, "Chips")
        assert len(errors) == 1
        assert "calories" in errors[0]
        assert "950" in errors[0]

    def test_exceeds_absolute_cap_salt(self) -> None:
        product = {"salt_g": "55"}
        errors, warnings = check_nutrition_anomalies(product, "Chips")
        assert len(errors) == 1
        assert "salt_g" in errors[0]

    def test_exceeds_absolute_cap_fat(self) -> None:
        product = {"total_fat_g": "110"}
        errors, warnings = check_nutrition_anomalies(product, "Chips")
        assert len(errors) == 1
        assert "total_fat_g" in errors[0]

    def test_multiple_cap_violations(self) -> None:
        product = {"calories": "950", "total_fat_g": "110", "salt_g": "55"}
        errors, warnings = check_nutrition_anomalies(product, "Chips")
        assert len(errors) == 3

    def test_at_exact_cap_no_error(self) -> None:
        product = {"calories": "900"}
        errors, warnings = check_nutrition_anomalies(product, "Chips")
        assert errors == []

    def test_category_range_high_outlier_warning(self) -> None:
        """Value > 1.5× category high triggers warning."""
        # Chips calories range is (400, 600), so 1.5 × 600 = 900
        # 901 > 900 cap, so it would be an error. Use a field with more room.
        # Chips salt_g range is (0.5, 3.0), so 1.5 × 3.0 = 4.5
        product = {"salt_g": "5.0"}
        errors, warnings = check_nutrition_anomalies(product, "Chips")
        assert errors == []
        assert len(warnings) == 1
        assert "salt_g" in warnings[0]
        assert "category" in warnings[0].lower()

    def test_category_range_low_outlier_warning(self) -> None:
        """Value < 0.5× category low triggers warning."""
        # Chips calories range is (400, 600), so 0.5 × 400 = 200
        product = {"calories": "150"}
        errors, warnings = check_nutrition_anomalies(product, "Chips")
        assert errors == []
        assert len(warnings) == 1
        assert "calories" in warnings[0]

    def test_category_range_within_bounds_no_warning(self) -> None:
        product = {"calories": "500"}
        errors, warnings = check_nutrition_anomalies(product, "Chips")
        assert errors == []
        assert warnings == []

    def test_unknown_category_only_caps_checked(self) -> None:
        product = {"calories": "500", "total_fat_g": "30"}
        errors, warnings = check_nutrition_anomalies(product, "UnknownCategory")
        assert errors == []
        assert warnings == []

    def test_unknown_category_cap_still_blocks(self) -> None:
        product = {"calories": "950"}
        errors, warnings = check_nutrition_anomalies(product, "UnknownCategory")
        assert len(errors) == 1

    def test_missing_field_skipped(self) -> None:
        product = {"something_else": "42"}
        errors, warnings = check_nutrition_anomalies(product, "Chips")
        assert errors == []
        assert warnings == []

    def test_non_numeric_value_skipped(self) -> None:
        product = {"calories": "N/A"}
        errors, warnings = check_nutrition_anomalies(product, "Chips")
        assert errors == []
        assert warnings == []

    def test_none_value_skipped(self) -> None:
        product = {"calories": None}
        errors, warnings = check_nutrition_anomalies(product, "Chips")
        assert errors == []
        assert warnings == []

    def test_absolute_caps_dict_has_expected_keys(self) -> None:
        expected = {
            "calories",
            "total_fat_g",
            "saturated_fat_g",
            "carbs_g",
            "sugars_g",
            "protein_g",
            "fibre_g",
            "salt_g",
            "trans_fat_g",
        }
        assert set(ABSOLUTE_CAPS.keys()) == expected


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
            "carbs_g": "50",
            "protein_g": "7",
            "salt_g": "1.5",
            "_completeness": "0.8",
            "_has_image": True,
            "vegan_status": "yes",
            "vegetarian_status": "yes",
            "allergen_tags": "",
        }
        result = validate_product(product, "Chips")
        assert result["validation_warnings"] == []
        assert result["anomaly_errors"] == []
        assert result["anomaly_warnings"] == []
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

    def test_anomaly_error_blocks_with_estimated_confidence(self) -> None:
        product = {
            "ean": "5901234123457",
            "calories": "950",
            "_completeness": "0.9",
            "_has_image": True,
        }
        result = validate_product(product, "Chips")
        assert len(result["anomaly_errors"]) == 1
        assert result["confidence"] == "estimated"

    def test_anomaly_warnings_included_in_validation_warnings(self) -> None:
        """Anomaly warnings (category range) should appear in validation_warnings."""
        # Chips salt_g range is (0.5, 3.0), so 1.5 × 3.0 = 4.5; 5.0 > 4.5 triggers warning
        product = {
            "ean": "5901234123457",
            "salt_g": "5.0",
            "_completeness": "0.9",
            "_has_image": True,
        }
        result = validate_product(product, "Chips")
        assert result["anomaly_errors"] == []
        assert len(result["anomaly_warnings"]) >= 1
        # Anomaly warnings are merged into validation_warnings
        assert any("category" in w.lower() for w in result["validation_warnings"])
