// ─── API Gateway Client ──────────────────────────────────────────────────────
// Frontend wrapper for the api-gateway Edge Function.
// Abstracts the `supabase.functions.invoke()` call and provides type-safe
// methods for each gateway action.
//
// Usage:
//   const gateway = createApiGateway(supabase);
//   const result = await gateway.recordScan("5901234123457");
//
// Issue: #478 — Phase 1
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

// ─── Core invoke ────────────────────────────────────────────────────────────

async function invokeGateway<T = unknown>(
  supabase: SupabaseClient,
  action: string,
  params: Record<string, unknown> = {},
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

// ─── Gateway Factory ────────────────────────────────────────────────────────

export interface ApiGateway {
  recordScan: (ean: string) => Promise<GatewayResult>;
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
  };
}
