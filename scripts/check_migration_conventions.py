"""Validate migration file naming conventions and header block standards.

Scans supabase/migrations/*.sql to verify compliance with the standards
documented in docs/MIGRATION_CONVENTIONS.md §3 (Migration Naming Convention).

Checks:
  1. File naming: YYYYMMDDHHMMSS_description.sql
     - Timestamp is 14 digits
     - Separator is underscore
     - Description is lowercase, words separated by underscores
  2. Header block: must contain at least "Migration:" and "Rollback:" lines
     within the first 20 lines of the file
  3. _TEMPLATE.sql is ignored (not a real migration)

Usage:
    python scripts/check_migration_conventions.py            # check all
    python scripts/check_migration_conventions.py --strict   # also require Issue: line
    python scripts/check_migration_conventions.py --report   # summary report only

Exit codes:
    0 — all checks pass (or report-only mode)
    1 — violations found
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

MIGRATIONS_ROOT = Path(__file__).resolve().parent.parent / "supabase" / "migrations"

# ── Naming convention ─────────────────────────────────────────────────────

# Valid: 20260301000000_drift_detection_automation.sql
# Invalid: 2026_03_01_drift.sql, migration_v2.sql
_FILENAME_RE = re.compile(r"^(\d{14})_([a-z][a-z0-9_]*)\.sql$")

# Timestamp: first 8 digits = YYYYMMDD (basic sanity)
_MIN_DATE = 20250101
_MAX_DATE = 20291231

# Description should not contain double underscores or trailing underscore
_BAD_DESC_RE = re.compile(r"__|_$")

# ── Header block ──────────────────────────────────────────────────────────

# We look in the first 20 lines for these markers.  They may appear
# as part of a decorated comment block (═══, ───, etc.) or bare "-- Key: ...".
_MIGRATION_LINE = re.compile(r"^--\s*Migration:", re.IGNORECASE)
_ROLLBACK_LINE = re.compile(r"^--\s*Rollback:", re.IGNORECASE)
_ISSUE_LINE = re.compile(r"^--\s*Issue:", re.IGNORECASE)

HEADER_SCAN_LINES = 20

# Files to skip
SKIP_FILES = {"_TEMPLATE.sql"}


def _check_filename(name: str) -> list[str]:
    """Validate a single migration filename. Returns list of violations."""
    violations: list[str] = []

    m = _FILENAME_RE.match(name)
    if not m:
        violations.append(
            f"[{name}] Filename does not match YYYYMMDDHHMMSS_description.sql pattern"
        )
        return violations  # can't check further

    timestamp_str, description = m.group(1), m.group(2)

    # Basic date sanity
    date_part = int(timestamp_str[:8])
    if date_part < _MIN_DATE or date_part > _MAX_DATE:
        violations.append(
            f"[{name}] Date portion {date_part} out of expected range "
            f"({_MIN_DATE}–{_MAX_DATE})"
        )

    # Month 01–12
    month = int(timestamp_str[4:6])
    if month < 1 or month > 12:
        violations.append(f"[{name}] Invalid month: {month:02d}")

    # Day 01–31
    day = int(timestamp_str[6:8])
    if day < 1 or day > 31:
        violations.append(f"[{name}] Invalid day: {day:02d}")

    # Description quality
    if _BAD_DESC_RE.search(description):
        violations.append(
            f"[{name}] Description contains double underscores or trailing underscore"
        )

    if len(description) < 3:
        violations.append(f"[{name}] Description too short (min 3 chars)")

    return violations


def _check_header(name: str, content: str, *, strict: bool = False) -> list[str]:
    """Validate header block in the first N lines. Returns violations."""
    violations: list[str] = []
    lines = content.split("\n")[:HEADER_SCAN_LINES]

    has_migration = any(_MIGRATION_LINE.search(line) for line in lines)
    has_rollback = any(_ROLLBACK_LINE.search(line) for line in lines)
    has_issue = any(_ISSUE_LINE.search(line) for line in lines)

    if not has_migration:
        violations.append(
            f"[{name}] Missing 'Migration:' in header (first {HEADER_SCAN_LINES} lines)"
        )

    if not has_rollback:
        violations.append(
            f"[{name}] Missing 'Rollback:' in header (first {HEADER_SCAN_LINES} lines)"
        )

    if strict and not has_issue:
        violations.append(f"[{name}] Missing 'Issue:' in header (strict mode)")

    return violations


def check_migration(path: Path, *, strict: bool = False) -> list[str]:
    """Check a single migration file. Returns list of violations."""
    violations: list[str] = []
    name = path.name

    if name in SKIP_FILES:
        return []

    # Filename checks
    violations.extend(_check_filename(name))

    # Header block checks
    try:
        content = path.read_text(encoding="utf-8", errors="replace")
    except OSError as exc:
        violations.append(f"[{name}] Cannot read file: {exc}")
        return violations

    violations.extend(_check_header(name, content, strict=strict))

    return violations


def main() -> None:
    strict = "--strict" in sys.argv
    report_only = "--report" in sys.argv

    if not MIGRATIONS_ROOT.is_dir():
        print(f"ERROR: Migrations directory not found: {MIGRATIONS_ROOT}")
        sys.exit(1)

    sql_files = sorted(MIGRATIONS_ROOT.glob("*.sql"))
    sql_files = [f for f in sql_files if f.name not in SKIP_FILES]

    if not sql_files:
        print("ERROR: No migration files found.")
        sys.exit(1)

    all_violations: list[str] = []
    name_ok = 0
    name_fail = 0
    header_ok = 0
    header_missing_migration = 0
    header_missing_rollback = 0
    header_missing_issue = 0

    for path in sql_files:
        violations = check_migration(path, strict=strict)

        # Categorize — use specific markers from _check_filename messages
        fname_violations = [
            v
            for v in violations
            if "does not match" in v
            or "out of expected range" in v
            or "Invalid month" in v
            or "Invalid day" in v
            or "double underscores" in v
            or "trailing underscore" in v
            or "too short" in v
        ]
        if fname_violations:
            name_fail += 1
        else:
            name_ok += 1

        for v in violations:
            if "Migration:" in v:
                header_missing_migration += 1
            elif "Rollback:" in v:
                header_missing_rollback += 1
            elif "Issue:" in v:
                header_missing_issue += 1

        if not any(
            "Migration:" in v or "Rollback:" in v or "Issue:" in v for v in violations
        ):
            header_ok += 1

        all_violations.extend(violations)

    total = len(sql_files)

    if report_only:
        print(f"Migration Convention Report — {total} files scanned")
        print(f"  Naming: {name_ok}/{total} compliant ({name_fail} violations)")
        print(f"  Header: {header_ok}/{total} have complete header block")
        print(f"    Missing 'Migration:' line: {header_missing_migration}")
        print(f"    Missing 'Rollback:' line: {header_missing_rollback}")
        if strict:
            print(f"    Missing 'Issue:' line: {header_missing_issue}")
        sys.exit(0)

    if all_violations:
        print(
            f"Migration convention check — {len(all_violations)} violations in {total} files:"
        )
        for v in all_violations:
            print(f"  x {v}")
        print(f"\nSummary: {name_ok}/{total} naming OK, {header_ok}/{total} header OK")
        sys.exit(1)
    else:
        mode = " (strict)" if strict else ""
        print(f"Migration convention check PASSED{mode} — {total} files verified.")
        sys.exit(0)


if __name__ == "__main__":
    main()
