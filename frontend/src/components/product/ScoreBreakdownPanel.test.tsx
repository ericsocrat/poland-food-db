import { describe, it, expect, vi, beforeEach } from "vitest";
import { render, screen, fireEvent, waitFor } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import type { ReactNode } from "react";
import type { ScoreExplanation } from "@/lib/types";

// ─── Mocks ──────────────────────────────────────────────────────────────────

const mockGetScoreExplanation = vi.fn();

vi.mock("@/lib/supabase/client", () => ({
  createClient: () => ({}),
}));

vi.mock("@/lib/api", () => ({
  getScoreExplanation: (...args: unknown[]) => mockGetScoreExplanation(...args),
}));

vi.mock("@/lib/query-keys", () => ({
  queryKeys: { scoreExplanation: (id: number) => ["scoreExplanation", id] },
  staleTimes: { productProfile: 60_000 },
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

import { ScoreBreakdownPanel } from "./ScoreBreakdownPanel";

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

const MOCK_EXPLANATION: ScoreExplanation = {
  api_version: "1.0",
  product_id: 42,
  product_name: "Test Product",
  brand: "TestBrand",
  category: "Snacks",
  score_breakdown: {},
  summary: {
    score: 65,
    score_band: "Elevated Risk",
    headline: "This product has elevated sugar levels.",
    nutri_score: "C",
    nova_group: "4",
    processing_risk: "high",
  },
  top_factors: [
    { factor: "Sugar", raw: 75, weighted: 22.5 },
    { factor: "Saturated Fat", raw: 40, weighted: 12.0 },
    { factor: "Fiber", raw: 10, weighted: 3.0 },
  ],
  warnings: [
    { type: "additives", message: "Contains controversial additives" },
  ],
  category_context: {
    category_avg_score: 55,
    category_rank: 15,
    category_total: 50,
    relative_position: "worse than average",
  },
};

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("ScoreBreakdownPanel", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("renders collapsed by default", () => {
    render(
      <ScoreBreakdownPanel
        productId={42}
        score={65}
        scoreBand="Elevated Risk"
      />,
      { wrapper: createWrapper() },
    );
    expect(screen.getByTestId("score-breakdown-panel")).toBeInTheDocument();
    expect(screen.getByRole("button", { expanded: false })).toBeInTheDocument();
    expect(
      screen.queryByText("tooltip.scoreBreakdown.error"),
    ).not.toBeInTheDocument();
  });

  it("displays score and band in header", () => {
    render(
      <ScoreBreakdownPanel
        productId={42}
        score={65}
        scoreBand="Elevated Risk"
      />,
      { wrapper: createWrapper() },
    );
    expect(screen.getByText("65/100 — Elevated Risk")).toBeInTheDocument();
  });

  it("expands on click and shows loading state", async () => {
    mockGetScoreExplanation.mockReturnValue(new Promise(() => {})); // never resolves
    render(
      <ScoreBreakdownPanel
        productId={42}
        score={65}
        scoreBand="Elevated Risk"
      />,
      { wrapper: createWrapper() },
    );

    fireEvent.click(screen.getByRole("button"));
    expect(screen.getByRole("button", { expanded: true })).toBeInTheDocument();
  });

  it("renders explanation data after loading", async () => {
    mockGetScoreExplanation.mockResolvedValue({
      ok: true,
      data: MOCK_EXPLANATION,
    });

    render(
      <ScoreBreakdownPanel
        productId={42}
        score={65}
        scoreBand="Elevated Risk"
        defaultOpen
      />,
      { wrapper: createWrapper() },
    );

    await waitFor(() => {
      expect(
        screen.getByText("This product has elevated sugar levels."),
      ).toBeInTheDocument();
    });

    // Factor bars
    expect(screen.getByText("Sugar")).toBeInTheDocument();
    expect(screen.getByText("+22.5 pts")).toBeInTheDocument();
    expect(screen.getByText("Saturated Fat")).toBeInTheDocument();
    expect(screen.getByText("Fiber")).toBeInTheDocument();

    // Progress bars with correct aria
    const bars = screen.getAllByRole("progressbar");
    expect(bars).toHaveLength(3);
    expect(bars[0]).toHaveAttribute("aria-valuenow", "75");
    expect(bars[1]).toHaveAttribute("aria-valuenow", "40");
    expect(bars[2]).toHaveAttribute("aria-valuenow", "10");
  });

  it("renders category context", async () => {
    mockGetScoreExplanation.mockResolvedValue({
      ok: true,
      data: MOCK_EXPLANATION,
    });

    render(
      <ScoreBreakdownPanel
        productId={42}
        score={65}
        scoreBand="Elevated Risk"
        defaultOpen
      />,
      { wrapper: createWrapper() },
    );

    await waitFor(() => {
      expect(screen.getByText(/rank=15/)).toBeInTheDocument();
    });
    expect(screen.getByText(/total=50/)).toBeInTheDocument();
  });

  it("renders warnings", async () => {
    mockGetScoreExplanation.mockResolvedValue({
      ok: true,
      data: MOCK_EXPLANATION,
    });

    render(
      <ScoreBreakdownPanel
        productId={42}
        score={65}
        scoreBand="Elevated Risk"
        defaultOpen
      />,
      { wrapper: createWrapper() },
    );

    await waitFor(() => {
      expect(
        screen.getByText("Contains controversial additives"),
      ).toBeInTheDocument();
    });
  });

  it("shows error message on API failure", async () => {
    mockGetScoreExplanation.mockResolvedValue({
      ok: false,
      error: { message: "Server error" },
    });

    render(
      <ScoreBreakdownPanel
        productId={42}
        score={65}
        scoreBand="Elevated Risk"
        defaultOpen
      />,
      { wrapper: createWrapper() },
    );

    await waitFor(() => {
      expect(
        screen.getByText("tooltip.scoreBreakdown.error"),
      ).toBeInTheDocument();
    });
  });

  it("toggles open and closed", () => {
    render(
      <ScoreBreakdownPanel
        productId={42}
        score={65}
        scoreBand="Elevated Risk"
      />,
      { wrapper: createWrapper() },
    );

    const button = screen.getByRole("button");

    // Open
    fireEvent.click(button);
    expect(button).toHaveAttribute("aria-expanded", "true");

    // Close
    fireEvent.click(button);
    expect(button).toHaveAttribute("aria-expanded", "false");
  });
});
