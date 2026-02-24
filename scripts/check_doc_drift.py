"""
Documentation Freshness Checker — Drift Detection Automation (#199)

Scans all .md files in the docs/ directory and checks whether they have been
updated within a configurable threshold (default: 90 days). This helps detect
documentation drift — when code changes but docs remain stale.

Usage:
    python scripts/check_doc_drift.py              # Default 90-day threshold
    python scripts/check_doc_drift.py --max-age 60 # Custom threshold
    python scripts/check_doc_drift.py --warn-only   # Exit 0 even if stale

Exit codes:
    0 — All documents within freshness threshold (or --warn-only)
    1 — Stale documents detected

Designed for both local use and CI integration.
"""

import argparse
import os
import subprocess
import sys
from datetime import datetime, timezone


def get_last_commit_date(filepath: str) -> datetime | None:
    """Get the date of the most recent git commit that touched this file."""
    try:
        result = subprocess.run(
            ["git", "log", "-1", "--format=%cI", filepath],
            capture_output=True,
            text=True,
            timeout=10,
        )
        date_str = result.stdout.strip()
        if not date_str:
            return None
        return datetime.fromisoformat(date_str)
    except (subprocess.TimeoutExpired, ValueError):
        return None


def check_docs_freshness(
    docs_dir: str = "docs",
    max_age_days: int = 90,
) -> list[tuple[str, int]]:
    """
    Check all .md files in docs_dir for staleness.

    Returns a list of (filepath, age_days) tuples for stale files.
    """
    stale: list[tuple[str, int]] = []
    now = datetime.now(timezone.utc)

    if not os.path.isdir(docs_dir):
        print(f"Warning: docs directory '{docs_dir}' not found", file=sys.stderr)
        return stale

    for root, _, files in os.walk(docs_dir):
        for filename in sorted(files):
            if not filename.endswith(".md"):
                continue

            filepath = os.path.join(root, filename)
            last_commit = get_last_commit_date(filepath)

            if last_commit is None:
                # File not tracked by git or no commits — skip
                continue

            age_days = (now - last_commit).days
            if age_days > max_age_days:
                stale.append((filepath, age_days))

    return sorted(stale, key=lambda x: -x[1])  # Most stale first


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Check documentation freshness (drift detection)"
    )
    parser.add_argument(
        "--max-age",
        type=int,
        default=90,
        help="Maximum allowed age in days (default: 90)",
    )
    parser.add_argument(
        "--docs-dir",
        type=str,
        default="docs",
        help="Directory to scan (default: docs)",
    )
    parser.add_argument(
        "--warn-only",
        action="store_true",
        help="Print warnings but exit 0 regardless",
    )
    args = parser.parse_args()

    stale = check_docs_freshness(args.docs_dir, args.max_age)

    if not stale:
        total = sum(
            1
            for _, _, files in os.walk(args.docs_dir)
            for f in files
            if f.endswith(".md")
        )
        print(
            f"OK  All {total} documents in {args.docs_dir}/ "
            f"updated within {args.max_age} days"
        )
        return 0

    print(f"STALE DOCUMENTS DETECTED ({len(stale)} files):")
    print(f"  Threshold: {args.max_age} days")
    print()
    for filepath, age in stale:
        print(f"  {filepath}: {age} days since last update")

    if args.warn_only:
        print()
        print("  (--warn-only: exiting with code 0)")
        return 0

    return 1


if __name__ == "__main__":
    sys.exit(main())
