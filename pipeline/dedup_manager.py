"""Cross-source deduplication manager for multi-source product ingestion.

Designed for the 10K-scale expansion where products may arrive from
multiple sources (OFF API, CSV imports, scrapers, user submissions).

Source priority (highest wins):
    1. off_api  — Open Food Facts API (primary, most structured)
    2. csv_import — Curated CSV spreadsheets
    3. scraper   — Automated web scrapers
    4. user_submission — Community-submitted products

Usage::

    from pipeline.dedup_manager import DedupManager

    mgr = DedupManager()
    merged = mgr.merge(existing_product, incoming_product)
    winner = mgr.pick_winner(candidates)
"""

from __future__ import annotations

from dataclasses import dataclass, field
from enum import IntEnum


class SourcePriority(IntEnum):
    """Source priority — lower numeric value = higher trust."""

    OFF_API = 1
    CSV_IMPORT = 2
    SCRAPER = 3
    USER_SUBMISSION = 4


# Map DB source_type values to priority enum
_SOURCE_MAP: dict[str, SourcePriority] = {
    "off_api": SourcePriority.OFF_API,
    "csv_import": SourcePriority.CSV_IMPORT,
    "off_search": SourcePriority.SCRAPER,
    "scraper": SourcePriority.SCRAPER,
    "user_submission": SourcePriority.USER_SUBMISSION,
}


@dataclass
class MergeResult:
    """Result of merging two product records."""

    product: dict
    source_used: str
    fields_from_secondary: list[str] = field(default_factory=list)


class DedupManager:
    """Cross-source deduplication and merge manager.

    Determines which product record wins when the same product arrives
    from multiple sources, and optionally fills gaps from lower-priority
    sources.
    """

    # Nutrition fields that can be back-filled from a secondary source
    # when the primary source has NULL / 0 values.
    _BACKFILL_FIELDS: tuple[str, ...] = (
        "calories",
        "total_fat",
        "saturated_fat",
        "carbs",
        "sugars",
        "protein",
        "fiber",
        "salt",
        "trans_fat",
    )

    # Identity fields — never overwritten by a secondary source.
    _IDENTITY_FIELDS: tuple[str, ...] = (
        "product_name",
        "brand",
        "ean",
        "country",
        "category",
    )

    @staticmethod
    def priority(source_type: str) -> SourcePriority:
        """Return the priority for a given source_type string."""
        return _SOURCE_MAP.get(source_type, SourcePriority.USER_SUBMISSION)

    def pick_winner(self, candidates: list[dict]) -> dict:
        """Pick the highest-priority product from a list of candidates.

        When two candidates share the same source priority, the one with
        more non-NULL nutrition fields wins.
        """
        if not candidates:
            raise ValueError("candidates list must not be empty")
        if len(candidates) == 1:
            return candidates[0]

        def _sort_key(p: dict) -> tuple[int, int]:
            pri = self.priority(p.get("source_type", ""))
            # Count non-null nutrition fields (more = better, so negate)
            filled = sum(1 for f in self._BACKFILL_FIELDS if p.get(f) is not None and p.get(f) != 0)
            return (pri.value, -filled)

        return min(candidates, key=_sort_key)

    def merge(self, primary: dict, secondary: dict) -> MergeResult:
        """Merge two product records, using *primary* as the base.

        Fields from *secondary* are only used to fill gaps (NULL or 0)
        in the primary record's nutrition columns.  Identity fields are
        never overwritten.
        """
        merged = dict(primary)
        backfilled: list[str] = []

        for fld in self._BACKFILL_FIELDS:
            primary_val = primary.get(fld)
            secondary_val = secondary.get(fld)
            if (primary_val is None or primary_val == 0) and secondary_val:
                merged[fld] = secondary_val
                backfilled.append(fld)

        return MergeResult(
            product=merged,
            source_used=primary.get("source_type", "unknown"),
            fields_from_secondary=backfilled,
        )

    def deduplicate(self, products: list[dict], key_fn=None) -> list[dict]:
        """Deduplicate a list of products, keeping the highest-priority version.

        Parameters
        ----------
        products:
            List of product dicts (must have ``brand``, ``product_name``,
            and optionally ``source_type``).
        key_fn:
            Optional callable to compute the dedup key from a product dict.
            Defaults to ``(brand.lower().strip(), product_name.lower().strip())``.

        Returns
        -------
        list
            Deduplicated products with secondary-source gap-filling applied.
        """
        if key_fn is None:

            def key_fn(p: dict) -> tuple[str, str]:
                return (
                    p.get("brand", "").lower().strip(),
                    p.get("product_name", "").lower().strip(),
                )

        groups: dict[tuple, list[dict]] = {}
        for p in products:
            k = key_fn(p)
            groups.setdefault(k, []).append(p)

        results: list[dict] = []
        for group in groups.values():
            if len(group) == 1:
                results.append(group[0])
                continue
            winner = self.pick_winner(group)
            for other in group:
                if other is not winner:
                    merge_result = self.merge(winner, other)
                    winner = merge_result.product
            results.append(winner)

        return results
