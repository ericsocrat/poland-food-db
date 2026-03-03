import type { DashboardData } from "@/lib/types";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { render, screen, waitFor } from "@testing-library/react";
import { useState } from "react";
import { beforeEach, describe, expect, it, vi } from "vitest";

// ─── Mocks ──────────────────────────────────────────────────────────────────

const mockGetDashboardData = vi.fn();
const mockGetCategoryOverview = vi.fn();

vi.mock("@/lib/supabase/client", () => ({
  createClient: () => ({}),
}));

vi.mock("@/lib/api", () => ({
  getDashboardData: (...args: unknown[]) => mockGetDashboardData(...args),
  getCategoryOverview: (...args: unknown[]) => mockGetCategoryOverview(...args),
}));

vi.mock("next/link", () => ({
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  default: ({ href, children, className, ...rest }: any) => (
    <a href={href} className={className} {...rest}>
      {children}
    </a>
  ),
}));

vi.mock("@/hooks/use-product-allergens", () => ({
  useProductAllergenWarnings: () => ({}),
}));

// ─── Wrapper ────────────────────────────────────────────────────────────────

function Wrapper({ children }: { children: React.ReactNode }) {
  const [queryClient] = useState(
    () =>
      new QueryClient({
        defaultOptions: { queries: { retry: false, staleTime: 0 } },
      }),
  );
  return (
    <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
  );
}

function createWrapper() {
  const TestWrapper = ({ children }: { children: React.ReactNode }) => (
    <Wrapper>{children}</Wrapper>
  );
  TestWrapper.displayName = "TestWrapper";
  return TestWrapper;
}

// ─── Mock data ──────────────────────────────────────────────────────────────

// Use relative dates so weekly summary logic works regardless of when tests run
const now = new Date();
const oneDayAgo = new Date(
  now.getTime() - 1 * 24 * 60 * 60 * 1000,
).toISOString();
const twoDaysAgo = new Date(
  now.getTime() - 2 * 24 * 60 * 60 * 1000,
).toISOString();
const threeDaysAgo = new Date(
  now.getTime() - 3 * 24 * 60 * 60 * 1000,
).toISOString();
const tenDaysAgo = new Date(
  now.getTime() - 10 * 24 * 60 * 60 * 1000,
).toISOString();

const mockDashboard: DashboardData = {
  api_version: "1.0",
  recently_viewed: [
    {
      product_id: 1,
      product_name: "Lay's Classic",
      brand: "Lay's",
      category: "chips",
      country: "PL",
      unhealthiness_score: 65,
      nutri_score_label: "D",
      viewed_at: oneDayAgo,
    },
    {
      product_id: 2,
      product_name: "Pepsi Max",
      brand: "Pepsi",
      category: "drinks",
      country: "PL",
      unhealthiness_score: 30,
      nutri_score_label: "B",
      viewed_at: twoDaysAgo,
    },
  ],
  favorites_preview: [
    {
      product_id: 3,
      product_name: "Activia Natural",
      brand: "Danone",
      category: "dairy",
      country: "PL",
      unhealthiness_score: 15,
      nutri_score_label: "A",
      added_at: threeDaysAgo,
    },
  ],
  new_products: [
    {
      product_id: 4,
      product_name: "New Crunchy Chips",
      brand: "Crunchies",
      category: "chips",
      country: "PL",
      unhealthiness_score: 72,
      nutri_score_label: "D",
    },
  ],
  stats: {
    total_scanned: 42,
    total_viewed: 15,
    lists_count: 3,
    favorites_count: 7,
    most_viewed_category: "chips",
  },
};

// ─── Import page after mocks ────────────────────────────────────────────────

import DashboardPage from "./page";

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("DashboardPage", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mockGetDashboardData.mockResolvedValue({ ok: true, data: mockDashboard });
    mockGetCategoryOverview.mockResolvedValue({ ok: true, data: [] });
  });

  it("shows skeleton loading state initially", () => {
    // Never resolve to keep loading state
    mockGetDashboardData.mockReturnValue(new Promise(() => {}));
    render(<DashboardPage />, { wrapper: createWrapper() });
    const status = screen.getAllByRole("status");
    expect(status.length).toBeGreaterThanOrEqual(1);
    expect(status[0].getAttribute("aria-busy")).toBe("true");
  });

  it("renders a time-aware greeting", async () => {
    render(<DashboardPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      // The greeting is time-dependent, so check for any of the possible greetings
      const greetingEl = screen.getByRole("heading", { level: 1 });
      expect(greetingEl).toBeInTheDocument();
      expect(greetingEl.textContent).toMatch(
        /Good morning|Good afternoon|Good evening|Good night/,
      );
    });
  });

  it("renders stats in summary card", async () => {
    render(<DashboardPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      const grid = screen.getByTestId("stats-grid");
      expect(grid).toBeInTheDocument();
      expect(screen.getByText("42")).toBeInTheDocument();
      expect(screen.getByText("15")).toBeInTheDocument();
      expect(screen.getByText("3")).toBeInTheDocument();
      expect(screen.getByText("7")).toBeInTheDocument();
    });
  });

  it("renders stats labels in summary card", async () => {
    render(<DashboardPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getByText("Scanned")).toBeInTheDocument();
      expect(screen.getByText("Viewed")).toBeInTheDocument();
      // "Lists" may also appear in QuickActions
      expect(screen.getAllByText("Lists").length).toBeGreaterThanOrEqual(1);
      expect(screen.getAllByText("Favorites").length).toBeGreaterThanOrEqual(1);
    });
  });

  it("renders recently viewed products", async () => {
    render(<DashboardPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(
        screen.getAllByText("Lay's Classic").length,
      ).toBeGreaterThanOrEqual(1);
      expect(screen.getAllByText("Pepsi Max").length).toBeGreaterThanOrEqual(1);
    });
  });

  it("renders recently viewed section header", async () => {
    render(<DashboardPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getByText(/Recently Viewed/)).toBeInTheDocument();
    });
  });

  it("renders product links with correct hrefs", async () => {
    render(<DashboardPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(
        screen.getAllByText("Lay's Classic").length,
      ).toBeGreaterThanOrEqual(1);
    });
    const link = screen.getAllByText("Lay's Classic")[0].closest("a");
    expect(link).toHaveAttribute("href", "/app/product/1");
  });

  it("renders nutri-score badges", async () => {
    render(<DashboardPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(
        screen.getAllByText("Lay's Classic").length,
      ).toBeGreaterThanOrEqual(1);
    });
    // Should have D and B badges from recently viewed products
    const badges = screen.getAllByText("D");
    expect(badges.length).toBeGreaterThanOrEqual(1);
  });

  it("renders score pills", async () => {
    render(<DashboardPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getAllByText("65").length).toBeGreaterThanOrEqual(1);
      expect(screen.getAllByText("30").length).toBeGreaterThanOrEqual(1);
    });
  });

  it("shows error state on failure", async () => {
    mockGetDashboardData.mockResolvedValue({
      ok: false,
      error: { code: "500", message: "Server error" },
    });
    render(<DashboardPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getByText(/Something went wrong/)).toBeInTheDocument();
    });
  });

  it("shows empty dashboard when no content", async () => {
    mockGetDashboardData.mockResolvedValue({
      ok: true,
      data: {
        ...mockDashboard,
        recently_viewed: [],
        favorites_preview: [],
        new_products: [],
        stats: { total_scanned: 0, total_viewed: 0, lists_count: 0, favorites_count: 0, most_viewed_category: null },
      },
    });
    render(<DashboardPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getByText("Welcome to your Dashboard")).toBeInTheDocument();
    });
  });

  it("shows scan CTA on empty dashboard", async () => {
    mockGetDashboardData.mockResolvedValue({
      ok: true,
      data: {
        ...mockDashboard,
        recently_viewed: [],
        favorites_preview: [],
        new_products: [],
        stats: { total_scanned: 0, total_viewed: 0, lists_count: 0, favorites_count: 0, most_viewed_category: null },
      },
    });
    render(<DashboardPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      const scanLink = screen.getByText(/Scan a Product/).closest("a");
      expect(scanLink).toHaveAttribute("href", "/app/scan");
    });
  });

  it("hides recently viewed section when empty", async () => {
    mockGetDashboardData.mockResolvedValue({
      ok: true,
      data: {
        ...mockDashboard,
        recently_viewed: [],
      },
    });
    render(<DashboardPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      // Stats values ensure dashboard is not empty
      expect(screen.getByText("42")).toBeInTheDocument();
    });
    expect(screen.queryByText(/Recently Viewed/)).not.toBeInTheDocument();
  });

  // ─── Summary Card & Layout ────────────────────────────────────────────────

  it("uses tabular-nums on stat values", async () => {
    render(<DashboardPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getByText("42")).toBeInTheDocument();
    });
    const statValue = screen.getByText("42");
    expect(statValue.className).toContain("tabular-nums");
  });

  // ─── Weekly Summary Card (§3.5) ──────────────────────────────────────────

  it("renders weekly summary card", async () => {
    render(<DashboardPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getByTestId("weekly-summary")).toBeInTheDocument();
    });
    expect(screen.getByText("This Week")).toBeInTheDocument();
  });

  it("shows weekly viewed and favorited counts", async () => {
    render(<DashboardPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getByTestId("weekly-viewed-count")).toHaveTextContent("2");
      expect(screen.getByTestId("weekly-favorited-count")).toHaveTextContent(
        "1",
      );
    });
  });

  it("shows weekly average score", async () => {
    render(<DashboardPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      // Avg of 65 + 30 = 95 / 2 = 48 (rounded)
      const avgBadge = screen.getByTestId("weekly-avg-score");
      expect(avgBadge).toHaveTextContent("48");
    });
  });

  it("shows best find of the week", async () => {
    render(<DashboardPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      const bestFind = screen.getByTestId("weekly-best-find");
      // Pepsi Max has score 30 (lowest)
      expect(bestFind).toHaveTextContent("Pepsi Max");
    });
  });

  it("hides weekly activity when all activity is older than 7 days", async () => {
    mockGetDashboardData.mockResolvedValue({
      ok: true,
      data: {
        ...mockDashboard,
        recently_viewed: [
          {
            ...mockDashboard.recently_viewed[0],
            viewed_at: tenDaysAgo,
          },
        ],
        favorites_preview: [
          {
            ...mockDashboard.favorites_preview[0],
            added_at: tenDaysAgo,
          },
        ],
      },
    });
    render(<DashboardPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      // Stats grid always renders
      expect(screen.getByTestId("stats-grid")).toBeInTheDocument();
    });
    // Weekly activity section hidden — heading not present
    expect(screen.queryByText("This Week")).not.toBeInTheDocument();
  });

  it("renders score sparkline in weekly summary", async () => {
    mockGetDashboardData.mockResolvedValue({
      ok: true,
      data: mockDashboard,
    });
    render(<DashboardPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getByTestId("weekly-summary")).toBeInTheDocument();
    });
    expect(screen.getByTestId("score-sparkline")).toBeInTheDocument();
    // 2 recently viewed products this week have scores 65 and 30
    expect(screen.getByTestId("sparkline-bar-low")).toBeInTheDocument();
    expect(screen.getByTestId("sparkline-bar-high")).toBeInTheDocument();
  });

});
