/**
 * RPC Contract Schemas — barrel re-export.
 *
 * Central index for all Zod RPC response contracts.
 * Import from `@/lib/rpc-contracts` to access any contract schema.
 *
 * @see Issue #179 — Schema-to-UI Contract Validation
 */

// ─── Helpers / shared fragments ─────────────────────────────────────────────
export {
  ScoreBandSchema,
  NutriGradeSchema,
  ListTypeSchema,
  WarningSeveritySchema,
  HealthConditionSchema,
  ApiVersionFragment,
} from "./helpers";

// ─── Product domain ─────────────────────────────────────────────────────────
export {
  ProductDetailContract,
  BetterAlternativesContract,
  ScoreExplanationContract,
  DataConfidenceContract,
} from "./product.contracts";

// ─── Search domain ──────────────────────────────────────────────────────────
export {
  SearchProductsContract,
  SearchAutocompleteContract,
  FilterOptionsContract,
  SavedSearchesContract,
  SearchQualityReportContract,
} from "./search.contracts";

// ─── Category domain ────────────────────────────────────────────────────────
export {
  CategoryOverviewContract,
  CategoryOverviewItemSchema,
  CategoryListingContract,
} from "./category.contracts";

// ─── Dashboard domain ───────────────────────────────────────────────────────
export {
  DashboardDataContract,
  RecentlyViewedContract,
} from "./dashboard.contracts";

// ─── Health profile domain ──────────────────────────────────────────────────
export {
  HealthProfileListContract,
  HealthProfileActiveContract,
  HealthWarningsContract,
} from "./health-profile.contracts";

// ─── Lists domain ───────────────────────────────────────────────────────────
export { ListsContract, ListItemsContract } from "./lists.contracts";

// ─── Compare domain ─────────────────────────────────────────────────────────
export { CompareContract } from "./compare.contracts";

// ─── Scan domain ────────────────────────────────────────────────────────────
export { ScanHistoryContract } from "./scan.contracts";

// ─── Provenance domain ──────────────────────────────────────────────────────
export {
  ProductProvenanceContract,
  CountryValidationContract,
  ProvenanceDashboardContract,
} from "./provenance.contracts";

// ─── User preferences domain ────────────────────────────────────────────────
export { UserPreferencesContract } from "./user.contracts";
