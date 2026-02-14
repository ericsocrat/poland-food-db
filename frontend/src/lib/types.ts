// ─── TypeScript interfaces matching backend RPC response shapes ─────────────

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

export interface SearchResult {
  product_id: number;
  product_name: string;
  brand: string;
  category: string;
  unhealthiness_score: number;
  score_band: ScoreBand;
  nutri_score: NutriGrade;
  nova_group: string;
  relevance: number;
}

export interface SearchResponse {
  api_version: string;
  query: string;
  category: string | null;
  country: string;
  total_count: number;
  limit: number;
  offset: number;
  results: SearchResult[];
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
