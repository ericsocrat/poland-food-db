"""One-shot migration script for pipeline SQL files.

Applies schema consolidation changes:
  1. Deletes all 02_add_servings.sql files (servings table removed)
  2. Updates 03_add_nutrition.sql — removes serving_id references
  3. Updates 04_scoring.sql — scores merged into products
  4. Updates 05_source_provenance.sql — product_sources merged into products
"""

import re
from pathlib import Path

PIPELINES_DIR = Path(__file__).resolve().parent.parent / "db" / "pipelines"


def transform_03_nutrition(text: str) -> str:
    """Remove serving-related references from nutrition SQL."""

    # 1) Fix the DELETE block: (product_id, serving_id) in (select p..., s.serving_id ...)
    #    → product_id in (select p.product_id ...)
    text = re.sub(
        r"delete from nutrition_facts\s*\n"
        r"where \(product_id, serving_id\) in \(\s*\n"
        r"  select p\.product_id, s\.serving_id\s*\n"
        r"  from products p\s*\n"
        r"  join servings s on s\.product_id = p\.product_id and s\.serving_basis = 'per 100 g'\s*\n"
        r"(  where.*?\n"
        r"(?:    .*?\n)*)"
        r"\);",
        lambda m: (
            "delete from nutrition_facts\n"
            "where product_id in (\n"
            "  select p.product_id\n"
            "  from products p\n"
            + m.group(1)
            + ");"
        ),
        text,
    )

    # 2) Fix INSERT column list: remove serving_id
    text = text.replace(
        "(product_id, serving_id, calories,",
        "(product_id, calories,",
    )

    # 3) Fix SELECT list in INSERT: remove s.serving_id
    text = re.sub(
        r"  p\.product_id, s\.serving_id,\n",
        "  p.product_id,\n",
        text,
    )

    # 4) Remove the servings JOIN line
    text = re.sub(
        r"join servings s on s\.product_id = p\.product_id and s\.serving_basis = 'per 100 g'\n",
        "",
        text,
    )

    # 5) Fix ON CONFLICT
    text = text.replace(
        "on conflict (product_id, serving_id) do update set",
        "on conflict (product_id) do update set",
    )

    return text


def transform_04_scoring(text: str) -> str:
    """Rewrite scoring to update products directly instead of scores table."""

    # 0) Remove the "ENSURE rows in scores" block entirely
    text = re.sub(
        r"-- 0\. ENSURE rows in scores\n"
        r"insert into scores \(product_id\)\n"
        r"select p\.product_id\n"
        r"from products p\n"
        r"left join scores sc on sc\.product_id = p\.product_id\n"
        r"where[^;]*;\n*",
        "",
        text,
    )

    # 1) Section 1: unhealthiness_score
    # "update scores sc set" → "update products p set"
    text = text.replace("update scores sc set\n  unhealthiness_score",
                        "update products p set\n  unhealthiness_score")

    # "sc.ingredient_concern_score" → "p.ingredient_concern_score"
    text = text.replace("sc.ingredient_concern_score", "p.ingredient_concern_score")

    # Remove "from products p\n" line (it's the first FROM before the joins)
    # and replace the servings+nutrition join with direct nutrition join
    text = re.sub(
        r"from products p\n"
        r"join servings sv on sv\.product_id = p\.product_id and sv\.serving_basis = 'per 100 g'\n"
        r"join nutrition_facts nf on nf\.product_id = p\.product_id and nf\.serving_id = sv\.serving_id\n"
        r"(left join \(\n"
        r"    select pi\.product_id.*?\n"
        r"    from product_ingredient.*?\n"
        r"    group by pi\.product_id\n"
        r"\) ia on ia\.product_id = p\.product_id\n)"
        r"where p\.product_id = sc\.product_id\n",
        r"from nutrition_facts nf\n"
        r"\1"
        r"where nf.product_id = p.product_id\n",
        text,
        flags=re.DOTALL,
    )

    # Fix the second occurrence (section 4: health-risk flags)
    # Same pattern but for the flags update
    text = re.sub(
        r"from products p\n"
        r"join servings sv on sv\.product_id = p\.product_id and sv\.serving_basis = 'per 100 g'\n"
        r"join nutrition_facts nf on nf\.product_id = p\.product_id and nf\.serving_id = sv\.serving_id\n"
        r"(left join \(\n"
        r"    select pi\.product_id.*?\n"
        r"    from product_ingredient.*?\n"
        r"    group by pi\.product_id\n"
        r"\) ia on ia\.product_id = p\.product_id\n)"
        r"where p\.product_id = sc\.product_id\n",
        r"from nutrition_facts nf\n"
        r"\1"
        r"where nf.product_id = p.product_id\n",
        text,
        flags=re.DOTALL,
    )

    # 2) Nutri-Score section:
    # "update scores sc set\n  nutri_score_label" → "update products p set\n  nutri_score_label"
    text = text.replace("update scores sc set\n  nutri_score_label",
                        "update products p set\n  nutri_score_label")

    # The FROM clause for nutri-score VALUES block:
    # "join products p on p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name\n"
    # "where p.product_id = sc.product_id;"
    # →
    # "where p.country = 'PL' and p.brand = d.brand and p.product_name = d.product_name;"
    text = re.sub(
        r"join products p on (p\.country = 'PL' and p\.brand = d\.brand and p\.product_name = d\.product_name)\n"
        r"where p\.product_id = sc\.product_id;",
        r"where \1;",
        text,
    )

    # 3) NOVA section: same pattern
    text = text.replace("update scores sc set\n  nova_classification",
                        "update products p set\n  nova_classification")

    # After the nutri-score fix above, the NOVA block has the same remaining pattern
    # (if the join+where wasn't already caught, handle it)
    text = re.sub(
        r"join products p on (p\.country = 'PL' and p\.brand = d\.brand and p\.product_name = d\.product_name)\n"
        r"where p\.product_id = sc\.product_id;",
        r"where \1;",
        text,
    )

    # 4) Health-risk flags: "update scores sc set\n  high_salt_flag" → "update products p set\n  high_salt_flag"
    text = text.replace("update scores sc set\n  high_salt_flag",
                        "update products p set\n  high_salt_flag")

    # 5) Confidence section:
    # "update scores sc set\n  confidence = assign_confidence(sc.data_completeness_pct"
    # → "update products p set\n  confidence = assign_confidence(p.data_completeness_pct"
    text = text.replace(
        "update scores sc set\n  confidence = assign_confidence(sc.data_completeness_pct",
        "update products p set\n  confidence = assign_confidence(p.data_completeness_pct",
    )

    # Remove the FROM + WHERE for confidence (which was: from products p where p.product_id = sc.product_id)
    text = re.sub(
        r"(update products p set\n  confidence = assign_confidence\(p\.data_completeness_pct.*?\))\n"
        r"from products p\n"
        r"where p\.product_id = sc\.product_id\n"
        r"  and (p\.country[^;]*;\n)",
        r"\1\nwhere \2",
        text,
    )

    return text


def transform_05_source(text: str) -> str:
    """Rewrite source provenance from INSERT product_sources to UPDATE products."""

    # Extract category from existing SQL
    cat_match = re.search(r"AND p\.category = ('.*?')", text)
    if not cat_match:
        cat_match = re.search(r"p\.category\s*=\s*('.*?')", text)
    category_literal = cat_match.group(1) if cat_match else "'Unknown'"

    # Extract the VALUES block
    values_match = re.search(
        r"FROM \(\s*\n\s*VALUES\s*\n(.*?)\n\) AS d\(",
        text,
        re.DOTALL,
    )
    if not values_match:
        return text  # Can't parse, leave unchanged

    values_block = values_match.group(1)

    # Extract the header comment
    header_match = re.search(r"(-- PIPELINE \(.*?\): source provenance\n-- Generated:.*?\n)", text)
    header = header_match.group(1) if header_match else "-- PIPELINE: source provenance\n"

    return f"""{header}
-- 1. Update source info on products
UPDATE products p SET
  source_type = 'off_api',
  source_url = d.source_url,
  source_ean = d.source_ean
FROM (
  VALUES
{values_block}
) AS d(brand, product_name, source_url, source_ean)
WHERE p.country = 'PL' AND p.brand = d.brand
  AND p.product_name = d.product_name
  AND p.category = {category_literal} AND p.is_deprecated IS NOT TRUE;
"""


def main():
    """Process all pipeline directories."""
    deleted = 0
    updated_03 = 0
    updated_04 = 0
    updated_05 = 0

    for cat_dir in sorted(PIPELINES_DIR.iterdir()):
        if not cat_dir.is_dir():
            continue

        # 1) Delete 02_add_servings.sql
        for f in cat_dir.glob("*__02_add_servings.sql"):
            f.unlink()
            deleted += 1
            print(f"  DELETED: {f.name}")

        # 2) Transform 03_add_nutrition.sql
        for f in cat_dir.glob("*__03_add_nutrition.sql"):
            text = f.read_text(encoding="utf-8")
            new_text = transform_03_nutrition(text)
            f.write_text(new_text, encoding="utf-8")
            updated_03 += 1
            print(f"  UPDATED: {f.name}")

        # 3) Transform 04_scoring.sql
        for f in cat_dir.glob("*__04_scoring.sql"):
            text = f.read_text(encoding="utf-8")
            new_text = transform_04_scoring(text)
            f.write_text(new_text, encoding="utf-8")
            updated_04 += 1
            print(f"  UPDATED: {f.name}")

        # 4) Transform 05_source_provenance.sql
        for f in cat_dir.glob("*__05_source_provenance.sql"):
            text = f.read_text(encoding="utf-8")
            new_text = transform_05_source(text)
            f.write_text(new_text, encoding="utf-8")
            updated_05 += 1
            print(f"  UPDATED: {f.name}")

    print(f"\nSummary:")
    print(f"  Deleted {deleted} servings files")
    print(f"  Updated {updated_03} nutrition files")
    print(f"  Updated {updated_04} scoring files")
    print(f"  Updated {updated_05} source provenance files")


if __name__ == "__main__":
    main()
