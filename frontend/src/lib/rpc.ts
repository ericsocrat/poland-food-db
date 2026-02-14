// ─── RPC call wrapper with error normalization ──────────────────────────────
// Every Supabase RPC call goes through callRpc<T>().
// Returns { ok, data?, error? } — never throws.

import { SupabaseClient } from "@supabase/supabase-js";
import type { RpcResult } from "./types";

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
  try {
    const { data, error } = await supabase.rpc(fnName, params);

    // Supabase-level error (network, auth, permission)
    if (error) {
      const normalized = {
        code: error.code ?? "RPC_ERROR",
        message: error.message ?? "Unknown error",
      };

      if (process.env.NODE_ENV === "development") {
        console.error(`[RPC] ${fnName} failed:`, error);
      }

      return { ok: false, error: normalized };
    }

    // Backend-level error (function returned { error: "..." })
    if (data && typeof data === "object" && "error" in data) {
      const msg = String((data as Record<string, unknown>).error);

      if (process.env.NODE_ENV === "development") {
        console.warn(`[RPC] ${fnName} returned error:`, msg);
      }

      return { ok: false, error: { code: "BUSINESS_ERROR", message: msg } };
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

/**
 * Checks if an RPC error is an auth/session error that should trigger redirect.
 */
export function isAuthError(error: { code: string; message: string }): boolean {
  const authCodes = ["PGRST301", "401", "403", "JWT_EXPIRED"];
  const authMessages = [
    "JWT expired",
    "not authenticated",
    "permission denied",
    "Invalid JWT",
  ];

  return (
    authCodes.includes(error.code) ||
    authMessages.some((m) =>
      error.message.toLowerCase().includes(m.toLowerCase()),
    )
  );
}
