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
    ApiVersionFragment, HealthConditionSchema, ListTypeSchema, NutriGradeSchema, ScoreBandSchema, WarningSeveritySchema
} from "./helpers";

// ─── Product domain ─────────────────────────────────────────────────────────
export {
    BetterAlternativesContract, CrossCountryLinksContract, DataConfidenceContract, ProductDetailContract, ScoreExplanationContract
} from "./product.contracts";

// ─── Search domain ──────────────────────────────────────────────────────────
export {
    FilterOptionsContract,
    SavedSearchesContract, SearchAutocompleteContract, SearchProductsContract, SearchQualityReportContract
} from "./search.contracts";

// ─── Category domain ────────────────────────────────────────────────────────
export {
    CategoryListingContract, CategoryOverviewContract,
    CategoryOverviewItemSchema
} from "./category.contracts";

// ─── Dashboard domain ───────────────────────────────────────────────────────
export {
    DashboardDataContract,
    RecentlyViewedContract
} from "./dashboard.contracts";

// ─── Health profile domain ──────────────────────────────────────────────────
export {
    HealthProfileActiveContract, HealthProfileListContract, HealthWarningsContract
} from "./health-profile.contracts";

// ─── Lists domain ───────────────────────────────────────────────────────────
export { ListItemsContract, ListsContract } from "./lists.contracts";

// ─── Compare domain ─────────────────────────────────────────────────────────
export { CompareContract } from "./compare.contracts";

// ─── Scan domain ────────────────────────────────────────────────────────────
export { ScanHistoryContract } from "./scan.contracts";

// ─── Provenance domain ──────────────────────────────────────────────────────
export {
    CountryValidationContract, ProductProvenanceContract, ProvenanceDashboardContract
} from "./provenance.contracts";

// ─── User preferences domain ────────────────────────────────────────────────
export { UserPreferencesContract } from "./user.contracts";
