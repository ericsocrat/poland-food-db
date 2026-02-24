#!/usr/bin/env python3
"""
Documentation Count Checker — Issue #150

Scans documentation files for hard-coded counts and compares them against
actual values derived from the filesystem.  Reports discrepancies so docs
can be kept in sync.

Usage:
    python scripts/check_doc_counts.py          # default: report mode
    python scripts/check_doc_counts.py --strict  # exit 1 on any mismatch

Filesystem-derivable counts (always checked):
  - Migration file count       (supabase/migrations/*.sql)
  - QA suite file count        (db/qa/QA__*.sql)
  - Negative test file count   (db/qa/TEST__*.sql)
  - Pipeline folder count      (db/pipelines/*/)

Data-dependent counts (reported but NOT enforced without a DB connection):
  - Product counts, EAN coverage, ingredient counts, row counts

Note: Product-level and row-level counts require a live database connection
and are intentionally excluded from automated enforcement.  Run the
check_doc_counts.py --db flag (future enhancement) to validate those.
"""

from __future__ import annotations

import argparse
import glob
import os
import re
import sys
from pathlib import Path
from typing import NamedTuple


class CountTarget(NamedTuple):
    """A hard-coded count reference in a documentation file."""

    file: str
    line: int  # 1-based
    text: str  # matched text
    metric: str  # what it represents
    value: int  # the number found in the text


class CountMismatch(NamedTuple):
    target: CountTarget
    actual: int


# ── Filesystem counters ─────────────────────────────────────────────────

ROOT = Path(__file__).resolve().parent.parent


def count_migrations() -> int:
    return len(glob.glob(str(ROOT / "supabase" / "migrations" / "*.sql")))


def count_qa_suites() -> int:
    return len(glob.glob(str(ROOT / "db" / "qa" / "QA__*.sql")))


def count_negative_tests() -> int:
    """Count CAUGHT/MISSED assertions in negative test files."""
    total = 0
    for f in glob.glob(str(ROOT / "db" / "qa" / "TEST__*.sql")):
        with open(f, encoding="utf-8") as fh:
            for line in fh:
                if "CAUGHT" in line and "MISSED" in line and "THEN" in line:
                    total += 1
    return total


def count_pipeline_folders() -> int:
    return len([d for d in (ROOT / "db" / "pipelines").iterdir() if d.is_dir()])


def count_qa_checks_from_run_qa() -> int:
    """Parse RUN_QA.ps1 suite definitions to sum expected check counts."""
    run_qa = ROOT / "RUN_QA.ps1"
    if not run_qa.exists():
        return -1
    total = 0
    with open(run_qa, encoding="utf-8") as fh:
        for line in fh:
            m = re.search(r"Checks\s*=\s*(\d+)", line)
            if m and "total_checks" not in line:
                total += int(m.group(1))
    return total


def count_run_qa_suites() -> int:
    """Count how many suites are defined in RUN_QA.ps1."""
    run_qa = ROOT / "RUN_QA.ps1"
    if not run_qa.exists():
        return -1
    count = 0
    with open(run_qa, encoding="utf-8") as fh:
        for line in fh:
            if re.search(r"Num\s*=\s*\d+.*Checks\s*=", line):
                count += 1
    return count


def count_sanity_checks() -> int:
    """Count '-- CHECK N:' headers in sanity_checks.sql."""
    sanity_file = ROOT / "supabase" / "sanity" / "sanity_checks.sql"
    if not sanity_file.exists():
        return -1
    count = 0
    with open(sanity_file, encoding="utf-8") as fh:
        for line in fh:
            if re.match(r"^-- CHECK \d+", line):
                count += 1
    return count


# ── Document scanners ────────────────────────────────────────────────────

MIGRATION_PATTERNS = [
    # Match "124 migrations" or "83 append-only schema migrations" but NOT
    # per-date counts like "| 7 | Theme" inside markdown tables.
    re.compile(
        r"(\d+)\s*(?:append-only\s+)?(?:schema\s+)?migrations?\b(?!\s*\|)", re.I
    ),
    re.compile(r"(\d+)\s+files?\s*\(migrations?\)", re.I),
    re.compile(r"(\d+)\s+migration\s+files?\b", re.I),
]

# Minimum migration count to consider (skip per-category/per-date sub-counts)
MIN_MIGRATION_TOTAL = 50

QA_SUITE_PATTERN = re.compile(r"(\d+)\s+(?:QA\s+)?suites?", re.I)

QA_CHECK_PATTERN = re.compile(r"(\d+)\s+(?:automated\s+)?checks?\s+across", re.I)

NEGATIVE_TEST_PATTERN = re.compile(
    r"(\d+)\s+negative\s+(?:validation\s+)?(?:test|check|injection)", re.I
)

SANITY_CHECK_PATTERN = re.compile(r"(\d+)\s+(?:SQL\s+)?sanity\s+check", re.I)

# Files to scan (relative to ROOT)
DOC_FILES = [
    "copilot-instructions.md",
    "README.md",
    "DEPLOYMENT.md",
    "docs/PERFORMANCE_REPORT.md",
    "docs/PRODUCTION_DATA.md",
    "docs/EAN_VALIDATION_STATUS.md",
    "docs/DATA_SOURCES.md",
    "docs/SCORING_METHODOLOGY.md",
]


def scan_file(relpath: str) -> list[CountTarget]:
    """Scan a single doc file for hard-coded counts."""
    fpath = ROOT / relpath
    if not fpath.exists():
        return []

    targets: list[CountTarget] = []
    with open(fpath, encoding="utf-8") as fh:
        for lineno, line in enumerate(fh, start=1):
            # Migration counts (skip small per-date/per-category sub-counts)
            for pat in MIGRATION_PATTERNS:
                m = pat.search(line)
                if m:
                    val = int(m.group(1))
                    if val >= MIN_MIGRATION_TOTAL:
                        targets.append(
                            CountTarget(
                                relpath,
                                lineno,
                                m.group(0).strip(),
                                "migration_count",
                                val,
                            )
                        )
            # QA suite counts
            m = QA_SUITE_PATTERN.search(line)
            if m:
                targets.append(
                    CountTarget(
                        relpath,
                        lineno,
                        m.group(0).strip(),
                        "qa_suite_count",
                        int(m.group(1)),
                    )
                )
            # QA check totals
            m = QA_CHECK_PATTERN.search(line)
            if m:
                targets.append(
                    CountTarget(
                        relpath,
                        lineno,
                        m.group(0).strip(),
                        "qa_check_total",
                        int(m.group(1)),
                    )
                )
            # Negative test counts
            m = NEGATIVE_TEST_PATTERN.search(line)
            if m:
                targets.append(
                    CountTarget(
                        relpath,
                        lineno,
                        m.group(0).strip(),
                        "negative_test_count",
                        int(m.group(1)),
                    )
                )
            # Sanity check counts
            m = SANITY_CHECK_PATTERN.search(line)
            if m:
                targets.append(
                    CountTarget(
                        relpath,
                        lineno,
                        m.group(0).strip(),
                        "sanity_check_count",
                        int(m.group(1)),
                    )
                )
    return targets


# ── Main ─────────────────────────────────────────────────────────────────


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Check documentation for stale hard-coded counts."
    )
    parser.add_argument(
        "--strict",
        action="store_true",
        help="Exit with code 1 if any filesystem-derivable count is wrong.",
    )
    args = parser.parse_args()

    # Compute actual values
    actuals: dict[str, int] = {
        "migration_count": count_migrations(),
        "qa_suite_count": count_run_qa_suites(),
        "qa_check_total": count_qa_checks_from_run_qa(),
        "negative_test_count": count_negative_tests(),
        "sanity_check_count": count_sanity_checks(),
    }

    print("=" * 64)
    print("  Documentation Count Checker")
    print("=" * 64)
    print()
    print("Filesystem Ground Truth:")
    print(f"  Migrations:        {actuals['migration_count']}")
    print(f"  QA suites (run):   {actuals['qa_suite_count']}")
    print(f"  QA total checks:   {actuals['qa_check_total']}")
    print(f"  Negative tests:    {actuals['negative_test_count']}")
    print(f"  Sanity checks:     {actuals['sanity_check_count']}")
    print(f"  QA files on disk:  {count_qa_suites()}")
    print(f"  Pipeline folders:  {count_pipeline_folders()}")
    print()

    # Scan all doc files
    all_targets: list[CountTarget] = []
    for relpath in DOC_FILES:
        all_targets.extend(scan_file(relpath))

    if not all_targets:
        print("No hard-coded counts found in documentation files.")
        return 0

    # Compare against actuals
    mismatches: list[CountMismatch] = []
    matches = 0

    for t in all_targets:
        actual = actuals.get(t.metric)
        if actual is None or actual < 0:
            continue
        if t.value != actual:
            mismatches.append(CountMismatch(t, actual))
        else:
            matches += 1

    # Report
    print(
        f"Scanned {len(DOC_FILES)} files, found {len(all_targets)} "
        f"hard-coded count references."
    )
    print(f"  Correct:    {matches}")
    print(f"  Mismatched: {len(mismatches)}")
    print()

    if mismatches:
        print("MISMATCHES:")
        print("-" * 64)
        for mm in mismatches:
            t = mm.target
            print(f"  {t.file}:{t.line}")
            print(f"    Found:    {t.text}  (value: {t.value})")
            print(f"    Actual:   {mm.actual}")
            print(f"    Metric:   {t.metric}")
            print()

    if not mismatches:
        print("All filesystem-derivable counts are correct.")
        return 0

    if args.strict:
        print(f"FAIL: {len(mismatches)} count(s) are stale.")
        return 1

    print(f"WARNING: {len(mismatches)} count(s) may be stale.")
    print("Run with --strict to enforce as CI gate.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
