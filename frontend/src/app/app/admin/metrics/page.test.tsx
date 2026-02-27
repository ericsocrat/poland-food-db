import { describe, it, expect, vi, beforeEach } from "vitest";
import { render, screen, waitFor, fireEvent } from "@testing-library/react";
import { useState } from "react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import type { BusinessMetricsResponse } from "@/lib/types";

// ─── Mocks ──────────────────────────────────────────────────────────────────

vi.mock("@/lib/i18n", () => ({
  useTranslation: () => ({
    t: (key: string) => {
      const msgs: Record<string, string> = {
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
  usePathname: () => "/app/admin/metrics",
  useRouter: () => ({ push: vi.fn(), back: vi.fn() }),
}));

const mockGetBusinessMetrics = vi.fn();

vi.mock("@/lib/api", () => ({
  getBusinessMetrics: (...args: unknown[]) => mockGetBusinessMetrics(...args),
}));

vi.mock("@/lib/supabase/client", () => ({
  createClient: () => ({ rpc: vi.fn() }),
}));

// Must import after mocks
import AdminMetricsPage from "./page";

// ─── Fixtures ───────────────────────────────────────────────────────────────

const sampleMetrics: BusinessMetricsResponse = {
  api_version: "1.0",
  date: "2026-02-24",
  days: 7,
  dau: 42,
  searches: 156,
  top_queries: [
    { query: "lay's", count: 25 },
    { query: "woda", count: 18 },
  ],
  failed_searches: [{ query: "unicorn food", count: 3 }],
  top_products: [
    { product_id: "1", product_name: "Lay's Classic", views: 40 },
    { product_id: "2", product_name: "Coca-Cola", views: 35 },
  ],
  allergen_distribution: [
    { allergen: "gluten", user_count: 15, percentage: 60 },
    { allergen: "milk", user_count: 10, percentage: 40 },
  ],
  feature_usage: [
    { feature: "search_performed", usage_count: 200, unique_users: 35 },
    { feature: "product_viewed", usage_count: 180, unique_users: 30 },
    { feature: "scanner_used", usage_count: 50, unique_users: 20 },
  ],
  scan_vs_search: [
    { method: "search_performed", count: 156, percentage: 75.7 },
    { method: "scanner_used", count: 50, percentage: 24.3 },
  ],
  onboarding_funnel: [
    { step: "welcome", user_count: 100, completion_rate: 100 },
    { step: "region", user_count: 85, completion_rate: 85 },
    { step: "done", user_count: 60, completion_rate: 60 },
  ],
  category_popularity: [
    { category: "chips-pl", views: 45, unique_users: 20 },
    { category: "dairy", views: 30, unique_users: 15 },
  ],
  trend: [
    { date: "2026-02-17", metric: "dau", value: 38 },
    { date: "2026-02-18", metric: "dau", value: 40 },
    { date: "2026-02-24", metric: "dau", value: 42 },
  ],
};

const emptyMetrics: BusinessMetricsResponse = {
  api_version: "1.0",
  date: "2026-02-24",
  days: 7,
  dau: 0,
  searches: 0,
  top_queries: [],
  failed_searches: [],
  top_products: [],
  allergen_distribution: [],
  feature_usage: [],
  scan_vs_search: [],
  onboarding_funnel: [],
  category_popularity: [],
  trend: [],
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

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("AdminMetricsPage", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mockGetBusinessMetrics.mockResolvedValue({
      ok: true,
      data: sampleMetrics,
    });
  });

  it("renders page title", async () => {
    render(<AdminMetricsPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("Business Metrics")).toBeInTheDocument();
    });
  });

  it("renders breadcrumbs", () => {
    render(<AdminMetricsPage />, { wrapper: createWrapper() });
    expect(screen.getByTestId("breadcrumbs")).toBeInTheDocument();
  });

  it("shows loading spinner while fetching", () => {
    mockGetBusinessMetrics.mockImplementation(() => new Promise(() => {}));

    render(<AdminMetricsPage />, { wrapper: createWrapper() });
    expect(screen.getByTestId("loading")).toBeInTheDocument();
  });

  it("displays DAU metric card", async () => {
    render(<AdminMetricsPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByTestId("metric-dau")).toBeInTheDocument();
    });

    expect(screen.getByTestId("metric-dau")).toHaveTextContent("42");
  });

  it("displays searches metric card", async () => {
    render(<AdminMetricsPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByTestId("metric-searches")).toBeInTheDocument();
    });

    expect(screen.getByTestId("metric-searches")).toHaveTextContent("156");
  });

  it("displays top queries table", async () => {
    render(<AdminMetricsPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByTestId("top-queries")).toBeInTheDocument();
    });

    expect(screen.getByTestId("top-queries")).toHaveTextContent("lay's");
    expect(screen.getByTestId("top-queries")).toHaveTextContent("woda");
  });

  it("displays top products table", async () => {
    render(<AdminMetricsPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByTestId("top-products")).toBeInTheDocument();
    });

    expect(screen.getByTestId("top-products")).toHaveTextContent(
      "Lay's Classic",
    );
    expect(screen.getByTestId("top-products")).toHaveTextContent("Coca-Cola");
  });

  it("displays feature usage section", async () => {
    render(<AdminMetricsPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByTestId("feature-usage")).toBeInTheDocument();
    });

    expect(screen.getByTestId("feature-usage")).toHaveTextContent(
      "search performed",
    );
  });

  it("displays allergen distribution section", async () => {
    render(<AdminMetricsPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByTestId("allergen-dist")).toBeInTheDocument();
    });

    expect(screen.getByTestId("allergen-dist")).toHaveTextContent("gluten");
    expect(screen.getByTestId("allergen-dist")).toHaveTextContent("milk");
  });

  it("displays scan vs search section", async () => {
    render(<AdminMetricsPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByTestId("scan-vs-search")).toBeInTheDocument();
    });
  });

  it("displays onboarding funnel table", async () => {
    render(<AdminMetricsPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByTestId("onboarding-funnel")).toBeInTheDocument();
    });

    expect(screen.getByTestId("onboarding-funnel")).toHaveTextContent(
      "welcome",
    );
    expect(screen.getByTestId("onboarding-funnel")).toHaveTextContent("100%");
  });

  it("displays category popularity table", async () => {
    render(<AdminMetricsPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByTestId("category-popularity")).toBeInTheDocument();
    });

    expect(screen.getByTestId("category-popularity")).toHaveTextContent(
      "chips-pl",
    );
  });

  it("has date range selector with default 7 days", async () => {
    render(<AdminMetricsPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByTestId("date-range-select")).toBeInTheDocument();
    });

    const select = screen.getByTestId("date-range-select") as HTMLSelectElement;
    expect(select.value).toBe("7");
  });

  it("changes date range and refetches", async () => {
    render(<AdminMetricsPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByTestId("date-range-select")).toBeInTheDocument();
    });

    const select = screen.getByTestId("date-range-select");
    fireEvent.change(select, { target: { value: "30" } });

    await waitFor(() => {
      // Should have called with days=30
      const calls = mockGetBusinessMetrics.mock.calls;
      const lastCall = calls[calls.length - 1];
      expect(lastCall[1]).toEqual(expect.objectContaining({ days: 30 }));
    });
  });

  it("has export JSON button", async () => {
    render(<AdminMetricsPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByTestId("export-btn")).toBeInTheDocument();
    });

    expect(screen.getByTestId("export-btn")).toHaveTextContent("Export JSON");
  });

  it("has refresh button", async () => {
    render(<AdminMetricsPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByTestId("refresh-btn")).toBeInTheDocument();
    });
  });

  it("shows error state on API failure", async () => {
    mockGetBusinessMetrics.mockResolvedValue({
      ok: false,
      error: { code: "INTERNAL", message: "RPC failed" },
    });

    render(<AdminMetricsPage />, { wrapper: createWrapper() });

    await waitFor(
      () => {
        expect(screen.getByTestId("error-state")).toBeInTheDocument();
      },
      { timeout: 5000 },
    );
  });

  it("handles empty metrics gracefully", async () => {
    mockGetBusinessMetrics.mockResolvedValue({
      ok: true,
      data: emptyMetrics,
    });

    render(<AdminMetricsPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByTestId("metric-dau")).toBeInTheDocument();
    });

    expect(screen.getByTestId("metric-dau")).toHaveTextContent("0");
    expect(screen.getByTestId("metric-searches")).toHaveTextContent("0");
  });
});
