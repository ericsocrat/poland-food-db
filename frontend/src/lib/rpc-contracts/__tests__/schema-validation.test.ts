// ═══════════════════════════════════════════════════════════════════════════════
// Schema Validation Unit Tests — verify contracts catch drift
// Issue #179 — Schema-to-UI Contract Validation (Quality Gate 9/9)
// ═══════════════════════════════════════════════════════════════════════════════
//
// These tests run WITHOUT Supabase — they validate that the Zod schemas
// correctly accept valid mock data and reject invalid shapes.
//
// Run: cd frontend && npx vitest run schema-validation
// ═══════════════════════════════════════════════════════════════════════════════

import { describe, it, expect } from "vitest";

import {
  ProductDetailContract,
  BetterAlternativesContract,
  ScoreExplanationContract,
  DataConfidenceContract,
  SearchProductsContract,
  SearchAutocompleteContract,
  FilterOptionsContract,
  CategoryOverviewContract,
  CategoryListingContract,
  DashboardDataContract,
  RecentlyViewedContract,
  HealthProfileListContract,
  HealthProfileActiveContract,
  HealthWarningsContract,
  ListsContract,
  ListItemsContract,
  CompareContract,
  ScanHistoryContract,
  UserPreferencesContract,
  SavedSearchesContract,
  SearchQualityReportContract,
} from "../index";
import {
  ProductProvenanceContract,
  CountryValidationContract,
  ProvenanceDashboardContract,
} from "../provenance.contracts";

// ─── Mock data factories ────────────────────────────────────────────────────

function mockProductDetail() {
  return {
    api_version: "1.0",
    product_id: 1,
    ean: "5900320001303",
    product_name: "Test Product",
    product_name_en: "Test Product EN",
    product_name_display: "Test Product",
    original_language: "pl",
    brand: "TestBrand",
    category: "dairy",
    category_display: "Dairy",
    category_icon: "🥛",
    product_type: null,
    country: "PL",
    store_availability: null,
    prep_method: null,
    scores: {
      unhealthiness_score: 35,
      score_band: "moderate" as const,
      nutri_score: "B",
      nutri_score_color: "#85BB2F",
      nova_group: "2",
      processing_risk: "low",
    },
    flags: {
      high_salt: false,
      high_sugar: false,
      high_sat_fat: false,
      high_additive_load: false,
      has_palm_oil: false,
    },
    nutrition_per_100g: {
      calories: 120,
      total_fat_g: 3.5,
      saturated_fat_g: 2.1,
      trans_fat_g: null,
      carbs_g: 10,
      sugars_g: 5,
      fibre_g: 0.5,
      protein_g: 8,
      salt_g: 0.3,
    },
    ingredients: {
      count: 5,
      additives_count: 0,
      additive_names: [],
      vegan_status: "no",
      vegetarian_status: "yes",
      data_quality: "high",
    },
    allergens: {
      count: 1,
      tags: ["milk"],
      trace_count: 0,
      trace_tags: [],
    },
    trust: {
      confidence: "high",
      data_completeness_pct: 95,
      source_type: "openfoodfacts",
      nutrition_data_quality: "high",
      ingredient_data_quality: "high",
    },
    freshness: {
      created_at: "2025-01-01T00:00:00Z",
      updated_at: "2025-06-01T00:00:00Z",
      data_age_days: 30,
    },
  };
}

function mockSearchResponse() {
  return {
    api_version: "1.0",
    query: "milk",
    country: "PL",
    total: 1,
    page: 1,
    pages: 1,
    page_size: 20,
    filters_applied: null,
    results: [
      {
        product_id: 1,
        product_name: "Milk",
        product_name_en: "Milk",
        product_name_display: "Milk",
        brand: "TestBrand",
        category: "dairy",
        category_display: "Dairy",
        category_icon: "🥛",
        unhealthiness_score: 20,
        score_band: "low" as const,
        nutri_score: "A",
        nova_group: "1",
        calories: 64,
        high_salt: false,
        high_sugar: false,
        high_sat_fat: false,
        high_additive_load: false,
        is_avoided: false,
        relevance: 0.95,
        image_thumb_url: null,
      },
    ],
  };
}

// ═══════════════════════════════════════════════════════════════════════════════
// 1. Valid data accepted
// ═══════════════════════════════════════════════════════════════════════════════

describe("Schema validation: valid data accepted", () => {
  it("ProductDetailContract accepts valid product", () => {
    const result = ProductDetailContract.safeParse(mockProductDetail());
    expect(result.success).toBe(true);
  });

  it("SearchProductsContract accepts valid search response", () => {
    const result = SearchProductsContract.safeParse(mockSearchResponse());
    expect(result.success).toBe(true);
  });

  it("SearchAutocompleteContract accepts valid autocomplete", () => {
    const data = {
      api_version: "1.0",
      query: "chi",
      suggestions: [
        {
          product_id: 1,
          product_name: "Chips",
          product_name_en: null,
          product_name_display: "Chips",
          brand: "TestBrand",
          category: "snacks",
          nutri_score: "D",
          unhealthiness_score: 70,
          score_band: "high" as const,
        },
      ],
    };
    expect(SearchAutocompleteContract.safeParse(data).success).toBe(true);
  });

  it("CategoryOverviewContract accepts valid overview", () => {
    const data = {
      api_version: "1.0",
      country: "PL",
      categories: [
        { category: "dairy", slug: "dairy", display_name: "Dairy", product_count: 100 },
      ],
    };
    expect(CategoryOverviewContract.safeParse(data).success).toBe(true);
  });

  it("CategoryListingContract accepts valid listing", () => {
    const data = {
      api_version: "1.0",
      category: "dairy",
      country: "PL",
      total_count: 42,
      limit: 20,
      offset: 0,
      sort_by: "score",
      sort_dir: "desc",
      products: [
        {
          product_id: 1,
          ean: "5900320001303",
          product_name: "Test Milk",
          brand: "TestBrand",
          unhealthiness_score: 72,
          score_band: "low",
          nutri_score: "A",
          nova_group: "1",
          processing_risk: "low",
          calories: 42,
          total_fat_g: 1.5,
          protein_g: 3.4,
          sugars_g: 4.8,
          salt_g: 0.1,
          high_salt_flag: false,
          high_sugar_flag: false,
          high_sat_fat_flag: false,
          confidence: "high",
          data_completeness_pct: 95,
          image_thumb_url: null,
        },
      ],
    };
    expect(CategoryListingContract.safeParse(data).success).toBe(true);
  });

  it("DashboardDataContract accepts valid dashboard", () => {
    const data = {
      api_version: "1.0",
      recently_viewed: [],
      favorites_preview: [],
      new_products: [],
      stats: {
        total_scanned: 0,
        total_viewed: 0,
        lists_count: 0,
        favorites_count: 0,
        most_viewed_category: null,
      },
    };
    expect(DashboardDataContract.safeParse(data).success).toBe(true);
  });

  it("HealthWarningsContract accepts valid warnings", () => {
    const data = {
      api_version: "1.0",
      product_id: 1,
      warning_count: 1,
      warnings: [{ condition: "diabetes", severity: "high", message: "High sugar" }],
    };
    expect(HealthWarningsContract.safeParse(data).success).toBe(true);
  });

  it("ListsContract accepts valid lists", () => {
    const data = {
      api_version: "1.0",
      lists: [
        {
          id: "abc-123",
          name: "Favorites",
          description: null,
          list_type: "favorites",
          is_default: true,
          share_enabled: false,
          share_token: null,
          item_count: 5,
          created_at: "2025-01-01T00:00:00Z",
          updated_at: "2025-06-01T00:00:00Z",
        },
      ],
    };
    expect(ListsContract.safeParse(data).success).toBe(true);
  });

  it("CompareContract accepts valid compare", () => {
    const data = {
      api_version: "1.0",
      product_count: 1,
      products: [
        {
          product_id: 1,
          ean: null,
          product_name: "Test",
          brand: "Brand",
          category: "dairy",
          category_display: "Dairy",
          category_icon: "🥛",
          unhealthiness_score: 30,
          score_band: "moderate",
          nutri_score: "B",
          nova_group: "2",
          processing_risk: "low",
          calories: 120,
          total_fat_g: 3.5,
          saturated_fat_g: 2.1,
          trans_fat_g: null,
          carbs_g: 10,
          sugars_g: 5,
          fibre_g: null,
          protein_g: 8,
          salt_g: 0.3,
          high_salt: false,
          high_sugar: false,
          high_sat_fat: false,
          high_additive_load: false,
          additives_count: 0,
          ingredient_count: 5,
          allergen_count: 1,
          allergen_tags: "milk",
          trace_tags: null,
          confidence: "high",
          data_completeness_pct: 95,
        },
      ],
    };
    expect(CompareContract.safeParse(data).success).toBe(true);
  });

  it("UserPreferencesContract accepts valid preferences", () => {
    const data = {
      api_version: "1.0",
      user_id: "uuid-123",
      country: "PL",
      preferred_language: "en",
      diet_preference: null,
      avoid_allergens: [],
      strict_allergen: false,
      strict_diet: false,
      treat_may_contain_as_unsafe: false,
      health_goals: [],
      favorite_categories: [],
      onboarding_complete: true,
      onboarding_completed: true,
      onboarding_skipped: false,
      created_at: "2025-01-01T00:00:00Z",
      updated_at: "2025-06-01T00:00:00Z",
    };
    expect(UserPreferencesContract.safeParse(data).success).toBe(true);
  });

  it("ScanHistoryContract accepts valid scan history", () => {
    const data = {
      api_version: "1.0",
      total: 0,
      page: 1,
      pages: 0,
      page_size: 20,
      filter: "all",
      scans: [],
    };
    expect(ScanHistoryContract.safeParse(data).success).toBe(true);
  });

  it("RecentlyViewedContract accepts valid data", () => {
    const data = { api_version: "1.0", products: [] };
    expect(RecentlyViewedContract.safeParse(data).success).toBe(true);
  });

  it("HealthProfileListContract accepts valid data", () => {
    const data = { api_version: "1.0", profiles: [] };
    expect(HealthProfileListContract.safeParse(data).success).toBe(true);
  });

  it("HealthProfileActiveContract accepts null profile", () => {
    const data = { api_version: "1.0", profile: null };
    expect(HealthProfileActiveContract.safeParse(data).success).toBe(true);
  });

  it("FilterOptionsContract accepts valid data", () => {
    const data = {
      api_version: "1.0",
      country: "PL",
      categories: [],
      nutri_scores: [],
      nova_groups: [],
      allergens: [],
    };
    expect(FilterOptionsContract.safeParse(data).success).toBe(true);
  });

  it("SavedSearchesContract accepts valid data", () => {
    const data = { api_version: "1.0", searches: [] };
    expect(SavedSearchesContract.safeParse(data).success).toBe(true);
  });

  it("ListItemsContract accepts valid list items", () => {
    const data = {
      api_version: "1.0",
      list_id: "abc",
      list_name: "Favorites",
      list_type: "favorites",
      description: null,
      total_count: 0,
      limit: 20,
      offset: 0,
      items: [],
    };
    expect(ListItemsContract.safeParse(data).success).toBe(true);
  });

  it("BetterAlternativesContract accepts valid alternatives", () => {
    const data = {
      api_version: "1.0",
      source_product: {
        product_id: 1,
        product_name: "Test",
        brand: "Brand",
        category: "dairy",
        unhealthiness_score: 50,
        nutri_score: "C",
      },
      search_scope: "same_category",
      alternatives: [],
      alternatives_count: 0,
    };
    expect(BetterAlternativesContract.safeParse(data).success).toBe(true);
  });

  it("ScoreExplanationContract accepts valid explanation", () => {
    const data = {
      api_version: "1.0",
      product_id: 1,
      product_name: "Test",
      brand: "Brand",
      category: "dairy",
      score_breakdown: { fat: 10, sugar: 5 },
      model_version: "v3.2",
      scored_at: "2026-02-25T12:00:00Z",
      summary: {
        score: 35,
        score_band: "moderate",
        headline: "Moderate health concern",
        nutri_score: "B",
        nova_group: "2",
        processing_risk: "low",
      },
      top_factors: [{ factor: "fat", raw: 3.5, weighted: 10 }],
      warnings: [],
      category_context: {
        category_avg_score: 40,
        category_rank: 5,
        category_total: 20,
        relative_position: "better_than_average",
      },
    };
    expect(ScoreExplanationContract.safeParse(data).success).toBe(true);
  });

  it("DataConfidenceContract accepts valid data", () => {
    const data = { api_version: "1.0", overall_score: 85 };
    expect(DataConfidenceContract.safeParse(data).success).toBe(true);
  });
});

// ═══════════════════════════════════════════════════════════════════════════════
// 2. Missing required keys rejected
// ═══════════════════════════════════════════════════════════════════════════════

describe("Schema validation: missing required keys rejected", () => {
  it("ProductDetailContract rejects missing product_name", () => {
    const data = mockProductDetail();
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    delete (data as any).product_name;
    expect(ProductDetailContract.safeParse(data).success).toBe(false);
  });

  it("ProductDetailContract rejects missing scores", () => {
    const data = mockProductDetail();
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    delete (data as any).scores;
    expect(ProductDetailContract.safeParse(data).success).toBe(false);
  });

  it("SearchProductsContract rejects missing results", () => {
    const data = mockSearchResponse();
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    delete (data as any).results;
    expect(SearchProductsContract.safeParse(data).success).toBe(false);
  });

  it("SearchProductsContract rejects missing total", () => {
    const data = mockSearchResponse();
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    delete (data as any).total;
    expect(SearchProductsContract.safeParse(data).success).toBe(false);
  });

  it("CategoryOverviewContract rejects missing categories", () => {
    const data = { api_version: "1.0", country: "PL" };
    expect(CategoryOverviewContract.safeParse(data).success).toBe(false);
  });

  it("DashboardDataContract rejects missing stats", () => {
    const data = {
      api_version: "1.0",
      recently_viewed: [],
      favorites_preview: [],
      new_products: [],
    };
    expect(DashboardDataContract.safeParse(data).success).toBe(false);
  });

  it("ListsContract rejects missing lists array", () => {
    const data = { api_version: "1.0" };
    expect(ListsContract.safeParse(data).success).toBe(false);
  });

  it("HealthWarningsContract rejects missing warnings array", () => {
    const data = { api_version: "1.0", product_id: 1, warning_count: 0 };
    expect(HealthWarningsContract.safeParse(data).success).toBe(false);
  });
});

// ═══════════════════════════════════════════════════════════════════════════════
// 3. Type mismatches rejected
// ═══════════════════════════════════════════════════════════════════════════════

describe("Schema validation: type mismatches rejected", () => {
  it("rejects product_id as string instead of number", () => {
    const data = mockProductDetail();
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    (data as any).product_id = "not-a-number";
    expect(ProductDetailContract.safeParse(data).success).toBe(false);
  });

  it("rejects score_band as invalid enum value", () => {
    const data = mockProductDetail();
    data.scores.score_band = "extreme" as never;
    expect(ProductDetailContract.safeParse(data).success).toBe(false);
  });

  it("rejects nutri_score as non-string value", () => {
    const data = mockProductDetail();
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    (data.scores as any).nutri_score = 123;
    expect(ProductDetailContract.safeParse(data).success).toBe(false);
  });

  it("rejects calories as string instead of number", () => {
    const data = mockProductDetail();
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    (data.nutrition_per_100g as any).calories = "120";
    expect(ProductDetailContract.safeParse(data).success).toBe(false);
  });

  it("rejects search total as string instead of number", () => {
    const data = mockSearchResponse();
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    (data as any).total = "1";
    expect(SearchProductsContract.safeParse(data).success).toBe(false);
  });

  it("rejects high_salt as string instead of boolean", () => {
    const data = mockProductDetail();
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    (data.flags as any).high_salt = "true";
    expect(ProductDetailContract.safeParse(data).success).toBe(false);
  });
});

// ═══════════════════════════════════════════════════════════════════════════════
// 4. Extra keys accepted (.passthrough)
// ═══════════════════════════════════════════════════════════════════════════════

describe("Schema validation: extra keys accepted (passthrough)", () => {
  it("ProductDetailContract allows unknown extra keys", () => {
    const data = { ...mockProductDetail(), future_field: "new-data" };
    expect(ProductDetailContract.safeParse(data).success).toBe(true);
  });

  it("SearchProductsContract allows extra keys", () => {
    const data = { ...mockSearchResponse(), experimental_flag: true };
    expect(SearchProductsContract.safeParse(data).success).toBe(true);
  });

  it("CategoryOverviewContract allows extra keys on items", () => {
    const data = {
      api_version: "1.0",
      country: "PL",
      categories: [
        {
          category: "dairy",
          slug: "dairy",
          display_name: "Dairy",
          product_count: 100,
          new_field: "extra",
        },
      ],
    };
    expect(CategoryOverviewContract.safeParse(data).success).toBe(true);
  });
});

// ═══════════════════════════════════════════════════════════════════════════════
// 5. Nullable fields handled correctly
// ═══════════════════════════════════════════════════════════════════════════════

describe("Schema validation: nullable fields", () => {
  it("ProductDetail accepts null ean", () => {
    const data = { ...mockProductDetail(), ean: null };
    expect(ProductDetailContract.safeParse(data).success).toBe(true);
  });

  it("ProductDetail accepts null nutri-score", () => {
    const data = mockProductDetail();
    data.scores.nutri_score = null;
    expect(ProductDetailContract.safeParse(data).success).toBe(true);
  });

  it("HealthProfileActive accepts null profile", () => {
    const data = { api_version: "1.0", profile: null };
    expect(HealthProfileActiveContract.safeParse(data).success).toBe(true);
  });

  it("rejects null where non-nullable", () => {
    const data = mockProductDetail();
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    (data as any).product_name = null;
    expect(ProductDetailContract.safeParse(data).success).toBe(false);
  });
});

// ═══════════════════════════════════════════════════════════════════════════════
// 6. Search Quality Report contract (Issue #192)
// ═══════════════════════════════════════════════════════════════════════════════

describe("Schema validation: SearchQualityReportContract", () => {
  const validStubReport = {
    api_version: "1.0",
    status: "pending_dependency",
    dependency: "issue_190_event_analytics",
    period_days: 7,
    country: "all",
    message:
      "Search quality metrics will be activated when Event Analytics (#190) is deployed.",
    planned_metrics: {
      total_searches: null,
      unique_queries: null,
      zero_result_rate: null,
      click_through_rate: null,
      mean_reciprocal_rank: null,
      avg_results_per_query: null,
      top_zero_result_queries: [],
      top_queries: [],
    },
  };

  it("accepts valid stub report", () => {
    expect(SearchQualityReportContract.safeParse(validStubReport).success).toBe(
      true,
    );
  });

  it("accepts report with extra keys (passthrough)", () => {
    const data = { ...validStubReport, extra_field: "future" };
    expect(SearchQualityReportContract.safeParse(data).success).toBe(true);
  });

  it("rejects report missing planned_metrics", () => {
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    const { planned_metrics: _pm, ...data } = validStubReport;
    expect(SearchQualityReportContract.safeParse(data).success).toBe(false);
  });

  it("rejects report missing period_days", () => {
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    const { period_days: _pd, ...data } = validStubReport;
    expect(SearchQualityReportContract.safeParse(data).success).toBe(false);
  });

  it("rejects report with wrong type for status", () => {
    const data = { ...validStubReport, status: 123 };
    expect(SearchQualityReportContract.safeParse(data).success).toBe(false);
  });
});

// ═══════════════════════════════════════════════════════════════════════════════
// 7. Data Provenance contracts (Issue #193)
// ═══════════════════════════════════════════════════════════════════════════════

describe("ProductProvenanceContract", () => {
  const validProvenance = {
    api_version: "2026-02-27",
    product_id: 42,
    product_name: "Jogurt naturalny",
    overall_trust_score: 0.72,
    freshness_status: "fresh",
    source_count: 3,
    data_completeness_pct: 86.7,
    field_sources: {
      product_name: {
        source: "Open Food Facts API",
        last_updated: "2026-02-20T10:00:00Z",
        confidence: 0.6,
      },
      calories_100g: {
        source: "Package / Label Scan",
        last_updated: "2026-02-22T14:00:00Z",
        confidence: 0.95,
      },
    },
    trust_explanation:
      "Data from multiple sources with moderate confidence",
    weakest_area: { field: "allergens", confidence: 0.4 },
  };

  it("accepts valid provenance response", () => {
    expect(ProductProvenanceContract.safeParse(validProvenance).success).toBe(
      true
    );
  });

  it("accepts response with null trust_score (no provenance data)", () => {
    const data = { ...validProvenance, overall_trust_score: null };
    expect(ProductProvenanceContract.safeParse(data).success).toBe(true);
  });

  it("accepts extra keys (passthrough)", () => {
    const data = { ...validProvenance, future_field: "v2" };
    expect(ProductProvenanceContract.safeParse(data).success).toBe(true);
  });

  it("rejects missing product_name", () => {
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    const { product_name: _pn, ...data } = validProvenance;
    expect(ProductProvenanceContract.safeParse(data).success).toBe(false);
  });

  it("rejects missing trust_explanation", () => {
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    const { trust_explanation: _te, ...data } = validProvenance;
    expect(ProductProvenanceContract.safeParse(data).success).toBe(false);
  });
});

describe("CountryValidationContract", () => {
  const validValidation = {
    product_id: 42,
    country: "PL",
    ready_for_publish: true,
    overall_confidence: 0.72,
    staleness_risk: "fresh",
    source_diversity: 3,
    issues: [],
    validated_at: "2026-02-27T10:00:00Z",
  };

  it("accepts valid country validation", () => {
    expect(CountryValidationContract.safeParse(validValidation).success).toBe(
      true
    );
  });

  it("accepts validation with issues", () => {
    const data = {
      ...validValidation,
      ready_for_publish: false,
      issues: [
        {
          check: "minimum_confidence",
          status: "fail" as const,
          detail: "Confidence 0.30 below minimum 0.50",
        },
      ],
    };
    expect(CountryValidationContract.safeParse(data).success).toBe(true);
  });

  it("rejects invalid issue status", () => {
    const data = {
      ...validValidation,
      issues: [{ check: "test", status: "invalid", detail: "d" }],
    };
    expect(CountryValidationContract.safeParse(data).success).toBe(false);
  });
});

describe("ProvenanceDashboardContract", () => {
  const validDashboard = {
    api_version: "2026-02-27",
    country: "PL",
    generated_at: "2026-02-27T12:00:00Z",
    total_products: 500,
    with_provenance: 450,
    without_provenance: 50,
    open_conflicts: 3,
    critical_conflicts: 0,
    source_distribution: { off_api: 400, manual: 50 },
    policies: [
      {
        field_group: "nutrition",
        max_age_days: 180,
        warning_age_days: 120,
        refresh_strategy: "auto_api",
      },
    ],
  };

  it("accepts valid dashboard response", () => {
    expect(ProvenanceDashboardContract.safeParse(validDashboard).success).toBe(
      true
    );
  });

  it("accepts null source_distribution", () => {
    const data = { ...validDashboard, source_distribution: null };
    expect(ProvenanceDashboardContract.safeParse(data).success).toBe(true);
  });

  it("rejects missing policies array", () => {
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    const { policies: _p, ...data } = validDashboard;
    expect(ProvenanceDashboardContract.safeParse(data).success).toBe(false);
  });
});
