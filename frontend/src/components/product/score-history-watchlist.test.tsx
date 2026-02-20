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
  useSupabase: () => ({}),
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
      data: { watching: false, threshold: null },
      error: null,
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
      data: { watching: true, threshold: 5 },
      error: null,
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
      data: { watching: false, threshold: null },
      error: null,
    });
    mockWatchProduct.mockResolvedValue({
      data: { success: true, product_id: 42, threshold: 5, watching: true },
      error: null,
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
      data: { watching: false, threshold: null },
      error: null,
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
      error: null,
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
