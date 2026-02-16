// ─── TypeScript interfaces matching backend RPC response shapes ─────────────

// ─── Utility types ──────────────────────────────────────────────────────────

/** Minimal form-event type — prevents tight coupling to React.FormEvent. */
export type FormSubmitEvent = { preventDefault: () => void };

/** Nullable cell value used in comparison grids. */
export type CellValue = number | string | null;

// ─── Common ─────────────────────────────────────────────────────────────────

export interface ApiError {
  api_version: string;
  error: string;
}

// ─── RPC wrapper result ─────────────────────────────────────────────────────

export type RpcResult<T> =
  | { ok: true; data: T }
  | { ok: false; error: { code: string; message: string } };

// ─── User Preferences ──────────────────────────────────────────────────────

export interface UserPreferences {
  api_version: string;
  user_id: string;
  country: string | null;
  preferred_language: string;
  diet_preference: string | null;
  avoid_allergens: string[];
  strict_allergen: boolean;
  strict_diet: boolean;
  treat_may_contain_as_unsafe: boolean;
  onboarding_complete: boolean;
  created_at: string;
  updated_at: string;
}

// ─── Search ─────────────────────────────────────────────────────────────────

export interface SearchFilters {
  category?: string[];
  nutri_score?: string[];
  allergen_free?: string[];
  max_unhealthiness?: number;
  country?: string;
  sort_by?: 'relevance' | 'name' | 'unhealthiness' | 'nutri_score' | 'calories';
  sort_order?: 'asc' | 'desc';
}

export interface SearchResult {
  product_id: number;
  product_name: string;
  product_name_en: string | null;
  product_name_display: string;
  brand: string;
  category: string;
  category_display: string;
  category_icon: string;
  unhealthiness_score: number;
  score_band: ScoreBand;
  nutri_score: NutriGrade;
  nova_group: string;
  calories: number | null;
  high_salt: boolean;
  high_sugar: boolean;
  high_sat_fat: boolean;
  high_additive_load: boolean;
  is_avoided: boolean;
  relevance: number;
}

export interface SearchResponse {
  api_version: string;
  query: string | null;
  country: string;
  total: number;
  page: number;
  pages: number;
  page_size: number;
  filters_applied: SearchFilters;
  results: SearchResult[];
}

// ─── Autocomplete ───────────────────────────────────────────────────────────

export interface AutocompleteSuggestion {
  product_id: number;
  product_name: string;
  product_name_en: string | null;
  product_name_display: string;
  brand: string;
  category: string;
  nutri_score: NutriGrade;
  unhealthiness_score: number;
  score_band: ScoreBand;
}

export interface AutocompleteResponse {
  api_version: string;
  query: string;
  suggestions: AutocompleteSuggestion[];
}

// ─── Filter Options ─────────────────────────────────────────────────────────

export interface FilterCategoryOption {
  category: string;
  display_name: string;
  icon_emoji: string;
  count: number;
}

export interface FilterNutriOption {
  label: string;
  count: number;
}

export interface FilterAllergenOption {
  tag: string;
  count: number;
}

export interface FilterOptionsResponse {
  api_version: string;
  country: string;
  categories: FilterCategoryOption[];
  nutri_scores: FilterNutriOption[];
  allergens: FilterAllergenOption[];
}

// ─── Saved Searches ─────────────────────────────────────────────────────────

export interface SavedSearch {
  id: string;
  name: string;
  query: string | null;
  filters: SearchFilters;
  created_at: string;
}

export interface SavedSearchesResponse {
  api_version: string;
  searches: SavedSearch[];
}

export interface SaveSearchResponse {
  api_version: string;
  id: string;
  name: string;
  created: boolean;
}

export interface DeleteSavedSearchResponse {
  api_version: string;
  success: boolean;
  deleted: boolean;
}

// ─── Category Listing ───────────────────────────────────────────────────────

export interface CategoryProduct {
  product_id: number;
  ean: string | null;
  product_name: string;
  brand: string;
  unhealthiness_score: number;
  score_band: ScoreBand;
  nutri_score: NutriGrade;
  nova_group: string;
  processing_risk: string;
  calories: number;
  total_fat_g: number;
  protein_g: number;
  sugars_g: number;
  salt_g: number;
  high_salt_flag: boolean;
  high_sugar_flag: boolean;
  high_sat_fat_flag: boolean;
  confidence: string;
  data_completeness_pct: number;
}

export interface CategoryListingResponse {
  api_version: string;
  category: string;
  country: string;
  total_count: number;
  limit: number;
  offset: number;
  sort_by: string;
  sort_dir: string;
  products: CategoryProduct[];
}

// ─── Category Overview ──────────────────────────────────────────────────────

export interface CategoryOverviewItem {
  country_code: string;
  category: string;
  slug: string;
  display_name: string;
  category_description: string | null;
  icon_emoji: string;
  sort_order: number;
  product_count: number;
  avg_score: number;
  min_score: number;
  max_score: number;
  median_score: number;
  pct_nutri_a_b: number;
  pct_nova_4: number;
}

// ─── Product Detail ─────────────────────────────────────────────────────────

export interface ProductDetail {
  api_version: string;
  product_id: number;
  ean: string | null;
  product_name: string;
  product_name_en: string | null;
  product_name_display: string;
  original_language: string;
  brand: string;
  category: string;
  category_display: string;
  category_icon: string;
  product_type: string | null;
  country: string;
  store_availability: string | null;
  prep_method: string | null;
  scores: {
    unhealthiness_score: number;
    score_band: ScoreBand;
    nutri_score: NutriGrade;
    nutri_score_color: string;
    nova_group: string;
    processing_risk: string;
  };
  flags: {
    high_salt: boolean;
    high_sugar: boolean;
    high_sat_fat: boolean;
    high_additive_load: boolean;
    has_palm_oil: boolean;
  };
  nutrition_per_100g: {
    calories: number;
    total_fat_g: number;
    saturated_fat_g: number;
    trans_fat_g: number | null;
    carbs_g: number;
    sugars_g: number;
    fibre_g: number | null;
    protein_g: number;
    salt_g: number;
  };
  ingredients: {
    count: number;
    additives_count: number;
    additive_names: string[];
    vegan_status: string;
    vegetarian_status: string;
    data_quality: string;
  };
  allergens: {
    count: number;
    tags: string[];
    trace_count: number;
    trace_tags: string[];
  };
  trust: {
    confidence: string;
    data_completeness_pct: number;
    source_type: string;
    nutrition_data_quality: string;
    ingredient_data_quality: string;
  };
  freshness: {
    created_at: string;
    updated_at: string;
    data_age_days: number;
  };
}

// ─── EAN Lookup ─────────────────────────────────────────────────────────────

export interface EanLookupResponse extends ProductDetail {
  scan: {
    scanned_ean: string;
    found: boolean;
    alternative_count: number;
  };
}

export interface EanNotFoundResponse {
  api_version: string;
  ean: string;
  country: string;
  found: false;
  error: string;
}

// ─── Better Alternatives ────────────────────────────────────────────────────

export interface Alternative {
  product_id: number;
  product_name: string;
  brand: string;
  category: string;
  unhealthiness_score: number;
  score_improvement: number;
  nutri_score: NutriGrade;
  similarity: number;
  shared_ingredients: number;
}

export interface AlternativesResponse {
  api_version: string;
  source_product: {
    product_id: number;
    product_name: string;
    brand: string;
    category: string;
    unhealthiness_score: number;
    nutri_score: NutriGrade;
  };
  search_scope: string;
  alternatives: Alternative[];
  alternatives_count: number;
}

// ─── Score Explanation ──────────────────────────────────────────────────────

export interface ScoreExplanation {
  api_version: string;
  product_id: number;
  product_name: string;
  brand: string;
  category: string;
  score_breakdown: Record<string, unknown>;
  summary: {
    score: number;
    score_band: ScoreBand;
    headline: string;
    nutri_score: NutriGrade;
    nova_group: string;
    processing_risk: string;
  };
  top_factors: { factor: string; raw: number; weighted: number }[];
  warnings: { type: string; message: string }[];
  category_context: {
    category_avg_score: number;
    category_rank: number;
    category_total: number;
    relative_position: string;
  };
}

// ─── Data Confidence ────────────────────────────────────────────────────────

export interface DataConfidence {
  api_version: string;
  [key: string]: unknown;
}

// ─── Product Profile (Composite) ────────────────────────────────────────────

export interface ProductProfileMeta {
  product_id: number;
  language: string;
  retrieved_at: string;
}

export interface ProductProfileProduct {
  product_id: number;
  product_name: string;
  product_name_en: string | null;
  product_name_display: string;
  original_language: string;
  brand: string;
  category: string;
  category_display: string;
  category_icon: string;
  product_type: string | null;
  country: string;
  ean: string | null;
  prep_method: string | null;
  store_availability: string | null;
  controversies: string | null;
}

export interface NutritionPer100g {
  calories_kcal: number;
  total_fat_g: number;
  saturated_fat_g: number;
  trans_fat_g: number | null;
  carbs_g: number;
  sugars_g: number;
  fibre_g: number | null;
  protein_g: number;
  salt_g: number;
}

export interface NutritionPerServing extends NutritionPer100g {
  serving_size: string;
  serving_grams: number;
}

export interface ProfileIngredients {
  count: number;
  additive_count: number;
  additive_names: string | null;
  has_palm_oil: boolean;
  vegan_status: string | null;
  vegetarian_status: string | null;
  ingredients_text: string | null;
  top_ingredients: {
    name: string;
    position: number;
    concern_tier: number;
    is_additive: boolean;
  }[];
}

export interface ProfileAllergens {
  contains: string;
  traces: string;
  contains_count: number;
  traces_count: number;
}

export interface CategoryContext {
  rank: number;
  total_in_category: number;
  category_avg_score: number;
  relative_position: string;
}

export interface ProfileScores {
  unhealthiness_score: number;
  score_band: ScoreBand;
  nutri_score_label: NutriGrade;
  nutri_score_color: string;
  nova_group: string;
  processing_risk: string;
  score_breakdown: Record<string, unknown>[];
  headline: string;
  category_context: CategoryContext;
}

export interface ProfileWarning {
  type: string;
  severity: "warning" | "info";
  message: string;
}

export interface ProfileAlternative {
  product_id: number;
  product_name: string;
  brand: string;
  category: string;
  unhealthiness_score: number;
  score_delta: number;
  nutri_score: NutriGrade;
  similarity: number;
}

export interface ProductProfile {
  api_version: string;
  meta: ProductProfileMeta;
  product: ProductProfileProduct;
  nutrition: {
    per_100g: NutritionPer100g;
    per_serving: NutritionPerServing | null;
  };
  ingredients: ProfileIngredients;
  allergens: ProfileAllergens;
  scores: ProfileScores;
  warnings: ProfileWarning[];
  quality: DataConfidence;
  alternatives: ProfileAlternative[];
  flags: {
    high_salt: boolean;
    high_sugar: boolean;
    high_sat_fat: boolean;
    high_additive_load: boolean;
    has_palm_oil: boolean;
  };
}

export interface ProductProfileNotFound {
  api_version: string;
  error: "product_not_found";
  ean: string;
}

// ─── Enums / Literals ───────────────────────────────────────────────────────

export type ScoreBand = "low" | "moderate" | "high" | "very_high";
export type NutriGrade = "A" | "B" | "C" | "D" | "E" | null;
export type DietPreference = "none" | "vegetarian" | "vegan";

// ─── Health Profiles ────────────────────────────────────────────────────────

export type HealthCondition =
  | "diabetes"
  | "hypertension"
  | "heart_disease"
  | "celiac_disease"
  | "gout"
  | "kidney_disease"
  | "ibs";

export interface HealthProfile {
  profile_id: string;
  profile_name: string;
  is_active: boolean;
  health_conditions: HealthCondition[];
  max_sugar_g: number | null;
  max_salt_g: number | null;
  max_saturated_fat_g: number | null;
  max_calories_kcal: number | null;
  notes: string | null;
  created_at: string;
  updated_at: string;
}

export interface HealthProfileListResponse {
  api_version: string;
  profiles: HealthProfile[];
}

export interface HealthProfileActiveResponse {
  api_version: string;
  profile: HealthProfile | null;
}

export interface HealthProfileMutationResponse {
  api_version: string;
  profile_id: string;
  created?: boolean;
  updated?: boolean;
  deleted?: boolean;
}

export type WarningSeverity = "critical" | "high" | "moderate";

export interface HealthWarning {
  condition: string;
  severity: WarningSeverity;
  message: string;
}

export interface HealthWarningsResponse {
  api_version: string;
  product_id: number;
  warning_count: number;
  warnings: HealthWarning[];
}

// ─── Product Lists ──────────────────────────────────────────────────────────

export type ListType = "favorites" | "avoid" | "custom";

export interface ProductList {
  id: string;
  name: string;
  description: string | null;
  list_type: ListType;
  is_default: boolean;
  share_enabled: boolean;
  share_token: string | null;
  item_count: number;
  created_at: string;
  updated_at: string;
}

export interface ListsResponse {
  api_version: string;
  lists: ProductList[];
}

export interface ListItem {
  item_id: string;
  product_id: number;
  position: number;
  notes: string | null;
  added_at: string;
  product_name: string;
  brand: string;
  category: string;
  unhealthiness_score: number;
  nutri_score_label: string;
  nova_classification: string;
  calories: number | null;
}

export interface ListItemsResponse {
  api_version: string;
  list_id: string;
  list_name: string;
  list_type: ListType;
  description: string | null;
  total_count: number;
  limit: number;
  offset: number;
  items: ListItem[];
}

export interface CreateListResponse {
  api_version: string;
  list_id: string;
  name: string;
  list_type: ListType;
}

export interface ToggleShareResponse {
  api_version: string;
  share_enabled: boolean;
  share_token: string | null;
}

export interface SharedListResponse {
  api_version: string;
  list_name: string;
  description: string | null;
  list_type: ListType;
  total_count: number;
  limit: number;
  offset: number;
  items: Omit<ListItem, "item_id" | "notes" | "added_at" | "nova_classification">[];
}

export interface AddToListResponse {
  api_version: string;
  item_id: string;
  list_type: ListType;
}

export interface AvoidProductIdsResponse {
  api_version: string;
  product_ids: number[];
}

export interface MutationSuccess {
  api_version: string;
  success: boolean;
}

export interface ProductListMembershipResponse {
  api_version: string;
  product_id: number;
  list_ids: string[];
}

export interface FavoriteProductIdsResponse {
  api_version: string;
  product_ids: number[];
}

// ─── Product Comparisons ────────────────────────────────────────────────────

export interface CompareProduct {
  product_id: number;
  ean: string | null;
  product_name: string;
  brand: string;
  category: string;
  category_display: string;
  category_icon: string;
  unhealthiness_score: number;
  score_band: ScoreBand;
  nutri_score: NutriGrade;
  nova_group: string;
  processing_risk: string;
  calories: number;
  total_fat_g: number;
  saturated_fat_g: number;
  trans_fat_g: number | null;
  carbs_g: number;
  sugars_g: number;
  fibre_g: number | null;
  protein_g: number;
  salt_g: number;
  high_salt: boolean;
  high_sugar: boolean;
  high_sat_fat: boolean;
  high_additive_load: boolean;
  additives_count: number;
  ingredient_count: number;
  allergen_count: number;
  allergen_tags: string | null;
  trace_tags: string | null;
  confidence: string;
  data_completeness_pct: number;
}

export interface CompareResponse {
  api_version: string;
  product_count: number;
  products: CompareProduct[];
}

export interface SaveComparisonResponse {
  api_version: string;
  comparison_id: string;
  share_token: string;
  product_ids: number[];
  title: string | null;
}

export interface SavedComparison {
  comparison_id: string;
  title: string | null;
  product_ids: number[];
  share_token: string;
  created_at: string;
  product_names: string[];
}

export interface SavedComparisonsResponse {
  api_version: string;
  total_count: number;
  limit: number;
  offset: number;
  comparisons: SavedComparison[];
}

export interface SharedComparisonResponse {
  api_version: string;
  comparison_id: string;
  title: string | null;
  created_at: string;
  product_count: number;
  products: CompareProduct[];
}

// ─── Scanner & Submissions ──────────────────────────────────────────────────

export interface RecordScanFoundResponse {
  api_version: string;
  found: true;
  product_id: number;
  product_name: string;
  product_name_en: string | null;
  product_name_display: string;
  brand: string;
  category: string;
  category_display: string;
  category_icon: string;
  unhealthiness_score: number;
  nutri_score: NutriGrade;
}

export interface RecordScanNotFoundResponse {
  api_version: string;
  found: false;
  ean: string;
  has_pending_submission: boolean;
}

export type RecordScanResponse =
  | RecordScanFoundResponse
  | RecordScanNotFoundResponse;

export interface ScanHistoryItem {
  scan_id: string;
  ean: string;
  found: boolean;
  scanned_at: string;
  product_id: number | null;
  product_name: string | null;
  brand: string | null;
  category: string | null;
  unhealthiness_score: number | null;
  nutri_score: NutriGrade | null;
  submission_status: string | null;
}

export interface ScanHistoryResponse {
  api_version: string;
  total: number;
  page: number;
  pages: number;
  page_size: number;
  filter: string;
  scans: ScanHistoryItem[];
}

export interface Submission {
  id: string;
  ean: string;
  product_name: string;
  brand: string | null;
  category: string | null;
  photo_url: string | null;
  status: 'pending' | 'approved' | 'rejected' | 'merged';
  merged_product_id: number | null;
  created_at: string;
  updated_at: string;
}

export interface SubmissionsResponse {
  api_version: string;
  total: number;
  page: number;
  pages: number;
  page_size: number;
  submissions: Submission[];
}

export interface SubmitProductResponse {
  api_version: string;
  submission_id: string;
  status: string;
  error?: string;
}

export interface AdminSubmission extends Submission {
  notes: string | null;
  user_id: string;
  reviewed_at: string | null;
}

export interface AdminSubmissionsResponse {
  api_version: string;
  total: number;
  page: number;
  pages: number;
  page_size: number;
  status_filter: string;
  submissions: AdminSubmission[];
}

export interface AdminReviewResponse {
  api_version: string;
  submission_id: string;
  status: string;
  merged_product_id?: number;
  error?: string;
}

// ─── Analytics / Telemetry ──────────────────────────────────────────────────

export type AnalyticsEventName =
  | "search_performed"
  | "filter_applied"
  | "search_saved"
  | "compare_opened"
  | "list_created"
  | "list_shared"
  | "favorites_added"
  | "list_item_added"
  | "avoid_added"
  | "scanner_used"
  | "product_not_found"
  | "submission_created"
  | "product_viewed"
  | "dashboard_viewed"
  | "share_link_opened"
  | "category_viewed"
  | "preferences_updated"
  | "onboarding_completed";

export type DeviceType = "mobile" | "tablet" | "desktop";

export interface TrackEventResponse {
  api_version: string;
  tracked: boolean;
  error?: string;
}

// ─── Dashboard / Recently Viewed ────────────────────────────────────────────

export interface RecentlyViewedProduct {
  product_id: number;
  product_name: string;
  brand: string | null;
  category: string;
  country: string;
  unhealthiness_score: number | null;
  nutri_score_label: NutriGrade | null;
  viewed_at: string;
}

export interface RecentlyViewedResponse {
  api_version: string;
  products: RecentlyViewedProduct[];
}

export interface RecordProductViewResponse {
  api_version: string;
  recorded?: boolean;
  error?: string;
}

export interface DashboardStats {
  total_scanned: number;
  total_viewed: number;
  lists_count: number;
  favorites_count: number;
  most_viewed_category: string | null;
}

export interface DashboardFavoritePreview {
  product_id: number;
  product_name: string;
  brand: string | null;
  category: string;
  country: string;
  unhealthiness_score: number | null;
  nutri_score_label: NutriGrade | null;
  added_at: string;
}

export interface DashboardNewProduct {
  product_id: number;
  product_name: string;
  brand: string | null;
  category: string;
  country: string;
  unhealthiness_score: number | null;
  nutri_score_label: NutriGrade | null;
}

export interface DashboardData {
  api_version: string;
  recently_viewed: RecentlyViewedProduct[];
  favorites_preview: DashboardFavoritePreview[];
  new_products: DashboardNewProduct[];
  stats: DashboardStats;
}
