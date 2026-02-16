import { describe, it, expect, vi, beforeEach } from "vitest";
import {
  // User Preferences
  getUserPreferences,
  setUserPreferences,
  // Search
  searchProducts,
  searchAutocomplete,
  getFilterOptions,
  saveSearch,
  getSavedSearches,
  deleteSavedSearch,
  // Category
  getCategoryListing,
  getCategoryOverview,
  // Product Detail
  getProductDetail,
  lookupByEan,
  getBetterAlternatives,
  getScoreExplanation,
  getDataConfidence,
  // Health Profiles
  listHealthProfiles,
  getActiveHealthProfile,
  createHealthProfile,
  updateHealthProfile,
  deleteHealthProfile,
  getProductHealthWarnings,
  // Lists
  getLists,
  getListItems,
  createList,
  updateList,
  deleteList,
  addToList,
  removeFromList,
  reorderList,
  toggleShare,
  revokeShare,
  getSharedList,
  getAvoidProductIds,
  getProductListMembership,
  getFavoriteProductIds,
  // Comparisons
  getProductsForCompare,
  saveComparison,
  getSavedComparisons,
  getSharedComparison,
  deleteComparison,
  // Scanner & Submissions
  recordScan,
  getScanHistory,
  submitProduct,
  getMySubmissions,
  // Analytics
  trackEvent,
} from "@/lib/api";

// ─── Mock the RPC layer ─────────────────────────────────────────────────────

const mockCallRpc = vi.fn();

vi.mock("@/lib/rpc", () => ({
  callRpc: (...args: unknown[]) => mockCallRpc(...args),
}));

// ─── Helpers ────────────────────────────────────────────────────────────────

// eslint-disable-next-line @typescript-eslint/no-explicit-any
const fakeSupabase = {} as any;

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("Health Profile API functions", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  // ─── listHealthProfiles ───────────────────────────────────────────

  it("listHealthProfiles calls api_list_health_profiles with no params", async () => {
    mockCallRpc.mockResolvedValue({ ok: true, data: { profiles: [] } });
    await listHealthProfiles(fakeSupabase);
    expect(mockCallRpc).toHaveBeenCalledWith(
      fakeSupabase,
      "api_list_health_profiles",
    );
  });

  // ─── getActiveHealthProfile ───────────────────────────────────────

  it("getActiveHealthProfile calls api_get_active_health_profile", async () => {
    mockCallRpc.mockResolvedValue({ ok: true, data: { profile: null } });
    await getActiveHealthProfile(fakeSupabase);
    expect(mockCallRpc).toHaveBeenCalledWith(
      fakeSupabase,
      "api_get_active_health_profile",
    );
  });

  // ─── createHealthProfile ──────────────────────────────────────────

  it("createHealthProfile passes params to api_create_health_profile", async () => {
    const params = {
      p_profile_name: "Test",
      p_health_conditions: ["diabetes"],
      p_is_active: true,
      p_max_sugar_g: 25,
    };
    mockCallRpc.mockResolvedValue({
      ok: true,
      data: { profile_id: "abc", created: true },
    });
    await createHealthProfile(fakeSupabase, params);
    expect(mockCallRpc).toHaveBeenCalledWith(
      fakeSupabase,
      "api_create_health_profile",
      params,
    );
  });

  // ─── updateHealthProfile ──────────────────────────────────────────

  it("updateHealthProfile passes params to api_update_health_profile", async () => {
    const params = { p_profile_id: "p-1", p_profile_name: "Updated" };
    mockCallRpc.mockResolvedValue({
      ok: true,
      data: { profile_id: "p-1", updated: true },
    });
    await updateHealthProfile(fakeSupabase, params);
    expect(mockCallRpc).toHaveBeenCalledWith(
      fakeSupabase,
      "api_update_health_profile",
      params,
    );
  });

  it("updateHealthProfile passes clear flags to api_update_health_profile", async () => {
    const params = {
      p_profile_id: "p-2",
      p_clear_max_sugar: true,
      p_clear_max_salt: false,
      p_clear_max_sat_fat: true,
      p_clear_max_calories: false,
    };
    mockCallRpc.mockResolvedValue({
      ok: true,
      data: { profile_id: "p-2", updated: true },
    });
    await updateHealthProfile(fakeSupabase, params);
    expect(mockCallRpc).toHaveBeenCalledWith(
      fakeSupabase,
      "api_update_health_profile",
      params,
    );
  });

  // ─── deleteHealthProfile ──────────────────────────────────────────

  it("deleteHealthProfile passes profile_id to api_delete_health_profile", async () => {
    mockCallRpc.mockResolvedValue({
      ok: true,
      data: { profile_id: "d-1", deleted: true },
    });
    await deleteHealthProfile(fakeSupabase, "d-1");
    expect(mockCallRpc).toHaveBeenCalledWith(
      fakeSupabase,
      "api_delete_health_profile",
      { p_profile_id: "d-1" },
    );
  });

  // ─── getProductHealthWarnings ─────────────────────────────────────

  it("getProductHealthWarnings calls api_product_health_warnings with product_id", async () => {
    mockCallRpc.mockResolvedValue({
      ok: true,
      data: { product_id: 42, warning_count: 0, warnings: [] },
    });
    await getProductHealthWarnings(fakeSupabase, 42);
    expect(mockCallRpc).toHaveBeenCalledWith(
      fakeSupabase,
      "api_product_health_warnings",
      { p_product_id: 42 },
    );
  });

  it("getProductHealthWarnings includes profile_id when provided", async () => {
    mockCallRpc.mockResolvedValue({
      ok: true,
      data: { product_id: 42, warning_count: 1, warnings: [] },
    });
    await getProductHealthWarnings(fakeSupabase, 42, "prof-1");
    expect(mockCallRpc).toHaveBeenCalledWith(
      fakeSupabase,
      "api_product_health_warnings",
      { p_product_id: 42, p_profile_id: "prof-1" },
    );
  });
});

// ─── User Preferences ──────────────────────────────────────────────────────

describe("User Preferences API functions", () => {
  beforeEach(() => vi.clearAllMocks());

  it("getUserPreferences calls api_get_user_preferences with no params", async () => {
    mockCallRpc.mockResolvedValue({ ok: true, data: {} });
    await getUserPreferences(fakeSupabase);
    expect(mockCallRpc).toHaveBeenCalledWith(fakeSupabase, "api_get_user_preferences");
  });

  it("setUserPreferences passes prefs to api_set_user_preferences", async () => {
    const prefs = { p_country: "PL", p_diet_preference: "vegetarian" };
    mockCallRpc.mockResolvedValue({ ok: true, data: prefs });
    await setUserPreferences(fakeSupabase, prefs);
    expect(mockCallRpc).toHaveBeenCalledWith(fakeSupabase, "api_set_user_preferences", prefs);
  });
});

// ─── Search API functions ───────────────────────────────────────────────────

describe("Search API functions", () => {
  beforeEach(() => vi.clearAllMocks());

  it("searchProducts applies defaults for missing params", async () => {
    mockCallRpc.mockResolvedValue({ ok: true, data: { products: [] } });
    await searchProducts(fakeSupabase, {});
    expect(mockCallRpc).toHaveBeenCalledWith(fakeSupabase, "api_search_products", {
      p_query: null,
      p_filters: {},
      p_page: 1,
      p_page_size: 20,
      p_show_avoided: false,
    });
  });

  it("searchProducts passes explicit params", async () => {
    mockCallRpc.mockResolvedValue({ ok: true, data: { products: [] } });
    await searchProducts(fakeSupabase, {
      p_query: "chips",
      p_filters: { category: ["Chips"] },
      p_page: 2,
      p_page_size: 10,
      p_show_avoided: true,
    });
    expect(mockCallRpc).toHaveBeenCalledWith(fakeSupabase, "api_search_products", {
      p_query: "chips",
      p_filters: { category: ["Chips"] },
      p_page: 2,
      p_page_size: 10,
      p_show_avoided: true,
    });
  });

  it("searchAutocomplete passes query and optional limit", async () => {
    mockCallRpc.mockResolvedValue({ ok: true, data: { suggestions: [] } });
    await searchAutocomplete(fakeSupabase, "lay");
    expect(mockCallRpc).toHaveBeenCalledWith(fakeSupabase, "api_search_autocomplete", {
      p_query: "lay",
    });
  });

  it("searchAutocomplete includes p_limit when provided", async () => {
    mockCallRpc.mockResolvedValue({ ok: true, data: { suggestions: [] } });
    await searchAutocomplete(fakeSupabase, "lay", 5);
    expect(mockCallRpc).toHaveBeenCalledWith(fakeSupabase, "api_search_autocomplete", {
      p_query: "lay",
      p_limit: 5,
    });
  });

  it("getFilterOptions passes p_country: null", async () => {
    mockCallRpc.mockResolvedValue({ ok: true, data: {} });
    await getFilterOptions(fakeSupabase);
    expect(mockCallRpc).toHaveBeenCalledWith(fakeSupabase, "api_get_filter_options", {
      p_country: null,
    });
  });

  it("saveSearch passes name and optional query/filters", async () => {
    mockCallRpc.mockResolvedValue({ ok: true, data: { search_id: "s1" } });
    await saveSearch(fakeSupabase, "My Search", "chips", { category: ["Chips"] });
    expect(mockCallRpc).toHaveBeenCalledWith(fakeSupabase, "api_save_search", {
      p_name: "My Search",
      p_query: "chips",
      p_filters: { category: ["Chips"] },
    });
  });

  it("saveSearch omits query when not provided", async () => {
    mockCallRpc.mockResolvedValue({ ok: true, data: { search_id: "s2" } });
    await saveSearch(fakeSupabase, "No Query");
    expect(mockCallRpc).toHaveBeenCalledWith(fakeSupabase, "api_save_search", {
      p_name: "No Query",
    });
  });

  it("getSavedSearches calls api_get_saved_searches", async () => {
    mockCallRpc.mockResolvedValue({ ok: true, data: { searches: [] } });
    await getSavedSearches(fakeSupabase);
    expect(mockCallRpc).toHaveBeenCalledWith(fakeSupabase, "api_get_saved_searches");
  });

  it("deleteSavedSearch passes search ID", async () => {
    mockCallRpc.mockResolvedValue({ ok: true, data: { deleted: true } });
    await deleteSavedSearch(fakeSupabase, "s-123");
    expect(mockCallRpc).toHaveBeenCalledWith(fakeSupabase, "api_delete_saved_search", {
      p_id: "s-123",
    });
  });
});

// ─── Category API functions ─────────────────────────────────────────────────

describe("Category API functions", () => {
  beforeEach(() => vi.clearAllMocks());

  it("getCategoryListing passes params with p_country: null", async () => {
    const params = { p_category: "Chips", p_sort_by: "name", p_limit: 10 };
    mockCallRpc.mockResolvedValue({ ok: true, data: { products: [] } });
    await getCategoryListing(fakeSupabase, params);
    expect(mockCallRpc).toHaveBeenCalledWith(fakeSupabase, "api_category_listing", {
      ...params,
      p_country: null,
    });
  });

  it("getCategoryOverview unwraps categories from response", async () => {
    const categories = [{ category: "Chips", count: 50 }];
    mockCallRpc.mockResolvedValue({
      ok: true,
      data: { api_version: "1.0", country: "PL", categories },
    });
    const result = await getCategoryOverview(fakeSupabase);
    expect(result).toEqual({ ok: true, data: categories });
    expect(mockCallRpc).toHaveBeenCalledWith(fakeSupabase, "api_category_overview", {
      p_country: null,
    });
  });

  it("getCategoryOverview passes through errors", async () => {
    const err = { ok: false, error: { code: "ERR", message: "fail" } };
    mockCallRpc.mockResolvedValue(err);
    const result = await getCategoryOverview(fakeSupabase);
    expect(result.ok).toBe(false);
  });
});

// ─── Product Detail API functions ───────────────────────────────────────────

describe("Product Detail API functions", () => {
  beforeEach(() => vi.clearAllMocks());

  it("getProductDetail passes product_id", async () => {
    mockCallRpc.mockResolvedValue({ ok: true, data: { product_id: 42 } });
    await getProductDetail(fakeSupabase, 42);
    expect(mockCallRpc).toHaveBeenCalledWith(fakeSupabase, "api_product_detail", {
      p_product_id: 42,
    });
  });

  it("lookupByEan passes ean with p_country: null", async () => {
    mockCallRpc.mockResolvedValue({ ok: true, data: { found: true } });
    await lookupByEan(fakeSupabase, "5901234123457");
    expect(mockCallRpc).toHaveBeenCalledWith(fakeSupabase, "api_product_detail_by_ean", {
      p_ean: "5901234123457",
      p_country: null,
    });
  });

  it("getBetterAlternatives passes product_id and optional params", async () => {
    mockCallRpc.mockResolvedValue({ ok: true, data: { alternatives: [] } });
    await getBetterAlternatives(fakeSupabase, 42, { p_same_category: true, p_limit: 5 });
    expect(mockCallRpc).toHaveBeenCalledWith(fakeSupabase, "api_better_alternatives", {
      p_product_id: 42,
      p_same_category: true,
      p_limit: 5,
    });
  });

  it("getBetterAlternatives works without optional params", async () => {
    mockCallRpc.mockResolvedValue({ ok: true, data: { alternatives: [] } });
    await getBetterAlternatives(fakeSupabase, 42);
    expect(mockCallRpc).toHaveBeenCalledWith(fakeSupabase, "api_better_alternatives", {
      p_product_id: 42,
    });
  });

  it("getScoreExplanation passes product_id", async () => {
    mockCallRpc.mockResolvedValue({ ok: true, data: {} });
    await getScoreExplanation(fakeSupabase, 42);
    expect(mockCallRpc).toHaveBeenCalledWith(fakeSupabase, "api_score_explanation", {
      p_product_id: 42,
    });
  });

  it("getDataConfidence passes product_id", async () => {
    mockCallRpc.mockResolvedValue({ ok: true, data: {} });
    await getDataConfidence(fakeSupabase, 42);
    expect(mockCallRpc).toHaveBeenCalledWith(fakeSupabase, "api_data_confidence", {
      p_product_id: 42,
    });
  });
});

// ─── Product Lists API functions ────────────────────────────────────────────

describe("Product Lists API functions", () => {
  beforeEach(() => vi.clearAllMocks());

  it("getLists calls api_get_lists", async () => {
    mockCallRpc.mockResolvedValue({ ok: true, data: { lists: [] } });
    await getLists(fakeSupabase);
    expect(mockCallRpc).toHaveBeenCalledWith(fakeSupabase, "api_get_lists");
  });

  it("getListItems passes list_id and optional pagination", async () => {
    mockCallRpc.mockResolvedValue({ ok: true, data: { items: [] } });
    await getListItems(fakeSupabase, "list-1", 10, 20);
    expect(mockCallRpc).toHaveBeenCalledWith(fakeSupabase, "api_get_list_items", {
      p_list_id: "list-1",
      p_limit: 10,
      p_offset: 20,
    });
  });

  it("getListItems omits pagination when not provided", async () => {
    mockCallRpc.mockResolvedValue({ ok: true, data: { items: [] } });
    await getListItems(fakeSupabase, "list-1");
    expect(mockCallRpc).toHaveBeenCalledWith(fakeSupabase, "api_get_list_items", {
      p_list_id: "list-1",
    });
  });

  it("createList passes name and optional description/type", async () => {
    mockCallRpc.mockResolvedValue({ ok: true, data: { list_id: "new-1" } });
    await createList(fakeSupabase, "Favorites", "My faves", "favorites");
    expect(mockCallRpc).toHaveBeenCalledWith(fakeSupabase, "api_create_list", {
      p_name: "Favorites",
      p_description: "My faves",
      p_list_type: "favorites",
    });
  });

  it("createList omits optional fields when not provided", async () => {
    mockCallRpc.mockResolvedValue({ ok: true, data: { list_id: "new-2" } });
    await createList(fakeSupabase, "Simple");
    expect(mockCallRpc).toHaveBeenCalledWith(fakeSupabase, "api_create_list", {
      p_name: "Simple",
    });
  });

  it("updateList passes list_id and optional fields", async () => {
    mockCallRpc.mockResolvedValue({ ok: true, data: { success: true } });
    await updateList(fakeSupabase, "list-1", "New Name", "New desc");
    expect(mockCallRpc).toHaveBeenCalledWith(fakeSupabase, "api_update_list", {
      p_list_id: "list-1",
      p_name: "New Name",
      p_description: "New desc",
    });
  });

  it("deleteList passes list_id", async () => {
    mockCallRpc.mockResolvedValue({ ok: true, data: { success: true } });
    await deleteList(fakeSupabase, "list-1");
    expect(mockCallRpc).toHaveBeenCalledWith(fakeSupabase, "api_delete_list", {
      p_list_id: "list-1",
    });
  });

  it("addToList passes list_id, product_id, and optional notes", async () => {
    mockCallRpc.mockResolvedValue({ ok: true, data: { added: true } });
    await addToList(fakeSupabase, "list-1", 42, "Great snack");
    expect(mockCallRpc).toHaveBeenCalledWith(fakeSupabase, "api_add_to_list", {
      p_list_id: "list-1",
      p_product_id: 42,
      p_notes: "Great snack",
    });
  });

  it("addToList omits notes when not provided", async () => {
    mockCallRpc.mockResolvedValue({ ok: true, data: { added: true } });
    await addToList(fakeSupabase, "list-1", 42);
    expect(mockCallRpc).toHaveBeenCalledWith(fakeSupabase, "api_add_to_list", {
      p_list_id: "list-1",
      p_product_id: 42,
    });
  });

  it("removeFromList passes list_id and product_id", async () => {
    mockCallRpc.mockResolvedValue({ ok: true, data: { success: true } });
    await removeFromList(fakeSupabase, "list-1", 42);
    expect(mockCallRpc).toHaveBeenCalledWith(fakeSupabase, "api_remove_from_list", {
      p_list_id: "list-1",
      p_product_id: 42,
    });
  });

  it("reorderList passes list_id and product_ids array", async () => {
    mockCallRpc.mockResolvedValue({ ok: true, data: { success: true } });
    await reorderList(fakeSupabase, "list-1", [3, 1, 2]);
    expect(mockCallRpc).toHaveBeenCalledWith(fakeSupabase, "api_reorder_list", {
      p_list_id: "list-1",
      p_product_ids: [3, 1, 2],
    });
  });

  it("toggleShare passes list_id and enabled flag", async () => {
    mockCallRpc.mockResolvedValue({ ok: true, data: { share_token: "abc" } });
    await toggleShare(fakeSupabase, "list-1", true);
    expect(mockCallRpc).toHaveBeenCalledWith(fakeSupabase, "api_toggle_share", {
      p_list_id: "list-1",
      p_enabled: true,
    });
  });

  it("revokeShare passes list_id", async () => {
    mockCallRpc.mockResolvedValue({ ok: true, data: { success: true } });
    await revokeShare(fakeSupabase, "list-1");
    expect(mockCallRpc).toHaveBeenCalledWith(fakeSupabase, "api_revoke_share", {
      p_list_id: "list-1",
    });
  });

  it("getSharedList passes share_token and optional pagination", async () => {
    mockCallRpc.mockResolvedValue({ ok: true, data: { items: [] } });
    await getSharedList(fakeSupabase, "tok-abc", 10, 0);
    expect(mockCallRpc).toHaveBeenCalledWith(fakeSupabase, "api_get_shared_list", {
      p_share_token: "tok-abc",
      p_limit: 10,
      p_offset: 0,
    });
  });

  it("getSharedList omits pagination when not provided", async () => {
    mockCallRpc.mockResolvedValue({ ok: true, data: { items: [] } });
    await getSharedList(fakeSupabase, "tok-abc");
    expect(mockCallRpc).toHaveBeenCalledWith(fakeSupabase, "api_get_shared_list", {
      p_share_token: "tok-abc",
    });
  });

  it("getAvoidProductIds calls api_get_avoid_product_ids", async () => {
    mockCallRpc.mockResolvedValue({ ok: true, data: { product_ids: [] } });
    await getAvoidProductIds(fakeSupabase);
    expect(mockCallRpc).toHaveBeenCalledWith(fakeSupabase, "api_get_avoid_product_ids");
  });

  it("getProductListMembership passes product_id", async () => {
    mockCallRpc.mockResolvedValue({ ok: true, data: { lists: [] } });
    await getProductListMembership(fakeSupabase, 42);
    expect(mockCallRpc).toHaveBeenCalledWith(fakeSupabase, "api_get_product_list_membership", {
      p_product_id: 42,
    });
  });

  it("getFavoriteProductIds calls api_get_favorite_product_ids", async () => {
    mockCallRpc.mockResolvedValue({ ok: true, data: { product_ids: [] } });
    await getFavoriteProductIds(fakeSupabase);
    expect(mockCallRpc).toHaveBeenCalledWith(fakeSupabase, "api_get_favorite_product_ids");
  });
});

// ─── Product Comparisons API functions ──────────────────────────────────────

describe("Product Comparisons API functions", () => {
  beforeEach(() => vi.clearAllMocks());

  it("getProductsForCompare passes product_ids array", async () => {
    mockCallRpc.mockResolvedValue({ ok: true, data: { products: [] } });
    await getProductsForCompare(fakeSupabase, [1, 2, 3]);
    expect(mockCallRpc).toHaveBeenCalledWith(fakeSupabase, "api_get_products_for_compare", {
      p_product_ids: [1, 2, 3],
    });
  });

  it("saveComparison passes product_ids and optional title", async () => {
    mockCallRpc.mockResolvedValue({ ok: true, data: { comparison_id: "c1" } });
    await saveComparison(fakeSupabase, [1, 2], "My Compare");
    expect(mockCallRpc).toHaveBeenCalledWith(fakeSupabase, "api_save_comparison", {
      p_product_ids: [1, 2],
      p_title: "My Compare",
    });
  });

  it("saveComparison omits title when not provided", async () => {
    mockCallRpc.mockResolvedValue({ ok: true, data: { comparison_id: "c2" } });
    await saveComparison(fakeSupabase, [1, 2]);
    expect(mockCallRpc).toHaveBeenCalledWith(fakeSupabase, "api_save_comparison", {
      p_product_ids: [1, 2],
    });
  });

  it("getSavedComparisons passes optional pagination", async () => {
    mockCallRpc.mockResolvedValue({ ok: true, data: { comparisons: [] } });
    await getSavedComparisons(fakeSupabase, 5, 10);
    expect(mockCallRpc).toHaveBeenCalledWith(fakeSupabase, "api_get_saved_comparisons", {
      p_limit: 5,
      p_offset: 10,
    });
  });

  it("getSavedComparisons omits pagination when not provided", async () => {
    mockCallRpc.mockResolvedValue({ ok: true, data: { comparisons: [] } });
    await getSavedComparisons(fakeSupabase);
    expect(mockCallRpc).toHaveBeenCalledWith(fakeSupabase, "api_get_saved_comparisons", {});
  });

  it("getSharedComparison passes share_token", async () => {
    mockCallRpc.mockResolvedValue({ ok: true, data: { products: [] } });
    await getSharedComparison(fakeSupabase, "share-xyz");
    expect(mockCallRpc).toHaveBeenCalledWith(fakeSupabase, "api_get_shared_comparison", {
      p_share_token: "share-xyz",
    });
  });

  it("deleteComparison passes comparison_id", async () => {
    mockCallRpc.mockResolvedValue({ ok: true, data: { success: true } });
    await deleteComparison(fakeSupabase, "comp-1");
    expect(mockCallRpc).toHaveBeenCalledWith(fakeSupabase, "api_delete_comparison", {
      p_comparison_id: "comp-1",
    });
  });
});

// ─── Scanner & Submissions API functions ────────────────────────────────────

describe("Scanner & Submissions API functions", () => {
  beforeEach(() => vi.clearAllMocks());

  it("recordScan passes ean", async () => {
    mockCallRpc.mockResolvedValue({ ok: true, data: { scan_id: "s1" } });
    await recordScan(fakeSupabase, "5901234123457");
    expect(mockCallRpc).toHaveBeenCalledWith(fakeSupabase, "api_record_scan", {
      p_ean: "5901234123457",
    });
  });

  it("getScanHistory applies defaults for missing params", async () => {
    mockCallRpc.mockResolvedValue({ ok: true, data: { scans: [] } });
    await getScanHistory(fakeSupabase);
    expect(mockCallRpc).toHaveBeenCalledWith(fakeSupabase, "api_get_scan_history", {
      p_page: 1,
      p_page_size: 20,
      p_filter: "all",
    });
  });

  it("getScanHistory passes explicit params", async () => {
    mockCallRpc.mockResolvedValue({ ok: true, data: { scans: [] } });
    await getScanHistory(fakeSupabase, 2, 10, "found");
    expect(mockCallRpc).toHaveBeenCalledWith(fakeSupabase, "api_get_scan_history", {
      p_page: 2,
      p_page_size: 10,
      p_filter: "found",
    });
  });

  it("submitProduct passes full parameter set with defaults", async () => {
    mockCallRpc.mockResolvedValue({ ok: true, data: { submission_id: "sub1" } });
    await submitProduct(fakeSupabase, { ean: "123", productName: "Test" });
    expect(mockCallRpc).toHaveBeenCalledWith(fakeSupabase, "api_submit_product", {
      p_ean: "123",
      p_product_name: "Test",
      p_brand: null,
      p_category: null,
      p_photo_url: null,
      p_notes: null,
    });
  });

  it("submitProduct passes all optional fields", async () => {
    mockCallRpc.mockResolvedValue({ ok: true, data: { submission_id: "sub2" } });
    await submitProduct(fakeSupabase, {
      ean: "123",
      productName: "Test",
      brand: "Lay's",
      category: "Chips",
      photoUrl: "https://example.com/img.jpg",
      notes: "Found at Żabka",
    });
    expect(mockCallRpc).toHaveBeenCalledWith(fakeSupabase, "api_submit_product", {
      p_ean: "123",
      p_product_name: "Test",
      p_brand: "Lay's",
      p_category: "Chips",
      p_photo_url: "https://example.com/img.jpg",
      p_notes: "Found at Żabka",
    });
  });

  it("getMySubmissions applies defaults for missing params", async () => {
    mockCallRpc.mockResolvedValue({ ok: true, data: { submissions: [] } });
    await getMySubmissions(fakeSupabase);
    expect(mockCallRpc).toHaveBeenCalledWith(fakeSupabase, "api_get_my_submissions", {
      p_page: 1,
      p_page_size: 20,
    });
  });

  it("getMySubmissions passes explicit pagination", async () => {
    mockCallRpc.mockResolvedValue({ ok: true, data: { submissions: [] } });
    await getMySubmissions(fakeSupabase, 3, 5);
    expect(mockCallRpc).toHaveBeenCalledWith(fakeSupabase, "api_get_my_submissions", {
      p_page: 3,
      p_page_size: 5,
    });
  });
});

// ─── Analytics ──────────────────────────────────────────────────────────────

describe("Analytics API functions", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("trackEvent calls api_track_event with all parameters", async () => {
    mockCallRpc.mockResolvedValue({ ok: true, data: { api_version: "1.0.0", tracked: true } });
    await trackEvent(fakeSupabase, {
      eventName: "search_performed",
      eventData: { query: "milk" },
      sessionId: "sess-123",
      deviceType: "mobile",
    });
    expect(mockCallRpc).toHaveBeenCalledWith(fakeSupabase, "api_track_event", {
      p_event_name: "search_performed",
      p_event_data: { query: "milk" },
      p_session_id: "sess-123",
      p_device_type: "mobile",
    });
  });

  it("trackEvent defaults optional params to null", async () => {
    mockCallRpc.mockResolvedValue({ ok: true, data: { api_version: "1.0.0", tracked: true } });
    await trackEvent(fakeSupabase, {
      eventName: "product_viewed",
    });
    expect(mockCallRpc).toHaveBeenCalledWith(fakeSupabase, "api_track_event", {
      p_event_name: "product_viewed",
      p_event_data: null,
      p_session_id: null,
      p_device_type: null,
    });
  });
});
