// ─── Zustand store for product comparison selection ─────────────────────────
// Holds the set of product IDs selected for comparison (max 4).
// Used by CompareCheckbox, CompareFloatingButton, and ComparisonTray components.

import { create } from "zustand";

interface CompareStore {
  /** Set of product IDs selected for comparison */
  selectedIds: Set<number>;

  /** Map of product ID → display name (for ComparisonTray) */
  productNames: Map<number, string>;

  /** Maximum number of products that can be compared */
  maxItems: 4;

  /** Check if a product is selected — O(1) */
  isSelected: (productId: number) => boolean;

  /** Whether max capacity is reached */
  isFull: () => boolean;

  /** Current count of selected products */
  count: () => number;

  /** Toggle a product in/out of the selection */
  toggle: (productId: number, productName?: string) => void;

  /** Add a product to the selection (no-op if full or already selected) */
  add: (productId: number, productName?: string) => void;

  /** Remove a product from the selection */
  remove: (productId: number) => void;

  /** Clear all selections */
  clear: () => void;

  /** Get sorted array of selected IDs */
  getIds: () => number[];

  /** Get display name for a product (or "Product #ID" fallback) */
  getName: (productId: number) => string;
}

export const useCompareStore = create<CompareStore>((set, get) => ({
  selectedIds: new Set(),
  productNames: new Map(),
  maxItems: 4,

  isSelected: (productId: number) => get().selectedIds.has(productId),

  isFull: () => get().selectedIds.size >= 4,

  count: () => get().selectedIds.size,

  toggle: (productId: number, productName?: string) => {
    const state = get();
    if (state.selectedIds.has(productId)) {
      const nextIds = new Set(state.selectedIds);
      nextIds.delete(productId);
      const nextNames = new Map(state.productNames);
      nextNames.delete(productId);
      set({ selectedIds: nextIds, productNames: nextNames });
    } else if (state.selectedIds.size < 4) {
      const nextIds = new Set(state.selectedIds);
      nextIds.add(productId);
      const nextNames = new Map(state.productNames);
      if (productName) nextNames.set(productId, productName);
      set({ selectedIds: nextIds, productNames: nextNames });
    }
  },

  add: (productId: number, productName?: string) =>
    set((state) => {
      if (state.selectedIds.has(productId) || state.selectedIds.size >= 4) {
        return state;
      }
      const nextIds = new Set(state.selectedIds);
      nextIds.add(productId);
      const nextNames = new Map(state.productNames);
      if (productName) nextNames.set(productId, productName);
      return { selectedIds: nextIds, productNames: nextNames };
    }),

  remove: (productId: number) =>
    set((state) => {
      if (!state.selectedIds.has(productId)) return state;
      const nextIds = new Set(state.selectedIds);
      nextIds.delete(productId);
      const nextNames = new Map(state.productNames);
      nextNames.delete(productId);
      return { selectedIds: nextIds, productNames: nextNames };
    }),

  clear: () => set({ selectedIds: new Set(), productNames: new Map() }),

  getIds: () => [...get().selectedIds].sort((a, b) => a - b),

  getName: (productId: number) =>
    get().productNames.get(productId) ?? `Product #${productId}`,
}));
