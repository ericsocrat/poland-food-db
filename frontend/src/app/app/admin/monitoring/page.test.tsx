import { describe, it, expect, vi, beforeEach } from "vitest";
import { render, screen, waitFor, within } from "@testing-library/react";
import { useState } from "react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import type { HealthCheckResponse } from "@/app/api/health/route";

// ─── Mocks ──────────────────────────────────────────────────────────────────

vi.mock("@/lib/i18n", () => ({
  useTranslation: () => ({
    t: (key: string) => {
      const msgs: Record<string, string> = {
        "monitoring.title": "System Monitoring",
        "monitoring.subtitle": "Database health metrics and status",
        "monitoring.overallStatus": "Overall Status",
        "monitoring.lastChecked": "Last checked",
        "monitoring.mvStaleness": "Materialized View Staleness",
        "monitoring.rowCounts": "Row Counts",
        "monitoring.loadFailed": "Failed to load health check data",
        "monitoring.autoRefresh": "Auto-refreshes every 60 seconds",
        "monitoring.lastUpdated": "Last updated",
        "nav.admin": "Admin",
      };
      return msgs[key] ?? key;
    },
  }),
}));

vi.mock("@/components/layout/Breadcrumbs", () => ({
  Breadcrumbs: () => <nav data-testid="breadcrumbs" />,
}));

vi.mock("@/components/common/LoadingSpinner", () => ({
  LoadingSpinner: () => <div data-testid="loading-spinner">Loading…</div>,
}));

vi.mock("next/navigation", () => ({
  usePathname: () => "/app/admin/monitoring",
  useRouter: () => ({ push: vi.fn(), back: vi.fn() }),
}));

// Must import after mocks
import AdminMonitoringPage from "./page";

// ─── Fixtures ───────────────────────────────────────────────────────────────

const healthyData: HealthCheckResponse = {
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

const degradedData: HealthCheckResponse = {
  ...healthyData,
  status: "degraded",
  checks: {
    ...healthyData.checks,
    mv_staleness: {
      mv_ingredient_frequency: {
        mv_rows: 400,
        source_rows: 487,
        stale: true,
      },
      v_product_confidence: {
        mv_rows: 3012,
        source_rows: 3012,
        stale: false,
      },
    },
  },
};

// ─── Helpers ────────────────────────────────────────────────────────────────

function Wrapper({ children }: Readonly<{ children: React.ReactNode }>) {
  const [client] = useState(
    () =>
      new QueryClient({
        defaultOptions: { queries: { retry: false, staleTime: 0 } },
      }),
  );
  return <QueryClientProvider client={client}>{children}</QueryClientProvider>;
}

function createWrapper() {
  return Wrapper;
}

let mockFetchResponse: HealthCheckResponse | null = healthyData;
let mockFetchStatus = 200;

function setupFetchMock() {
  global.fetch = vi.fn().mockImplementation(() =>
    Promise.resolve({
      ok: mockFetchStatus === 200,
      status: mockFetchStatus,
      json: () => Promise.resolve(mockFetchResponse),
    }),
  );
}

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("AdminMonitoringPage", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mockFetchResponse = healthyData;
    mockFetchStatus = 200;
    setupFetchMock();
  });

  it("renders page title and subtitle", async () => {
    render(<AdminMonitoringPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("System Monitoring")).toBeInTheDocument();
    });
    expect(
      screen.getByText("Database health metrics and status"),
    ).toBeInTheDocument();
  });

  it("renders breadcrumbs", async () => {
    render(<AdminMonitoringPage />, { wrapper: createWrapper() });

    expect(screen.getByTestId("breadcrumbs")).toBeInTheDocument();
  });

  it("shows loading spinner while fetching", () => {
    // Make fetch hang forever
    global.fetch = vi.fn().mockImplementation(
      () => new Promise(() => {}),
    );

    render(<AdminMonitoringPage />, { wrapper: createWrapper() });

    expect(screen.getByTestId("loading")).toBeInTheDocument();
  });

  it("displays overall status as HEALTHY", async () => {
    render(<AdminMonitoringPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByTestId("overall-status")).toBeInTheDocument();
    });

    expect(screen.getByText("healthy")).toBeInTheDocument();
    expect(screen.getByText("Overall Status")).toBeInTheDocument();
  });

  it("displays MV staleness cards", async () => {
    render(<AdminMonitoringPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByTestId("mv-mv_ingredient_frequency")).toBeInTheDocument();
    });

    expect(screen.getByTestId("mv-v_product_confidence")).toBeInTheDocument();
    const mvCard = within(screen.getByTestId("mv-mv_ingredient_frequency"));
    expect(mvCard.getAllByText("487")).toHaveLength(2);
  });

  it("displays row count card with utilization", async () => {
    render(<AdminMonitoringPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByTestId("row-counts")).toBeInTheDocument();
    });

    const card = within(screen.getByTestId("row-counts"));
    expect(card.getByText("3,012")).toBeInTheDocument();
    expect(card.getByText("15,000")).toBeInTheDocument();
    expect(card.getByText("20.1%")).toBeInTheDocument();
  });

  it("shows degraded status with stale MV", async () => {
    mockFetchResponse = degradedData;
    setupFetchMock();

    render(<AdminMonitoringPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("degraded")).toBeInTheDocument();
    });

    // The stale MV card should show "Yes" for stale
    const mvCard = screen.getByTestId("mv-mv_ingredient_frequency");
    expect(mvCard).toHaveTextContent("Yes");
  });

  it("shows error state on fetch failure", async () => {
    global.fetch = vi.fn().mockImplementation(() =>
      Promise.resolve({
        ok: false,
        status: 500,
        json: () => Promise.reject(new Error("Server error")),
      }),
    );

    render(<AdminMonitoringPage />, { wrapper: createWrapper() });

    await waitFor(
      () => {
        expect(screen.getByTestId("error-state")).toBeInTheDocument();
      },
      { timeout: 5000 },
    );

    expect(
      screen.getByText("Failed to load health check data"),
    ).toBeInTheDocument();
  });

  it("includes auto-refresh indicator", async () => {
    render(<AdminMonitoringPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(
        screen.getByText("Auto-refreshes every 60 seconds"),
      ).toBeInTheDocument();
    });
  });

  it("fetches from /api/health with no-store cache", async () => {
    render(<AdminMonitoringPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByTestId("overall-status")).toBeInTheDocument();
    });

    expect(global.fetch).toHaveBeenCalledWith("/api/health", {
      cache: "no-store",
    });
  });

  it("shows timestamp in overall status", async () => {
    render(<AdminMonitoringPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText(/2026-02-22T14:35:00Z/)).toBeInTheDocument();
    });
  });

  it("renders No stale indicator for healthy MVs", async () => {
    render(<AdminMonitoringPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByTestId("mv-mv_ingredient_frequency")).toBeInTheDocument();
    });

    const mvCard = screen.getByTestId("mv-mv_ingredient_frequency");
    expect(mvCard).toHaveTextContent("No");
  });
});
