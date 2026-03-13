"""Full data refresh orchestrator.

Sequences the pipeline for all categories in a country:
  1. pipeline.run → fetch from OFF API → generate SQL files
  2. Execute generated SQL against target DB
  3. enrich_ingredients → generate enrichment SQL
  4. Execute enrichment SQL
  5. CALL score_category('CategoryName') via psql
  6. Log results to JSON report

Usage::

    python -m pipeline.orchestrate --country PL --max-products 100
    python -m pipeline.orchestrate --country DE --max-products 100
    python -m pipeline.orchestrate --category "Dairy" --country PL
    python -m pipeline.orchestrate --dry-run
    python -m pipeline.orchestrate --stale-only --stale-days 90
"""

from __future__ import annotations

import argparse
import json
import logging
import os
import subprocess
import sys
import time
from datetime import UTC, datetime
from pathlib import Path

from pipeline.categories import CATEGORY_SEARCH_TERMS
from pipeline.run import run_pipeline
from pipeline.utils import slug as _slug

logger = logging.getLogger(__name__)

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

PROJECT_ROOT = Path(__file__).resolve().parent.parent
PIPELINE_DIR = PROJECT_ROOT / "db" / "pipelines"
REPORTS_DIR = PROJECT_ROOT / "pipeline" / "reports"
ENRICH_SCRIPT = PROJECT_ROOT / "enrich_ingredients.py"

DB_CONTAINER = "supabase_db_tryvit"
DB_USER = "postgres"
DB_NAME = "postgres"

_COUNTRY_OFF_NAME: dict[str, str] = {"PL": "poland", "DE": "germany"}
SUPPORTED_COUNTRIES = list(_COUNTRY_OFF_NAME)

# Stale product cap: max EANs to re-fetch per category per run.
STALE_BATCH_LIMIT = 50


# ---------------------------------------------------------------------------
# DB helpers
# ---------------------------------------------------------------------------


def _psql_cmd(query: str) -> list[str]:
    """Build psql command — CI mode (DATABASE_URL set) uses psql directly,
    local mode uses docker exec into the Supabase container."""
    db_url = os.environ.get("DATABASE_URL")
    if db_url:
        return ["psql", db_url, "-t", "-A", "-F", "|", "-c", query]
    return [
        "docker",
        "exec",
        DB_CONTAINER,
        "psql",
        "-U",
        DB_USER,
        "-d",
        DB_NAME,
        "-t",
        "-A",
        "-F",
        "|",
        "-c",
        query,
    ]


def _run_psql(query: str) -> str:
    """Execute a psql query and return stdout."""
    cmd = _psql_cmd(query)
    result = subprocess.run(cmd, capture_output=True, text=True, check=True)
    return result.stdout.strip()


def _execute_sql_file(filepath: Path) -> None:
    """Execute a single SQL file against the database."""
    db_url = os.environ.get("DATABASE_URL")
    if db_url:
        cmd = ["psql", db_url, "-f", str(filepath)]
    else:
        # Read file content and pipe via docker exec
        sql = filepath.read_text(encoding="utf-8")
        cmd = [
            "docker",
            "exec",
            "-i",
            DB_CONTAINER,
            "psql",
            "-U",
            DB_USER,
            "-d",
            DB_NAME,
        ]
        subprocess.run(
            cmd,
            input=sql,
            capture_output=True,
            text=True,
            check=True,
        )
        return
    subprocess.run(cmd, capture_output=True, text=True, check=True)


# ---------------------------------------------------------------------------
# Orchestrator
# ---------------------------------------------------------------------------


class PipelineOrchestrator:
    """Coordinates pipeline runs across categories for a single country."""

    def __init__(
        self,
        country: str,
        categories: list[str] | None = None,
        max_products: int = 100,
        stale_days: int = 90,
        dry_run: bool = False,
        stale_only: bool = False,
    ) -> None:
        self.country = country.upper()
        self.max_products = max_products
        self.stale_days = stale_days
        self.dry_run = dry_run
        self.stale_only = stale_only

        # Resolve category list — default to all categories in CATEGORY_SEARCH_TERMS.
        if categories:
            unknown = [c for c in categories if c not in CATEGORY_SEARCH_TERMS]
            if unknown:
                msg = f"Unknown categories: {', '.join(unknown)}"
                raise ValueError(msg)
            self.categories = categories
        else:
            self.categories = sorted(CATEGORY_SEARCH_TERMS.keys())

        # Report accumulator
        self._report: dict = {
            "run_id": datetime.now(tz=UTC).isoformat(),
            "country": self.country,
            "dry_run": self.dry_run,
            "stale_only": self.stale_only,
            "categories_processed": 0,
            "products_added": 0,
            "products_updated": 0,
            "products_enriched": 0,
            "products_scored": 0,
            "stale_products_refreshed": 0,
            "duration_seconds": 0,
            "errors": [],
            "warnings": [],
            "category_results": [],
        }

    # -- public API ----------------------------------------------------------

    def run_all(self) -> dict:
        """Run the full refresh for all configured categories.

        Returns the execution report dict.
        """
        start = time.monotonic()
        print(f"\n{'='*60}")
        print("  TryVit — Data Refresh Orchestrator")
        print(f"  Country:  {self.country}")
        print(f"  Mode:     {'DRY RUN' if self.dry_run else 'LIVE'}")
        print(f"  Categories: {len(self.categories)}")
        if self.stale_only:
            print(f"  Stale-only: products older than {self.stale_days} days")
        print(f"{'='*60}\n")

        for i, category in enumerate(self.categories, 1):
            print(f"\n[{i}/{len(self.categories)}] {category}")
            print("-" * 40)
            cat_result = self.run_category(category)
            self._report["category_results"].append(cat_result)
            self._report["categories_processed"] += 1

        self._report["duration_seconds"] = round(time.monotonic() - start, 1)

        # Write report
        report_path = self._write_report()
        self._print_summary(report_path)
        return self._report

    def run_category(self, category: str) -> dict:
        """Run the full pipeline for one category.

        Returns a per-category result dict.
        """
        result: dict = {
            "category": category,
            "status": "success",
            "products_fetched": 0,
            "sql_files_executed": 0,
            "enriched": False,
            "scored": False,
            "stale_count": 0,
            "error": None,
        }

        try:
            # Phase 1: Detect stale products (informational)
            if not self.dry_run:
                stale_count = self._detect_stale_products(category)
                result["stale_count"] = stale_count
                if stale_count:
                    print(f"  Stale products: {stale_count}")
                    self._report["stale_products_refreshed"] += stale_count

                if self.stale_only and stale_count == 0:
                    print("  No stale products — skipping")
                    result["status"] = "skipped"
                    return result

            # Phase 2: Run pipeline (fetch from OFF API → generate SQL)
            slug_base = _slug(category)
            dir_slug = f"{slug_base}-{self.country.lower()}" if self.country != "PL" else slug_base

            print("  Fetching from OFF API...")
            run_pipeline(
                category=category,
                max_products=self.max_products,
                dry_run=self.dry_run,
                country=self.country,
            )

            if self.dry_run:
                result["status"] = "dry_run"
                return result

            # Phase 3: Execute generated SQL files
            output_dir = PIPELINE_DIR / dir_slug
            sql_count = self._execute_sql_files(output_dir)
            result["sql_files_executed"] = sql_count
            print(f"  Executed {sql_count} SQL files")

            # Phase 4: Enrich ingredients/allergens
            try:
                self._enrich_category(category)
                result["enriched"] = True
                print("  Enrichment complete")
            except Exception as exc:
                msg = f"{category}: enrichment failed — {exc}"
                logger.warning(msg)
                self._report["warnings"].append(msg)
                print(f"  Enrichment skipped (error: {exc})")

            # Phase 5: Score category
            self._score_category(category)
            result["scored"] = True
            self._report["products_scored"] += 1
            print("  Scoring complete")

        except Exception as exc:
            result["status"] = "error"
            result["error"] = str(exc)
            msg = f"{category}: {exc}"
            logger.error(msg)
            self._report["errors"].append(msg)
            print(f"  ERROR: {exc}")

        return result

    # -- internal methods ----------------------------------------------------

    def _detect_stale_products(self, category: str) -> int:
        """Count products older than stale_days in this category."""
        try:
            count_str = _run_psql(
                f"SELECT COUNT(*) FROM products "
                f"WHERE category = '{category}' AND country = '{self.country}' "
                f"AND is_deprecated IS NOT TRUE AND ean IS NOT NULL "
                f"AND (last_fetched_at IS NULL "
                f"OR last_fetched_at < NOW() - INTERVAL '{self.stale_days} days') "
                f"LIMIT 1;"
            )
            return int(count_str) if count_str else 0
        except (subprocess.CalledProcessError, ValueError):
            return 0

    def _execute_sql_files(self, folder: Path) -> int:
        """Execute all pipeline SQL files in a folder in sorted order.

        Returns the number of files executed.
        """
        if not folder.is_dir():
            return 0

        sql_files = sorted(folder.glob("PIPELINE__*.sql"))
        for sql_file in sql_files:
            _execute_sql_file(sql_file)
        return len(sql_files)

    def _enrich_category(self, category: str) -> None:
        """Run enrich_ingredients.py for the category's country."""
        if not ENRICH_SCRIPT.is_file():
            msg = f"Enrichment script not found: {ENRICH_SCRIPT}"
            raise FileNotFoundError(msg)

        cmd = [
            sys.executable,
            str(ENRICH_SCRIPT),
            "--country",
            self.country,
        ]
        subprocess.run(cmd, capture_output=True, text=True, check=True)

    def _score_category(self, category: str) -> None:
        """CALL score_category('CategoryName') via psql."""
        _run_psql(f"CALL score_category('{category}');")

    # -- reporting -----------------------------------------------------------

    def _write_report(self) -> Path:
        """Write JSON execution report to pipeline/reports/."""
        REPORTS_DIR.mkdir(parents=True, exist_ok=True)
        ts = datetime.now(tz=UTC).strftime("%Y%m%d_%H%M%S")
        filename = f"refresh_{self.country}_{ts}.json"
        path = REPORTS_DIR / filename
        path.write_text(json.dumps(self._report, indent=2), encoding="utf-8")
        return path

    def _print_summary(self, report_path: Path) -> None:
        """Print a human-readable summary after the run."""
        r = self._report
        print(f"\n{'='*60}")
        print("  Data Refresh Summary")
        print(f"{'='*60}")
        print(f"  Country:    {r['country']}")
        print(f"  Mode:       {'DRY RUN' if r['dry_run'] else 'LIVE'}")
        print(f"  Categories: {r['categories_processed']}")
        print(f"  Duration:   {r['duration_seconds']}s")

        success = sum(1 for c in r["category_results"] if c["status"] == "success")
        errors = sum(1 for c in r["category_results"] if c["status"] == "error")
        skipped = sum(1 for c in r["category_results"] if c["status"] in ("skipped", "dry_run"))
        print(f"  Success:    {success}  |  Errors: {errors}  |  Skipped: {skipped}")

        if r["errors"]:
            print(f"\n  ERRORS ({len(r['errors'])}):")
            for err in r["errors"]:
                print(f"    ✗ {err}")
        if r["warnings"]:
            print(f"\n  WARNINGS ({len(r['warnings'])}):")
            for w in r["warnings"]:
                print(f"    ⚠ {w}")

        print(f"\n  Report: {report_path}")
        print()


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------


def main() -> None:
    """Parse arguments and run the orchestrator."""
    parser = argparse.ArgumentParser(
        description="TryVit — Full data refresh orchestrator. "
        "Sequences pipeline runs across all categories for a country.",
    )
    parser.add_argument(
        "--country",
        default="ALL",
        help="Country to refresh: PL, DE, or ALL (default: ALL)",
    )
    parser.add_argument(
        "--category",
        default=None,
        help="Single category to refresh (e.g. 'Dairy'). If omitted, runs all.",
    )
    parser.add_argument(
        "--max-products",
        type=int,
        default=100,
        help="Maximum products per category (default: 100)",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Generate SQL but do not execute against DB",
    )
    parser.add_argument(
        "--stale-only",
        action="store_true",
        help="Only re-fetch categories with stale products",
    )
    parser.add_argument(
        "--stale-days",
        type=int,
        default=90,
        help="Products older than N days are considered stale (default: 90)",
    )

    args = parser.parse_args()

    logging.basicConfig(
        level=logging.INFO,
        format="%(levelname)s: %(message)s",
    )

    # Determine countries to process
    countries = SUPPORTED_COUNTRIES if args.country.upper() == "ALL" else [args.country.upper()]
    for c in countries:
        if c not in SUPPORTED_COUNTRIES:
            print(f"ERROR: Unsupported country '{c}'. Supported: {', '.join(SUPPORTED_COUNTRIES)}")
            sys.exit(1)

    # Resolve category filter
    categories = [args.category] if args.category else None

    all_reports: list[dict] = []
    has_errors = False

    for country in countries:
        orchestrator = PipelineOrchestrator(
            country=country,
            categories=categories,
            max_products=args.max_products,
            stale_days=args.stale_days,
            dry_run=args.dry_run,
            stale_only=args.stale_only,
        )
        report = orchestrator.run_all()
        all_reports.append(report)
        if report["errors"]:
            has_errors = True

    if has_errors:
        sys.exit(1)


if __name__ == "__main__":
    main()
