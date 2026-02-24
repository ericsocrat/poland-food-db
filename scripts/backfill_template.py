"""Backfill Template — Batch data operations with registry integration.

Usage:
    python scripts/backfill_template.py --name "my_backfill_v1" --dry-run
    python scripts/backfill_template.py --name "my_backfill_v1" --batch-size 500

This is a TEMPLATE.  Copy to scripts/backfill_{name}.py and customise:
  1. BACKFILL_NAME, DESCRIPTION, SOURCE_ISSUE
  2. NEEDS_BACKFILL_QUERY (which rows to update)
  3. UPDATE_SQL (what to set)
  4. VALIDATION_QUERIES (pre/post checks)

Requirements:
  - Register in backfill_registry BEFORE execution
  - Run pre-validation
  - Execute in batches with SKIP LOCKED
  - Run post-validation
  - Update registry with final status

See docs/BACKFILL_STANDARD.md for full governance standard.
"""

from __future__ import annotations

import argparse
import os
import sys
import time

# ---------------------------------------------------------------------------
# Configuration — EDIT THESE for your backfill
# ---------------------------------------------------------------------------

BACKFILL_NAME = "template_backfill_v1"
DESCRIPTION = "Template backfill — replace with your description"
SOURCE_ISSUE = "#000"
DEFAULT_BATCH_SIZE = 1000
PAUSE_SECONDS = 0.1  # Pause between batches to reduce lock contention

# SQL: count rows that need backfilling
COUNT_QUERY = """
SELECT count(*) FROM products
WHERE 1 = 0;  -- REPLACE: your needs-backfill condition
"""

# SQL: batched update (must include FOR UPDATE SKIP LOCKED)
# Use $1 for batch_size parameter
BATCH_UPDATE_SQL = """
WITH batch AS (
    SELECT product_id
    FROM products
    WHERE 1 = 0  -- REPLACE: your needs-backfill condition
    ORDER BY product_id
    LIMIT $1
    FOR UPDATE SKIP LOCKED
)
UPDATE products p
SET    updated_at = now()  -- REPLACE: your actual column updates
FROM   batch b
WHERE  p.product_id = b.product_id;
"""

# SQL: pre-validation (run before backfill, results printed)
PRE_VALIDATION_SQL = """
SELECT
    count(*) AS total_rows,
    count(*) FILTER (WHERE 1 = 0) AS needs_backfill  -- REPLACE
FROM products;
"""

# SQL: post-validation (run after backfill, results printed)
POST_VALIDATION_SQL = """
SELECT
    count(*) AS total_rows,
    count(*) FILTER (WHERE 1 = 0) AS still_needs_backfill  -- REPLACE: should be 0
FROM products;
"""

# SQL: rollback (stored in registry, executed manually if needed)
ROLLBACK_SQL = """
-- REPLACE: SQL to undo this backfill
-- Example: UPDATE products SET target_column = NULL WHERE target_column IS NOT NULL;
"""

# ---------------------------------------------------------------------------
# Implementation — typically no edits needed below
# ---------------------------------------------------------------------------

def get_db_url() -> str:
    """Get database URL from environment or use local default."""
    return os.environ.get(
        "DATABASE_URL",
        "postgresql://postgres:postgres@127.0.0.1:54322/postgres",
    )


def run_backfill(batch_size: int, dry_run: bool) -> None:
    """Execute the backfill with registry tracking."""
    try:
        import psycopg2  # type: ignore[import-untyped]
    except ImportError:
        print("ERROR: psycopg2 not installed. Run: pip install psycopg2-binary")
        sys.exit(1)

    db_url = get_db_url()
    conn = psycopg2.connect(db_url)
    conn.autocommit = True

    try:
        cur = conn.cursor()

        # 1. Count rows to process
        cur.execute(COUNT_QUERY)
        rows_expected = cur.fetchone()[0]
        print(f"Rows to backfill: {rows_expected}")

        if rows_expected == 0:
            print("Nothing to backfill. Exiting.")
            return

        if dry_run:
            print(f"DRY RUN: Would process {rows_expected} rows in batches of {batch_size}")
            print(f"Estimated batches: {(rows_expected + batch_size - 1) // batch_size}")
            return

        # 2. Register backfill
        cur.execute(
            "SELECT register_backfill(%s, %s, %s, %s, %s, %s, %s)",
            (
                BACKFILL_NAME,
                DESCRIPTION,
                SOURCE_ISSUE,
                rows_expected,
                batch_size,
                ROLLBACK_SQL.strip(),
                os.environ.get("GITHUB_ACTOR", "local"),
            ),
        )
        backfill_id = cur.fetchone()[0]
        print(f"Registered backfill: {backfill_id}")

        # 3. Pre-validation
        print("\n--- Pre-validation ---")
        cur.execute(PRE_VALIDATION_SQL)
        cols = [desc[0] for desc in cur.description]
        row = cur.fetchone()
        for col, val in zip(cols, row):
            print(f"  {col}: {val}")

        # 4. Start backfill
        cur.execute("SELECT start_backfill(%s)", (backfill_id,))
        total_processed = 0
        batch_num = 0
        start_time = time.time()

        # 5. Execute in batches
        while True:
            cur.execute(BATCH_UPDATE_SQL, (batch_size,))
            affected = cur.rowcount
            if affected == 0:
                break

            batch_num += 1
            total_processed += affected
            elapsed = time.time() - start_time
            pct = (total_processed / rows_expected * 100) if rows_expected > 0 else 0
            print(
                f"  Batch {batch_num}: +{affected} rows "
                f"({total_processed}/{rows_expected} = {pct:.1f}%) "
                f"[{elapsed:.1f}s]"
            )

            # Update registry progress
            cur.execute(
                "SELECT update_backfill_progress(%s, %s)",
                (backfill_id, total_processed),
            )

            time.sleep(PAUSE_SECONDS)

        elapsed = time.time() - start_time
        print(f"\nBackfill complete: {total_processed} rows in {elapsed:.1f}s")

        # 6. Post-validation
        print("\n--- Post-validation ---")
        cur.execute(POST_VALIDATION_SQL)
        cols = [desc[0] for desc in cur.description]
        row = cur.fetchone()
        validation_ok = True
        for col, val in zip(cols, row):
            print(f"  {col}: {val}")
            if col == "still_needs_backfill" and val > 0:
                validation_ok = False

        # 7. Complete backfill
        cur.execute(
            "SELECT complete_backfill(%s, %s, %s)",
            (backfill_id, total_processed, validation_ok),
        )
        status = "PASSED" if validation_ok else "FAILED"
        print(f"\nValidation: {status}")
        print(f"Registry updated: {backfill_id}")

    except Exception as exc:
        print(f"\nERROR: {exc}")
        # Try to mark as failed
        try:
            cur.execute(
                "SELECT fail_backfill(%s, %s)",
                (backfill_id, str(exc)[:500]),
            )
        except Exception:
            pass
        sys.exit(1)
    finally:
        conn.close()


def main() -> None:
    parser = argparse.ArgumentParser(description="Run a registered backfill operation")
    parser.add_argument(
        "--name",
        default=BACKFILL_NAME,
        help=f"Backfill name (default: {BACKFILL_NAME})",
    )
    parser.add_argument(
        "--batch-size",
        type=int,
        default=DEFAULT_BATCH_SIZE,
        help=f"Rows per batch (default: {DEFAULT_BATCH_SIZE})",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Count rows and estimate work without executing",
    )
    args = parser.parse_args()

    print(f"Backfill: {args.name}")
    print(f"Batch size: {args.batch_size}")
    print(f"Dry run: {args.dry_run}")
    print(f"DB: {get_db_url().split('@')[1] if '@' in get_db_url() else 'local'}")
    print()

    run_backfill(args.batch_size, args.dry_run)


if __name__ == "__main__":
    main()
