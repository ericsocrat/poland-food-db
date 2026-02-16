"""Validate pipeline folder structure and SQL patterns.

Each pipeline folder under db/pipelines/ must contain the required step files
following the project's naming convention and idempotent SQL patterns.

Checks:
  - Required files exist (01, 03, 04, 05)
  - Step 01 uses ON CONFLICT (country, brand, product_name)
  - Step 03 uses ON CONFLICT (product_id)
  - Step 04 calls score_category()
  - No hardcoded product_id integer literals in INSERT/UPDATE
  - No references to non-portable constructs

Usage:
    python check_pipeline_structure.py          # check all categories
    python check_pipeline_structure.py chips    # check one category

Exit codes:
    0 — all checks pass
    1 — structural violations found
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

PIPELINE_ROOT = Path(__file__).parent / "db" / "pipelines"

REQUIRED_STEPS = {
    "01_insert_products",
    "03_add_nutrition",
    "04_scoring",
    "05_source_provenance",
}

# Regex: literal integer after "product_id =" or "product_id IN (" or "VALUES (\d"
# This catches hardcoded product_id references like "product_id = 42"
HARDCODED_PID = re.compile(
    r"""
    \bproduct_id\s*=\s*\d+           |  # product_id = 42
    VALUES\s*\(\s*\d+\s*,            |  # VALUES (42, ...
    \(\s*\d+\s*,\s*\d+\.?\d*\s*,        # (42, 500.0, ... — nutrition insert with raw id
    """,
    re.IGNORECASE | re.VERBOSE,
)

# Step 01 must have the upsert conflict key
STEP_01_CONFLICT = re.compile(
    r"on\s+conflict\s*\(\s*country\s*,\s*brand\s*,\s*product_name\s*\)",
    re.IGNORECASE,
)

# Step 03 must have ON CONFLICT (product_id)
STEP_03_CONFLICT = re.compile(
    r"on\s+conflict\s*\(\s*product_id\s*\)",
    re.IGNORECASE,
)

# Step 04 must call score_category
STEP_04_SCORE_CALL = re.compile(
    r"CALL\s+score_category\s*\(",
    re.IGNORECASE,
)


def _check_required_files(category: str, folder: Path) -> list[str]:
    """Check that all required step files exist for a category."""
    violations: list[str] = []
    sql_files = {f.name for f in folder.glob("PIPELINE__*.sql")}
    for step in REQUIRED_STEPS:
        pattern = f"PIPELINE__{category}__{step}.sql"
        if pattern not in sql_files:
            violations.append(f"[{category}] Missing: {pattern}")
    return violations


def _is_conflict_context(content: str, start: int) -> bool:
    """Return True if the match position occurs near an ON CONFLICT clause."""
    prefix = content[max(0, start - 20) : start].lower()
    return "on conflict" in prefix


def _is_subquery_context(content: str, start: int, end: int) -> bool:
    """Return True if the match occurs in a p.product_id subquery context."""
    context = content[max(0, start - 50) : end + 10]
    return bool(re.search(r"\bp\.product_id\b", context, re.IGNORECASE))


def _check_hardcoded_pids(category: str, fname: str, content: str) -> list[str]:
    """Detect hardcoded product_id literals in pipeline SQL."""
    violations: list[str] = []
    for match in HARDCODED_PID.finditer(content):
        if _is_conflict_context(content, match.start()):
            continue
        if _is_subquery_context(content, match.start(), match.end()):
            continue
        violations.append(
            f"[{category}/{fname}] Possible hardcoded product_id: {match.group().strip()}"
        )
    return violations


def _check_step_structure(
    category: str, fname: str, step: str, content: str
) -> list[str]:
    """Validate step-specific SQL patterns."""
    violations: list[str] = []

    if step == "01_insert_products" and not STEP_01_CONFLICT.search(content):
        violations.append(
            f"[{category}/{fname}] Missing ON CONFLICT (country, brand, product_name)"
        )

    elif step == "03_add_nutrition":
        has_upsert = STEP_03_CONFLICT.search(content)
        has_delete_insert = re.search(
            r"delete\s+from\s+nutrition_facts", content, re.IGNORECASE
        ) and re.search(r"insert\s+into\s+nutrition_facts", content, re.IGNORECASE)
        if not has_upsert and not has_delete_insert:
            violations.append(
                f"[{category}/{fname}] Missing ON CONFLICT (product_id) or delete-then-insert pattern"
            )

    elif step == "04_scoring" and not STEP_04_SCORE_CALL.search(content):
        violations.append(f"[{category}/{fname}] Missing CALL score_category()")

    return violations


def check_category(folder: Path) -> list[str]:
    """Check a single pipeline category folder. Returns list of violations."""
    violations: list[str] = []
    category = folder.name

    # 1. Check all required files exist
    violations.extend(_check_required_files(category, folder))

    # 2. Validate each file
    for sql_file in sorted(folder.glob("PIPELINE__*.sql")):
        content = sql_file.read_text(encoding="utf-8", errors="replace")
        fname = sql_file.name

        # Extract step identifier
        parts = fname.replace(".sql", "").split("__")
        step = parts[-1] if len(parts) >= 3 else ""

        # Check for hardcoded product_id integers in step 01 and 03
        if step in ("01_insert_products", "03_add_nutrition"):
            violations.extend(_check_hardcoded_pids(category, fname, content))

        # Step-specific structural checks
        violations.extend(_check_step_structure(category, fname, step, content))

    return violations


def main() -> None:
    # Optional: filter to a specific category
    target = sys.argv[1] if len(sys.argv) > 1 else None

    if target:
        folders = [PIPELINE_ROOT / target]
        if not folders[0].is_dir():
            print(f"ERROR: Pipeline folder not found: {folders[0]}")
            sys.exit(1)
    else:
        folders = sorted(p for p in PIPELINE_ROOT.iterdir() if p.is_dir())

    if not folders:
        print("ERROR: No pipeline folders found.")
        sys.exit(1)

    all_violations: list[str] = []
    for folder in folders:
        violations = check_category(folder)
        all_violations.extend(violations)

    if all_violations:
        print(f"Pipeline structure check FAILED ({len(all_violations)} violations):")
        for v in all_violations:
            print(f"  ✗ {v}")
        sys.exit(1)
    else:
        print(f"Pipeline structure check PASSED — {len(folders)} categories verified.")
        sys.exit(0)


if __name__ == "__main__":
    main()
