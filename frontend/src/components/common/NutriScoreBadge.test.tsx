import { describe, it, expect } from "vitest";
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import * as TooltipPrimitive from "@radix-ui/react-tooltip";
import { NutriScoreBadge } from "./NutriScoreBadge";

describe("NutriScoreBadge", () => {
  it.each(["A", "B", "C", "D", "E"] as const)(
    "renders grade %s with correct EU color",
    (grade) => {
      render(<NutriScoreBadge grade={grade} />);
      const badge = screen.getByText(grade);
      expect(badge).toBeTruthy();
      expect(badge.className).toContain(`bg-nutri-${grade}`);
    },
  );

  it("normalizes lowercase grades", () => {
    render(<NutriScoreBadge grade="b" />);
    expect(screen.getByText("B")).toBeTruthy();
    expect(screen.getByText("B").className).toContain("bg-nutri-B");
  });

  it("renders ? for null grade", () => {
    render(<NutriScoreBadge grade={null} />);
    expect(screen.getByText("?")).toBeTruthy();
    expect(screen.getByText("?").className).toContain("bg-surface-muted");
  });

  it("renders ? for invalid grade", () => {
    render(<NutriScoreBadge grade="X" />);
    expect(screen.getByText("?")).toBeTruthy();
    expect(screen.getByText("?").className).toContain("text-foreground-muted");
  });

  it("has accessible aria-label for valid grade", () => {
    render(<NutriScoreBadge grade="A" />);
    expect(screen.getByLabelText("Nutri-Score A")).toBeTruthy();
  });

  it("has accessible aria-label for unknown grade", () => {
    render(<NutriScoreBadge grade={null} />);
    expect(screen.getByLabelText("Nutri-Score unknown")).toBeTruthy();
  });

  it("applies size classes", () => {
    render(<NutriScoreBadge grade="A" size="lg" />);
    expect(screen.getByText("A").className).toContain("h-9");
  });

  it("applies A text as foreground-inverse", () => {
    render(<NutriScoreBadge grade="A" />);
    expect(screen.getByText("A").className).toContain(
      "text-foreground-inverse",
    );
  });

  it("applies C text as foreground (not inverse, since C is yellow)", () => {
    render(<NutriScoreBadge grade="C" />);
    const el = screen.getByText("C");
    expect(el.className).toContain("text-foreground");
    expect(el.className).not.toContain("text-foreground-inverse");
  });

  it("shows tooltip on hover when showTooltip is true", async () => {
    const user = userEvent.setup();
    render(
      <TooltipPrimitive.Provider delayDuration={0}>
        <NutriScoreBadge grade="A" showTooltip />
      </TooltipPrimitive.Provider>,
    );

    await user.hover(screen.getByText("A"));
    const tooltip = await screen.findByRole("tooltip");
    expect(tooltip.textContent).toContain("Nutri-Score A");
  });
});
