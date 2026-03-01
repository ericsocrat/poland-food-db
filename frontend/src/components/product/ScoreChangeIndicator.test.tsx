import { describe, it, expect, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import { ScoreChangeIndicator } from "./ScoreChangeIndicator";

// ─── Mocks ──────────────────────────────────────────────────────────────────

vi.mock("@/lib/i18n", () => ({
  useTranslation: () => ({
    t: (key: string, params?: Record<string, string>) => {
      const map: Record<string, string> = {
        "watchlist.scoreWorsened": `Worsened by ${params?.delta ?? "?"}`,
        "watchlist.scoreImproved": `Improved by ${params?.delta ?? "?"}`,
      };
      return map[key] ?? key;
    },
  }),
}));

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("ScoreChangeIndicator", () => {
  it("renders nothing for null delta", () => {
    const { container } = render(<ScoreChangeIndicator delta={null} />);
    expect(container.innerHTML).toBe("");
  });

  it("renders nothing for zero delta", () => {
    const { container } = render(<ScoreChangeIndicator delta={0} />);
    expect(container.innerHTML).toBe("");
  });

  it("renders up arrow for positive delta (worsened)", () => {
    render(<ScoreChangeIndicator delta={5} />);
    const badge = screen.getByTestId("score-change-indicator");
    expect(badge.textContent).toContain("↑");
    expect(badge.textContent).toContain("5");
  });

  it("renders down arrow for negative delta (improved)", () => {
    render(<ScoreChangeIndicator delta={-3} />);
    const badge = screen.getByTestId("score-change-indicator");
    expect(badge.textContent).toContain("↓");
    expect(badge.textContent).toContain("3");
  });

  it("shows error color class for worsened score", () => {
    render(<ScoreChangeIndicator delta={10} />);
    const badge = screen.getByTestId("score-change-indicator");
    expect(badge.className).toContain("text-error");
  });

  it("shows success color class for improved score", () => {
    render(<ScoreChangeIndicator delta={-7} />);
    const badge = screen.getByTestId("score-change-indicator");
    expect(badge.className).toContain("text-success");
  });

  it("sets aria-label with worsened message", () => {
    render(<ScoreChangeIndicator delta={5} />);
    const badge = screen.getByTestId("score-change-indicator");
    expect(badge).toHaveAttribute("aria-label", "Worsened by 5");
  });

  it("sets aria-label with improved message", () => {
    render(<ScoreChangeIndicator delta={-3} />);
    const badge = screen.getByTestId("score-change-indicator");
    expect(badge).toHaveAttribute("aria-label", "Improved by 3");
  });

  it("applies custom className", () => {
    render(<ScoreChangeIndicator delta={2} className="mt-4" />);
    const badge = screen.getByTestId("score-change-indicator");
    expect(badge.className).toContain("mt-4");
  });
});
