// ─── Zustand store for avoided product IDs ──────────────────────────────────
// Fetched once on auth, cached as a Set for O(1) badge lookups.
// Invalidated when the user mutates their Avoid list.

import { create } from "zustand";

interface AvoidStore {
  /** Set of product IDs the user is avoiding */
  avoidedIds: Set<number>;

  /** Whether the initial fetch has completed */
  loaded: boolean;

  /** Check if a product is avoided — O(1) */
  isAvoided: (productId: number) => boolean;

  /** Replace the entire set (called after fetch) */
  setAvoidedIds: (ids: number[]) => void;

  /** Add a single product to the avoid set (optimistic update) */
  addAvoided: (productId: number) => void;

  /** Remove a single product from the avoid set (optimistic update) */
  removeAvoided: (productId: number) => void;

  /** Reset store (on sign-out) */
  reset: () => void;
}

export const useAvoidStore = create<AvoidStore>((set, get) => ({
  avoidedIds: new Set(),
  loaded: false,

  isAvoided: (productId: number) => get().avoidedIds.has(productId),

  setAvoidedIds: (ids: number[]) =>
    set({ avoidedIds: new Set(ids), loaded: true }),

  addAvoided: (productId: number) =>
    set((state) => {
      const next = new Set(state.avoidedIds);
      next.add(productId);
      return { avoidedIds: next };
    }),

  removeAvoided: (productId: number) =>
    set((state) => {
      const next = new Set(state.avoidedIds);
      next.delete(productId);
      return { avoidedIds: next };
    }),

  reset: () => set({ avoidedIds: new Set(), loaded: false }),
}));
