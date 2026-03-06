import { describe, it, expect } from "vitest";

import {
  deterministicHash,
  assignVariant,
  evaluateFlag,
} from "./evaluator";
import type { FeatureFlag, FlagContext } from "./types";

// ─── Helpers ────────────────────────────────────────────────────────────────

function makeFlag(overrides: Partial<FeatureFlag> = {}): FeatureFlag {
  return {
    id: 1,
    key: "test-flag",
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
    country: "PL",
    environment: "production",
    ...overrides,
  };
}

// ─── deterministicHash ──────────────────────────────────────────────────────

describe("deterministicHash", () => {
  it("returns a number between 0 and 99", () => {
    const result = deterministicHash("flag-a", "user-123");
    expect(result).toBeGreaterThanOrEqual(0);
    expect(result).toBeLessThan(100);
  });

  it("is deterministic for the same inputs", () => {
    const a = deterministicHash("flag-a", "user-123");
    const b = deterministicHash("flag-a", "user-123");
    expect(a).toBe(b);
  });

  it("produces different hashes for different flag keys", () => {
    const a = deterministicHash("flag-a", "user-123");
    const b = deterministicHash("flag-b", "user-123");
    expect(a).not.toBe(b);
  });

  it("produces different hashes for different identifiers", () => {
    const a = deterministicHash("flag-a", "user-1");
    const b = deterministicHash("flag-a", "user-2");
    expect(a).not.toBe(b);
  });

  it("handles empty strings", () => {
    const result = deterministicHash("", "");
    expect(result).toBeGreaterThanOrEqual(0);
    expect(result).toBeLessThan(100);
  });
});

// ─── assignVariant ──────────────────────────────────────────────────────────

describe("assignVariant", () => {
  it("returns empty string for empty variants", () => {
    expect(assignVariant("flag", "user", [])).toBe("");
  });

  it("returns the only variant when there is one", () => {
    const result = assignVariant("flag", "user", [
      { name: "control", weight: 100 },
    ]);
    expect(result).toBe("control");
  });

  it("distributes users across variants deterministically", () => {
    const variants = [
      { name: "control", weight: 50 },
      { name: "treatment", weight: 50 },
    ];
    const resultA = assignVariant("flag", "user-a", variants);
    const resultB = assignVariant("flag", "user-a", variants);
    expect(resultA).toBe(resultB);
  });

  it("assigns to the last variant when hash equals cumulative", () => {
    // With 100% weight on a single variant, all users get it
    const result = assignVariant("anything", "anyone", [
      { name: "only-option", weight: 100 },
    ]);
    expect(result).toBe("only-option");
  });

  it("handles three-way split", () => {
    const variants = [
      { name: "a", weight: 33 },
      { name: "b", weight: 34 },
      { name: "c", weight: 33 },
    ];
    const result = assignVariant("flag", "user-x", variants);
    expect(["a", "b", "c"]).toContain(result);
  });
});

// ─── evaluateFlag ───────────────────────────────────────────────────────────

describe("evaluateFlag", () => {
  const ctx = makeCtx();

  it("returns disabled/default when flag is undefined", () => {
    const result = evaluateFlag(undefined, ctx);
    expect(result).toEqual({ enabled: false, source: "default" });
  });

  it("returns enabled for a simple enabled flag", () => {
    const result = evaluateFlag(makeFlag(), ctx);
    expect(result).toEqual({ enabled: true, source: "rule" });
  });

  // ── Kill switch ─────────────────────────────────────────────────────────

  it("returns disabled/kill when flag is disabled", () => {
    const flag = makeFlag({ enabled: false });
    const result = evaluateFlag(flag, ctx);
    expect(result).toEqual({ enabled: false, source: "kill" });
  });

  // ── Expiration ──────────────────────────────────────────────────────────

  it("returns disabled/expired for an expired flag", () => {
    const flag = makeFlag({ expires_at: "2020-01-01T00:00:00Z" });
    const result = evaluateFlag(flag, ctx);
    expect(result).toEqual({ enabled: false, source: "expired" });
  });

  it("returns enabled for a flag with future expiration", () => {
    const flag = makeFlag({ expires_at: "2099-01-01T00:00:00Z" });
    const result = evaluateFlag(flag, ctx);
    expect(result.enabled).toBe(true);
  });

  // ── Environment targeting ───────────────────────────────────────────────

  it("disables when environment does not match", () => {
    const flag = makeFlag({ environments: ["staging"] });
    const result = evaluateFlag(flag, makeCtx({ environment: "production" }));
    expect(result).toEqual({ enabled: false, source: "rule" });
  });

  it("enables when environment matches", () => {
    const flag = makeFlag({ environments: ["production"] });
    const result = evaluateFlag(flag, makeCtx({ environment: "production" }));
    expect(result.enabled).toBe(true);
  });

  it("enables when environments array is empty (all environments)", () => {
    const flag = makeFlag({ environments: [] });
    const result = evaluateFlag(flag, ctx);
    expect(result.enabled).toBe(true);
  });

  // ── Country targeting ───────────────────────────────────────────────────

  it("disables when country does not match", () => {
    const flag = makeFlag({ countries: ["DE"] });
    const result = evaluateFlag(flag, makeCtx({ country: "PL" }));
    expect(result).toEqual({ enabled: false, source: "rule" });
  });

  it("enables when country matches", () => {
    const flag = makeFlag({ countries: ["PL", "DE"] });
    const result = evaluateFlag(flag, makeCtx({ country: "PL" }));
    expect(result.enabled).toBe(true);
  });

  // ── Role targeting ──────────────────────────────────────────────────────

  it("disables when role does not match", () => {
    const flag = makeFlag({ roles: ["admin"] });
    const result = evaluateFlag(flag, makeCtx({ role: "user" }));
    expect(result).toEqual({ enabled: false, source: "rule" });
  });

  it("enables when role matches", () => {
    const flag = makeFlag({ roles: ["admin", "user"] });
    const result = evaluateFlag(flag, makeCtx({ role: "user" }));
    expect(result.enabled).toBe(true);
  });

  it("treats missing role as 'anonymous'", () => {
    const flag = makeFlag({ roles: ["anonymous"] });
    const result = evaluateFlag(flag, makeCtx());
    expect(result.enabled).toBe(true);
  });

  // ── Percentage rollout ──────────────────────────────────────────────────

  it("enables for 100% rollout", () => {
    const flag = makeFlag({ percentage: 100 });
    const result = evaluateFlag(flag, makeCtx({ userId: "any-user" }));
    expect(result.enabled).toBe(true);
  });

  it("disables for 0% rollout", () => {
    const flag = makeFlag({ percentage: 0 });
    const result = evaluateFlag(flag, makeCtx({ userId: "any-user" }));
    expect(result).toEqual({ enabled: false, source: "rule" });
  });

  it("uses userId for percentage hash when available", () => {
    const flag = makeFlag({ percentage: 50 });
    const ctxA = makeCtx({ userId: "user-a" });
    const resultA = evaluateFlag(flag, ctxA);
    // Result is deterministic
    const resultB = evaluateFlag(flag, ctxA);
    expect(resultA.enabled).toBe(resultB.enabled);
  });

  it("falls back to sessionId when userId is missing", () => {
    const flag = makeFlag({ percentage: 50 });
    const ctxSess = makeCtx({ sessionId: "sess-123" });
    const result = evaluateFlag(flag, ctxSess);
    expect(typeof result.enabled).toBe("boolean");
  });

  // ── Variant assignment ──────────────────────────────────────────────────

  it("assigns variant for multivariate flags", () => {
    const flag = makeFlag({
      flag_type: "variant",
      variants: [
        { name: "control", weight: 50 },
        { name: "treatment", weight: 50 },
      ],
    });
    const result = evaluateFlag(flag, makeCtx({ userId: "user-1" }));
    expect(result.enabled).toBe(true);
    expect(result.source).toBe("rule");
    expect(["control", "treatment"]).toContain(result.variant);
  });

  it("returns enabled without variant for boolean flag type", () => {
    const flag = makeFlag({ flag_type: "boolean" });
    const result = evaluateFlag(flag, ctx);
    expect(result.enabled).toBe(true);
    expect(result.variant).toBeUndefined();
  });

  // ── Priority order ──────────────────────────────────────────────────────

  it("checks expiration before kill switch", () => {
    const flag = makeFlag({
      enabled: false,
      expires_at: "2020-01-01T00:00:00Z",
    });
    const result = evaluateFlag(flag, ctx);
    // Expired takes priority over kill switch
    expect(result.source).toBe("expired");
  });

  it("checks kill switch before targeting rules", () => {
    const flag = makeFlag({
      enabled: false,
      countries: ["PL"],
    });
    const result = evaluateFlag(flag, makeCtx({ country: "PL" }));
    expect(result.source).toBe("kill");
  });
});
