"""Tests for enrichment SQL generation portability.

Validates that enrich_ingredients.py generates portable SQL that resolves
all IDs (product_id, ingredient_id, parent_ingredient_id) via stable natural
key JOINs rather than hardcoded integer literals.
"""

from __future__ import annotations

import pytest

from check_enrichment_identity import validate_statement
from enrich_ingredients import (
    _format_ingredient_row,
    _gen_ingredient_batch,
    _gen_ingredient_section,
    process_ingredients,
)

# ─── _format_ingredient_row ────────────────────────────────────────────────

class TestFormatIngredientRow:
    def test_basic_row(self):
        row = {
            "percent": 10.5,
            "percent_estimate": 8.2,
            "is_sub_ingredient": False,
            "parent_ingredient_name": None,
        }
        pct, pct_est, parent_sql, is_sub = _format_ingredient_row(row)
        assert pct == "10.5"
        assert pct_est == "8.2"
        assert parent_sql == "NULL"
        assert is_sub is False

    def test_sub_ingredient_with_parent(self):
        row = {
            "percent": None,
            "percent_estimate": 3.0,
            "is_sub_ingredient": True,
            "parent_ingredient_name": "Wheat Flour",
        }
        pct, _pct_est, parent_sql, is_sub = _format_ingredient_row(row)
        assert pct == "NULL"
        assert "Wheat Flour" in parent_sql
        assert is_sub is True

    def test_sub_ingredient_without_parent_forced_false(self):
        """chk_sub_has_parent: if parent is None, is_sub must be false."""
        row = {
            "percent": None,
            "percent_estimate": None,
            "is_sub_ingredient": True,
            "parent_ingredient_name": None,
        }
        _, _, parent_sql, is_sub = _format_ingredient_row(row)
        assert parent_sql == "NULL"
        assert is_sub is False


# ─── _gen_ingredient_batch ─────────────────────────────────────────────────

class TestGenIngredientBatch:
    @pytest.fixture
    def sample_rows(self):
        return [
            {
                "country": "PL",
                "ean": "5900000000001",
                "ingredient_name": "Sugar",
                "position": 1,
                "percent": None,
                "percent_estimate": 15.0,
                "is_sub_ingredient": False,
                "parent_ingredient_name": None,
            },
            {
                "country": "PL",
                "ean": "5900000000001",
                "ingredient_name": "Wheat Flour",
                "position": 2,
                "percent": 30.0,
                "percent_estimate": None,
                "is_sub_ingredient": False,
                "parent_ingredient_name": None,
            },
        ]

    def test_uses_ingredient_ref_name_join(self, sample_rows):
        sql = "\n".join(_gen_ingredient_batch(sample_rows))
        assert "JOIN ingredient_ref ir ON lower(ir.name_en) = lower(v.ingredient_name)" in sql

    def test_uses_parent_ingredient_ref_join(self, sample_rows):
        sql = "\n".join(_gen_ingredient_batch(sample_rows))
        assert "LEFT JOIN ingredient_ref ir_parent ON lower(ir_parent.name_en) = lower(v.parent_ingredient_name)" in sql

    def test_uses_products_join(self, sample_rows):
        sql = "\n".join(_gen_ingredient_batch(sample_rows))
        assert "JOIN products p ON p.country = v.country AND p.ean = v.ean" in sql

    def test_no_hardcoded_ingredient_id(self, sample_rows):
        """Ensure no raw integer ingredient_id appears in VALUES."""
        sql = "\n".join(_gen_ingredient_batch(sample_rows))
        # VALUES should contain ingredient_name strings, not integer IDs
        assert "v.ingredient_id" not in sql.lower()
        # Should select ir.ingredient_id from JOIN
        assert "ir.ingredient_id" in sql

    def test_selects_ir_parent_ingredient_id(self, sample_rows):
        sql = "\n".join(_gen_ingredient_batch(sample_rows))
        assert "ir_parent.ingredient_id" in sql

    def test_sub_ingredient_with_parent_name(self):
        rows = [
            {
                "country": "DE",
                "ean": "4012345000001",
                "ingredient_name": "Glucose Syrup",
                "position": 3,
                "percent": None,
                "percent_estimate": 5.0,
                "is_sub_ingredient": True,
                "parent_ingredient_name": "Sugar",
            },
        ]
        sql = "\n".join(_gen_ingredient_batch(rows))
        assert "'Sugar'" in sql
        assert "'Glucose Syrup'" in sql
        assert "true" in sql  # is_sub_ingredient

    def test_on_conflict(self, sample_rows):
        sql = "\n".join(_gen_ingredient_batch(sample_rows))
        assert "ON CONFLICT (product_id, ingredient_id, position) DO NOTHING" in sql


# ─── _gen_ingredient_section ───────────────────────────────────────────────

class TestGenIngredientSection:
    def test_batches_large_input(self):
        rows = [
            {
                "country": "PL",
                "ean": f"590000000{i:04d}",
                "ingredient_name": f"Ingredient {i}",
                "position": 1,
                "percent": None,
                "percent_estimate": None,
                "is_sub_ingredient": False,
                "parent_ingredient_name": None,
            }
            for i in range(1200)
        ]
        sql = "\n".join(_gen_ingredient_section(rows))
        # With 1200 rows and batch_size=500, should have 3 INSERT blocks
        assert sql.count("INSERT INTO product_ingredient") == 3

    def test_all_batches_have_name_join(self):
        rows = [
            {
                "country": "PL",
                "ean": f"590000000{i:04d}",
                "ingredient_name": f"Ingredient {i}",
                "position": 1,
                "percent": None,
                "percent_estimate": None,
                "is_sub_ingredient": False,
                "parent_ingredient_name": None,
            }
            for i in range(600)
        ]
        sql = "\n".join(_gen_ingredient_section(rows))
        join_count = sql.count("JOIN ingredient_ref ir ON lower(ir.name_en) = lower(v.ingredient_name)")
        insert_count = sql.count("INSERT INTO product_ingredient")
        assert join_count == insert_count


# ─── process_ingredients ───────────────────────────────────────────────────

class TestProcessIngredients:
    def test_rows_have_ingredient_name_not_id(self):
        off_product = {
            "ingredients": [
                {"text": "sugar", "id": "en:sugar"},
                {"text": "salt", "id": "en:salt"},
            ]
        }
        lookup = {"sugar": 42, "salt": 99}
        new_ingredients: dict = {}
        rows = process_ingredients(off_product, "PL", "5900000000001", lookup, new_ingredients)
        assert len(rows) == 2
        for row in rows:
            assert "ingredient_name" in row
            assert "ingredient_id" not in row
            assert "parent_ingredient_name" in row
            assert "parent_ingredient_id" not in row

    def test_sub_ingredient_parent_name(self):
        off_product = {
            "ingredients": [
                {
                    "text": "wheat flour",
                    "id": "en:wheat-flour",
                    "ingredients": [
                        {"text": "wheat", "id": "en:wheat"},
                    ],
                },
            ]
        }
        lookup = {"wheat flour": 10, "wheat": 11}
        new_ingredients: dict = {}
        rows = process_ingredients(off_product, "PL", "5900000000001", lookup, new_ingredients)
        assert len(rows) == 2
        parent_row = rows[0]
        child_row = rows[1]
        assert parent_row["ingredient_name"] == "Wheat Flour"
        assert parent_row["parent_ingredient_name"] is None
        assert parent_row["is_sub_ingredient"] is False
        assert child_row["ingredient_name"] == "Wheat"
        assert child_row["parent_ingredient_name"] == "Wheat Flour"
        assert child_row["is_sub_ingredient"] is True

    def test_new_ingredient_tracked(self):
        off_product = {
            "ingredients": [
                {"text": "xylitol", "id": "en:xylitol"},
            ]
        }
        lookup: dict = {}  # not in DB
        new_ingredients: dict = {}
        rows = process_ingredients(off_product, "DE", "4012345000001", lookup, new_ingredients)
        assert len(rows) == 1
        assert "xylitol" in new_ingredients
        assert rows[0]["ingredient_name"] == "Xylitol"


# ─── validate_statement (identity guard) ───────────────────────────────────

class TestValidateStatement:
    def test_portable_ingredient_insert_passes(self):
        sql = """
        INSERT INTO product_ingredient (product_id, ingredient_id, position)
        SELECT p.product_id, ir.ingredient_id, v.position
        FROM (VALUES ('PL', '5900000000001', 'Sugar', 1)
        ) AS v(country, ean, ingredient_name, position)
        JOIN products p ON p.country = v.country AND p.ean = v.ean
        JOIN ingredient_ref ir ON lower(ir.name_en) = lower(v.ingredient_name)
        ON CONFLICT DO NOTHING
        """
        issues = validate_statement(sql)
        assert issues == []

    def test_hardcoded_ingredient_id_fails(self):
        sql = """
        INSERT INTO product_ingredient (product_id, ingredient_id, position)
        SELECT p.product_id, v.ingredient_id, v.position
        FROM (VALUES ('PL', '5900000000001', 42, 1)
        ) AS v(country, ean, ingredient_id, position)
        JOIN products p ON p.country = v.country AND p.ean = v.ean
        ON CONFLICT DO NOTHING
        """
        issues = validate_statement(sql)
        assert any("ingredient name join" in i.lower() for i in issues)

    def test_allergen_insert_no_ingredient_check(self):
        """Allergen inserts don't need ingredient_ref JOIN."""
        sql = """
        INSERT INTO product_allergen_info (product_id, tag, type)
        SELECT p.product_id, v.tag, v.type
        FROM (VALUES ('PL', '5900000000001', 'en:gluten', 'contains')
        ) AS v(country, ean, tag, type)
        JOIN products p ON p.country = v.country AND p.ean = v.ean
        ON CONFLICT DO NOTHING
        """
        issues = validate_statement(sql)
        assert issues == []

    def test_allergen_without_product_join_fails(self):
        sql = """
        INSERT INTO product_allergen_info (product_id, tag, type)
        VALUES (123, 'en:gluten', 'contains')
        """
        issues = validate_statement(sql)
        assert len(issues) > 0

    def test_unrelated_insert_passes(self):
        sql = "INSERT INTO some_other_table (id, name) VALUES (1, 'test')"
        issues = validate_statement(sql)
        assert issues == []

    def test_generated_sql_passes_guard(self):
        """End-to-end: SQL from _gen_ingredient_batch must pass the identity guard."""
        rows = [
            {
                "country": "PL",
                "ean": "5900000000001",
                "ingredient_name": "Sugar",
                "position": 1,
                "percent": None,
                "percent_estimate": None,
                "is_sub_ingredient": False,
                "parent_ingredient_name": None,
            },
        ]
        sql = "\n".join(_gen_ingredient_batch(rows))
        issues = validate_statement(sql)
        assert issues == [], f"Generated SQL failed identity guard: {issues}"
