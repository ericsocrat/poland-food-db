// ─── API layer: typed RPC wrappers ──────────────────────────────────────────
// All product functions pass p_country: null — backend resolves from user_preferences.
// Frontend NEVER passes a country explicitly.

import { SupabaseClient } from "@supabase/supabase-js";
import { callRpc } from "./rpc";
import type {
  AddToListResponse,
  AlternativesResponse,
  AutocompleteResponse,
  AvoidProductIdsResponse,
  CategoryListingResponse,
  CategoryOverviewItem,
  CompareResponse,
  CreateListResponse,
  DataConfidence,
  DeleteSavedSearchResponse,
  EanLookupResponse,
  EanNotFoundResponse,
  FavoriteProductIdsResponse,
  FilterOptionsResponse,
  HealthProfileActiveResponse,
  HealthProfileListResponse,
  HealthProfileMutationResponse,
  HealthWarningsResponse,
  ListItemsResponse,
  ListsResponse,
  MutationSuccess,
  ProductDetail,
  ProductListMembershipResponse,
  RecordScanResponse,
  RpcResult,
  SaveComparisonResponse,
  SavedComparisonsResponse,
  SavedSearchesResponse,
  SaveSearchResponse,
  ScanHistoryResponse,
  ScoreExplanation,
  SearchFilters,
  SearchResponse,
  SharedComparisonResponse,
  SharedListResponse,
  SubmissionsResponse,
  SubmitProductResponse,
  ToggleShareResponse,
  TrackEventResponse,
  UserPreferences,
} from "./types";
import type { AnalyticsEventName, DeviceType } from "./types";
import type {
  DashboardData,
  RecentlyViewedResponse,
  RecordProductViewResponse,
} from "./types";

// ─── User Preferences ──────────────────────────────────────────────────────

export function getUserPreferences(
  supabase: SupabaseClient,
): Promise<RpcResult<UserPreferences>> {
  return callRpc<UserPreferences>(supabase, "api_get_user_preferences");
}

export function setUserPreferences(
  supabase: SupabaseClient,
  prefs: {
    p_country?: string;
    p_diet_preference?: string;
    p_avoid_allergens?: string[];
    p_strict_allergen?: boolean;
    p_strict_diet?: boolean;
    p_treat_may_contain_as_unsafe?: boolean;
  },
): Promise<RpcResult<UserPreferences>> {
  return callRpc<UserPreferences>(
    supabase,
    "api_set_user_preferences",
    prefs,
  );
}

// ─── Search ─────────────────────────────────────────────────────────────────

export function searchProducts(
  supabase: SupabaseClient,
  params: {
    p_query?: string;
    p_filters?: SearchFilters;
    p_page?: number;
    p_page_size?: number;
    p_show_avoided?: boolean;
  },
): Promise<RpcResult<SearchResponse>> {
  return callRpc<SearchResponse>(supabase, "api_search_products", {
    p_query: params.p_query ?? null,
    p_filters: params.p_filters ?? {},
    p_page: params.p_page ?? 1,
    p_page_size: params.p_page_size ?? 20,
    p_show_avoided: params.p_show_avoided ?? false,
  });
}

export function searchAutocomplete(
  supabase: SupabaseClient,
  query: string,
  limit?: number,
): Promise<RpcResult<AutocompleteResponse>> {
  return callRpc<AutocompleteResponse>(supabase, "api_search_autocomplete", {
    p_query: query,
    ...(limit === undefined ? {} : { p_limit: limit }),
  });
}

export function getFilterOptions(
  supabase: SupabaseClient,
): Promise<RpcResult<FilterOptionsResponse>> {
  return callRpc<FilterOptionsResponse>(supabase, "api_get_filter_options", {
    p_country: null,
  });
}

export function saveSearch(
  supabase: SupabaseClient,
  name: string,
  query?: string,
  filters?: SearchFilters,
): Promise<RpcResult<SaveSearchResponse>> {
  return callRpc<SaveSearchResponse>(supabase, "api_save_search", {
    p_name: name,
    ...(query ? { p_query: query } : {}),
    ...(filters ? { p_filters: filters } : {}),
  });
}

export function getSavedSearches(
  supabase: SupabaseClient,
): Promise<RpcResult<SavedSearchesResponse>> {
  return callRpc<SavedSearchesResponse>(supabase, "api_get_saved_searches");
}

export function deleteSavedSearch(
  supabase: SupabaseClient,
  searchId: string,
): Promise<RpcResult<DeleteSavedSearchResponse>> {
  return callRpc<DeleteSavedSearchResponse>(
    supabase,
    "api_delete_saved_search",
    { p_id: searchId },
  );
}

// ─── Category Listing ───────────────────────────────────────────────────────

export function getCategoryListing(
  supabase: SupabaseClient,
  params: {
    p_category: string;
    p_sort_by?: string;
    p_sort_dir?: string;
    p_limit?: number;
    p_offset?: number;
    p_diet_preference?: string;
    p_avoid_allergens?: string[];
    p_strict_diet?: boolean;
    p_strict_allergen?: boolean;
    p_treat_may_contain?: boolean;
  },
): Promise<RpcResult<CategoryListingResponse>> {
  return callRpc<CategoryListingResponse>(supabase, "api_category_listing", {
    ...params,
    p_country: null,
  });
}

// ─── Category Overview ──────────────────────────────────────────────────────

export async function getCategoryOverview(
  supabase: SupabaseClient,
): Promise<RpcResult<CategoryOverviewItem[]>> {
  const result = await callRpc<{ api_version: string; country: string; categories: CategoryOverviewItem[] }>(
    supabase,
    "api_category_overview",
    { p_country: null },
  );

  if (!result.ok) return result;

  // Unwrap: the RPC returns { api_version, country, categories: [...] }
  return { ok: true, data: result.data.categories };
}

// ─── Product Detail ─────────────────────────────────────────────────────────

export function getProductDetail(
  supabase: SupabaseClient,
  productId: number,
): Promise<RpcResult<ProductDetail>> {
  return callRpc<ProductDetail>(supabase, "api_product_detail", {
    p_product_id: productId,
  });
}

// ─── EAN Lookup (Barcode) ───────────────────────────────────────────────────

export function lookupByEan(
  supabase: SupabaseClient,
  ean: string,
): Promise<RpcResult<EanLookupResponse | EanNotFoundResponse>> {
  return callRpc<EanLookupResponse | EanNotFoundResponse>(
    supabase,
    "api_product_detail_by_ean",
    {
      p_ean: ean,
      p_country: null,
    },
  );
}

// ─── Better Alternatives ────────────────────────────────────────────────────

export function getBetterAlternatives(
  supabase: SupabaseClient,
  productId: number,
  params?: {
    p_same_category?: boolean;
    p_limit?: number;
    p_diet_preference?: string;
    p_avoid_allergens?: string[];
    p_strict_diet?: boolean;
    p_strict_allergen?: boolean;
    p_treat_may_contain?: boolean;
  },
): Promise<RpcResult<AlternativesResponse>> {
  return callRpc<AlternativesResponse>(supabase, "api_better_alternatives", {
    p_product_id: productId,
    ...params,
  });
}

// ─── Score Explanation ──────────────────────────────────────────────────────

export function getScoreExplanation(
  supabase: SupabaseClient,
  productId: number,
): Promise<RpcResult<ScoreExplanation>> {
  return callRpc<ScoreExplanation>(supabase, "api_score_explanation", {
    p_product_id: productId,
  });
}

// ─── Data Confidence ────────────────────────────────────────────────────────

export function getDataConfidence(
  supabase: SupabaseClient,
  productId: number,
): Promise<RpcResult<DataConfidence>> {
  return callRpc<DataConfidence>(supabase, "api_data_confidence", {
    p_product_id: productId,
  });
}

// ─── Health Profiles ────────────────────────────────────────────────────────

export function listHealthProfiles(
  supabase: SupabaseClient,
): Promise<RpcResult<HealthProfileListResponse>> {
  return callRpc<HealthProfileListResponse>(
    supabase,
    "api_list_health_profiles",
  );
}

export function getActiveHealthProfile(
  supabase: SupabaseClient,
): Promise<RpcResult<HealthProfileActiveResponse>> {
  return callRpc<HealthProfileActiveResponse>(
    supabase,
    "api_get_active_health_profile",
  );
}

export function createHealthProfile(
  supabase: SupabaseClient,
  params: {
    p_profile_name: string;
    p_health_conditions?: string[];
    p_is_active?: boolean;
    p_max_sugar_g?: number;
    p_max_salt_g?: number;
    p_max_saturated_fat_g?: number;
    p_max_calories_kcal?: number;
    p_notes?: string;
  },
): Promise<RpcResult<HealthProfileMutationResponse>> {
  return callRpc<HealthProfileMutationResponse>(
    supabase,
    "api_create_health_profile",
    params,
  );
}

export function updateHealthProfile(
  supabase: SupabaseClient,
  params: {
    p_profile_id: string;
    p_profile_name?: string;
    p_health_conditions?: string[];
    p_is_active?: boolean;
    p_max_sugar_g?: number;
    p_max_salt_g?: number;
    p_max_saturated_fat_g?: number;
    p_max_calories_kcal?: number;
    p_notes?: string;
    p_clear_max_sugar?: boolean;
    p_clear_max_salt?: boolean;
    p_clear_max_sat_fat?: boolean;
    p_clear_max_calories?: boolean;
  },
): Promise<RpcResult<HealthProfileMutationResponse>> {
  return callRpc<HealthProfileMutationResponse>(
    supabase,
    "api_update_health_profile",
    params,
  );
}

export function deleteHealthProfile(
  supabase: SupabaseClient,
  profileId: string,
): Promise<RpcResult<HealthProfileMutationResponse>> {
  return callRpc<HealthProfileMutationResponse>(
    supabase,
    "api_delete_health_profile",
    { p_profile_id: profileId },
  );
}

export function getProductHealthWarnings(
  supabase: SupabaseClient,
  productId: number,
  profileId?: string,
): Promise<RpcResult<HealthWarningsResponse>> {
  return callRpc<HealthWarningsResponse>(
    supabase,
    "api_product_health_warnings",
    {
      p_product_id: productId,
      ...(profileId ? { p_profile_id: profileId } : {}),
    },
  );
}

// ─── Product Lists ──────────────────────────────────────────────────────────

export function getLists(
  supabase: SupabaseClient,
): Promise<RpcResult<ListsResponse>> {
  return callRpc<ListsResponse>(supabase, "api_get_lists");
}

export function getListItems(
  supabase: SupabaseClient,
  listId: string,
  limit?: number,
  offset?: number,
): Promise<RpcResult<ListItemsResponse>> {
  return callRpc<ListItemsResponse>(supabase, "api_get_list_items", {
    p_list_id: listId,
    ...(limit === undefined ? {} : { p_limit: limit }),
    ...(offset === undefined ? {} : { p_offset: offset }),
  });
}

export function createList(
  supabase: SupabaseClient,
  name: string,
  description?: string,
  listType?: string,
): Promise<RpcResult<CreateListResponse>> {
  return callRpc<CreateListResponse>(supabase, "api_create_list", {
    p_name: name,
    ...(description ? { p_description: description } : {}),
    ...(listType ? { p_list_type: listType } : {}),
  });
}

export function updateList(
  supabase: SupabaseClient,
  listId: string,
  name?: string,
  description?: string,
): Promise<RpcResult<MutationSuccess>> {
  return callRpc<MutationSuccess>(supabase, "api_update_list", {
    p_list_id: listId,
    ...(name === undefined ? {} : { p_name: name }),
    ...(description === undefined ? {} : { p_description: description }),
  });
}

export function deleteList(
  supabase: SupabaseClient,
  listId: string,
): Promise<RpcResult<MutationSuccess>> {
  return callRpc<MutationSuccess>(supabase, "api_delete_list", {
    p_list_id: listId,
  });
}

export function addToList(
  supabase: SupabaseClient,
  listId: string,
  productId: number,
  notes?: string,
): Promise<RpcResult<AddToListResponse>> {
  return callRpc<AddToListResponse>(supabase, "api_add_to_list", {
    p_list_id: listId,
    p_product_id: productId,
    ...(notes ? { p_notes: notes } : {}),
  });
}

export function removeFromList(
  supabase: SupabaseClient,
  listId: string,
  productId: number,
): Promise<RpcResult<MutationSuccess>> {
  return callRpc<MutationSuccess>(supabase, "api_remove_from_list", {
    p_list_id: listId,
    p_product_id: productId,
  });
}

export function reorderList(
  supabase: SupabaseClient,
  listId: string,
  productIds: number[],
): Promise<RpcResult<MutationSuccess>> {
  return callRpc<MutationSuccess>(supabase, "api_reorder_list", {
    p_list_id: listId,
    p_product_ids: productIds,
  });
}

export function toggleShare(
  supabase: SupabaseClient,
  listId: string,
  enabled: boolean,
): Promise<RpcResult<ToggleShareResponse>> {
  return callRpc<ToggleShareResponse>(supabase, "api_toggle_share", {
    p_list_id: listId,
    p_enabled: enabled,
  });
}

export function revokeShare(
  supabase: SupabaseClient,
  listId: string,
): Promise<RpcResult<MutationSuccess>> {
  return callRpc<MutationSuccess>(supabase, "api_revoke_share", {
    p_list_id: listId,
  });
}

export function getSharedList(
  supabase: SupabaseClient,
  shareToken: string,
  limit?: number,
  offset?: number,
): Promise<RpcResult<SharedListResponse>> {
  return callRpc<SharedListResponse>(supabase, "api_get_shared_list", {
    p_share_token: shareToken,
    ...(limit === undefined ? {} : { p_limit: limit }),
    ...(offset === undefined ? {} : { p_offset: offset }),
  });
}

export function getAvoidProductIds(
  supabase: SupabaseClient,
): Promise<RpcResult<AvoidProductIdsResponse>> {
  return callRpc<AvoidProductIdsResponse>(
    supabase,
    "api_get_avoid_product_ids",
  );
}

export function getProductListMembership(
  supabase: SupabaseClient,
  productId: number,
): Promise<RpcResult<ProductListMembershipResponse>> {
  return callRpc<ProductListMembershipResponse>(
    supabase,
    "api_get_product_list_membership",
    { p_product_id: productId },
  );
}

export function getFavoriteProductIds(
  supabase: SupabaseClient,
): Promise<RpcResult<FavoriteProductIdsResponse>> {
  return callRpc<FavoriteProductIdsResponse>(
    supabase,
    "api_get_favorite_product_ids",
  );
}

// ─── Product Comparisons ────────────────────────────────────────────────────

export function getProductsForCompare(
  supabase: SupabaseClient,
  productIds: number[],
): Promise<RpcResult<CompareResponse>> {
  return callRpc<CompareResponse>(supabase, "api_get_products_for_compare", {
    p_product_ids: productIds,
  });
}

export function saveComparison(
  supabase: SupabaseClient,
  productIds: number[],
  title?: string,
): Promise<RpcResult<SaveComparisonResponse>> {
  return callRpc<SaveComparisonResponse>(supabase, "api_save_comparison", {
    p_product_ids: productIds,
    ...(title ? { p_title: title } : {}),
  });
}

export function getSavedComparisons(
  supabase: SupabaseClient,
  limit?: number,
  offset?: number,
): Promise<RpcResult<SavedComparisonsResponse>> {
  return callRpc<SavedComparisonsResponse>(
    supabase,
    "api_get_saved_comparisons",
    {
      ...(limit === undefined ? {} : { p_limit: limit }),
      ...(offset === undefined ? {} : { p_offset: offset }),
    },
  );
}

export function getSharedComparison(
  supabase: SupabaseClient,
  shareToken: string,
): Promise<RpcResult<SharedComparisonResponse>> {
  return callRpc<SharedComparisonResponse>(
    supabase,
    "api_get_shared_comparison",
    { p_share_token: shareToken },
  );
}

export function deleteComparison(
  supabase: SupabaseClient,
  comparisonId: string,
): Promise<RpcResult<MutationSuccess>> {
  return callRpc<MutationSuccess>(supabase, "api_delete_comparison", {
    p_comparison_id: comparisonId,
  });
}

// ─── Scanner & Submissions ──────────────────────────────────────────────────

export function recordScan(
  supabase: SupabaseClient,
  ean: string,
): Promise<RpcResult<RecordScanResponse>> {
  return callRpc<RecordScanResponse>(supabase, "api_record_scan", {
    p_ean: ean,
  });
}

export function getScanHistory(
  supabase: SupabaseClient,
  page?: number,
  pageSize?: number,
  filter?: string,
): Promise<RpcResult<ScanHistoryResponse>> {
  return callRpc<ScanHistoryResponse>(supabase, "api_get_scan_history", {
    p_page: page ?? 1,
    p_page_size: pageSize ?? 20,
    p_filter: filter ?? "all",
  });
}

export function submitProduct(
  supabase: SupabaseClient,
  params: {
    ean: string;
    productName: string;
    brand?: string;
    category?: string;
    photoUrl?: string;
    notes?: string;
  },
): Promise<RpcResult<SubmitProductResponse>> {
  return callRpc<SubmitProductResponse>(supabase, "api_submit_product", {
    p_ean: params.ean,
    p_product_name: params.productName,
    p_brand: params.brand ?? null,
    p_category: params.category ?? null,
    p_photo_url: params.photoUrl ?? null,
    p_notes: params.notes ?? null,
  });
}

export function getMySubmissions(
  supabase: SupabaseClient,
  page?: number,
  pageSize?: number,
): Promise<RpcResult<SubmissionsResponse>> {
  return callRpc<SubmissionsResponse>(supabase, "api_get_my_submissions", {
    p_page: page ?? 1,
    p_page_size: pageSize ?? 20,
  });
}

// ─── Analytics / Telemetry ──────────────────────────────────────────────────

export function trackEvent(
  supabase: SupabaseClient,
  params: {
    eventName: AnalyticsEventName;
    eventData?: Record<string, unknown>;
    sessionId?: string;
    deviceType?: DeviceType;
  },
): Promise<RpcResult<TrackEventResponse>> {
  return callRpc<TrackEventResponse>(supabase, "api_track_event", {
    p_event_name: params.eventName,
    p_event_data: params.eventData ?? null,
    p_session_id: params.sessionId ?? null,
    p_device_type: params.deviceType ?? null,
  });
}

// ─── Dashboard / Recently Viewed ────────────────────────────────────────────

export function recordProductView(
  supabase: SupabaseClient,
  productId: number,
): Promise<RpcResult<RecordProductViewResponse>> {
  return callRpc<RecordProductViewResponse>(
    supabase,
    "api_record_product_view",
    { p_product_id: productId },
  );
}

export function getRecentlyViewed(
  supabase: SupabaseClient,
  limit?: number,
): Promise<RpcResult<RecentlyViewedResponse>> {
  return callRpc<RecentlyViewedResponse>(
    supabase,
    "api_get_recently_viewed",
    { ...(limit ? { p_limit: limit } : {}) },
  );
}

export function getDashboardData(
  supabase: SupabaseClient,
): Promise<RpcResult<DashboardData>> {
  return callRpc<DashboardData>(supabase, "api_get_dashboard_data");
}
