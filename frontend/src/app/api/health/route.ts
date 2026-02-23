// ─── Health Check API Route ──────────────────────────────────────────────────
// GET /api/health — Returns database health metrics for uptime monitoring.
// Uses service_role client to call api_health_check() (SECURITY DEFINER).
// Response contains ONLY health metrics — NO secrets, tokens, or infra details.
// Returns 200 for healthy/degraded, 503 for unhealthy or connection failure.
// Instrumented with structured logging (#183).

import { NextResponse } from "next/server";
import { createServiceRoleClient } from "@/lib/supabase/service";
import { logger } from "@/lib/logger";

/** Expected shape from api_health_check() RPC */
export interface HealthCheckResponse {
  status: "healthy" | "degraded" | "unhealthy";
  checks: {
    connectivity: boolean;
    mv_staleness: {
      mv_ingredient_frequency: {
        mv_rows: number;
        source_rows: number;
        stale: boolean;
      };
      v_product_confidence: {
        mv_rows: number;
        source_rows: number;
        stale: boolean;
      };
    };
    row_counts: {
      products: number;
      ceiling: number;
      utilization_pct: number;
    };
  };
  timestamp: string;
}

/** Validate the response shape to prevent leaking unexpected data */
function sanitizeResponse(data: unknown): HealthCheckResponse | null {
  if (!data || typeof data !== "object") return null;

  const d = data as Record<string, unknown>;

  if (
    typeof d.status !== "string" ||
    !["healthy", "degraded", "unhealthy"].includes(d.status)
  ) {
    return null;
  }

  if (!d.checks || typeof d.checks !== "object") return null;
  if (typeof d.timestamp !== "string") return null;

  const checks = d.checks as Record<string, unknown>;

  // Validate connectivity
  if (typeof checks.connectivity !== "boolean") return null;

  // Validate mv_staleness
  if (!checks.mv_staleness || typeof checks.mv_staleness !== "object")
    return null;

  // Validate row_counts
  if (!checks.row_counts || typeof checks.row_counts !== "object") return null;

  const rowCounts = checks.row_counts as Record<string, unknown>;
  if (
    typeof rowCounts.products !== "number" ||
    typeof rowCounts.ceiling !== "number" ||
    typeof rowCounts.utilization_pct !== "number"
  ) {
    return null;
  }

  // Return only expected fields (strip anything unexpected)
  return {
    status: d.status as HealthCheckResponse["status"],
    checks: {
      connectivity: checks.connectivity,
      mv_staleness: checks.mv_staleness as HealthCheckResponse["checks"]["mv_staleness"],
      row_counts: {
        products: rowCounts.products,
        ceiling: rowCounts.ceiling,
        utilization_pct: rowCounts.utilization_pct,
      },
    },
    timestamp: d.timestamp,
  };
}

export async function GET() {
  const start = performance.now();

  try {
    const supabase = createServiceRoleClient();
    const { data, error } = await supabase.rpc("api_health_check");

    if (error) {
      const duration = Math.round(performance.now() - start);
      logger.warn("Health check RPC error", {
        route: "/api/health",
        method: "GET",
        status: 503,
        duration,
        error: { name: "RPCError", message: error.message },
      });

      return NextResponse.json(
        {
          status: "unhealthy",
          checks: { connectivity: false },
          timestamp: new Date().toISOString(),
        },
        {
          status: 503,
          headers: { "Cache-Control": "no-store" },
        },
      );
    }

    const sanitized = sanitizeResponse(data);
    if (!sanitized) {
      return NextResponse.json(
        {
          status: "unhealthy",
          checks: { connectivity: true },
          timestamp: new Date().toISOString(),
        },
        {
          status: 503,
          headers: { "Cache-Control": "no-store" },
        },
      );
    }

    const httpStatus = sanitized.status === "unhealthy" ? 503 : 200;
    const duration = Math.round(performance.now() - start);

    logger.info("Health check completed", {
      route: "/api/health",
      method: "GET",
      status: httpStatus,
      duration,
      meta: { dbStatus: sanitized.status },
    });

    return NextResponse.json(sanitized, {
      status: httpStatus,
      headers: { "Cache-Control": "no-store" },
    });
  } catch (error) {
    const duration = Math.round(performance.now() - start);
    logger.error("Health check exception", {
      route: "/api/health",
      method: "GET",
      status: 503,
      duration,
      error:
        error instanceof Error
          ? { name: error.name, message: error.message }
          : { name: "Unknown", message: String(error) },
    });

    return NextResponse.json(
      {
        status: "unhealthy",
        checks: { connectivity: false },
        timestamp: new Date().toISOString(),
      },
      {
        status: 503,
        headers: { "Cache-Control": "no-store" },
      },
    );
  }
}
