// ─── Tests: N+1 Query Pattern Observer ──────────────────────────────────────
// Issue: #185 — [Hardening 5/7] Query-Level Performance Guardrails

import { describe, it, expect, beforeEach, vi, afterEach } from "vitest";
import {
  observeQuery,
  resetObserver,
  getWarnings,
  isObserverActive,
  N_PLUS_ONE_THRESHOLD,
  WINDOW_MS,
} from "./query-observer";

describe("query-observer", () => {
  beforeEach(() => {
    resetObserver();
    vi.stubEnv("NODE_ENV", "development");
    vi.stubEnv("NEXT_PUBLIC_QA_MODE", "");
  });

  afterEach(() => {
    vi.unstubAllEnvs();
  });

  // ── Configuration constants ─────────────────────────────────────────────

  it("exports expected threshold constants", () => {
    expect(N_PLUS_ONE_THRESHOLD).toBe(5);
    expect(WINDOW_MS).toBe(500);
  });

  // ── isObserverActive ───────────────────────────────────────────────────

  it("is active in development", () => {
    vi.stubEnv("NODE_ENV", "development");
    expect(isObserverActive()).toBe(true);
  });

  it("is active when QA_MODE is set", () => {
    vi.stubEnv("NODE_ENV", "production");
    vi.stubEnv("NEXT_PUBLIC_QA_MODE", "true");
    expect(isObserverActive()).toBe(true);
  });

  it("is inactive in production without QA_MODE", () => {
    vi.stubEnv("NODE_ENV", "production");
    vi.stubEnv("NEXT_PUBLIC_QA_MODE", "");
    expect(isObserverActive()).toBe(false);
  });

  // ── observeQuery — no detection ────────────────────────────────────────

  it("returns null for a single call", () => {
    expect(observeQuery("api_product_detail")).toBeNull();
  });

  it("returns null for calls below threshold", () => {
    for (let i = 0; i < N_PLUS_ONE_THRESHOLD - 1; i++) {
      expect(observeQuery("api_product_detail")).toBeNull();
    }
  });

  it("returns null for different RPC names even if total exceeds threshold", () => {
    observeQuery("api_product_detail");
    observeQuery("api_category_listing");
    observeQuery("api_search_products");
    observeQuery("api_better_alternatives");
    observeQuery("api_score_explanation");
    // 5 calls total but all different => no N+1
    expect(getWarnings()).toHaveLength(0);
  });

  // ── observeQuery — detection ───────────────────────────────────────────

  it("detects N+1 pattern at exact threshold", () => {
    const warnSpy = vi.spyOn(console, "warn").mockImplementation(() => {});

    for (let i = 0; i < N_PLUS_ONE_THRESHOLD - 1; i++) {
      observeQuery("api_product_detail");
    }

    const result = observeQuery("api_product_detail");
    expect(result).toContain("[N+1 DETECTED]");
    expect(result).toContain("api_product_detail");
    expect(result).toContain(`${N_PLUS_ONE_THRESHOLD}`);
    expect(warnSpy).toHaveBeenCalled();

    warnSpy.mockRestore();
  });

  it("detects N+1 for calls above threshold", () => {
    vi.spyOn(console, "warn").mockImplementation(() => {});

    for (let i = 0; i < N_PLUS_ONE_THRESHOLD + 3; i++) {
      observeQuery("api_product_detail");
    }

    const warnings = getWarnings();
    expect(warnings.length).toBeGreaterThan(0);
    expect(warnings[0]).toContain("api_product_detail");

    vi.mocked(console.warn).mockRestore();
  });

  it("tracks multiple RPC names independently", () => {
    vi.spyOn(console, "warn").mockImplementation(() => {});

    // Call rpc_a 5 times => triggers
    for (let i = 0; i < N_PLUS_ONE_THRESHOLD; i++) {
      observeQuery("rpc_a");
    }
    // Call rpc_b 3 times => does not trigger
    for (let i = 0; i < N_PLUS_ONE_THRESHOLD - 2; i++) {
      observeQuery("rpc_b");
    }

    const warnings = getWarnings();
    expect(warnings.some((w) => w.includes("rpc_a"))).toBe(true);
    expect(warnings.some((w) => w.includes("rpc_b"))).toBe(false);

    vi.mocked(console.warn).mockRestore();
  });

  // ── observeQuery — production no-op ────────────────────────────────────

  it("is no-op in production without QA_MODE", () => {
    vi.stubEnv("NODE_ENV", "production");
    vi.stubEnv("NEXT_PUBLIC_QA_MODE", "");

    for (let i = 0; i < N_PLUS_ONE_THRESHOLD + 5; i++) {
      observeQuery("api_product_detail");
    }

    expect(getWarnings()).toHaveLength(0);
  });

  it("is active in production with QA_MODE=true", () => {
    vi.stubEnv("NODE_ENV", "production");
    vi.stubEnv("NEXT_PUBLIC_QA_MODE", "true");
    vi.spyOn(console, "warn").mockImplementation(() => {});

    for (let i = 0; i < N_PLUS_ONE_THRESHOLD; i++) {
      observeQuery("api_product_detail");
    }

    expect(getWarnings().length).toBeGreaterThan(0);
    vi.mocked(console.warn).mockRestore();
  });

  // ── Time window expiration ─────────────────────────────────────────────

  it("does not detect N+1 after window expires", () => {
    vi.useFakeTimers();

    for (let i = 0; i < N_PLUS_ONE_THRESHOLD - 1; i++) {
      observeQuery("api_product_detail");
    }

    // Advance past the window
    vi.advanceTimersByTime(WINDOW_MS + 10);

    // This call is the first in a new window
    expect(observeQuery("api_product_detail")).toBeNull();
    expect(getWarnings()).toHaveLength(0);

    vi.useRealTimers();
  });

  // ── resetObserver ──────────────────────────────────────────────────────

  it("clears all state on reset", () => {
    vi.spyOn(console, "warn").mockImplementation(() => {});

    for (let i = 0; i < N_PLUS_ONE_THRESHOLD; i++) {
      observeQuery("api_product_detail");
    }
    expect(getWarnings().length).toBeGreaterThan(0);

    resetObserver();
    expect(getWarnings()).toHaveLength(0);

    vi.mocked(console.warn).mockRestore();
  });

  // ── Warning message format ─────────────────────────────────────────────

  it("includes RPC name, count, and window in warning message", () => {
    vi.spyOn(console, "warn").mockImplementation(() => {});

    for (let i = 0; i < N_PLUS_ONE_THRESHOLD; i++) {
      observeQuery("api_daily_insights");
    }

    const warnings = getWarnings();
    expect(warnings[0]).toMatch(/\[N\+1 DETECTED\]/);
    expect(warnings[0]).toMatch(/api_daily_insights/);
    expect(warnings[0]).toMatch(new RegExp(`${WINDOW_MS}ms`));

    vi.mocked(console.warn).mockRestore();
  });
});
