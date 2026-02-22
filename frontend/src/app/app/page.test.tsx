import { describe, it, expect, vi, beforeEach } from "vitest";
import { render, screen, waitFor } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { useState } from "react";
import type { DashboardData } from "@/lib/types";

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

  it("renders stats bar with correct values", async () => {
    render(<DashboardPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getByText("42")).toBeInTheDocument();
      // "15" appears twice (stats + score pill), so use getAllByText
      expect(screen.getAllByText("15").length).toBeGreaterThanOrEqual(1);
      expect(screen.getByText("3")).toBeInTheDocument();
      expect(screen.getByText("7")).toBeInTheDocument();
    });
  });

  it("renders stats labels", async () => {
    render(<DashboardPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getByText("Scanned")).toBeInTheDocument();
      expect(screen.getByText("Viewed")).toBeInTheDocument();
      // "Lists" appears in both StatsBar and QuickActions, so use getAllByText
      expect(screen.getAllByText("Lists").length).toBeGreaterThanOrEqual(1);
      // "Favorites" appears in both StatsBar section header
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

  it("renders favorites preview", async () => {
    render(<DashboardPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getByText("Activia Natural")).toBeInTheDocument();
    });
  });

  it("renders favorites section with view all link", async () => {
    render(<DashboardPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      const viewAllLinks = screen.getAllByText("View all →");
      // Find the one linking to /app/lists (favorites)
      const favoritesLink = viewAllLinks
        .map((el) => el.closest("a"))
        .find((a) => a?.getAttribute("href") === "/app/lists");
      expect(favoritesLink).toBeTruthy();
    });
  });

  it("renders new products section", async () => {
    render(<DashboardPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getByText("New Crunchy Chips")).toBeInTheDocument();
    });
  });

  it("renders new products with category context", async () => {
    render(<DashboardPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getByText(/New chips/)).toBeInTheDocument();
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
    // Should have D and B badges plus A from favorites and D from new products
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
        // Keep favorites so dashboard is not empty
        favorites_preview: mockDashboard.favorites_preview,
      },
    });
    render(<DashboardPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(
        screen.getAllByText("Activia Natural").length,
      ).toBeGreaterThanOrEqual(1);
    });
    expect(screen.queryByText(/Recently Viewed/)).not.toBeInTheDocument();
  });

  it("hides favorites section when empty", async () => {
    mockGetDashboardData.mockResolvedValue({
      ok: true,
      data: {
        ...mockDashboard,
        favorites_preview: [],
        // Keep recently viewed so dashboard is not empty
        recently_viewed: mockDashboard.recently_viewed,
      },
    });
    render(<DashboardPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(
        screen.getAllByText("Lay's Classic").length,
      ).toBeGreaterThanOrEqual(1);
    });
    // "View all →" may still appear in CategoriesBrowse, so check no link to /app/lists
    const viewAllLinks = screen.getAllByText("View all →");
    const favoritesLink = viewAllLinks
      .map((el) => el.closest("a"))
      .find((a) => a?.getAttribute("href") === "/app/lists");
    expect(favoritesLink).toBeUndefined();
  });

  // ─── Grid layout tests (Issue #74) ─────────────────────────────────────────

  it("applies 12-column grid on desktop (lg breakpoint)", async () => {
    render(<DashboardPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(
        screen.getAllByText("Lay's Classic").length,
      ).toBeGreaterThanOrEqual(1);
    });
    // h1 → space-y-1 div → col-span-12 wrapper → grid container
    const gridContainer = screen
      .getByRole("heading", { level: 1 })
      .closest("[class*='lg:grid-cols-12']");
    expect(gridContainer).toBeTruthy();
    expect(gridContainer?.className).toContain("lg:grid");
    expect(gridContainer?.className).toContain("lg:gap-6");
  });

  it("assigns correct grid spans to Quick Actions and Stats", async () => {
    render(<DashboardPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getByText("42")).toBeInTheDocument();
    });
    // Quick Actions section — aria-label is lowercase "Quick actions"
    const quickActionsSection = screen.getByLabelText("Quick actions");
    expect(quickActionsSection.parentElement?.className).toContain(
      "lg:col-span-8",
    );
    // Stats — find by stat value "42" (total_scanned)
    const statEl = screen.getByText("42").closest("[class*='lg:col-span-4']");
    expect(statEl).toBeTruthy();
  });

  it("keeps stacked layout on mobile (space-y-6)", async () => {
    render(<DashboardPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(
        screen.getAllByText("Lay's Classic").length,
      ).toBeGreaterThanOrEqual(1);
    });
    const gridContainer = screen
      .getByRole("heading", { level: 1 })
      .closest("[class*='lg:grid-cols-12']");
    expect(gridContainer?.className).toContain("space-y-6");
    expect(gridContainer?.className).toContain("lg:space-y-0");
  });

  it("uses tabular-nums on stat values", async () => {
    render(<DashboardPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getByText("42")).toBeInTheDocument();
    });
    const statValue = screen.getByText("42");
    expect(statValue.className).toContain("tabular-nums");
  });

  it("stat cards have hover-lift-press interaction class", async () => {
    render(<DashboardPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getByText("42")).toBeInTheDocument();
    });
    const statCard = screen.getByText("42").closest("a")!;
    expect(statCard.className).toContain("hover-lift-press");
  });

  it("view-all links have transition-colors class", async () => {
    render(<DashboardPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getAllByText("View all →").length).toBeGreaterThan(0);
    });
    const viewAllLinks = screen.getAllByText("View all →");
    for (const link of viewAllLinks) {
      const anchor = link.closest("a")!;
      expect(anchor.className).toContain("transition-colors");
    }
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

  it("hides weekly summary when all activity is older than 7 days", async () => {
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
      expect(screen.getByText("Lay's Classic")).toBeInTheDocument();
    });
    expect(screen.queryByTestId("weekly-summary")).not.toBeInTheDocument();
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

  // ─── Favorites empty state CTA (#134) ───────────────────────────────────

  it("renders favorites CTA when favorites_count is 0", async () => {
    mockGetDashboardData.mockResolvedValue({
      ok: true,
      data: {
        ...mockDashboard,
        stats: { ...mockDashboard.stats, favorites_count: 0 },
      },
    });
    render(<DashboardPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getByText(/Tap ❤️ on any product/)).toBeInTheDocument();
    });
  });

  it("renders favorites count (not CTA) when favorites_count > 0", async () => {
    render(<DashboardPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getByText("7")).toBeInTheDocument();
    });
    expect(screen.queryByText(/Tap ❤️ on any product/)).not.toBeInTheDocument();
  });
});
