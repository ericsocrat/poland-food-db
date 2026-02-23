// ─── RPC call wrapper with error normalization ──────────────────────────────
// Every Supabase RPC call goes through callRpc<T>().
// Returns { ok, data?, error? } — never throws.

import { SupabaseClient } from "@supabase/supabase-js";
import type { RpcResult } from "./types";
import { observeQuery } from "./query-observer";

// ─── Auth error detection constants ─────────────────────────────────────────

/** Error codes that indicate an auth/session issue. */
export const AUTH_CODES: readonly string[] = [
  "PGRST301",
  "401",
  "403",
  "JWT_EXPIRED",
];

/** Substrings in error messages that indicate an auth/session issue. */
export const AUTH_MESSAGES = [
  "JWT expired",
  "not authenticated",
  "permission denied",
  "Invalid JWT",
] as const;

// ─── Error normalisation helpers ────────────────────────────────────────────

export interface NormalizedError {
  code: string;
  message: string;
}

/** Turn a Supabase error (possibly partial) into a stable shape. */
export function normalizeRpcError(
  err: { code?: string | null; message?: string | null } | null | undefined,
): NormalizedError {
  return {
    code: err?.code ?? "RPC_ERROR",
    message: err?.message ?? "Unknown error",
  };
}

/** Type guard for objects with an `error` property. */
function hasErrorProperty(
  value: object,
): value is Record<"error", unknown> {
  return "error" in value;
}

/** Extract an error message from a backend-level `{ error: "..." }` payload. */
export function extractBusinessError(
  data: unknown,
): NormalizedError | null {
  if (data && typeof data === "object" && hasErrorProperty(data)) {
    return {
      code: "BUSINESS_ERROR",
      message: String(data.error),
    };
  }
  return null;
}

// ─── Core RPC caller ────────────────────────────────────────────────────────

/**
 * Normalized RPC caller.
 * - Catches Supabase errors and normalizes them.
 * - Detects backend-level { error: "..." } responses.
 * - Logs details in development.
 */
export async function callRpc<T>(
  supabase: SupabaseClient,
  fnName: string,
  params?: Record<string, unknown>,
): Promise<RpcResult<T>> {
  // N+1 query pattern detection (dev/QA only — no-op in production)
  observeQuery(fnName);

  try {
    const { data, error } = await supabase.rpc(fnName, params);

    // Supabase-level error (network, auth, permission)
    if (error) {
      const normalized = normalizeRpcError(error);

      if (process.env.NODE_ENV === "development") {
        console.error(`[RPC] ${fnName} failed:`, error);
      }

      return { ok: false, error: normalized };
    }

    // Backend-level error (function returned { error: "..." })
    const businessError = extractBusinessError(data);
    if (businessError) {
      if (process.env.NODE_ENV === "development") {
        console.warn(`[RPC] ${fnName} returned error:`, businessError.message);
      }

      return { ok: false, error: businessError };
    }

    return { ok: true, data: data as T };
  } catch (err) {
    const message = err instanceof Error ? err.message : "Unexpected error";

    if (process.env.NODE_ENV === "development") {
      console.error(`[RPC] ${fnName} exception:`, err);
    }

    return { ok: false, error: { code: "EXCEPTION", message } };
  }
}

// ─── Auth error detection ───────────────────────────────────────────────────

/**
 * Checks if an RPC error is an auth/session error that should trigger redirect.
 */
export function isAuthError(error: { code: string; message: string }): boolean {
  return (
    AUTH_CODES.includes(error.code) ||
    AUTH_MESSAGES.some((m) =>
      error.message.toLowerCase().includes(m.toLowerCase()),
    )
  );
}
