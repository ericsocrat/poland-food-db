/**
 * Tests for Score History, Watchlist & Reformulation components
 * Issue #38 — Product Score History, Watchlist & Reformulation Alerts
 */

import { describe, it, expect, vi, beforeEach } from "vitest";
import { render, screen, fireEvent, waitFor } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import type { ReactNode } from "react";

// ─── Mocks ──────────────────────────────────────────────────────────────────

vi.mock("@/lib/supabase/client", () => ({
  createClient: () => ({}),
}));

vi.mock("@/lib/i18n", () => ({
  useTranslation: () => ({
    t: (key: string, params?: Record<string, string>) => {
      if (params) {
        let result = key;
        for (const [k, v] of Object.entries(params)) {
          result += ` ${k}=${v}`;
        }
        return result;
      }
      return key;
    },
  }),
}));

vi.mock("next/link", () => ({
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  default: ({ href, children, className, ...rest }: any) => (
    <a href={href} className={className} {...rest}>
      {children}
    </a>
  ),
}));

vi.mock("@/components/layout/Breadcrumbs", () => ({
  Breadcrumbs: () => <nav data-testid="breadcrumbs" />,
}));

const mockGetScoreHistory = vi.fn();
const mockWatchProduct = vi.fn();
const mockUnwatchProduct = vi.fn();
const mockIsWatchingProduct = vi.fn();
const mockGetWatchlist = vi.fn();

vi.mock("@/lib/api", () => ({
  getScoreHistory: (...args: unknown[]) => mockGetScoreHistory(...args),
  watchProduct: (...args: unknown[]) => mockWatchProduct(...args),
  unwatchProduct: (...args: unknown[]) => mockUnwatchProduct(...args),
  isWatchingProduct: (...args: unknown[]) => mockIsWatchingProduct(...args),
  getWatchlist: (...args: unknown[]) => mockGetWatchlist(...args),
}));

// ─── Imports ────────────────────────────────────────────────────────────────

import { ScoreTrendChart } from "./ScoreTrendChart";
import { WatchButton } from "./WatchButton";
import { ScoreChangeIndicator } from "./ScoreChangeIndicator";
import { ReformulationBadge } from "./ReformulationBadge";
import { ScoreHistoryPanel } from "./ScoreHistoryPanel";
import WatchlistPage from "@/app/app/watchlist/page";

// ─── Helpers ────────────────────────────────────────────────────────────────

function createWrapper() {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false } },
  });
  return function Wrapper({ children }: { children: ReactNode }) {
    return (
      <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
    );
  };
}

beforeEach(() => {
  vi.clearAllMocks();
});

// ─── ScoreChangeIndicator ───────────────────────────────────────────────────

describe("ScoreChangeIndicator", () => {
  it("renders nothing for null delta", () => {
    const { container } = render(<ScoreChangeIndicator delta={null} />);
    expect(container.firstChild).toBeNull();
  });

  it("renders nothing for zero delta", () => {
    const { container } = render(<ScoreChangeIndicator delta={0} />);
    expect(container.firstChild).toBeNull();
  });

  it("renders worsened indicator for positive delta", () => {
    render(<ScoreChangeIndicator delta={5} />);
    const el = screen.getByTestId("score-change-indicator");
    expect(el).toBeInTheDocument();
    // Positive delta = worsened (higher unhealthiness_score = worse)
    expect(el.textContent).toContain("↑");
  });

  it("renders improved indicator for negative delta", () => {
    render(<ScoreChangeIndicator delta={-3} />);
    const el = screen.getByTestId("score-change-indicator");
    expect(el).toBeInTheDocument();
    expect(el.textContent).toContain("↓");
  });
});

// ─── ReformulationBadge ─────────────────────────────────────────────────────

describe("ReformulationBadge", () => {
  it("renders nothing when not detected", () => {
    const { container } = render(<ReformulationBadge detected={false} />);
    expect(container.firstChild).toBeNull();
  });

  it("renders badge when detected", () => {
    render(<ReformulationBadge detected={true} />);
    const el = screen.getByTestId("reformulation-badge");
    expect(el).toBeInTheDocument();
    expect(el.textContent).toContain("watchlist.reformulated");
  });
});

// ─── ScoreTrendChart ────────────────────────────────────────────────────────

describe("ScoreTrendChart", () => {
  it("renders empty state when no history", () => {
    render(<ScoreTrendChart history={[]} trend="stable" />);
    expect(screen.getByText("watchlist.noHistory")).toBeInTheDocument();
  });

  it("renders SVG for valid history", () => {
    const history = [
      { date: "2025-01-01", score: 45 },
      { date: "2025-02-01", score: 40 },
    ];
    const { container } = render(
      <ScoreTrendChart history={history} trend="improving" />,
    );
    const svg = container.querySelector("svg");
    expect(svg).toBeInTheDocument();
  });

  it("renders with single data point", () => {
    const history = [{ date: "2025-01-01", score: 50 }];
    const { container } = render(
      <ScoreTrendChart history={history} trend="stable" />,
    );
    // Should still render SVG (single dot)
    const svg = container.querySelector("svg");
    expect(svg).toBeInTheDocument();
  });
});

// ─── WatchButton ────────────────────────────────────────────────────────────

describe("WatchButton", () => {
  it("renders watch button when not watching", async () => {
    mockIsWatchingProduct.mockResolvedValue({
      ok: true,
      data: { watching: false, threshold: null },
    });

    render(<WatchButton productId={42} />, { wrapper: createWrapper() });

    await waitFor(() => {
      const btn = screen.getByTestId("watch-button");
      expect(btn).toBeInTheDocument();
      expect(btn.getAttribute("aria-pressed")).toBe("false");
    });
  });

  it("renders unwatch button when already watching", async () => {
    mockIsWatchingProduct.mockResolvedValue({
      ok: true,
      data: { watching: true, threshold: 5 },
    });

    render(<WatchButton productId={42} />, { wrapper: createWrapper() });

    await waitFor(() => {
      const btn = screen.getByTestId("watch-button");
      expect(btn).toBeInTheDocument();
      expect(btn.getAttribute("aria-pressed")).toBe("true");
    });
  });

  it("calls watchProduct on click when not watching", async () => {
    mockIsWatchingProduct.mockResolvedValue({
      ok: true,
      data: { watching: false, threshold: null },
    });
    mockWatchProduct.mockResolvedValue({
      ok: true,
      data: { success: true, product_id: 42, threshold: 5, watching: true },
    });

    render(<WatchButton productId={42} />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByTestId("watch-button")).toBeInTheDocument();
    });

    fireEvent.click(screen.getByTestId("watch-button"));

    await waitFor(() => {
      expect(mockWatchProduct).toHaveBeenCalled();
    });
  });

  it("supports compact mode", async () => {
    mockIsWatchingProduct.mockResolvedValue({
      ok: true,
      data: { watching: false, threshold: null },
    });

    render(<WatchButton productId={42} compact />, {
      wrapper: createWrapper(),
    });

    await waitFor(() => {
      expect(screen.getByTestId("watch-button")).toBeInTheDocument();
    });
  });
});

// ─── ScoreHistoryPanel ──────────────────────────────────────────────────────

describe("ScoreHistoryPanel", () => {
  it("renders collapsed by default", () => {
    render(<ScoreHistoryPanel productId={42} />, {
      wrapper: createWrapper(),
    });
    const panel = screen.getByTestId("score-history-panel");
    expect(panel).toBeInTheDocument();
    expect(screen.getByText("watchlist.scoreHistory")).toBeInTheDocument();
  });

  it("expands on click and shows loading", async () => {
    // Return a pending promise to keep it loading
    mockGetScoreHistory.mockReturnValue(new Promise(() => {}));

    render(<ScoreHistoryPanel productId={42} />, {
      wrapper: createWrapper(),
    });

    // Click to expand
    const header = screen.getByText("watchlist.scoreHistory");
    fireEvent.click(header);

    // Panel should now be expanded
    await waitFor(() => {
      expect(screen.getByTestId("score-history-panel")).toBeInTheDocument();
    });
  });

  it("shows error state", async () => {
    mockGetScoreHistory.mockRejectedValue(new Error("Failed"));

    render(<ScoreHistoryPanel productId={42} />, {
      wrapper: createWrapper(),
    });

    // Expand the panel
    fireEvent.click(screen.getByText("watchlist.scoreHistory"));

    await waitFor(() => {
      expect(screen.getByTestId("score-history-error")).toBeInTheDocument();
    });
  });

  it("shows history table when data loads successfully", async () => {
    mockGetScoreHistory.mockResolvedValue({
      ok: true,
      data: {
        product_id: 42,
        trend: "improving",
        current_score: 40,
        previous_score: 50,
        delta: -10,
        reformulation_detected: false,
        history: [
          {
            date: "2025-02-01",
            score: 40,
            nutri_score: "B",
            nova_group: 2,
            completeness_pct: 95,
            delta: -10,
            source: "pipeline",
            reason: null,
          },
          {
            date: "2025-01-01",
            score: 50,
            nutri_score: "C",
            nova_group: 3,
            completeness_pct: 90,
            delta: null,
            source: "backfill",
            reason: null,
          },
        ],
        total_snapshots: 2,
      },
    });

    render(<ScoreHistoryPanel productId={42} />, {
      wrapper: createWrapper(),
    });

    // Expand the panel
    fireEvent.click(screen.getByText("watchlist.scoreHistory"));

    await waitFor(() => {
      expect(screen.getByTestId("score-history-table")).toBeInTheDocument();
    });
  });
});

// ─── WatchButton (additional coverage) ──────────────────────────────────────

describe("WatchButton — additional branches", () => {
  it("renders loading skeleton while initial query loads", () => {
    mockIsWatchingProduct.mockReturnValue(new Promise(() => {}));

    render(<WatchButton productId={42} />, { wrapper: createWrapper() });

    expect(screen.getByTestId("watch-button-loading")).toBeInTheDocument();
  });

  it("renders loading skeleton with compact mode (no label)", () => {
    mockIsWatchingProduct.mockReturnValue(new Promise(() => {}));

    render(<WatchButton productId={42} compact />, {
      wrapper: createWrapper(),
    });

    expect(screen.getByTestId("watch-button-loading")).toBeInTheDocument();
    // Compact hides the text label, only spinner visible
    const btn = screen.getByTestId("watch-button-loading");
    expect(btn.querySelector("span")).toBeNull();
  });

  it("calls unwatchProduct on click when already watching", async () => {
    mockIsWatchingProduct.mockResolvedValue({
      ok: true,
      data: { watching: true, threshold: 5 },
    });
    mockUnwatchProduct.mockResolvedValue({
      ok: true,
      data: { success: true, product_id: 42 },
    });

    render(<WatchButton productId={42} />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByTestId("watch-button")).toBeInTheDocument();
    });

    fireEvent.click(screen.getByTestId("watch-button"));

    await waitFor(() => {
      expect(mockUnwatchProduct).toHaveBeenCalled();
    });
  });

  it("applies custom className", async () => {
    mockIsWatchingProduct.mockResolvedValue({
      ok: true,
      data: { watching: false, threshold: null },
    });

    render(<WatchButton productId={42} className="extra-class" />, {
      wrapper: createWrapper(),
    });

    await waitFor(() => {
      const btn = screen.getByTestId("watch-button");
      expect(btn.className).toContain("extra-class");
    });
  });
});

// ─── ScoreHistoryPanel (additional coverage) ────────────────────────────────

describe("ScoreHistoryPanel — additional branches", () => {
  it("renders expanded when defaultOpen=true and fires query", async () => {
    mockGetScoreHistory.mockReturnValue(new Promise(() => {}));

    render(<ScoreHistoryPanel productId={42} defaultOpen />, {
      wrapper: createWrapper(),
    });

    // Should be expanded immediately
    const btn = screen.getByRole("button", { expanded: true });
    expect(btn).toBeInTheDocument();
    // query should have been called since panel starts open
    expect(mockGetScoreHistory).toHaveBeenCalled();
  });

  it("shows worsening trend with correct icon", async () => {
    mockGetScoreHistory.mockResolvedValue({
      ok: true,
      data: {
        product_id: 42,
        trend: "worsening",
        current_score: 60,
        previous_score: 50,
        delta: 10,
        reformulation_detected: false,
        history: [
          { date: "2025-01-01", score: 50, nutri_score: "C", nova_group: 3, completeness_pct: 90, delta: null, source: "backfill", reason: null },
          { date: "2025-02-01", score: 60, nutri_score: "D", nova_group: 3, completeness_pct: 88, delta: 10, source: "pipeline", reason: null },
        ],
        total_snapshots: 2,
      },
    });

    render(<ScoreHistoryPanel productId={42} />, { wrapper: createWrapper() });
    fireEvent.click(screen.getByText("watchlist.scoreHistory"));

    await waitFor(() => {
      expect(screen.getByText("watchlist.trend.worsening")).toBeInTheDocument();
    });
  });

  it("shows stable trend with correct icon", async () => {
    mockGetScoreHistory.mockResolvedValue({
      ok: true,
      data: {
        product_id: 42,
        trend: "stable",
        current_score: 50,
        previous_score: 50,
        delta: 0,
        reformulation_detected: false,
        history: [
          { date: "2025-01-01", score: 50, nutri_score: "C", nova_group: 3, completeness_pct: 90, delta: null, source: "backfill", reason: null },
        ],
        total_snapshots: 1,
      },
    });

    render(<ScoreHistoryPanel productId={42} />, { wrapper: createWrapper() });
    fireEvent.click(screen.getByText("watchlist.scoreHistory"));

    await waitFor(() => {
      expect(screen.getByText("watchlist.trend.stable")).toBeInTheDocument();
    });
  });

  it("shows noHistoryYet when history array is empty", async () => {
    mockGetScoreHistory.mockResolvedValue({
      ok: true,
      data: {
        product_id: 42,
        trend: "stable",
        current_score: null,
        previous_score: null,
        delta: null,
        reformulation_detected: false,
        history: [],
        total_snapshots: 0,
      },
    });

    render(<ScoreHistoryPanel productId={42} />, { wrapper: createWrapper() });
    fireEvent.click(screen.getByText("watchlist.scoreHistory"));

    await waitFor(() => {
      expect(screen.getByText("watchlist.noHistoryYet")).toBeInTheDocument();
    });
  });

  it("shows reformulation badge when detected", async () => {
    mockGetScoreHistory.mockResolvedValue({
      ok: true,
      data: {
        product_id: 42,
        trend: "improving",
        current_score: 40,
        previous_score: 50,
        delta: -10,
        reformulation_detected: true,
        history: [
          { date: "2025-01-01", score: 50, nutri_score: "C", nova_group: 3, completeness_pct: 90, delta: null, source: "backfill", reason: null },
          { date: "2025-02-01", score: 40, nutri_score: "B", nova_group: 2, completeness_pct: 95, delta: -10, source: "pipeline", reason: null },
        ],
        total_snapshots: 2,
      },
    });

    render(<ScoreHistoryPanel productId={42} />, { wrapper: createWrapper() });
    fireEvent.click(screen.getByText("watchlist.scoreHistory"));

    await waitFor(() => {
      expect(screen.getByTestId("reformulation-badge")).toBeInTheDocument();
    });
  });

  it("toggles collapse after expand", async () => {
    mockGetScoreHistory.mockReturnValue(new Promise(() => {}));

    render(<ScoreHistoryPanel productId={42} />, { wrapper: createWrapper() });

    const headerBtn = screen.getByText("watchlist.scoreHistory");
    // Expand
    fireEvent.click(headerBtn);
    expect(headerBtn.closest("button")?.getAttribute("aria-expanded")).toBe(
      "true",
    );

    // Collapse
    fireEvent.click(headerBtn);
    expect(headerBtn.closest("button")?.getAttribute("aria-expanded")).toBe(
      "false",
    );
  });

  it("applies custom className", () => {
    render(<ScoreHistoryPanel productId={42} className="custom-panel" />, {
      wrapper: createWrapper(),
    });

    const panel = screen.getByTestId("score-history-panel");
    expect(panel.className).toContain("custom-panel");
  });
});

// ─── ScoreTrendChart (additional coverage) ──────────────────────────────────

describe("ScoreTrendChart — additional branches", () => {
  it("uses worsening stroke color", () => {
    const history = [
      { date: "2025-01-01", score: 40 },
      { date: "2025-02-01", score: 60 },
    ];
    const { container } = render(
      <ScoreTrendChart history={history} trend="worsening" />,
    );
    const polyline = container.querySelector("polyline");
    expect(polyline?.getAttribute("stroke")).toContain("error");
  });

  it("handles range=0 (identical scores) without division by zero", () => {
    const history = [
      { date: "2025-01-01", score: 50 },
      { date: "2025-02-01", score: 50 },
    ];
    const { container } = render(
      <ScoreTrendChart history={history} trend="stable" />,
    );
    const svg = container.querySelector("svg");
    expect(svg).toBeInTheDocument();
    // Should not have NaN in points
    const polyline = container.querySelector("polyline");
    expect(polyline?.getAttribute("points")).not.toContain("NaN");
  });

  it("accepts custom width and height", () => {
    const history = [{ date: "2025-01-01", score: 50 }];
    const { container } = render(
      <ScoreTrendChart history={history} trend="stable" width={200} height={80} />,
    );
    const svg = container.querySelector("svg");
    expect(svg?.getAttribute("width")).toBe("200");
    expect(svg?.getAttribute("height")).toBe("80");
  });

  it("applies className to empty state", () => {
    render(
      <ScoreTrendChart history={[]} trend="stable" className="my-chart" />,
    );
    const empty = screen.getByTestId("score-trend-empty");
    expect(empty.className).toContain("my-chart");
  });

  it("applies className to SVG", () => {
    const history = [{ date: "2025-01-01", score: 50 }];
    const { container } = render(
      <ScoreTrendChart history={history} trend="stable" className="svg-class" />,
    );
    const svg = container.querySelector("svg");
    expect(svg?.getAttribute("class")).toContain("svg-class");
  });
});

// ─── WatchlistPage ──────────────────────────────────────────────────────────

describe("WatchlistPage", () => {
  it("renders loading skeleton while fetching", () => {
    mockGetWatchlist.mockReturnValue(new Promise(() => {}));

    render(<WatchlistPage />, { wrapper: createWrapper() });

    expect(screen.getByTestId("watchlist-loading")).toBeInTheDocument();
  });

  it("renders error state when API rejects", async () => {
    mockGetWatchlist.mockRejectedValue(new Error("Network error"));

    render(<WatchlistPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByTestId("watchlist-error")).toBeInTheDocument();
    });
  });

  it("renders empty state when items are empty", async () => {
    mockGetWatchlist.mockResolvedValue({
      ok: true,
      data: { items: [], total: 0, page: 1, page_size: 20, total_pages: 1, success: true },
    });

    render(<WatchlistPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByTestId("watchlist-empty")).toBeInTheDocument();
      expect(screen.getByText("watchlist.emptyTitle")).toBeInTheDocument();
    });
  });

  it("renders watchlist cards with product info", async () => {
    mockGetWatchlist.mockResolvedValue({
      ok: true,
      data: {
        items: [
          {
            watch_id: 1,
            product_id: 42,
            alert_threshold: 5,
            watched_since: "2025-01-01",
            product_name: "Test Product",
            brand: "Test Brand",
            category: "Snacks",
            current_score: 35,
            score_band: "low",
            nutri_score: "A",
            nova_group: "1",
            last_delta: -5,
            trend: "improving" as const,
            reformulation_detected: false,
            sparkline: [
              { date: "2025-01-01", score: 40 },
              { date: "2025-02-01", score: 35 },
            ],
          },
        ],
        total: 1,
        page: 1,
        page_size: 20,
        total_pages: 1,
        success: true,
      },
    });

    render(<WatchlistPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByTestId("watchlist-card")).toBeInTheDocument();
      expect(screen.getByText("Test Product")).toBeInTheDocument();
      expect(screen.getByText("Test Brand")).toBeInTheDocument();
      expect(screen.getByText("Snacks")).toBeInTheDocument();
      expect(screen.getByTestId("watchlist-score").textContent).toBe("35");
    });
  });

  it("renders card with null brand and category omitted", async () => {
    mockGetWatchlist.mockResolvedValue({
      ok: true,
      data: {
        items: [
          {
            watch_id: 2,
            product_id: 99,
            alert_threshold: 5,
            watched_since: "2025-01-01",
            product_name: "No Brand Product",
            brand: null,
            category: null,
            current_score: null,
            score_band: "unknown_band",
            nutri_score: null,
            nova_group: null,
            last_delta: null,
            trend: "stable" as const,
            reformulation_detected: true,
            sparkline: [],
          },
        ],
        total: 1,
        page: 1,
        page_size: 20,
        total_pages: 1,
        success: true,
      },
    });

    render(<WatchlistPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      // Null score shows dash
      expect(screen.getByTestId("watchlist-score").textContent).toBe("–");
      // Reformulation badge shown
      expect(screen.getByTestId("reformulation-badge")).toBeInTheDocument();
    });
  });

  it("renders score band color classes correctly", async () => {
    const items = [
      { watch_id: 1, product_id: 1, alert_threshold: 5, watched_since: "2025-01-01", product_name: "Low", brand: null, category: null, current_score: 20, score_band: "low", nutri_score: null, nova_group: null, last_delta: null, trend: "stable" as const, reformulation_detected: false, sparkline: [] },
      { watch_id: 2, product_id: 2, alert_threshold: 5, watched_since: "2025-01-01", product_name: "High", brand: null, category: null, current_score: 70, score_band: "high", nutri_score: null, nova_group: null, last_delta: null, trend: "stable" as const, reformulation_detected: false, sparkline: [] },
    ];

    mockGetWatchlist.mockResolvedValue({
      ok: true,
      data: { items, total: 2, page: 1, page_size: 20, total_pages: 1, success: true },
    });

    render(<WatchlistPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      const scores = screen.getAllByTestId("watchlist-score");
      expect(scores[0].className).toContain("text-success");
      expect(scores[1].className).toContain("text-orange");
    });
  });

  it("renders pagination when total_pages > 1", async () => {
    mockGetWatchlist.mockResolvedValue({
      ok: true,
      data: {
        items: [
          {
            watch_id: 1,
            product_id: 42,
            alert_threshold: 5,
            watched_since: "2025-01-01",
            product_name: "Test",
            brand: null,
            category: null,
            current_score: 50,
            score_band: "moderate",
            nutri_score: null,
            nova_group: null,
            last_delta: null,
            trend: "stable" as const,
            reformulation_detected: false,
            sparkline: [],
          },
        ],
        total: 40,
        page: 1,
        page_size: 20,
        total_pages: 2,
        success: true,
      },
    });

    render(<WatchlistPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      const prevBtn = screen.getByLabelText("watchlist.prevPage");
      const nextBtn = screen.getByLabelText("watchlist.nextPage");
      expect(prevBtn).toBeDisabled();
      expect(nextBtn).not.toBeDisabled();
    });
  });

  it("navigates pages with prev/next", async () => {
    mockGetWatchlist.mockResolvedValue({
      ok: true,
      data: {
        items: [
          {
            watch_id: 1,
            product_id: 42,
            alert_threshold: 5,
            watched_since: "2025-01-01",
            product_name: "Test",
            brand: null,
            category: null,
            current_score: 50,
            score_band: "moderate",
            nutri_score: null,
            nova_group: null,
            last_delta: null,
            trend: "stable" as const,
            reformulation_detected: false,
            sparkline: [],
          },
        ],
        total: 60,
        page: 1,
        page_size: 20,
        total_pages: 3,
        success: true,
      },
    });

    render(<WatchlistPage />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByLabelText("watchlist.nextPage")).not.toBeDisabled();
    });

    // Click next
    fireEvent.click(screen.getByLabelText("watchlist.nextPage"));

    // The query should be called again with page 2
    await waitFor(() => {
      expect(mockGetWatchlist).toHaveBeenCalledTimes(2);
    });
  });
});

// ─── i18n Key Coverage ──────────────────────────────────────────────────────

describe("i18n watchlist keys", () => {
  it("en.json contains all required watchlist keys", async () => {
    const en = (await import("../../../messages/en.json")).default;

    const requiredKeys = [
      "nav.watchlist",
      "watchlist.title",
      "watchlist.subtitle",
      "watchlist.loadError",
      "watchlist.emptyTitle",
      "watchlist.emptyDescription",
      "watchlist.browseProducts",
      "watchlist.prevPage",
      "watchlist.nextPage",
      "watchlist.pageIndicator",
      "watchlist.watchButton",
      "watchlist.unwatchButton",
      "watchlist.loading",
      "watchlist.scoreHistory",
      "watchlist.historyError",
      "watchlist.noHistory",
      "watchlist.noHistoryYet",
      "watchlist.trendLabel",
      "watchlist.snapshotCount",
      "watchlist.historyDate",
      "watchlist.historyScore",
      "watchlist.historyDelta",
      "watchlist.historySource",
      "watchlist.scoreWorsened",
      "watchlist.scoreImproved",
      "watchlist.reformulated",
      "watchlist.trend.improving",
      "watchlist.trend.worsening",
      "watchlist.trend.stable",
    ];

    for (const key of requiredKeys) {
      const parts = key.split(".");
      let obj: Record<string, unknown> = en;
      for (const part of parts) {
        expect(obj).toHaveProperty(part);
        obj = obj[part] as Record<string, unknown>;
      }
    }
  });

  it("pl.json contains all required watchlist keys", async () => {
    const pl = (await import("../../../messages/pl.json")).default;

    const requiredKeys = [
      "nav.watchlist",
      "watchlist.title",
      "watchlist.subtitle",
      "watchlist.loadError",
      "watchlist.emptyTitle",
      "watchlist.emptyDescription",
      "watchlist.browseProducts",
      "watchlist.prevPage",
      "watchlist.nextPage",
      "watchlist.pageIndicator",
      "watchlist.watchButton",
      "watchlist.unwatchButton",
      "watchlist.loading",
      "watchlist.scoreHistory",
      "watchlist.historyError",
      "watchlist.noHistory",
      "watchlist.noHistoryYet",
      "watchlist.trendLabel",
      "watchlist.snapshotCount",
      "watchlist.historyDate",
      "watchlist.historyScore",
      "watchlist.historyDelta",
      "watchlist.historySource",
      "watchlist.scoreWorsened",
      "watchlist.scoreImproved",
      "watchlist.reformulated",
      "watchlist.trend.improving",
      "watchlist.trend.worsening",
      "watchlist.trend.stable",
    ];

    for (const key of requiredKeys) {
      const parts = key.split(".");
      let obj: Record<string, unknown> = pl;
      for (const part of parts) {
        expect(obj).toHaveProperty(part);
        obj = obj[part] as Record<string, unknown>;
      }
    }
  });
});
