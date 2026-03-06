import { describe, it, expect, vi, beforeEach } from "vitest";
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import type { ReactNode } from "react";

import { ScoreHistoryPanel } from "./ScoreHistoryPanel";

// ─── Mocks ──────────────────────────────────────────────────────────────────

vi.mock("@/lib/i18n", () => ({
  useTranslation: () => ({
    t: (key: string) => key,
  }),
}));

vi.mock("@/lib/supabase/client", () => ({
  createClient: () => ({}),
}));

const mockGetScoreHistory = vi.fn();
vi.mock("@/lib/api", () => ({
  getScoreHistory: (...args: unknown[]) => mockGetScoreHistory(...args),
}));

vi.mock("@/lib/query-keys", () => ({
  queryKeys: { scoreHistory: (id: number) => ["scoreHistory", id] },
  staleTimes: { scoreHistory: 0 },
}));

vi.mock("./ScoreTrendChart", () => ({
  ScoreTrendChart: () => <div data-testid="score-trend-chart-mock" />,
}));

vi.mock("./ScoreChangeIndicator", () => ({
  ScoreChangeIndicator: ({ delta }: { delta: number }) => (
    <span data-testid="score-change-indicator">{delta}</span>
  ),
}));

vi.mock("./ReformulationBadge", () => ({
  ReformulationBadge: ({ detected }: { detected: boolean }) => (
    <span data-testid="reformulation-badge">{String(detected)}</span>
  ),
}));

vi.mock("@/components/common/Icon", () => ({
  Icon: ({ icon: _icon, ...rest }: Record<string, unknown>) => (
    <span data-testid="icon" {...rest} />
  ),
}));

// ─── Helpers ────────────────────────────────────────────────────────────────

function createWrapper() {
  const queryClient = new QueryClient({
    defaultOptions: {
      queries: { retry: false, staleTime: 0 },
    },
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

// ─── Collapsed State ────────────────────────────────────────────────────────

describe("ScoreHistoryPanel — collapsed", () => {
  it("renders the panel with toggle button", () => {
    render(<ScoreHistoryPanel productId={1} />, { wrapper: createWrapper() });

    expect(screen.getByTestId("score-history-panel")).toBeVisible();
    expect(screen.getByRole("button")).toBeVisible();
    expect(screen.getByText("watchlist.scoreHistory")).toBeVisible();
  });

  it("does not show content when collapsed (default)", () => {
    render(<ScoreHistoryPanel productId={1} />, { wrapper: createWrapper() });

    expect(
      screen.queryByTestId("score-history-error"),
    ).not.toBeInTheDocument();
    expect(
      screen.queryByTestId("score-history-table"),
    ).not.toBeInTheDocument();
  });

  it("sets aria-expanded=false when collapsed", () => {
    render(<ScoreHistoryPanel productId={1} />, { wrapper: createWrapper() });

    expect(screen.getByRole("button")).toHaveAttribute(
      "aria-expanded",
      "false",
    );
  });
});

// ─── Expand / Collapse ─────────────────────────────────────────────────────

describe("ScoreHistoryPanel — expand / collapse", () => {
  it("expands on click and sets aria-expanded=true", async () => {
    mockGetScoreHistory.mockResolvedValue({
      ok: true,
      data: {
        trend: "stable",
        delta: 0,
        reformulation_detected: false,
        total_snapshots: 0,
        history: [],
      },
    });

    render(<ScoreHistoryPanel productId={42} />, { wrapper: createWrapper() });
    const user = userEvent.setup();

    await user.click(screen.getByRole("button"));

    expect(screen.getByRole("button")).toHaveAttribute(
      "aria-expanded",
      "true",
    );
  });

  it("renders defaultOpen=true without click", () => {
    mockGetScoreHistory.mockResolvedValue({
      ok: true,
      data: {
        trend: "stable",
        delta: 0,
        reformulation_detected: false,
        total_snapshots: 0,
        history: [],
      },
    });

    render(<ScoreHistoryPanel productId={42} defaultOpen />, {
      wrapper: createWrapper(),
    });

    expect(screen.getByRole("button")).toHaveAttribute(
      "aria-expanded",
      "true",
    );
  });
});

// ─── Error State ────────────────────────────────────────────────────────────

describe("ScoreHistoryPanel — error state", () => {
  it("shows error message when API returns error", async () => {
    mockGetScoreHistory.mockResolvedValue({
      ok: false,
      error: { message: "Network failure" },
    });

    render(<ScoreHistoryPanel productId={99} defaultOpen />, {
      wrapper: createWrapper(),
    });

    expect(
      await screen.findByTestId("score-history-error"),
    ).toBeVisible();
    expect(screen.getByText("watchlist.historyError")).toBeVisible();
  });
});

// ─── Data Rendering ─────────────────────────────────────────────────────────

describe("ScoreHistoryPanel — data rendering", () => {
  const historyData = {
    trend: "improving" as const,
    delta: -5,
    reformulation_detected: true,
    total_snapshots: 3,
    history: [
      { date: "2025-01-01", score: 40, delta: 0, source: "off_api" },
      { date: "2025-02-01", score: 35, delta: -5, source: "off_api" },
      { date: "2025-03-01", score: 30, delta: -5, source: "manual" },
    ],
  };

  it("renders the history table with rows", async () => {
    mockGetScoreHistory.mockResolvedValue({ ok: true, data: historyData });

    render(<ScoreHistoryPanel productId={1} defaultOpen />, {
      wrapper: createWrapper(),
    });

    expect(
      await screen.findByTestId("score-history-table"),
    ).toBeVisible();
  });

  it("renders ScoreChangeIndicator for overall delta", async () => {
    mockGetScoreHistory.mockResolvedValue({ ok: true, data: historyData });

    render(<ScoreHistoryPanel productId={1} defaultOpen />, {
      wrapper: createWrapper(),
    });

    const indicators = await screen.findAllByTestId("score-change-indicator");
    // 1 overall + 3 per history row = 4
    expect(indicators.length).toBe(4);
  });

  it("renders ReformulationBadge with detected=true", async () => {
    mockGetScoreHistory.mockResolvedValue({ ok: true, data: historyData });

    render(<ScoreHistoryPanel productId={1} defaultOpen />, {
      wrapper: createWrapper(),
    });

    const badge = await screen.findByTestId("reformulation-badge");
    expect(badge).toHaveTextContent("true");
  });

  it("renders snapshot count text", async () => {
    mockGetScoreHistory.mockResolvedValue({ ok: true, data: historyData });

    render(<ScoreHistoryPanel productId={1} defaultOpen />, {
      wrapper: createWrapper(),
    });

    expect(
      await screen.findByText("watchlist.snapshotCount"),
    ).toBeVisible();
  });

  it("shows noHistoryYet message when history array is empty", async () => {
    mockGetScoreHistory.mockResolvedValue({
      ok: true,
      data: {
        ...historyData,
        history: [],
      },
    });

    render(<ScoreHistoryPanel productId={1} defaultOpen />, {
      wrapper: createWrapper(),
    });

    expect(
      await screen.findByText("watchlist.noHistoryYet"),
    ).toBeVisible();
  });

  it("applies custom className", () => {
    render(
      <ScoreHistoryPanel productId={1} className="custom-panel" />,
      { wrapper: createWrapper() },
    );

    const panel = screen.getByTestId("score-history-panel");
    expect(panel.classList.contains("custom-panel")).toBe(true);
  });
});
