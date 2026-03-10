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

vi.mock("@/hooks/use-alternatives-v2", () => ({
  useAlternativesV2: () => ({ data: null, isLoading: false }),
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

// Use relative dates so tests work regardless of when they run
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

  it("renders health summary section", async () => {
    render(<DashboardPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getByTestId("health-summary")).toBeInTheDocument();
    });
  });

  it("renders quick win card", async () => {
    render(<DashboardPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getByTestId("quick-win-card")).toBeInTheDocument();
    });
  });

  it("renders recently viewed compact list", async () => {
    render(<DashboardPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getByTestId("recently-viewed-compact")).toBeInTheDocument();
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

  it("shows new user welcome when no content", async () => {
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
      expect(screen.getByTestId("new-user-welcome")).toBeInTheDocument();
    });
  });

  it("shows scan CTA on new user welcome", async () => {
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
      expect(screen.getByTestId("new-user-scan-cta")).toBeInTheDocument();
    });
    const scanLink = screen.getByTestId("new-user-scan-cta").closest("a");
    expect(scanLink).toHaveAttribute("href", "/app/scan");
  });

  it("hides recently viewed section when empty", async () => {
    mockGetDashboardData.mockResolvedValue({
      ok: true,
      data: {
        ...mockDashboard,
        recently_viewed: [],
        stats: { ...mockDashboard.stats, total_viewed: 1 },
      },
    });
    render(<DashboardPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      // Health summary should still render (with no scored products)
      expect(screen.getByTestId("health-summary")).toBeInTheDocument();
    });
    expect(
      screen.queryByTestId("recently-viewed-compact"),
    ).not.toBeInTheDocument();
  });

  it("renders quick actions section", async () => {
    render(<DashboardPage />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.getByTestId("quick-actions")).toBeInTheDocument();
    });
  });
});
