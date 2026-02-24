// ─── Feature Flag Evaluator ──────────────────────────────────────────────────
// Pure evaluation logic for feature flags (#191).
// No Supabase dependency — takes flag data + context, returns result.
// This module is fully testable without any external dependencies.

import type { FeatureFlag, FlagContext, FlagResult, FlagVariant } from "./types";

/**
 * Deterministic FNV-1a hash → 0-99 range.
 * Given the same (flagKey, identifier), always returns the same bucket.
 * Used for percentage rollout and variant assignment.
 */
export function deterministicHash(flagKey: string, identifier: string): number {
  let hash = 2166136261;
  const input = `${flagKey}:${identifier}`;
  for (let i = 0; i < input.length; i++) {
    hash ^= input.charCodeAt(i);
    hash = Math.imul(hash, 16777619);
  }
  return Math.abs(hash) % 100;
}

/**
 * Assign a variant based on weighted distribution using deterministic hash.
 * Variants must have positive weights that sum to 100.
 */
export function assignVariant(
  flagKey: string,
  identifier: string,
  variants: FlagVariant[],
): string {
  if (variants.length === 0) return "";
  const hash = deterministicHash(flagKey, identifier);
  let cumulative = 0;
  for (const v of variants) {
    cumulative += v.weight;
    if (hash < cumulative) return v.name;
  }
  return variants[variants.length - 1].name;
}

/**
 * Evaluate a single feature flag against the given context.
 * Pure function — no I/O, no side effects.
 *
 * Evaluation order:
 * 1. Flag not found → disabled (default)
 * 2. Flag expired → disabled (expired)
 * 3. Flag kill switch (enabled=false) → disabled (kill)
 * 4. Environment targeting → disabled if not in list
 * 5. Country targeting → disabled if not in list
 * 6. Role targeting → disabled if not in list
 * 7. Percentage rollout → disabled if hash >= percentage
 * 8. Variant assignment → enabled with variant name
 * 9. Enabled (rule)
 */
export function evaluateFlag(
  flag: FeatureFlag | undefined,
  ctx: FlagContext,
): FlagResult {
  // 1. Flag not found
  if (!flag) {
    return { enabled: false, source: "default" };
  }

  // 2. Check expiration
  if (flag.expires_at && new Date(flag.expires_at) < new Date()) {
    return { enabled: false, source: "expired" };
  }

  // 3. Kill switch
  if (!flag.enabled) {
    return { enabled: false, source: "kill" };
  }

  // 4. Environment targeting (empty array = all environments)
  if (flag.environments.length > 0 && !flag.environments.includes(ctx.environment)) {
    return { enabled: false, source: "rule" };
  }

  // 5. Country targeting (empty array = all countries)
  if (flag.countries.length > 0 && !flag.countries.includes(ctx.country)) {
    return { enabled: false, source: "rule" };
  }

  // 6. Role targeting (empty array = all roles)
  if (flag.roles.length > 0 && !flag.roles.includes(ctx.role ?? "anonymous")) {
    return { enabled: false, source: "rule" };
  }

  // 7. Percentage rollout (deterministic hash)
  if (flag.percentage < 100) {
    const identifier = ctx.userId ?? ctx.sessionId ?? "anonymous";
    const hash = deterministicHash(flag.key, identifier);
    if (hash >= flag.percentage) {
      return { enabled: false, source: "rule" };
    }
  }

  // 8. Variant assignment (for multivariate flags)
  if (flag.flag_type === "variant" && flag.variants?.length > 0) {
    const identifier = ctx.userId ?? ctx.sessionId ?? "anonymous";
    const variant = assignVariant(flag.key, identifier, flag.variants);
    return { enabled: true, variant, source: "rule" };
  }

  // 9. Default: enabled
  return { enabled: true, source: "rule" };
}
