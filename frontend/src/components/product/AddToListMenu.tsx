"use client";

// ─── AddToListMenu ──────────────────────────────────────────────────────────
// Dropdown button that lets users quickly add/remove a product from their
// lists. Shows ❤️ toggle for favorites, plus any other lists in a dropdown.
// Stops click propagation so it works inside <Link>-wrapped product rows.
//
// Uses useProductListMembership to lazily fetch which lists contain this
// product when the dropdown opens, and Zustand stores for compact badges.

import { useCallback, useEffect, useMemo, useRef, useState } from "react";
import {
  useLists,
  useAddToList,
  useRemoveFromList,
  useProductListMembership,
} from "@/hooks/use-lists";
import { useFavoritesStore } from "@/stores/favorites-store";
import { useTranslation } from "@/lib/i18n";
import type { ProductList } from "@/lib/types";

function getListIcon(listType: string, inList: boolean): string {
  switch (listType) {
    case "favorites":
      return inList ? "❤️" : "🤍";
    case "avoid":
      return inList ? "🚫" : "⭕";
    default:
      return inList ? "✅" : "➕";
  }
}

interface AddToListMenuProps {
  readonly productId: number;
  /** Compact mode: just the heart icon for favorites toggle */
  readonly compact?: boolean;
}

export function AddToListMenu({ productId, compact }: AddToListMenuProps) {
  const [open, setOpen] = useState(false);
  const ref = useRef<HTMLDivElement>(null);
  const { t } = useTranslation();

  const { data: listsResponse } = useLists();
  const addMutation = useAddToList();
  const removeMutation = useRemoveFromList();

  // Lazy load membership only when dropdown is open
  const { data: membership } = useProductListMembership(productId, open);
  const memberListIds = useMemo(
    () => new Set(membership?.list_ids ?? []),
    [membership?.list_ids],
  );

  // Zustand store for compact heart toggle
  const isFavorite = useFavoritesStore((s) => s.isFavorite(productId));

  const lists: ProductList[] = listsResponse?.lists ?? [];
  const favoritesList = lists.find((l) => l.list_type === "favorites");

  // Close dropdown on click-outside
  useEffect(() => {
    if (!open) return;
    function handleClick(e: MouseEvent) {
      if (
        ref.current &&
        e.target instanceof Node &&
        !ref.current.contains(e.target)
      ) {
        setOpen(false);
      }
    }
    document.addEventListener("mousedown", handleClick);
    return () => document.removeEventListener("mousedown", handleClick);
  }, [open]);

  const isInList = useCallback(
    (list: ProductList) => memberListIds.has(list.id),
    [memberListIds],
  );

  const toggleList = useCallback(
    (list: ProductList) => {
      if (isInList(list)) {
        removeMutation.mutate({
          listId: list.id,
          productId,
          listType: list.list_type,
        });
      } else {
        addMutation.mutate({
          listId: list.id,
          productId,
          listType: list.list_type,
        });
      }
    },
    [isInList, removeMutation, addMutation, productId],
  );

  const isBusy = addMutation.isPending || removeMutation.isPending;

  // Compact mode: just the heart icon for favorites
  if (compact && favoritesList) {
    return (
      <button
        type="button"
        disabled={isBusy}
        title={
          isFavorite
            ? t("productActions.removeFromFavorites")
            : t("productActions.addToFavorites")
        }
        aria-label={
          isFavorite
            ? t("productActions.removeFromFavorites")
            : t("productActions.addToFavorites")
        }
        className="touch-target flex-shrink-0 text-xl transition-transform hover:scale-110 disabled:opacity-50"
        onClick={(e) => {
          e.preventDefault();
          e.stopPropagation();
          if (isFavorite) {
            removeMutation.mutate({
              listId: favoritesList.id,
              productId,
              listType: "favorites",
            });
          } else {
            addMutation.mutate({
              listId: favoritesList.id,
              productId,
              listType: "favorites",
            });
          }
        }}
      >
        {isFavorite ? "❤️" : "🤍"}
      </button>
    );
  }

  return (
    <div ref={ref} className="relative flex-shrink-0">
      <button
        type="button"
        title={t("productActions.addToList")}
        aria-label={t("productActions.addToList")}
        aria-expanded={open}
        className="touch-target flex h-11 w-11 items-center justify-center rounded-full text-sm transition-colors hover:bg-surface-subtle"
        onClick={(e) => {
          e.preventDefault();
          e.stopPropagation();
          setOpen((v) => !v);
        }}
      >
        📋
      </button>

      {open && (
        <div
          className="absolute right-0 top-full z-50 mt-1 w-56 rounded-xl border border-gray-200 bg-white py-1 shadow-lg"
          role="menu"
        >
          <p className="px-3 py-1.5 text-xs font-medium text-gray-400">
            {t("productActions.yourLists")}
          </p>

          {lists.length === 0 && (
            <p className="px-3 py-2 text-sm text-gray-400">
              {t("productActions.noLists")}
            </p>
          )}

          {lists.map((list) => {
            const inList = isInList(list);
            const icon = getListIcon(list.list_type, inList);

            return (
              <button
                key={list.id}
                type="button"
                role="menuitem"
                disabled={isBusy}
                className="flex w-full items-center gap-2 px-3 py-2 text-left text-sm transition-colors hover:bg-gray-50 disabled:opacity-50"
                onClick={(e) => {
                  e.preventDefault();
                  e.stopPropagation();
                  toggleList(list);
                }}
              >
                <span className="text-base">{icon}</span>
                <span className="flex-1 truncate text-gray-700">
                  {list.name}
                </span>
                {inList && (
                  <span className="text-xs text-gray-400">
                    {t("productActions.remove")}
                  </span>
                )}
              </button>
            );
          })}
        </div>
      )}
    </div>
  );
}
