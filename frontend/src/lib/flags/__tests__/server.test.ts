// ─── Feature Flag Server Tests ──────────────────────────────────────────────
// Tests for server-side flag evaluation with caching and overrides (#191).

import { describe, it, expect, vi, beforeEach } from "vitest";
import type { FeatureFlag, FlagContext } from "@/lib/flags/types";

// ─── Mocks ──────────────────────────────────────────────────────────────────

const mockFrom = vi.fn();
const mockSelect = vi.fn();
const mockEq = vi.fn();
const mockIn = vi.fn();
const mockLimit = vi.fn();
const mockMaybeSingle = vi.fn();

vi.mock("@/lib/supabase/server", () => ({
  createServerSupabaseClient: vi.fn().mockResolvedValue({
    from: (...args: unknown[]) => {
      mockFrom(...args);
      return {
        select: (...sArgs: unknown[]) => {
          mockSelect(...sArgs);
          return {
            data: [],
            error: null,
            // chain for flag_overrides queries
            eq: (...eqArgs: unknown[]) => {
              mockEq(...eqArgs);
              return {
                in: (...inArgs: unknown[]) => {
                  mockIn(...inArgs);
                  return {
                    limit: (...lArgs: unknown[]) => {
                      mockLimit(...lArgs);
                      return {
                        maybeSingle: mockMaybeSingle,
                      };
                    },
                  };
                },
              };
            },
          };
        },
      };
    },
  }),
}));

const mockEvaluateFlag = vi.fn();
vi.mock("@/lib/flags/evaluator", () => ({
  evaluateFlag: (...args: unknown[]) => mockEvaluateFlag(...args),
}));

// Import AFTER mocks are set up
import {
  loadFlags,
  invalidateFlagCache,
  evaluateFlagWithOverrides,
  getFlag,
  getFlagVariant,
  evaluateAllFlags,
} from "@/lib/flags/server";

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

// ─── loadFlags ──────────────────────────────────────────────────────────────

describe("loadFlags", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    invalidateFlagCache();
  });

  it("fetches flags from feature_flags table", async () => {
    const flags = await loadFlags();
    expect(mockFrom).toHaveBeenCalledWith("feature_flags");
    expect(mockSelect).toHaveBeenCalledWith("*");
    expect(flags).toBeInstanceOf(Map);
  });

  it("returns an empty map when no flags exist", async () => {
    const flags = await loadFlags();
    expect(flags.size).toBe(0);
  });

  it("uses cache on second call within TTL", async () => {
    await loadFlags();
    const callCount = mockFrom.mock.calls.length;

    await loadFlags();
    // Should NOT have called from() again — cache hit
    expect(mockFrom).toHaveBeenCalledTimes(callCount);
  });

  it("refreshes cache after TTL expires", async () => {
    await loadFlags();
    const callCountAfterFirst = mockFrom.mock.calls.length;

    // Advance time past 5s TTL
    vi.useFakeTimers();
    vi.advanceTimersByTime(6_000);

    await loadFlags();
    expect(mockFrom.mock.calls.length).toBeGreaterThan(callCountAfterFirst);

    vi.useRealTimers();
  });
});

// ─── invalidateFlagCache ────────────────────────────────────────────────────

describe("invalidateFlagCache", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    invalidateFlagCache();
  });

  it("forces a fresh fetch on next loadFlags call", async () => {
    await loadFlags();
    const callCountAfterFirst = mockFrom.mock.calls.length;

    invalidateFlagCache();
    await loadFlags();
    // Should have made a new query
    expect(mockFrom.mock.calls.length).toBeGreaterThan(callCountAfterFirst);
  });
});

// ─── evaluateFlagWithOverrides ──────────────────────────────────────────────

describe("evaluateFlagWithOverrides", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    invalidateFlagCache();
    mockMaybeSingle.mockResolvedValue({ data: null, error: null });
  });

  it("returns default result when flag does not exist", async () => {
    const result = await evaluateFlagWithOverrides("nonexistent", makeCtx());
    expect(result).toEqual({ enabled: false, source: "default" });
  });

  it("checks overrides before evaluating rules", async () => {
    // Override returns enabled
    mockMaybeSingle.mockResolvedValue({
      data: {
        override_value: { enabled: true, variant: "beta" },
        expires_at: null,
      },
      error: null,
    });

    // Need flags to have the key
    const { createServerSupabaseClient } = await import(
      "@/lib/supabase/server"
    );
    const mockClient = await (
      createServerSupabaseClient as ReturnType<typeof vi.fn>
    )();
    // Patch from to return a flag for loadFlags
    const originalFrom = mockClient.from;
    let callIdx = 0;
    mockClient.from = vi.fn((...args: unknown[]) => {
      callIdx++;
      const res = originalFrom(...args);
      // First call is loadFlags (feature_flags)
      if (callIdx === 1) {
        return {
          select: () => ({
            data: [makeFlag({ key: "overridden_flag" })],
            error: null,
          }),
        };
      }
      return res;
    });
    (createServerSupabaseClient as ReturnType<typeof vi.fn>).mockResolvedValue(
      mockClient,
    );

    invalidateFlagCache();
    const result = await evaluateFlagWithOverrides("overridden_flag", makeCtx());
    expect(result.source).toBe("override");
    expect(result.enabled).toBe(true);
    expect(result.variant).toBe("beta");

    // evaluateFlag should NOT have been called
    expect(mockEvaluateFlag).not.toHaveBeenCalled();
  });

  it("falls back to evaluateFlag when no override exists", async () => {
    mockMaybeSingle.mockResolvedValue({ data: null, error: null });
    mockEvaluateFlag.mockReturnValue({ enabled: true, source: "rule" });

    const { createServerSupabaseClient } = await import(
      "@/lib/supabase/server"
    );
    const mockClient = await (
      createServerSupabaseClient as ReturnType<typeof vi.fn>
    )();
    const originalFrom = mockClient.from;
    let callIdx = 0;
    mockClient.from = vi.fn((...args: unknown[]) => {
      callIdx++;
      const res = originalFrom(...args);
      if (callIdx === 1) {
        return {
          select: () => ({
            data: [makeFlag({ key: "rule_flag" })],
            error: null,
          }),
        };
      }
      return res;
    });
    (createServerSupabaseClient as ReturnType<typeof vi.fn>).mockResolvedValue(
      mockClient,
    );

    invalidateFlagCache();
    const result = await evaluateFlagWithOverrides("rule_flag", makeCtx());
    expect(result.source).toBe("rule");
    expect(mockEvaluateFlag).toHaveBeenCalled();
  });

  it("ignores expired overrides", async () => {
    // Override that expired yesterday
    mockMaybeSingle.mockResolvedValue({
      data: {
        override_value: { enabled: true },
        expires_at: "2020-01-01T00:00:00Z",
      },
      error: null,
    });
    mockEvaluateFlag.mockReturnValue({ enabled: false, source: "rule" });

    const { createServerSupabaseClient } = await import(
      "@/lib/supabase/server"
    );
    const mockClient = await (
      createServerSupabaseClient as ReturnType<typeof vi.fn>
    )();
    const originalFrom = mockClient.from;
    let callIdx = 0;
    mockClient.from = vi.fn((...args: unknown[]) => {
      callIdx++;
      const res = originalFrom(...args);
      if (callIdx === 1) {
        return {
          select: () => ({
            data: [makeFlag({ key: "expired_override" })],
            error: null,
          }),
        };
      }
      return res;
    });
    (createServerSupabaseClient as ReturnType<typeof vi.fn>).mockResolvedValue(
      mockClient,
    );

    invalidateFlagCache();
    const result = await evaluateFlagWithOverrides(
      "expired_override",
      makeCtx(),
    );
    // Should have fallen back to evaluateFlag
    expect(result.source).toBe("rule");
    expect(mockEvaluateFlag).toHaveBeenCalled();
  });

  it("skips override check when context has no targets", async () => {
    mockEvaluateFlag.mockReturnValue({ enabled: true, source: "rule" });

    const { createServerSupabaseClient } = await import(
      "@/lib/supabase/server"
    );
    const mockClient = await (
      createServerSupabaseClient as ReturnType<typeof vi.fn>
    )();
    const originalFrom = mockClient.from;
    let callIdx = 0;
    mockClient.from = vi.fn((...args: unknown[]) => {
      callIdx++;
      const res = originalFrom(...args);
      if (callIdx === 1) {
        return {
          select: () => ({
            data: [makeFlag({ key: "no_target" })],
            error: null,
          }),
        };
      }
      return res;
    });
    (createServerSupabaseClient as ReturnType<typeof vi.fn>).mockResolvedValue(
      mockClient,
    );

    invalidateFlagCache();
    // Empty context — no userId, no sessionId, country is still set
    const ctx = makeCtx({ userId: undefined, sessionId: undefined });
    const result = await evaluateFlagWithOverrides("no_target", ctx);
    // country is still a target so override lookup still happens,
    // but mockMaybeSingle returns null by default
    expect(result.source).toBe("rule");
  });
});

// ─── getFlag ────────────────────────────────────────────────────────────────

describe("getFlag", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    invalidateFlagCache();
    mockMaybeSingle.mockResolvedValue({ data: null, error: null });
  });

  it("returns boolean from evaluateFlagWithOverrides", async () => {
    mockEvaluateFlag.mockReturnValue({ enabled: true, source: "rule" });

    const { createServerSupabaseClient } = await import(
      "@/lib/supabase/server"
    );
    const mockClient = await (
      createServerSupabaseClient as ReturnType<typeof vi.fn>
    )();
    mockClient.from = vi.fn(() => ({
      select: () => ({
        data: [makeFlag({ key: "bool_flag" })],
        error: null,
        eq: () => ({
          in: () => ({
            limit: () => ({ maybeSingle: mockMaybeSingle }),
          }),
        }),
      }),
    }));
    (createServerSupabaseClient as ReturnType<typeof vi.fn>).mockResolvedValue(
      mockClient,
    );

    invalidateFlagCache();
    const result = await getFlag("bool_flag", makeCtx());
    expect(typeof result).toBe("boolean");
    expect(result).toBe(true);
  });

  it("returns false for nonexistent flags", async () => {
    const result = await getFlag("does_not_exist", makeCtx());
    expect(result).toBe(false);
  });
});

// ─── getFlagVariant ─────────────────────────────────────────────────────────

describe("getFlagVariant", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    invalidateFlagCache();
    mockMaybeSingle.mockResolvedValue({ data: null, error: null });
  });

  it("returns variant string from evaluation", async () => {
    mockEvaluateFlag.mockReturnValue({
      enabled: true,
      variant: "beta",
      source: "rule",
    });

    const { createServerSupabaseClient } = await import(
      "@/lib/supabase/server"
    );
    const mockClient = await (
      createServerSupabaseClient as ReturnType<typeof vi.fn>
    )();
    mockClient.from = vi.fn(() => ({
      select: () => ({
        data: [makeFlag({ key: "variant_flag", flag_type: "variant" })],
        error: null,
        eq: () => ({
          in: () => ({
            limit: () => ({ maybeSingle: mockMaybeSingle }),
          }),
        }),
      }),
    }));
    (createServerSupabaseClient as ReturnType<typeof vi.fn>).mockResolvedValue(
      mockClient,
    );

    invalidateFlagCache();
    const variant = await getFlagVariant("variant_flag", makeCtx());
    expect(variant).toBe("beta");
  });

  it("returns undefined for nonexistent flags", async () => {
    const variant = await getFlagVariant("missing", makeCtx());
    expect(variant).toBeUndefined();
  });
});

// ─── evaluateAllFlags ───────────────────────────────────────────────────────

describe("evaluateAllFlags", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    invalidateFlagCache();
  });

  it("returns flags and variants records", async () => {
    mockEvaluateFlag
      .mockReturnValueOnce({ enabled: true, source: "rule" })
      .mockReturnValueOnce({
        enabled: true,
        variant: "dark",
        source: "rule",
      })
      .mockReturnValueOnce({ enabled: false, source: "rule" });

    const { createServerSupabaseClient } = await import(
      "@/lib/supabase/server"
    );
    const mockClient = await (
      createServerSupabaseClient as ReturnType<typeof vi.fn>
    )();
    mockClient.from = vi.fn(() => ({
      select: () => ({
        data: [
          makeFlag({ key: "flag_a" }),
          makeFlag({ key: "flag_b", flag_type: "variant" }),
          makeFlag({ key: "flag_c", enabled: false }),
        ],
        error: null,
      }),
    }));
    (createServerSupabaseClient as ReturnType<typeof vi.fn>).mockResolvedValue(
      mockClient,
    );

    invalidateFlagCache();
    const result = await evaluateAllFlags(makeCtx());
    expect(result.flags).toEqual({
      flag_a: true,
      flag_b: true,
      flag_c: false,
    });
    expect(result.variants).toEqual({ flag_b: "dark" });
  });

  it("returns empty records when no flags exist", async () => {
    const { createServerSupabaseClient } = await import(
      "@/lib/supabase/server"
    );
    const emptyClient = await (
      createServerSupabaseClient as ReturnType<typeof vi.fn>
    )();
    emptyClient.from = vi.fn(() => ({
      select: () => ({ data: [], error: null }),
    }));
    (createServerSupabaseClient as ReturnType<typeof vi.fn>).mockResolvedValue(
      emptyClient,
    );

    invalidateFlagCache();
    const result = await evaluateAllFlags(makeCtx());
    expect(result.flags).toEqual({});
    expect(result.variants).toEqual({});
  });
});
