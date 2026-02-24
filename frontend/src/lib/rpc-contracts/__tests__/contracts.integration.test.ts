// ═══════════════════════════════════════════════════════════════════════════════
// RPC Contract Integration Tests — Zod-validated response shapes
// Issue #179 — Schema-to-UI Contract Validation (Quality Gate 9/9)
// ═══════════════════════════════════════════════════════════════════════════════
//
// Run:  cd frontend && INTEGRATION=1 npx vitest run rpc-contracts
// CI:   api-contract.yml (runs automatically on migration/contract changes)
//
// Public RPCs are validated directly. Auth-required RPCs handle permission
// errors gracefully (skip if no user context, validate if data returns).
// ═══════════════════════════════════════════════════════════════════════════════

import { describe, it, expect, beforeAll } from "vitest";
import { createClient, type SupabaseClient } from "@supabase/supabase-js";
import type { z } from "zod";

import {
  ProductDetailContract,
  BetterAlternativesContract,
  ScoreExplanationContract,
  DataConfidenceContract,
  SearchProductsContract,
  SearchAutocompleteContract,
  FilterOptionsContract,
  SavedSearchesContract,
  CategoryOverviewContract,
  CategoryListingContract,
  DashboardDataContract,
  RecentlyViewedContract,
  HealthProfileListContract,
  HealthProfileActiveContract,
  HealthWarningsContract,
  ListsContract,
  CompareContract,
  ScanHistoryContract,
  UserPreferencesContract,
} from "../index";

// ─── Environment & guards ───────────────────────────────────────────────────

const INTEGRATION = process.env.INTEGRATION === "1";
const SUPABASE_URL = process.env.NEXT_PUBLIC_SUPABASE_URL ?? "";
const SUPABASE_ANON_KEY = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY ?? "";
const SUPABASE_KEY =
  process.env.SUPABASE_SERVICE_ROLE_KEY || SUPABASE_ANON_KEY;
const QA_PRODUCT_ID = Number(process.env.QA_PRODUCT_ID ?? 1);

const describeIntegration = INTEGRATION ? describe : describe.skip;

// ─── Supabase client setup ──────────────────────────────────────────────────

let supabase: SupabaseClient;

beforeAll(() => {
  if (!INTEGRATION) return;
  supabase = createClient(SUPABASE_URL, SUPABASE_KEY, {
    auth: { autoRefreshToken: false, persistSession: false },
  });
});

// ─── Helpers ────────────────────────────────────────────────────────────────

/**
 * Check whether an RPC response contains meaningful data.
 * Service-role calls to auth-required RPCs may return `{}` or `null`
 * instead of an error — this detects those empty envelopes.
 */
function isEmptyResponse(data: unknown): boolean {
  if (data === null || data === undefined) return true;
  if (
    typeof data === "object" &&
    !Array.isArray(data) &&
    Object.keys(data as Record<string, unknown>).length === 0
  )
    return true;
  return false;
}

/**
 * Validate RPC response against a Zod contract.
 * Logs detailed violations on failure for CI debugging.
 */
function assertContract<T>(
  rpcName: string,
  data: unknown,
  contract: z.ZodType<T>,
): void {
  const result = contract.safeParse(data);
  if (!result.success) {
    // eslint-disable-next-line no-console
    console.error(
      `\n❌ Contract violation [${rpcName}]:\n`,
      JSON.stringify(result.error.issues, null, 2),
    );
  }
  expect(result.success).toBe(true);
}

// ═══════════════════════════════════════════════════════════════════════════════
// P0 — Core Product RPCs
// ═══════════════════════════════════════════════════════════════════════════════

describeIntegration("P0 Contract: api_product_detail", () => {
  it("returns valid product detail shape", async () => {
    const { data, error } = await supabase.rpc("api_product_detail", {
      p_product_id: QA_PRODUCT_ID,
    });
    expect(error).toBeNull();
    if (data === null) return; // product may not exist in staging
    assertContract("api_product_detail", data, ProductDetailContract);
  });
});

describeIntegration("P0 Contract: api_better_alternatives", () => {
  it("returns valid alternatives shape", async () => {
    const { data, error } = await supabase.rpc("api_better_alternatives", {
      p_product_id: QA_PRODUCT_ID,
    });
    expect(error).toBeNull();
    if (data === null) return; // product may not exist in staging
    assertContract("api_better_alternatives", data, BetterAlternativesContract);
  });
});

describeIntegration("P0 Contract: api_score_explanation", () => {
  it("returns valid score explanation shape", async () => {
    const { data, error } = await supabase.rpc("api_score_explanation", {
      p_product_id: QA_PRODUCT_ID,
    });
    expect(error).toBeNull();
    if (data === null) return; // product may not exist in staging
    assertContract("api_score_explanation", data, ScoreExplanationContract);
  });
});

describeIntegration("P0 Contract: api_data_confidence", () => {
  it("returns valid data confidence shape", async () => {
    const { data, error } = await supabase.rpc("api_data_confidence", {
      p_product_id: QA_PRODUCT_ID,
    });
    expect(error).toBeNull();
    if (data === null) return; // product may not exist in staging
    assertContract("api_data_confidence", data, DataConfidenceContract);
  });
});

// ═══════════════════════════════════════════════════════════════════════════════
// P0 — Search RPCs
// ═══════════════════════════════════════════════════════════════════════════════

describeIntegration("P0 Contract: api_search_products", () => {
  it("returns valid search response shape", async () => {
    const { data, error } = await supabase.rpc("api_search_products", {
      p_query: "milk",
    });
    expect(error).toBeNull();
    if (data === null) return; // no results in staging
    assertContract("api_search_products", data, SearchProductsContract);
  });
});

describeIntegration("P0 Contract: api_search_autocomplete", () => {
  it("returns valid autocomplete shape", async () => {
    const { data, error } = await supabase.rpc("api_search_autocomplete", {
      p_query: "chi",
    });
    expect(error).toBeNull();
    if (data === null) return; // no results in staging
    assertContract("api_search_autocomplete", data, SearchAutocompleteContract);
  });
});

// ═══════════════════════════════════════════════════════════════════════════════
// P0 — Category RPCs
// ═══════════════════════════════════════════════════════════════════════════════

describeIntegration("P0 Contract: api_category_overview", () => {
  it("returns valid category overview shape", async () => {
    const { data, error } = await supabase.rpc("api_category_overview", {
      p_country: "PL",
    });
    expect(error).toBeNull();
    if (data === null) return; // no categories in staging
    assertContract("api_category_overview", data, CategoryOverviewContract);
  });
});

describeIntegration("P0 Contract: api_category_listing", () => {
  it("returns valid category listing shape", async () => {
    // Resolve a real slug from overview
    const { data: overview } = await supabase.rpc("api_category_overview", {
      p_country: "PL",
    });
    const slug = overview?.categories?.[0]?.slug ?? "dairy";

    const { data, error } = await supabase.rpc("api_category_listing", {
      p_category: slug,
    });
    expect(error).toBeNull();
    if (data === null) return; // category may not exist in staging
    assertContract("api_category_listing", data, CategoryListingContract);
  });
});

// ═══════════════════════════════════════════════════════════════════════════════
// P0 — Dashboard & Health Warnings
// ═══════════════════════════════════════════════════════════════════════════════

describeIntegration("P0 Contract: api_get_dashboard_data", () => {
  it("returns valid dashboard shape (auth-required)", async () => {
    const { data, error } = await supabase.rpc("api_get_dashboard_data");
    // Service-role key bypasses RLS; if RPC itself checks auth.uid(), skip
    if (error || isEmptyResponse(data)) return;
    assertContract("api_get_dashboard_data", data, DashboardDataContract);
  });
});

describeIntegration("P0 Contract: api_product_health_warnings", () => {
  it("returns valid health warnings shape", async () => {
    const { data, error } = await supabase.rpc(
      "api_product_health_warnings",
      { p_product_id: QA_PRODUCT_ID },
    );
    expect(error).toBeNull();
    if (isEmptyResponse(data)) return; // product may not exist in staging
    assertContract(
      "api_product_health_warnings",
      data,
      HealthWarningsContract,
    );
  });
});

// ═══════════════════════════════════════════════════════════════════════════════
// P1 — Search Supplemental
// ═══════════════════════════════════════════════════════════════════════════════

describeIntegration("P1 Contract: api_get_filter_options", () => {
  it("returns valid filter options shape", async () => {
    const { data, error } = await supabase.rpc("api_get_filter_options", {
      p_country: "PL",
    });
    expect(error).toBeNull();
    if (data === null) return; // no filters in staging
    assertContract("api_get_filter_options", data, FilterOptionsContract);
  });
});

describeIntegration("P1 Contract: api_get_saved_searches", () => {
  it("returns valid saved searches shape (auth-required)", async () => {
    const { data, error } = await supabase.rpc("api_get_saved_searches");
    if (error || isEmptyResponse(data)) return;
    assertContract("api_get_saved_searches", data, SavedSearchesContract);
  });
});

// ═══════════════════════════════════════════════════════════════════════════════
// P1 — Lists
// ═══════════════════════════════════════════════════════════════════════════════

describeIntegration("P1 Contract: api_get_lists", () => {
  it("returns valid lists shape (auth-required)", async () => {
    const { data, error } = await supabase.rpc("api_get_lists");
    if (error || isEmptyResponse(data)) return;
    assertContract("api_get_lists", data, ListsContract);
  });
});

// ═══════════════════════════════════════════════════════════════════════════════
// P1 — Compare
// ═══════════════════════════════════════════════════════════════════════════════

describeIntegration("P1 Contract: api_get_products_for_compare", () => {
  it("returns valid compare shape", async () => {
    const { data, error } = await supabase.rpc(
      "api_get_products_for_compare",
      { p_product_ids: [QA_PRODUCT_ID] },
    );
    expect(error).toBeNull();
    if (isEmptyResponse(data)) return; // products may not exist in staging
    assertContract(
      "api_get_products_for_compare",
      data,
      CompareContract,
    );
  });
});

// ═══════════════════════════════════════════════════════════════════════════════
// P1 — Health Profiles
// ═══════════════════════════════════════════════════════════════════════════════

describeIntegration("P1 Contract: api_list_health_profiles", () => {
  it("returns valid health profiles list (auth-required)", async () => {
    const { data, error } = await supabase.rpc("api_list_health_profiles");
    if (error || isEmptyResponse(data)) return;
    assertContract(
      "api_list_health_profiles",
      data,
      HealthProfileListContract,
    );
  });
});

describeIntegration("P1 Contract: api_get_active_health_profile", () => {
  it("returns valid active profile shape (auth-required)", async () => {
    const { data, error } = await supabase.rpc(
      "api_get_active_health_profile",
    );
    if (error || isEmptyResponse(data)) return;
    assertContract(
      "api_get_active_health_profile",
      data,
      HealthProfileActiveContract,
    );
  });
});

// ═══════════════════════════════════════════════════════════════════════════════
// P1 — User Preferences
// ═══════════════════════════════════════════════════════════════════════════════

describeIntegration("P1 Contract: api_get_user_preferences", () => {
  it("returns valid preferences shape (auth-required)", async () => {
    const { data, error } = await supabase.rpc("api_get_user_preferences");
    if (error || isEmptyResponse(data)) return;
    assertContract(
      "api_get_user_preferences",
      data,
      UserPreferencesContract,
    );
  });
});

// ═══════════════════════════════════════════════════════════════════════════════
// P1 — Scan History
// ═══════════════════════════════════════════════════════════════════════════════

describeIntegration("P1 Contract: api_get_scan_history", () => {
  it("returns valid scan history shape (auth-required)", async () => {
    const { data, error } = await supabase.rpc("api_get_scan_history", {
      p_page: 1,
      p_page_size: 5,
      p_filter: "all",
    });
    if (error || isEmptyResponse(data)) return;
    assertContract("api_get_scan_history", data, ScanHistoryContract);
  });
});

// ═══════════════════════════════════════════════════════════════════════════════
// P1 — Recently Viewed
// ═══════════════════════════════════════════════════════════════════════════════

describeIntegration("P1 Contract: api_get_recently_viewed", () => {
  it("returns valid recently viewed shape (auth-required)", async () => {
    const { data, error } = await supabase.rpc("api_get_recently_viewed");
    if (error || isEmptyResponse(data)) return;
    assertContract("api_get_recently_viewed", data, RecentlyViewedContract);
  });
});
