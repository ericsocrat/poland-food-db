// ─── API layer: typed RPC wrappers ──────────────────────────────────────────
// All product functions pass p_country: null — backend resolves from user_preferences.
// Frontend NEVER passes a country explicitly.

import { SupabaseClient } from "@supabase/supabase-js";
import { callRpc } from "./rpc";
import type {
  AlternativesResponse,
  CategoryListingResponse,
  CategoryOverviewItem,
  DataConfidence,
  EanLookupResponse,
  EanNotFoundResponse,
  HealthProfileActiveResponse,
  HealthProfileListResponse,
  HealthProfileMutationResponse,
  HealthWarningsResponse,
  ProductDetail,
  RpcResult,
  ScoreExplanation,
  SearchResponse,
  UserPreferences,
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
    p_query: string;
    p_category?: string;
    p_limit?: number;
    p_offset?: number;
    p_diet_preference?: string;
    p_avoid_allergens?: string[];
    p_strict_diet?: boolean;
    p_strict_allergen?: boolean;
    p_treat_may_contain?: boolean;
  },
): Promise<RpcResult<SearchResponse>> {
  return callRpc<SearchResponse>(supabase, "api_search_products", {
    ...params,
    p_country: null, // always let backend resolve
  });
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
