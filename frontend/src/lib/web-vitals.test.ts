import { describe, it, expect, vi, beforeEach } from "vitest";

// ─── Web Vitals Tests (#621) ────────────────────────────────────────────────
// Tests the web-vitals collection module: rateMetric classification,
// reportWebVitals initialization, and handler invocation.

import {
  rateMetric,
  reportWebVitals,
  WEB_VITAL_THRESHOLDS,
  defaultMetricHandler,
  type MetricHandler,
  type VitalRating,
} from "./web-vitals";

// ─── rateMetric classification ──────────────────────────────────────────────

describe("rateMetric", () => {
  // ── CLS thresholds ──────────────────────────────────────────────────────
  describe("CLS", () => {
    it("rates 0.05 as good", () => {
      expect(rateMetric("CLS", 0.05)).toBe("good");
    });

    it("rates 0.1 as good (boundary)", () => {
      expect(rateMetric("CLS", 0.1)).toBe("good");
    });

    it("rates 0.15 as needs-improvement", () => {
      expect(rateMetric("CLS", 0.15)).toBe("needs-improvement");
    });

    it("rates 0.25 as needs-improvement (boundary)", () => {
      expect(rateMetric("CLS", 0.25)).toBe("needs-improvement");
    });

    it("rates 0.3 as poor", () => {
      expect(rateMetric("CLS", 0.3)).toBe("poor");
    });

    it("rates 0 as good", () => {
      expect(rateMetric("CLS", 0)).toBe("good");
    });
  });

  // ── INP thresholds ──────────────────────────────────────────────────────
  describe("INP", () => {
    it("rates 100 as good", () => {
      expect(rateMetric("INP", 100)).toBe("good");
    });

    it("rates 200 as good (boundary)", () => {
      expect(rateMetric("INP", 200)).toBe("good");
    });

    it("rates 300 as needs-improvement", () => {
      expect(rateMetric("INP", 300)).toBe("needs-improvement");
    });

    it("rates 500 as needs-improvement (boundary)", () => {
      expect(rateMetric("INP", 500)).toBe("needs-improvement");
    });

    it("rates 600 as poor", () => {
      expect(rateMetric("INP", 600)).toBe("poor");
    });
  });

  // ── LCP thresholds ──────────────────────────────────────────────────────
  describe("LCP", () => {
    it("rates 1500 as good", () => {
      expect(rateMetric("LCP", 1500)).toBe("good");
    });

    it("rates 2500 as good (boundary)", () => {
      expect(rateMetric("LCP", 2500)).toBe("good");
    });

    it("rates 3000 as needs-improvement", () => {
      expect(rateMetric("LCP", 3000)).toBe("needs-improvement");
    });

    it("rates 4000 as needs-improvement (boundary)", () => {
      expect(rateMetric("LCP", 4000)).toBe("needs-improvement");
    });

    it("rates 5000 as poor", () => {
      expect(rateMetric("LCP", 5000)).toBe("poor");
    });
  });

  // ── TTFB and FCP (simple threshold) ─────────────────────────────────────
  describe("TTFB", () => {
    it("rates 400 as good", () => {
      expect(rateMetric("TTFB", 400)).toBe("good");
    });

    it("rates 800 as good (boundary)", () => {
      expect(rateMetric("TTFB", 800)).toBe("good");
    });

    it("rates 1200 as poor", () => {
      expect(rateMetric("TTFB", 1200)).toBe("poor");
    });
  });

  describe("FCP", () => {
    it("rates 1000 as good", () => {
      expect(rateMetric("FCP", 1000)).toBe("good");
    });

    it("rates 1800 as good (boundary)", () => {
      expect(rateMetric("FCP", 1800)).toBe("good");
    });

    it("rates 3000 as poor", () => {
      expect(rateMetric("FCP", 3000)).toBe("poor");
    });
  });

  // ── Unknown metric ──────────────────────────────────────────────────────
  describe("unknown metric", () => {
    it("rates unknown metric as good", () => {
      expect(rateMetric("UNKNOWN_METRIC", 99999)).toBe("good");
    });
  });
});

// ─── WEB_VITAL_THRESHOLDS ───────────────────────────────────────────────────

describe("WEB_VITAL_THRESHOLDS", () => {
  it("defines thresholds for all 5 core metrics", () => {
    expect(WEB_VITAL_THRESHOLDS).toHaveProperty("CLS");
    expect(WEB_VITAL_THRESHOLDS).toHaveProperty("INP");
    expect(WEB_VITAL_THRESHOLDS).toHaveProperty("LCP");
    expect(WEB_VITAL_THRESHOLDS).toHaveProperty("TTFB");
    expect(WEB_VITAL_THRESHOLDS).toHaveProperty("FCP");
  });

  it("has CLS threshold of 0.1", () => {
    expect(WEB_VITAL_THRESHOLDS.CLS).toBe(0.1);
  });

  it("has INP threshold of 200ms", () => {
    expect(WEB_VITAL_THRESHOLDS.INP).toBe(200);
  });

  it("has LCP threshold of 2500ms", () => {
    expect(WEB_VITAL_THRESHOLDS.LCP).toBe(2500);
  });
});

// ─── reportWebVitals ────────────────────────────────────────────────────────

describe("reportWebVitals", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("calls handler for each metric reported", async () => {
    const handler = vi.fn<MetricHandler>();
    const metrics: Array<{ name: string; value: number; id: string }> = [];

    // Mock web-vitals module
    vi.doMock("web-vitals", () => ({
      onCLS: (cb: (m: { name: string; value: number; id: string }) => void) => {
        const m = { name: "CLS", value: 0.05, id: "cls-1" };
        metrics.push(m);
        cb(m);
      },
      onINP: (cb: (m: { name: string; value: number; id: string }) => void) => {
        const m = { name: "INP", value: 150, id: "inp-1" };
        metrics.push(m);
        cb(m);
      },
      onLCP: (cb: (m: { name: string; value: number; id: string }) => void) => {
        const m = { name: "LCP", value: 2000, id: "lcp-1" };
        metrics.push(m);
        cb(m);
      },
      onTTFB: (cb: (m: { name: string; value: number; id: string }) => void) => {
        const m = { name: "TTFB", value: 500, id: "ttfb-1" };
        metrics.push(m);
        cb(m);
      },
      onFCP: (cb: (m: { name: string; value: number; id: string }) => void) => {
        const m = { name: "FCP", value: 1200, id: "fcp-1" };
        metrics.push(m);
        cb(m);
      },
    }));

    // Re-import to pick up mock
    const { reportWebVitals: report } = await import("./web-vitals");
    report(handler);

    // Dynamic import is async — wait for it
    await vi.dynamicImportSettled();

    expect(handler).toHaveBeenCalledTimes(5);

    // Verify each metric was reported with correct rating
    const calls = handler.mock.calls.map((c) => ({
      name: c[0].name,
      rating: c[0].rating,
    }));
    expect(calls).toEqual(
      expect.arrayContaining([
        { name: "CLS", rating: "good" },
        { name: "INP", rating: "good" },
        { name: "LCP", rating: "good" },
        { name: "TTFB", rating: "good" },
        { name: "FCP", rating: "good" },
      ]),
    );
  });

  it("is a no-op when window is undefined (SSR)", () => {
    const handler = vi.fn<MetricHandler>();
    const originalWindow = globalThis.window;

    // Simulate SSR
    // @ts-expect-error — intentionally removing window for SSR simulation
    delete globalThis.window;

    reportWebVitals(handler);

    expect(handler).not.toHaveBeenCalled();

    // Restore
    globalThis.window = originalWindow;
  });
});

// ─── defaultMetricHandler ───────────────────────────────────────────────────

describe("defaultMetricHandler", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("logs to console.debug in development", () => {
    const spy = vi.spyOn(console, "debug").mockImplementation(() => {});
    const originalEnv = process.env.NODE_ENV;
    process.env.NODE_ENV = "development";

    defaultMetricHandler({
      name: "LCP",
      value: 2000,
      id: "lcp-test",
      rating: "good" as VitalRating,
    });

    expect(spy).toHaveBeenCalledWith(
      "[Web Vital] LCP: 2000 (good)",
    );

    process.env.NODE_ENV = originalEnv;
    spy.mockRestore();
  });

  it("is exported as a function", () => {
    expect(typeof defaultMetricHandler).toBe("function");
  });
});
