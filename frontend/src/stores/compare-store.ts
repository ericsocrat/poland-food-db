// ─── Zustand store for product comparison selection ─────────────────────────
// Holds the set of product IDs selected for comparison (max 4).
// Used by CompareCheckbox and CompareFloatingButton components.

import { create } from "zustand";

interface CompareStore {
  /** Set of product IDs selected for comparison */
  selectedIds: Set<number>;

  /** Maximum number of products that can be compared */
  maxItems: 4;

  /** Check if a product is selected — O(1) */
  isSelected: (productId: number) => boolean;

  /** Whether max capacity is reached */
  isFull: () => boolean;

  /** Current count of selected products */
  count: () => number;

  /** Toggle a product in/out of the selection */
  toggle: (productId: number) => void;

  /** Add a product to the selection (no-op if full or already selected) */
  add: (productId: number) => void;

  /** Remove a product from the selection */
  remove: (productId: number) => void;

  /** Clear all selections */
  clear: () => void;

  /** Get sorted array of selected IDs */
  getIds: () => number[];
}

export const useCompareStore = create<CompareStore>((set, get) => ({
  selectedIds: new Set(),
  maxItems: 4,

  isSelected: (productId: number) => get().selectedIds.has(productId),

  isFull: () => get().selectedIds.size >= 4,

  count: () => get().selectedIds.size,

  toggle: (productId: number) => {
    const state = get();
    if (state.selectedIds.has(productId)) {
      const next = new Set(state.selectedIds);
      next.delete(productId);
      set({ selectedIds: next });
    } else if (state.selectedIds.size < 4) {
      const next = new Set(state.selectedIds);
      next.add(productId);
      set({ selectedIds: next });
    }
  },

  add: (productId: number) =>
    set((state) => {
      if (state.selectedIds.has(productId) || state.selectedIds.size >= 4) {
        return state;
      }
      const next = new Set(state.selectedIds);
      next.add(productId);
      return { selectedIds: next };
    }),

  remove: (productId: number) =>
    set((state) => {
      if (!state.selectedIds.has(productId)) return state;
      const next = new Set(state.selectedIds);
      next.delete(productId);
      return { selectedIds: next };
    }),

  clear: () => set({ selectedIds: new Set() }),

  getIds: () => [...get().selectedIds].sort((a, b) => a - b),
}));
