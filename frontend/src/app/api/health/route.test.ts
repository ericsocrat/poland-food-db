import { describe, it, expect, vi, beforeEach } from "vitest";

// ─── Mocks ──────────────────────────────────────────────────────────────────

const mockRpc = vi.fn();

vi.mock("@/lib/supabase/service", () => ({
  createServiceRoleClient: () => ({
    rpc: mockRpc,
  }),
}));

// Import AFTER mocks are set up
import { GET, type HealthCheckResponse } from "./route";

// ─── Fixtures ───────────────────────────────────────────────────────────────

const healthyResponse: HealthCheckResponse = {
  status: "healthy",
  checks: {
    connectivity: true,
    mv_staleness: {
      mv_ingredient_frequency: {
        mv_rows: 487,
        source_rows: 487,
        stale: false,
      },
      v_product_confidence: {
        mv_rows: 3012,
        source_rows: 3012,
        stale: false,
      },
    },
    row_counts: {
      products: 3012,
      ceiling: 15000,
      utilization_pct: 20.1,
    },
  },
  timestamp: "2026-02-22T14:35:00Z",
};

const degradedResponse: HealthCheckResponse = {
  ...healthyResponse,
  status: "degraded",
  checks: {
    ...healthyResponse.checks,
    row_counts: {
      products: 12500,
      ceiling: 15000,
      utilization_pct: 83.3,
    },
  },
};

const unhealthyResponse: HealthCheckResponse = {
  ...healthyResponse,
  status: "unhealthy",
  checks: {
    ...healthyResponse.checks,
    row_counts: {
      products: 14800,
      ceiling: 15000,
      utilization_pct: 98.7,
    },
  },
};

// ─── Helpers ────────────────────────────────────────────────────────────────

async function parseResponse(response: Response) {
  const body = await response.json();
  return { status: response.status, body };
}

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("GET /api/health", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("returns 200 with healthy response", async () => {
    mockRpc.mockResolvedValue({ data: healthyResponse, error: null });

    const { status, body } = await parseResponse(await GET());

    expect(status).toBe(200);
    expect(body.status).toBe("healthy");
    expect(body.checks.connectivity).toBe(true);
    expect(body.checks.row_counts.products).toBe(3012);
    expect(body.timestamp).toBe("2026-02-22T14:35:00Z");
  });

  it("returns 200 for degraded status", async () => {
    mockRpc.mockResolvedValue({ data: degradedResponse, error: null });

    const { status, body } = await parseResponse(await GET());

    expect(status).toBe(200);
    expect(body.status).toBe("degraded");
    expect(body.checks.row_counts.utilization_pct).toBe(83.3);
  });

  it("returns 503 for unhealthy status", async () => {
    mockRpc.mockResolvedValue({ data: unhealthyResponse, error: null });

    const { status, body } = await parseResponse(await GET());

    expect(status).toBe(503);
    expect(body.status).toBe("unhealthy");
  });

  it("returns 503 on database error", async () => {
    mockRpc.mockResolvedValue({
      data: null,
      error: { message: "connection refused", code: "PGRST301" },
    });

    const { status, body } = await parseResponse(await GET());

    expect(status).toBe(503);
    expect(body.status).toBe("unhealthy");
    expect(body.checks.connectivity).toBe(false);
  });

  it("returns 503 when RPC returns unexpected shape", async () => {
    mockRpc.mockResolvedValue({
      data: { unexpected: "shape" },
      error: null,
    });

    const { status, body } = await parseResponse(await GET());

    expect(status).toBe(503);
    expect(body.status).toBe("unhealthy");
    expect(body.checks.connectivity).toBe(true);
  });

  it("returns 503 when RPC returns null data", async () => {
    mockRpc.mockResolvedValue({ data: null, error: null });

    const { status, body } = await parseResponse(await GET());

    expect(status).toBe(503);
    expect(body.status).toBe("unhealthy");
  });

  it("returns 503 on thrown exception", async () => {
    mockRpc.mockRejectedValue(new Error("Network error"));

    const { status, body } = await parseResponse(await GET());

    expect(status).toBe(503);
    expect(body.status).toBe("unhealthy");
    expect(body.checks.connectivity).toBe(false);
  });

  it("sets Cache-Control: no-store header", async () => {
    mockRpc.mockResolvedValue({ data: healthyResponse, error: null });

    const response = await GET();

    expect(response.headers.get("Cache-Control")).toBe("no-store");
  });

  it("includes timestamp in error responses", async () => {
    mockRpc.mockResolvedValue({
      data: null,
      error: { message: "fail" },
    });

    const { body } = await parseResponse(await GET());

    expect(body.timestamp).toBeDefined();
    expect(typeof body.timestamp).toBe("string");
  });

  it("sanitizes response to only include expected fields", async () => {
    const dataWithExtra = {
      ...healthyResponse,
      secret_key: "should-be-stripped",
      internal_ip: "10.0.0.1",
    };
    mockRpc.mockResolvedValue({ data: dataWithExtra, error: null });

    const { body } = await parseResponse(await GET());

    expect(body.secret_key).toBeUndefined();
    expect(body.internal_ip).toBeUndefined();
    expect(body.status).toBe("healthy");
    expect(body.checks).toBeDefined();
    expect(body.timestamp).toBeDefined();
  });

  it("returns correct MV staleness metrics", async () => {
    mockRpc.mockResolvedValue({ data: healthyResponse, error: null });

    const { body } = await parseResponse(await GET());

    const mvIngredient = body.checks.mv_staleness.mv_ingredient_frequency;
    expect(mvIngredient.mv_rows).toBe(487);
    expect(mvIngredient.source_rows).toBe(487);
    expect(mvIngredient.stale).toBe(false);

    const vConfidence = body.checks.mv_staleness.v_product_confidence;
    expect(vConfidence.mv_rows).toBe(3012);
    expect(vConfidence.source_rows).toBe(3012);
    expect(vConfidence.stale).toBe(false);
  });

  it("rejects response with missing status field", async () => {
    const noStatus = { ...healthyResponse };
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    delete (noStatus as any).status;
    mockRpc.mockResolvedValue({ data: noStatus, error: null });

    const { status } = await parseResponse(await GET());

    expect(status).toBe(503);
  });

  it("rejects response with invalid status value", async () => {
    mockRpc.mockResolvedValue({
      data: { ...healthyResponse, status: "invalid" },
      error: null,
    });

    const { status } = await parseResponse(await GET());

    expect(status).toBe(503);
  });

  it("rejects response with missing checks object", async () => {
    mockRpc.mockResolvedValue({
      data: { status: "healthy", timestamp: "2026-01-01T00:00:00Z" },
      error: null,
    });

    const { status } = await parseResponse(await GET());

    expect(status).toBe(503);
  });

  it("rejects response with non-numeric row counts", async () => {
    const badRowCounts = {
      ...healthyResponse,
      checks: {
        ...healthyResponse.checks,
        row_counts: {
          products: "many",
          ceiling: 15000,
          utilization_pct: 20.1,
        },
      },
    };
    mockRpc.mockResolvedValue({ data: badRowCounts, error: null });

    const { status } = await parseResponse(await GET());

    expect(status).toBe(503);
  });
});
