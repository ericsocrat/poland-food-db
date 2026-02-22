// ─── TanStack Query key constants and caching rules ─────────────────────────

import type { SearchFilters } from "@/lib/types";

export const queryKeys = {
  /** User preferences — invalidated after set */
  preferences: ["preferences"] as const,

  /** Product search results */
  search: (query: string, filters?: SearchFilters, page?: number) =>
    ["search", { query, filters, page }] as const,

  /** Autocomplete suggestions */
  autocomplete: (query: string) => ["autocomplete", query] as const,

  /** "Did you mean?" fuzzy suggestions (#62) */
  didYouMean: (query: string) => ["did-you-mean", query] as const,

  /** Filter options (category/nutri/allergen counts) */
  filterOptions: ["filter-options"] as const,

  /** Saved searches */
  savedSearches: ["saved-searches"] as const,

  /** Category listing (paginated) */
  categoryListing: (
    category: string,
    sortBy?: string,
    sortDir?: string,
    offset?: number,
  ) => ["category-listing", { category, sortBy, sortDir, offset }] as const,

  /** Category overview (dashboard) */
  categoryOverview: ["category-overview"] as const,

  /** Single product detail */
  product: (id: number) => ["product", id] as const,

  /** EAN barcode lookup */
  scan: (ean: string) => ["scan", ean] as const,

  /** Better alternatives for a product */
  alternatives: (productId: number) => ["alternatives", productId] as const,

  /** Score explanation for a product */
  scoreExplanation: (productId: number) =>
    ["score-explanation", productId] as const,

  /** Data confidence for a product */
  dataConfidence: (productId: number) =>
    ["data-confidence", productId] as const,

  /** Composite product profile (bundles detail + scores + alternatives + quality) */
  productProfile: (id: number) => ["product-profile", id] as const,

  /** Ingredient profile — deep-dive page */
  ingredientProfile: (id: number) => ["ingredient-profile", id] as const,

  /** Health profiles list */
  healthProfiles: ["health-profiles"] as const,

  /** Active health profile */
  activeHealthProfile: ["active-health-profile"] as const,

  /** Product health warnings */
  healthWarnings: (productId: number) =>
    ["health-warnings", productId] as const,

  /** User product lists */
  lists: ["lists"] as const,

  /** Items in a specific list */
  listItems: (listId: string) => ["list-items", listId] as const,

  /** Preview items for list cards (limited, for overview page) */
  listPreview: (listId: string) => ["list-preview", listId] as const,

  /** Shared list (public, by token) */
  sharedList: (token: string) => ["shared-list", token] as const,

  /** Avoided product IDs (for badge rendering) */
  avoidProductIds: ["avoid-product-ids"] as const,

  /** Favorite product IDs (for heart badge) */
  favoriteProductIds: ["favorite-product-ids"] as const,

  /** Which lists contain a specific product (for dropdown toggle state) */
  productListMembership: (productId: number) =>
    ["product-list-membership", productId] as const,

  /** Products for comparison view */
  compareProducts: (ids: number[]) =>
    ["compare-products", ids.toSorted((a, b) => a - b).join(",")] as const,

  /** User's saved comparisons */
  savedComparisons: ["saved-comparisons"] as const,

  /** Shared comparison (public, by token) */
  sharedComparison: (token: string) => ["shared-comparison", token] as const,

  /** Scan history (paginated) */
  scanHistory: (page: number, filter: string) =>
    ["scan-history", { page, filter }] as const,

  /** User's product submissions */
  mySubmissions: (page: number) => ["my-submissions", page] as const,

  /** Dashboard data (batched) */
  dashboard: ["dashboard"] as const,

  /** Dashboard health insights (Issue #63) */
  dashboardInsights: ["dashboard-insights"] as const,

  /** Recently viewed products */
  recentlyViewed: (limit?: number) =>
    ["recently-viewed", { limit }] as const,

  /** Score history for a product (Issue #38) */
  scoreHistory: (productId: number) =>
    ["score-history", productId] as const,

  /** Watchlist (Issue #38) */
  watchlist: (page?: number) =>
    ["watchlist", { page }] as const,

  /** Is user watching a specific product (Issue #38) */
  isWatching: (productId: number) =>
    ["is-watching", productId] as const,

  /** User achievements with progress (Issue #51) */
  achievements: ["achievements"] as const,

  /** Recipe browse (optionally filtered) */
  recipes: (filters?: Record<string, unknown>) =>
    ["recipes", filters ?? {}] as const,

  /** Single recipe detail by slug */
  recipe: (slug: string) => ["recipe", slug] as const,

  /** Products matching a recipe ingredient (#54) */
  ingredientProducts: (ingredientId: string) =>
    ["ingredient-products", ingredientId] as const,

  /** Admin monitoring health check (#119) */
  adminHealth: ["admin-health"] as const,

  /** Batch product allergen data (#128) */
  productAllergens: (ids: number[]) =>
    ["product-allergens", ids.toSorted((a, b) => a - b).join(",")] as const,
} as const;

// ─── Stale time constants (ms) ──────────────────────────────────────────────

export const staleTimes = {
  /** Preferences change rarely — 5 min */
  preferences: 5 * 60 * 1000,

  /** Search results — 2 min */
  search: 2 * 60 * 1000,

  /** Autocomplete — 30 sec (frequently changes) */
  autocomplete: 30 * 1000,

  /** Did-you-mean suggestions — 2 min (same as search) */
  didYouMean: 2 * 60 * 1000,

  /** Filter options — 10 min (rarely changes) */
  filterOptions: 10 * 60 * 1000,

  /** Saved searches — 5 min */
  savedSearches: 5 * 60 * 1000,

  /** Category listing — 5 min */
  categoryListing: 5 * 60 * 1000,

  /** Category overview — 10 min */
  categoryOverview: 10 * 60 * 1000,

  /** Product detail — 10 min */
  product: 10 * 60 * 1000,

  /** Scan results — 10 min */
  scan: 10 * 60 * 1000,

  /** Alternatives — 10 min */
  alternatives: 10 * 60 * 1000,

  /** Score explanation — 10 min */
  scoreExplanation: 10 * 60 * 1000,

  /** Product profile (composite) — 10 min (same as product detail) */
  productProfile: 10 * 60 * 1000,

  /** Ingredient profile — 10 min */
  ingredientProfile: 10 * 60 * 1000,

  /** Health profiles — 5 min */
  healthProfiles: 5 * 60 * 1000,

  /** Health warnings — 5 min (same as profiles, invalidated together) */
  healthWarnings: 5 * 60 * 1000,

  /** User lists — 5 min */
  lists: 5 * 60 * 1000,

  /** List items — 2 min (changes more frequently) */
  listItems: 2 * 60 * 1000,

  /** List preview — 5 min (less granular, stays fresh longer) */
  listPreview: 5 * 60 * 1000,

  /** Shared list — 5 min */
  sharedList: 5 * 60 * 1000,

  /** Avoid product IDs — 10 min (fetched once, invalidated on mutation) */
  avoidProductIds: 10 * 60 * 1000,

  /** Favorite product IDs — 10 min (same pattern as avoid) */
  favoriteProductIds: 10 * 60 * 1000,

  /** Product list membership — 2 min (fetched per dropdown) */
  productListMembership: 2 * 60 * 1000,

  /** Comparison products — 5 min (bounded data, max 4 products) */
  compareProducts: 5 * 60 * 1000,

  /** Saved comparisons — 5 min */
  savedComparisons: 5 * 60 * 1000,

  /** Shared comparison — 5 min */
  sharedComparison: 5 * 60 * 1000,

  /** Scan history — 2 min */
  scanHistory: 2 * 60 * 1000,

  /** User submissions — 5 min */
  mySubmissions: 5 * 60 * 1000,

  /** Dashboard data — 2 min (aggregated, changes frequently) */
  dashboard: 2 * 60 * 1000,

  /** Dashboard insights — 5 min (aggregated health stats) */
  dashboardInsights: 5 * 60 * 1000,

  /** Recently viewed — 1 min (updates on every product view) */
  recentlyViewed: 60 * 1000,

  /** Score history — 10 min (changes only on pipeline runs) */
  scoreHistory: 10 * 60 * 1000,

  /** Watchlist — 2 min (user may add/remove frequently) */
  watchlist: 2 * 60 * 1000,

  /** Is watching — 5 min (changes on user action) */
  isWatching: 5 * 60 * 1000,

  /** Achievements — 5 min (changes on user action) */
  achievements: 5 * 60 * 1000,

  /** Recipe browse — 10 min (curated, changes rarely) */
  recipes: 10 * 60 * 1000,

  /** Recipe detail — 10 min (curated, changes rarely) */
  recipe: 10 * 60 * 1000,

  /** Ingredient→product matches — 10 min (curated links, changes rarely) */
  ingredientProducts: 10 * 60 * 1000,

  /** Admin health check — 30 sec (auto-refresh every 60s, but allow re-fetch) */
  adminHealth: 30 * 1000,

  /** Product allergens — 5 min (allergen data changes only on pipeline runs) */
  productAllergens: 5 * 60 * 1000,
} as const;
