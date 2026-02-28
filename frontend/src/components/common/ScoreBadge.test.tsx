import { describe, it, expect } from "vitest";
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import * as TooltipPrimitive from "@radix-ui/react-tooltip";
import { ScoreBadge } from "./ScoreBadge";

describe("ScoreBadge", () => {
  it("renders score value", () => {
    render(<ScoreBadge score={42} />);
    expect(screen.getByText("42")).toBeTruthy();
  });

  it("maps score 1–20 to green band", () => {
    render(<ScoreBadge score={15} />);
    const badge = screen.getByText("15");
    expect(badge.className).toContain("text-score-green-text");
    expect(badge.className).toContain("bg-score-green/10");
  });

  it("maps score 21–40 to yellow band", () => {
    render(<ScoreBadge score={30} />);
    const badge = screen.getByText("30");
    expect(badge.className).toContain("text-score-yellow-text");
  });

  it("maps score 41–60 to orange band", () => {
    render(<ScoreBadge score={50} />);
    const badge = screen.getByText("50");
    expect(badge.className).toContain("text-score-orange-text");
  });

  it("maps score 61–80 to red band", () => {
    render(<ScoreBadge score={75} />);
    const badge = screen.getByText("75");
    expect(badge.className).toContain("text-score-red-text");
  });

  it("maps score 81–100 to darkred band", () => {
    render(<ScoreBadge score={95} />);
    const badge = screen.getByText("95");
    expect(badge.className).toContain("text-score-darkred-text");
  });

  it("renders N/A for null score", () => {
    render(<ScoreBadge score={null} />);
    expect(screen.getByText("N/A")).toBeTruthy();
    expect(screen.getByText("N/A").className).toContain(
      "text-foreground-muted",
    );
  });

  it("renders N/A for undefined score", () => {
    render(<ScoreBadge score={undefined} />);
    expect(screen.getByText("N/A")).toBeTruthy();
  });

  it("renders gray badge for out-of-range score", () => {
    render(<ScoreBadge score={0} />);
    expect(screen.getByText("N/A")).toBeTruthy();
  });

  it("shows label when showLabel is true", () => {
    render(<ScoreBadge score={15} showLabel />);
    expect(screen.getByText("Low")).toBeTruthy();
  });

  it("applies size classes", () => {
    render(<ScoreBadge score={50} size="md" />);
    expect(screen.getByText("50").className).toContain("text-sm");
  });

  it("has accessible aria-label", () => {
    render(<ScoreBadge score={42} />);
    expect(screen.getByLabelText("Score: 42")).toBeTruthy();
  });

  it("shows tooltip on hover when showTooltip is true", async () => {
    const user = userEvent.setup();
    render(
      <TooltipPrimitive.Provider delayDuration={0}>
        <ScoreBadge score={15} showTooltip />
      </TooltipPrimitive.Provider>,
    );

    await user.hover(screen.getByText("15"));
    const tooltip = await screen.findByRole("tooltip");
    expect(tooltip.textContent).toContain("Score 1–20");
  });

  it("does not render tooltip when showTooltip is false", () => {
    render(<ScoreBadge score={15} />);
    expect(screen.queryByRole("tooltip")).toBeNull();
  });

  // ─── Band boundary tests (Issue #373) ─────────────────────────────────

  it("maps boundary score 20 to green (upper green boundary)", () => {
    render(<ScoreBadge score={20} />);
    const badge = screen.getByText("20");
    expect(badge.className).toContain("text-score-green");
  });

  it("maps boundary score 21 to yellow (lower yellow boundary)", () => {
    render(<ScoreBadge score={21} />);
    const badge = screen.getByText("21");
    expect(badge.className).toContain("text-score-yellow");
  });

  it("maps boundary score 40 to yellow (upper yellow boundary)", () => {
    render(<ScoreBadge score={40} />);
    const badge = screen.getByText("40");
    expect(badge.className).toContain("text-score-yellow");
  });

  it("maps boundary score 41 to orange (lower orange boundary)", () => {
    render(<ScoreBadge score={41} />);
    const badge = screen.getByText("41");
    expect(badge.className).toContain("text-score-orange");
  });

  it("maps boundary score 60 to orange (upper orange boundary)", () => {
    render(<ScoreBadge score={60} />);
    const badge = screen.getByText("60");
    expect(badge.className).toContain("text-score-orange");
  });

  it("maps boundary score 61 to red (lower red boundary)", () => {
    render(<ScoreBadge score={61} />);
    const badge = screen.getByText("61");
    expect(badge.className).toContain("text-score-red");
  });

  it("maps boundary score 80 to red (upper red boundary)", () => {
    render(<ScoreBadge score={80} />);
    const badge = screen.getByText("80");
    expect(badge.className).toContain("text-score-red");
  });

  it("maps boundary score 81 to darkred (lower darkred boundary)", () => {
    render(<ScoreBadge score={81} />);
    const badge = screen.getByText("81");
    expect(badge.className).toContain("text-score-darkred");
  });

  it("maps boundary score 100 to darkred (upper darkred boundary)", () => {
    render(<ScoreBadge score={100} />);
    const badge = screen.getByText("100");
    expect(badge.className).toContain("text-score-darkred");
  });

  it("maps minimum valid score 1 to green", () => {
    render(<ScoreBadge score={1} />);
    const badge = screen.getByText("1");
    expect(badge.className).toContain("text-score-green");
  });

  // ─── Red & Dark Red label and aria tests (Issue #373) ─────────────────

  it("shows 'Very High' label for Red band scores", () => {
    render(<ScoreBadge score={70} showLabel />);
    expect(screen.getByText("Very High")).toBeTruthy();
  });

  it("shows 'Extreme' label for Dark Red band scores", () => {
    render(<ScoreBadge score={90} showLabel />);
    expect(screen.getByText("Extreme")).toBeTruthy();
  });

  it("has correct aria-label for Red band with label", () => {
    render(<ScoreBadge score={70} showLabel />);
    expect(screen.getByLabelText("Score: 70, Very High")).toBeTruthy();
  });

  it("has correct aria-label for Dark Red band with label", () => {
    render(<ScoreBadge score={90} showLabel />);
    expect(screen.getByLabelText("Score: 90, Extreme")).toBeTruthy();
  });

  // ─── Large (lg) ring variant tests ────────────────────────────────────

  it("renders SVG ring for lg size with valid score", () => {
    const { container } = render(<ScoreBadge score={42} size="lg" />);
    expect(container.querySelector("svg")).toBeTruthy();
    expect(container.querySelector("[data-testid='score-ring']")).toBeTruthy();
  });

  it("renders score text inside SVG for lg size", () => {
    const { container } = render(<ScoreBadge score={42} size="lg" />);
    const textEl = container.querySelector("svg text");
    expect(textEl?.textContent).toBe("42");
  });

  it("renders label below ring when showLabel is true for lg", () => {
    render(<ScoreBadge score={42} size="lg" showLabel />);
    expect(screen.getByText("High")).toBeTruthy();
  });

  it("uses correct stroke color for green band on lg ring", () => {
    const { container } = render(<ScoreBadge score={15} size="lg" />);
    const ring = container.querySelector("[data-testid='score-ring']");
    expect(ring?.getAttribute("stroke")).toBe("var(--color-score-green)");
  });

  it("uses correct stroke color for darkred band on lg ring", () => {
    const { container } = render(<ScoreBadge score={90} size="lg" />);
    const ring = container.querySelector("[data-testid='score-ring']");
    expect(ring?.getAttribute("stroke")).toBe("var(--color-score-darkred)");
  });

  it("applies animation class when animated is true (default)", () => {
    const { container } = render(<ScoreBadge score={50} size="lg" />);
    const ring = container.querySelector("[data-testid='score-ring']");
    expect(ring?.className.baseVal).toContain("transition-");
  });

  it("omits animation class when animated is false", () => {
    const { container } = render(
      <ScoreBadge score={50} size="lg" animated={false} />,
    );
    const ring = container.querySelector("[data-testid='score-ring']");
    expect(ring?.className.baseVal || "").not.toContain("transition-");
  });

  it("falls back to pill badge for lg with null score", () => {
    const { container } = render(<ScoreBadge score={null} size="lg" />);
    // Null score does not render SVG ring — falls through to pill
    expect(container.querySelector("svg")).toBeNull();
    expect(screen.getByText("N/A")).toBeTruthy();
  });

  it("has role=img on lg ring container", () => {
    render(<ScoreBadge score={42} size="lg" />);
    expect(screen.getByRole("img")).toBeTruthy();
  });

  it("has accessible aria-label on lg ring", () => {
    render(<ScoreBadge score={42} size="lg" />);
    expect(screen.getByLabelText("Score: 42")).toBeTruthy();
  });
});
