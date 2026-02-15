// ─── Zustand store for favorite product IDs ─────────────────────────────────
// Mirrors the avoid-store pattern: Set-based O(1) lookups for rendering
// heart badges on product rows without per-item network calls.

import { create } from "zustand";

interface FavoritesState {
  favoriteIds: Set<number>;
  loaded: boolean;

  /** Replace the full set (called after initial fetch) */
  setFavoriteIds: (ids: number[]) => void;

  /** Add a single ID after mutation */
  addFavorite: (id: number) => void;

  /** Remove a single ID after mutation */
  removeFavorite: (id: number) => void;

  /** Reset on logout */
  reset: () => void;

  /** O(1) membership check */
  isFavorite: (id: number) => boolean;
}

export const useFavoritesStore = create<FavoritesState>((set, get) => ({
  favoriteIds: new Set<number>(),
  loaded: false,

  setFavoriteIds: (ids) =>
    set({ favoriteIds: new Set(ids), loaded: true }),

  addFavorite: (id) =>
    set((state) => {
      const next = new Set(state.favoriteIds);
      next.add(id);
      return { favoriteIds: next };
    }),

  removeFavorite: (id) =>
    set((state) => {
      const next = new Set(state.favoriteIds);
      next.delete(id);
      return { favoriteIds: next };
    }),

  reset: () =>
    set({ favoriteIds: new Set<number>(), loaded: false }),

  isFavorite: (id) => get().favoriteIds.has(id),
}));
