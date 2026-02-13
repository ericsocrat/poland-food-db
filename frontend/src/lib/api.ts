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
