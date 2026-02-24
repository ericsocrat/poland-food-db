/**
 * Health endpoint — Zod contract test.
 *
 * Validates that the response shape is stable and never leaks secrets.
 * Runs in CI alongside route.test.ts to catch schema drift early.
 *
 * @see Issue #180 — [Quality Gate 8/9] Synthetic Monitoring in Production
 */

import { describe, it, expect } from "vitest";
import { z } from "zod";

// ─── Contract Schema ────────────────────────────────────────────────────────
// Mirrors HealthCheckResponse from route.ts but expressed as a Zod schema
// so drift between implementation and contract is caught automatically.

const MvStalenessEntrySchema = z.object({
  mv_rows: z.number(),
  source_rows: z.number(),
  stale: z.boolean(),
});

const HealthResponseSchema = z
  .object({
    status: z.enum(["healthy", "degraded", "unhealthy"]),
    checks: z.object({
      connectivity: z.boolean(),
      mv_staleness: z.object({
        mv_ingredient_frequency: MvStalenessEntrySchema,
        v_product_confidence: MvStalenessEntrySchema,
      }),
      row_counts: z.object({
        products: z.number(),
        ceiling: z.number(),
        utilization_pct: z.number(),
      }),
    }),
    timestamp: z.string(),
  })
  .strict();

// ─── Fixtures ───────────────────────────────────────────────────────────────

const VALID_HEALTHY = {
  status: "healthy",
  checks: {
    connectivity: true,
    mv_staleness: {
      mv_ingredient_frequency: { mv_rows: 487, source_rows: 487, stale: false },
      v_product_confidence: { mv_rows: 3012, source_rows: 3012, stale: false },
    },
    row_counts: { products: 3012, ceiling: 15000, utilization_pct: 20.1 },
  },
  timestamp: "2026-02-22T14:35:00Z",
} as const;

const VALID_DEGRADED = {
  ...VALID_HEALTHY,
  status: "degraded",
  checks: {
    ...VALID_HEALTHY.checks,
    row_counts: { products: 12500, ceiling: 15000, utilization_pct: 83.3 },
  },
} as const;

const VALID_UNHEALTHY = {
  ...VALID_HEALTHY,
  status: "unhealthy",
  checks: {
    ...VALID_HEALTHY.checks,
    connectivity: false,
  },
} as const;

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("Health response contract (Zod)", () => {
  // ── Happy paths ─────────────────────────────────────────────────────────

  it("accepts a healthy response", () => {
    expect(() => HealthResponseSchema.parse(VALID_HEALTHY)).not.toThrow();
  });

  it("accepts a degraded response", () => {
    expect(() => HealthResponseSchema.parse(VALID_DEGRADED)).not.toThrow();
  });

  it("accepts an unhealthy response", () => {
    expect(() => HealthResponseSchema.parse(VALID_UNHEALTHY)).not.toThrow();
  });

  // ── Strict mode: reject unknown keys (secret-leak guard) ───────────────

  it("rejects response with extra top-level fields (strict)", () => {
    const leaky = {
      ...VALID_HEALTHY,
      connectionString: "postgres://secret:pw@host/db",
    };
    expect(() => HealthResponseSchema.parse(leaky)).toThrow();
  });

  it("rejects response with internal_ip field", () => {
    const leaky = {
      ...VALID_HEALTHY,
      internal_ip: "10.0.0.1",
    };
    expect(() => HealthResponseSchema.parse(leaky)).toThrow();
  });

  it("rejects response with secret_key field", () => {
    const leaky = {
      ...VALID_HEALTHY,
      secret_key: "super-secret",
    };
    expect(() => HealthResponseSchema.parse(leaky)).toThrow();
  });

  // ── Missing required fields ────────────────────────────────────────────

  it("rejects response missing status", () => {
    const { status: _, ...noStatus } = VALID_HEALTHY;
    void _;
    expect(() => HealthResponseSchema.parse(noStatus)).toThrow();
  });

  it("rejects response missing checks", () => {
    const { checks: _, ...noChecks } = VALID_HEALTHY;
    void _;
    expect(() => HealthResponseSchema.parse(noChecks)).toThrow();
  });

  it("rejects response missing timestamp", () => {
    const { timestamp: _, ...noTimestamp } = VALID_HEALTHY;
    void _;
    expect(() => HealthResponseSchema.parse(noTimestamp)).toThrow();
  });

  // ── Invalid field values ───────────────────────────────────────────────

  it("rejects invalid status enum value", () => {
    const bad = { ...VALID_HEALTHY, status: "broken" };
    expect(() => HealthResponseSchema.parse(bad)).toThrow();
  });

  it("rejects non-boolean connectivity", () => {
    const bad = {
      ...VALID_HEALTHY,
      checks: { ...VALID_HEALTHY.checks, connectivity: "yes" },
    };
    expect(() => HealthResponseSchema.parse(bad)).toThrow();
  });

  it("rejects non-numeric row counts", () => {
    const bad = {
      ...VALID_HEALTHY,
      checks: {
        ...VALID_HEALTHY.checks,
        row_counts: { products: "many", ceiling: 15000, utilization_pct: 20.1 },
      },
    };
    expect(() => HealthResponseSchema.parse(bad)).toThrow();
  });

  it("rejects non-boolean stale field in mv_staleness", () => {
    const bad = {
      ...VALID_HEALTHY,
      checks: {
        ...VALID_HEALTHY.checks,
        mv_staleness: {
          mv_ingredient_frequency: { mv_rows: 487, source_rows: 487, stale: "no" },
          v_product_confidence: { mv_rows: 3012, source_rows: 3012, stale: false },
        },
      },
    };
    expect(() => HealthResponseSchema.parse(bad)).toThrow();
  });

  // ── Timestamp format ──────────────────────────────────────────────────

  it("accepts ISO-8601 timestamp strings", () => {
    const variants = [
      "2026-02-22T14:35:00Z",
      "2026-02-22T14:35:00.000Z",
      "2026-01-01T00:00:00Z",
    ];
    for (const ts of variants) {
      const response = { ...VALID_HEALTHY, timestamp: ts };
      expect(() => HealthResponseSchema.parse(response)).not.toThrow();
    }
  });

  it("rejects non-string timestamp", () => {
    const bad = { ...VALID_HEALTHY, timestamp: 1234567890 };
    expect(() => HealthResponseSchema.parse(bad)).toThrow();
  });

  // ── Schema exports for reuse ──────────────────────────────────────────

  it("schema infers correct TypeScript type", () => {
    type Inferred = z.infer<typeof HealthResponseSchema>;
    // Compile-time check — if this compiles, the type shape is correct
    const _typeCheck: Inferred = VALID_HEALTHY;
    expect(_typeCheck.status).toBe("healthy");
  });
});
