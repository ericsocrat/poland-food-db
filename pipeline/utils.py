"""Shared utilities for the pipeline package."""

from __future__ import annotations


def slug(category: str) -> str:
    """Convert a category name to a filesystem-safe slug.

    ``'Nuts, Seeds & Legumes'`` → ``'nuts-seeds-legumes'``
    """
    return (
        category.lower()
        .replace("&", "")
        .replace(",", "")
        .replace("  ", " ")
        .strip()
        .replace(" ", "-")
    )
