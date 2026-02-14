// ─── TanStack Query key constants and caching rules ─────────────────────────

export const queryKeys = {
  /** User preferences — invalidated after set */
  preferences: ["preferences"] as const,

  /** Product search results */
  search: (query: string, category?: string) =>
    ["search", { query, category }] as const,

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

  /** Health profiles list */
  healthProfiles: ["health-profiles"] as const,

  /** Active health profile */
  activeHealthProfile: ["active-health-profile"] as const,

  /** Product health warnings */
  healthWarnings: (productId: number) =>
    ["health-warnings", productId] as const,
} as const;

// ─── Stale time constants (ms) ──────────────────────────────────────────────

export const staleTimes = {
  /** Preferences change rarely — 5 min */
  preferences: 5 * 60 * 1000,

  /** Search results — 2 min */
  search: 2 * 60 * 1000,

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

  /** Health profiles — 5 min */
  healthProfiles: 5 * 60 * 1000,
} as const;
