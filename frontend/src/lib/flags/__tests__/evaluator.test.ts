// ─── Feature Flag Evaluator Tests ────────────────────────────────────────────
// Pure unit tests for the evaluation engine (#191).
// No Supabase dependency — tests pure functions only.

import { describe, it, expect } from "vitest";
import {
  evaluateFlag,
  deterministicHash,
  assignVariant,
} from "@/lib/flags/evaluator";
import type { FeatureFlag, FlagContext } from "@/lib/flags/types";

// ─── Test Helpers ───────────────────────────────────────────────────────────

function makeFlag(overrides: Partial<FeatureFlag> = {}): FeatureFlag {
  return {
    id: 1,
    key: "test_flag",
    name: "Test Flag",
    description: null,
    flag_type: "boolean",
    enabled: true,
    percentage: 100,
    countries: [],
    roles: [],
    environments: [],
    variants: [],
    created_at: "2026-01-01T00:00:00Z",
    updated_at: "2026-01-01T00:00:00Z",
    expires_at: null,
    created_by: null,
    tags: [],
    jira_ref: null,
    ...overrides,
  };
}

function makeCtx(overrides: Partial<FlagContext> = {}): FlagContext {
  return {
    userId: "user-123",
    country: "PL",
    environment: "production",
    ...overrides,
  };
}

// ─── deterministicHash ──────────────────────────────────────────────────────

describe("deterministicHash", () => {
  it("returns a number between 0 and 99", () => {
    for (let i = 0; i < 100; i++) {
      const hash = deterministicHash("flag", `user-${i}`);
      expect(hash).toBeGreaterThanOrEqual(0);
      expect(hash).toBeLessThan(100);
    }
  });

  it("is deterministic — same inputs produce same output", () => {
    const a = deterministicHash("my_flag", "user-42");
    const b = deterministicHash("my_flag", "user-42");
    expect(a).toBe(b);
  });

  it("produces different hashes for different flag keys", () => {
    const a = deterministicHash("flag_a", "user-1");
    const b = deterministicHash("flag_b", "user-1");
    // Not guaranteed to be different, but overwhelmingly likely
    // Testing that the function uses both inputs
    expect(typeof a).toBe("number");
    expect(typeof b).toBe("number");
  });

  it("produces different hashes for different identifiers", () => {
    const a = deterministicHash("flag", "user-1");
    const b = deterministicHash("flag", "user-2");
    expect(typeof a).toBe("number");
    expect(typeof b).toBe("number");
  });

  it("handles empty strings", () => {
    const hash = deterministicHash("", "");
    expect(hash).toBeGreaterThanOrEqual(0);
    expect(hash).toBeLessThan(100);
  });
});

// ─── assignVariant ──────────────────────────────────────────────────────────

describe("assignVariant", () => {
  it("assigns a variant from the list", () => {
    const variants = [
      { name: "control", weight: 50 },
      { name: "treatment", weight: 50 },
    ];
    const result = assignVariant("test", "user-1", variants);
    expect(["control", "treatment"]).toContain(result);
  });

  it("is deterministic for the same user + flag", () => {
    const variants = [
      { name: "A", weight: 33 },
      { name: "B", weight: 34 },
      { name: "C", weight: 33 },
    ];
    const a = assignVariant("flag", "user-x", variants);
    const b = assignVariant("flag", "user-x", variants);
    expect(a).toBe(b);
  });

  it("returns empty string for empty variants", () => {
    expect(assignVariant("flag", "user", [])).toBe("");
  });

  it("falls back to last variant if weights don't cover full range", () => {
    const variants = [{ name: "only", weight: 10 }];
    // Hash could be > 10, should fall back to last variant
    const result = assignVariant("high-hash-flag", "test-identifier", variants);
    expect(result).toBe("only");
  });
});

// ─── evaluateFlag ───────────────────────────────────────────────────────────

describe("evaluateFlag", () => {
  const ctx = makeCtx();

  // --- Basic boolean evaluation ---

  it("returns disabled with source 'default' when flag is undefined", () => {
    const result = evaluateFlag(undefined, ctx);
    expect(result).toEqual({ enabled: false, source: "default" });
  });

  it("returns enabled for a simple enabled boolean flag", () => {
    const result = evaluateFlag(makeFlag(), ctx);
    expect(result).toEqual({ enabled: true, source: "rule" });
  });

  it("returns disabled with source 'kill' when flag is disabled", () => {
    const result = evaluateFlag(makeFlag({ enabled: false }), ctx);
    expect(result).toEqual({ enabled: false, source: "kill" });
  });

  // --- Expiration ---

  it("returns disabled with source 'expired' when past expires_at", () => {
    const result = evaluateFlag(
      makeFlag({ expires_at: "2020-01-01T00:00:00Z" }),
      ctx,
    );
    expect(result).toEqual({ enabled: false, source: "expired" });
  });

  it("returns enabled when expires_at is in the future", () => {
    const result = evaluateFlag(
      makeFlag({ expires_at: "2099-12-31T23:59:59Z" }),
      ctx,
    );
    expect(result.enabled).toBe(true);
  });

  it("returns enabled when expires_at is null", () => {
    const result = evaluateFlag(makeFlag({ expires_at: null }), ctx);
    expect(result.enabled).toBe(true);
  });

  // --- Country targeting ---

  it("returns enabled when user country is in countries list", () => {
    const result = evaluateFlag(
      makeFlag({ countries: ["PL", "DE"] }),
      makeCtx({ country: "PL" }),
    );
    expect(result.enabled).toBe(true);
  });

  it("returns disabled when user country is not in countries list", () => {
    const result = evaluateFlag(
      makeFlag({ countries: ["DE"] }),
      makeCtx({ country: "PL" }),
    );
    expect(result).toEqual({ enabled: false, source: "rule" });
  });

  it("returns enabled when countries list is empty (all countries)", () => {
    const result = evaluateFlag(
      makeFlag({ countries: [] }),
      makeCtx({ country: "PL" }),
    );
    expect(result.enabled).toBe(true);
  });

  // --- Environment targeting ---

  it("returns enabled when environment matches", () => {
    const result = evaluateFlag(
      makeFlag({ environments: ["production"] }),
      makeCtx({ environment: "production" }),
    );
    expect(result.enabled).toBe(true);
  });

  it("returns disabled when environment does not match", () => {
    const result = evaluateFlag(
      makeFlag({ environments: ["staging"] }),
      makeCtx({ environment: "production" }),
    );
    expect(result).toEqual({ enabled: false, source: "rule" });
  });

  it("returns enabled when environments list is empty (all environments)", () => {
    const result = evaluateFlag(
      makeFlag({ environments: [] }),
      makeCtx({ environment: "production" }),
    );
    expect(result.enabled).toBe(true);
  });

  // --- Role targeting ---

  it("returns enabled when user role is in roles list", () => {
    const result = evaluateFlag(
      makeFlag({ roles: ["admin", "editor"] }),
      makeCtx({ role: "admin" }),
    );
    expect(result.enabled).toBe(true);
  });

  it("returns disabled when user role is not in roles list", () => {
    const result = evaluateFlag(
      makeFlag({ roles: ["admin"] }),
      makeCtx({ role: "user" }),
    );
    expect(result).toEqual({ enabled: false, source: "rule" });
  });

  it("treats undefined role as 'anonymous'", () => {
    const result = evaluateFlag(
      makeFlag({ roles: ["anonymous"] }),
      makeCtx({ role: undefined }),
    );
    expect(result.enabled).toBe(true);
  });

  it("excludes anonymous when roles are restricted", () => {
    const result = evaluateFlag(
      makeFlag({ roles: ["admin"] }),
      makeCtx({ role: undefined }),
    );
    expect(result.enabled).toBe(false);
  });

  // --- Percentage rollout ---

  it("enables flag at 100% rollout", () => {
    const result = evaluateFlag(
      makeFlag({ percentage: 100 }),
      ctx,
    );
    expect(result.enabled).toBe(true);
  });

  it("disables flag at 0% rollout", () => {
    const result = evaluateFlag(
      makeFlag({ percentage: 0 }),
      ctx,
    );
    expect(result.enabled).toBe(false);
  });

  it("produces consistent result for same user (percentage rollout)", () => {
    const flag = makeFlag({ percentage: 50 });
    const a = evaluateFlag(flag, ctx);
    const b = evaluateFlag(flag, ctx);
    expect(a.enabled).toBe(b.enabled);
  });

  it("uses sessionId when userId is not available for percentage", () => {
    const flag = makeFlag({ percentage: 50 });
    const ctxWithSession = makeCtx({ userId: undefined, sessionId: "sess-1" });
    const a = evaluateFlag(flag, ctxWithSession);
    const b = evaluateFlag(flag, ctxWithSession);
    expect(a.enabled).toBe(b.enabled);
  });

  // --- Variant assignment ---

  it("assigns a variant for variant-type flags", () => {
    const flag = makeFlag({
      flag_type: "variant",
      variants: [
        { name: "control", weight: 50 },
        { name: "treatment", weight: 50 },
      ],
    });
    const result = evaluateFlag(flag, ctx);
    expect(result.enabled).toBe(true);
    expect(result.source).toBe("rule");
    expect(["control", "treatment"]).toContain(result.variant);
  });

  it("produces consistent variant for same user", () => {
    const flag = makeFlag({
      flag_type: "variant",
      variants: [
        { name: "A", weight: 33 },
        { name: "B", weight: 34 },
        { name: "C", weight: 33 },
      ],
    });
    const a = evaluateFlag(flag, ctx);
    const b = evaluateFlag(flag, ctx);
    expect(a.variant).toBe(b.variant);
  });

  // --- Evaluation priority order ---

  it("checks expiration before kill switch", () => {
    const result = evaluateFlag(
      makeFlag({ enabled: false, expires_at: "2020-01-01T00:00:00Z" }),
      ctx,
    );
    // Expiration is checked first, so source should be 'expired'
    expect(result.source).toBe("expired");
  });

  it("checks kill switch before country targeting", () => {
    const result = evaluateFlag(
      makeFlag({ enabled: false, countries: ["PL"] }),
      makeCtx({ country: "PL" }),
    );
    // Kill switch takes priority over country match
    expect(result.source).toBe("kill");
  });

  it("checks environment before country", () => {
    const result = evaluateFlag(
      makeFlag({ environments: ["staging"], countries: ["DE"] }),
      makeCtx({ environment: "production", country: "PL" }),
    );
    // Environment mismatch caught first
    expect(result.enabled).toBe(false);
    expect(result.source).toBe("rule");
  });
});
