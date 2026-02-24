// ─── Feature Flag Server Utilities ──────────────────────────────────────────
// Server-side flag evaluation for Server Components, Route Handlers,
// and Middleware (#191).

import { createServerSupabaseClient } from "@/lib/supabase/server";
import { evaluateFlag } from "./evaluator";
import type { FeatureFlag, FlagContext, FlagResult } from "./types";

// ─── In-memory flag cache with TTL ─────────────────────────────────────────

const CACHE_TTL_MS = 5_000;

let flagCache: {
  flags: Map<string, FeatureFlag>;
  timestamp: number;
} | null = null;

/**
 * Load all flags from Supabase, with 5s in-memory cache.
 * Single query fetches all flags (table < 200 rows).
 */
export async function loadFlags(): Promise<Map<string, FeatureFlag>> {
  if (flagCache && Date.now() - flagCache.timestamp < CACHE_TTL_MS) {
    return flagCache.flags;
  }

  const supabase = await createServerSupabaseClient();
  const { data } = await supabase.from("feature_flags").select("*");

  const map = new Map<string, FeatureFlag>(
    (data ?? []).map((f: FeatureFlag) => [f.key, f]),
  );

  flagCache = { flags: map, timestamp: Date.now() };
  return map;
}

/**
 * Invalidate the in-memory flag cache.
 * Call this after flag mutations or for testing.
 */
export function invalidateFlagCache(): void {
  flagCache = null;
}

/**
 * Check for user/session/country overrides in the flag_overrides table.
 * Returns the override value if found, null otherwise.
 */
async function checkOverride(
  flagKey: string,
  ctx: FlagContext,
): Promise<{ enabled: boolean; variant?: string } | null> {
  const targets: string[] = [];
  if (ctx.userId) targets.push(ctx.userId);
  if (ctx.sessionId) targets.push(ctx.sessionId);
  if (ctx.country) targets.push(ctx.country);

  if (targets.length === 0) return null;

  const supabase = await createServerSupabaseClient();
  const { data } = await supabase
    .from("flag_overrides")
    .select("override_value, expires_at")
    .eq("flag_key", flagKey)
    .in("target_value", targets)
    .limit(1)
    .maybeSingle();

  if (!data) return null;

  // Check if override is expired
  if (data.expires_at && new Date(data.expires_at) < new Date()) {
    return null;
  }

  return data.override_value as { enabled: boolean; variant?: string };
}

/**
 * Full flag evaluation with override checking.
 * Checks overrides first (database lookup), then falls back to rule evaluation.
 */
export async function evaluateFlagWithOverrides(
  flagKey: string,
  ctx: FlagContext,
): Promise<FlagResult> {
  const flags = await loadFlags();
  const flag = flags.get(flagKey);

  if (!flag) return { enabled: false, source: "default" };

  // Check overrides before rule evaluation
  const override = await checkOverride(flagKey, ctx);
  if (override !== null) {
    return {
      enabled: override.enabled,
      variant: override.variant,
      source: "override",
    };
  }

  return evaluateFlag(flag, ctx);
}

/**
 * Simple boolean flag check for Server Components.
 * Uses the provided context (middleware or API route should build context).
 */
export async function getFlag(
  flagKey: string,
  ctx: FlagContext,
): Promise<boolean> {
  const result = await evaluateFlagWithOverrides(flagKey, ctx);
  return result.enabled;
}

/**
 * Get variant name for multivariate flags in Server Components.
 */
export async function getFlagVariant(
  flagKey: string,
  ctx: FlagContext,
): Promise<string | undefined> {
  const result = await evaluateFlagWithOverrides(flagKey, ctx);
  return result.variant;
}

/**
 * Evaluate all flags at once for a given context.
 * Returns a record of flag key → boolean (enabled/disabled).
 * Used by the /api/flags route and FlagProvider initialization.
 */
export async function evaluateAllFlags(
  ctx: FlagContext,
): Promise<{ flags: Record<string, boolean>; variants: Record<string, string> }> {
  const flagMap = await loadFlags();
  const flags: Record<string, boolean> = {};
  const variants: Record<string, string> = {};

  for (const [key, flag] of flagMap) {
    const result = evaluateFlag(flag, ctx);
    flags[key] = result.enabled;
    if (result.variant) {
      variants[key] = result.variant;
    }
  }

  return { flags, variants };
}
