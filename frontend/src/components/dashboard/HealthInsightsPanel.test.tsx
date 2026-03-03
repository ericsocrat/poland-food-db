import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { render, screen } from "@testing-library/react";
import { beforeEach, describe, expect, it, vi } from "vitest";
import { HealthInsightsPanel } from "./HealthInsightsPanel";

// ─── Mocks ──────────────────────────────────────────────────────────────────

vi.mock("@/lib/supabase/client", () => ({
  createClient: () => ({}),
}));

const mockGetDashboardInsights = vi.fn();
vi.mock("@/lib/api", () => ({
  getDashboardInsights: (...args: unknown[]) =>
    mockGetDashboardInsights(...args),
}));

vi.mock("next/link", () => ({
  default: ({
    href,
    children,
    ...rest
  }: {
    href: string;
    children: React.ReactNode;
    className?: string;
  }) => (
    <a href={href} {...rest}>
      {children}
    </a>
  ),
}));

vi.mock("./HealthInsightsSummary", () => ({
  HealthInsightsSummary: () => <div data-testid="insights-summary" />,
}));

vi.mock("./NovaDistribution", () => ({
  NovaDistributionChart: () => <div data-testid="nova-distribution" />,
}));

vi.mock("./AllergenAlert", () => ({
  AllergenAlert: () => null,
}));

vi.mock("./CategoryDiversity", () => ({
  CategoryDiversity: () => null,
}));

vi.mock("./RecentComparisons", () => ({
  RecentComparisons: () => null,
}));

// ─── Helpers ────────────────────────────────────────────────────────────────

function createWrapper() {
  const qc = new QueryClient({
    defaultOptions: { queries: { retry: false, staleTime: 0 } },
  });
  return function Wrapper({ children }: { children: React.ReactNode }) {
    return (
      <QueryClientProvider client={qc}>{children}</QueryClientProvider>
    );
  };
}

const MOCK_INSIGHTS = {
  avg_score: 35,
  score_trend: "worsening",
  nova_distribution: { "1": 5, "2": 3, "3": 2, "4": 1 },
  allergen_alerts: { count: 0, tags: [] },
  recent_comparisons: [],
  category_diversity: { explored: 8, total: 20, top_categories: [] },
};

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("HealthInsightsPanel", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("shows skeleton while loading", () => {
    mockGetDashboardInsights.mockReturnValue(new Promise(() => {})); // never resolves
    render(<HealthInsightsPanel />, { wrapper: createWrapper() });
    expect(screen.getByTestId("insights-skeleton")).toBeInTheDocument();
  });

  it("renders nothing when API returns error", async () => {
    mockGetDashboardInsights.mockResolvedValue({
      ok: false,
      error: { message: "fail" },
    });
    const { container } = render(<HealthInsightsPanel />, {
      wrapper: createWrapper(),
    });
    // Wait for query to settle — panel should disappear
    await vi.waitFor(() => {
      expect(container.querySelector("[data-testid='health-insights-panel']")).not.toBeInTheDocument();
    });
  });

  it("renders nothing when all data is zero", async () => {
    mockGetDashboardInsights.mockResolvedValue({
      ok: true,
      data: {
        avg_score: 0,
        score_trend: 0,
        nova_distribution: { "1": 0, "2": 0, "3": 0, "4": 0 },
        allergen_alerts: { count: 0, tags: [] },
        recent_comparisons: [],
        category_diversity: { explored: 0, total: 20, top_categories: [] },
      },
    });
    const { container } = render(<HealthInsightsPanel />, {
      wrapper: createWrapper(),
    });
    await vi.waitFor(() => {
      expect(
        container.querySelector("[data-testid='health-insights-panel']"),
      ).not.toBeInTheDocument();
    });
  });

  it("renders the panel when data is available", async () => {
    mockGetDashboardInsights.mockResolvedValue({
      ok: true,
      data: MOCK_INSIGHTS,
    });
    render(<HealthInsightsPanel />, { wrapper: createWrapper() });
    await vi.waitFor(() => {
      expect(screen.getByTestId("health-insights-panel")).toBeInTheDocument();
    });
  });

  it("renders NOVA distribution chart", async () => {
    mockGetDashboardInsights.mockResolvedValue({
      ok: true,
      data: MOCK_INSIGHTS,
    });
    render(<HealthInsightsPanel />, { wrapper: createWrapper() });
    await vi.waitFor(() => {
      expect(screen.getByTestId("nova-distribution")).toBeInTheDocument();
    });
  });
});
