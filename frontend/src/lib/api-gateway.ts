// ─── API Gateway Client ──────────────────────────────────────────────────────
// Frontend wrapper for the api-gateway Edge Function.
// Abstracts the `supabase.functions.invoke()` call and provides type-safe
// methods for each gateway action.
//
// Usage:
//   const gateway = createApiGateway(supabase);
//   const result = await gateway.recordScan("5901234123457");
//
// Issue: #478 — Phase 1 + Phase 2 + Phase 4
// ─────────────────────────────────────────────────────────────────────────────

import type { SupabaseClient } from "@supabase/supabase-js";

// ─── Types ──────────────────────────────────────────────────────────────────

export interface GatewaySuccess<T = unknown> {
  ok: true;
  data: T;
}

export interface GatewayError {
  ok: false;
  error: string;
  message: string;
  retry_after?: number;
}

export type GatewayResult<T = unknown> = GatewaySuccess<T> | GatewayError;

export const GATEWAY_FUNCTION_NAME = "api-gateway";

// ─── Error Helpers ──────────────────────────────────────────────────────────

export function isGatewayRateLimited(
  result: GatewayResult,
): result is GatewayError & { error: "rate_limit_exceeded" } {
  return !result.ok && result.error === "rate_limit_exceeded";
}

export function isGatewayAuthError(
  result: GatewayResult,
): result is GatewayError & { error: "unauthorized" } {
  return !result.ok && result.error === "unauthorized";
}

export function isGatewayValidationError(
  result: GatewayResult,
): result is GatewayError {
  return (
    !result.ok &&
    (result.error === "invalid_input" ||
      result.error === "invalid_ean" ||
      result.error === "invalid_ean_checksum")
  );
}

// ─── Core invoke ────────────────────────────────────────────────────────────

async function invokeGateway<T = unknown>(
  supabase: SupabaseClient,
  action: string,
  params: Record<string, unknown> | object = {},
): Promise<GatewayResult<T>> {
  try {
    const { data, error } = await supabase.functions.invoke(
      GATEWAY_FUNCTION_NAME,
      {
        body: { action, ...params },
      },
    );

    // Supabase client-level error (network, CORS, etc.)
    if (error) {
      return {
        ok: false,
        error: "gateway_unreachable",
        message: error.message ?? "Failed to reach the API gateway",
      };
    }

    // The Edge Function always returns JSON with { ok, ... }
    // data is already parsed when content-type is application/json
    if (data && typeof data === "object" && "ok" in data) {
      return data as GatewayResult<T>;
    }

    // Unexpected response shape — treat as success with raw data
    return { ok: true, data: data as T };
  } catch (err) {
    return {
      ok: false,
      error: "gateway_exception",
      message:
        err instanceof Error
          ? err.message
          : "An unexpected error occurred while calling the API gateway",
    };
  }
}

// ─── Action Methods ─────────────────────────────────────────────────────────

/**
 * Record a barcode scan via the gateway (rate limited: 100/day).
 * Falls back to direct RPC if the gateway is unreachable.
 */
export async function recordScanViaGateway(
  supabase: SupabaseClient,
  ean: string,
): Promise<GatewayResult> {
  const result = await invokeGateway(supabase, "record-scan", { ean });

  // Graceful degradation: if gateway is unreachable, fall back to direct RPC
  if (!result.ok && result.error === "gateway_unreachable") {
    try {
      const { data, error } = await supabase.rpc("api_record_scan", {
        p_ean: ean,
      });
      if (error) {
        return {
          ok: false,
          error: "rpc_error",
          message: error.message ?? "Failed to record scan",
        };
      }
      return { ok: true, data };
    } catch {
      // If fallback also fails, return original gateway error
      return result;
    }
  }

  return result;
}

// ─── Submit Product Types ───────────────────────────────────────────────────

export interface SubmitProductParams {
  ean: string;
  product_name: string;
  brand?: string | null;
  category?: string | null;
  photo_url?: string | null;
  notes?: string | null;
}

/**
 * Submit a new product via the gateway (rate limited: 10/day).
 * Validates EAN checksum and sanitizes inputs before forwarding.
 * Falls back to direct RPC if the gateway is unreachable.
 */
export async function submitProductViaGateway(
  supabase: SupabaseClient,
  params: SubmitProductParams,
): Promise<GatewayResult> {
  const result = await invokeGateway(supabase, "submit-product", params);

  // Graceful degradation: if gateway is unreachable, fall back to direct RPC
  if (!result.ok && result.error === "gateway_unreachable") {
    try {
      const { data, error } = await supabase.rpc("api_submit_product", {
        p_ean: params.ean,
        p_product_name: params.product_name,
        p_brand: params.brand ?? null,
        p_category: params.category ?? null,
        p_photo_url: params.photo_url ?? null,
        p_notes: params.notes ?? null,
      });
      if (error) {
        return {
          ok: false,
          error: "rpc_error",
          message: error.message ?? "Failed to submit product",
        };
      }
      return { ok: true, data };
    } catch {
      return result;
    }
  }

  return result;
}

// ─── Track Event Types ──────────────────────────────────────────────────────

export interface TrackEventParams {
  event_name: string;
  event_data?: Record<string, unknown>;
  session_id?: string | null;
  device_type?: "mobile" | "tablet" | "desktop" | null;
}

/**
 * Track an analytics event via the gateway (rate limited: 10,000/day).
 * Falls back to direct RPC if the gateway is unreachable.
 */
export async function trackEventViaGateway(
  supabase: SupabaseClient,
  params: TrackEventParams,
): Promise<GatewayResult> {
  const result = await invokeGateway(supabase, "track-event", params);

  // Graceful degradation: if gateway is unreachable, fall back to direct RPC
  if (!result.ok && result.error === "gateway_unreachable") {
    try {
      const { data, error } = await supabase.rpc("api_track_event", {
        p_event_name: params.event_name,
        p_event_data: params.event_data ?? {},
        p_session_id: params.session_id ?? null,
        p_device_type: params.device_type ?? null,
      });
      if (error) {
        return {
          ok: false,
          error: "rpc_error",
          message: error.message ?? "Failed to track event",
        };
      }
      return { ok: true, data };
    } catch {
      return result;
    }
  }

  return result;
}

// ─── Save Search Types ──────────────────────────────────────────────────────

export interface SaveSearchParams {
  name: string;
  query?: string | null;
  filters?: Record<string, unknown>;
}

/**
 * Save a search via the gateway (rate limited: 50/day).
 * Sanitizes inputs before forwarding.
 * Falls back to direct RPC if the gateway is unreachable.
 */
export async function saveSearchViaGateway(
  supabase: SupabaseClient,
  params: SaveSearchParams,
): Promise<GatewayResult> {
  const result = await invokeGateway(supabase, "save-search", params);

  // Graceful degradation: if gateway is unreachable, fall back to direct RPC
  if (!result.ok && result.error === "gateway_unreachable") {
    try {
      const { data, error } = await supabase.rpc("api_save_search", {
        p_name: params.name,
        p_query: params.query ?? null,
        p_filters: params.filters ?? {},
      });
      if (error) {
        return {
          ok: false,
          error: "rpc_error",
          message: error.message ?? "Failed to save search",
        };
      }
      return { ok: true, data };
    } catch {
      return result;
    }
  }

  return result;
}

// ─── Gateway Factory ────────────────────────────────────────────────────────

export interface ApiGateway {
  recordScan: (ean: string) => Promise<GatewayResult>;
  submitProduct: (params: SubmitProductParams) => Promise<GatewayResult>;
  trackEvent: (params: TrackEventParams) => Promise<GatewayResult>;
  saveSearch: (params: SaveSearchParams) => Promise<GatewayResult>;
}

/**
 * Create a typed API gateway client.
 *
 * @example
 * ```ts
 * const gateway = createApiGateway(supabase);
 * const result = await gateway.recordScan("5901234123457");
 * if (result.ok) {
 *   console.log("Scan recorded:", result.data);
 * } else if (isGatewayRateLimited(result)) {
 *   console.log("Rate limited, retry after:", result.retry_after);
 * }
 * ```
 */
export function createApiGateway(supabase: SupabaseClient): ApiGateway {
  return {
    recordScan: (ean: string) => recordScanViaGateway(supabase, ean),
    submitProduct: (params: SubmitProductParams) =>
      submitProductViaGateway(supabase, params),
    trackEvent: (params: TrackEventParams) =>
      trackEventViaGateway(supabase, params),
    saveSearch: (params: SaveSearchParams) =>
      saveSearchViaGateway(supabase, params),
  };
}
