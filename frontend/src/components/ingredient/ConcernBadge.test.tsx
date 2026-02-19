import { describe, it, expect } from "vitest";
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import * as TooltipPrimitive from "@radix-ui/react-tooltip";
import { ConcernBadge } from "./ConcernBadge";

describe("ConcernBadge", () => {
  it("renders the label text", () => {
    render(<ConcernBadge tier={0} label="No concern" />);
    expect(screen.getByTestId("concern-badge")).toHaveTextContent("No concern");
  });

  it("renders green styling for tier 0", () => {
    render(<ConcernBadge tier={0} label="No concern" />);
    const badge = screen.getByTestId("concern-badge");
    expect(badge.className).toContain("bg-confidence-high/10");
    expect(badge.className).toContain("text-confidence-high");
  });

  it("renders amber styling for tier 1", () => {
    render(<ConcernBadge tier={1} label="Low concern" />);
    const badge = screen.getByTestId("concern-badge");
    expect(badge.className).toContain("bg-confidence-medium/10");
  });

  it("renders orange styling for tier 2", () => {
    render(<ConcernBadge tier={2} label="Moderate concern" />);
    const badge = screen.getByTestId("concern-badge");
    expect(badge.className).toContain("bg-warning/10");
  });

  it("renders red styling for tier 3", () => {
    render(<ConcernBadge tier={3} label="High concern" />);
    const badge = screen.getByTestId("concern-badge");
    expect(badge.className).toContain("bg-error/10");
  });

  it("shows ✅ icon for tier 0", () => {
    render(<ConcernBadge tier={0} label="No concern" />);
    expect(
      screen.getByTestId("concern-badge").querySelector("svg"),
    ).toBeTruthy();
  });

  it("shows ⚠️ icon for tier 1", () => {
    render(<ConcernBadge tier={1} label="Low concern" />);
    expect(
      screen.getByTestId("concern-badge").querySelector("svg"),
    ).toBeTruthy();
  });

  it("shows 🔴 icon for tier 3", () => {
    render(<ConcernBadge tier={3} label="High concern" />);
    expect(screen.getByTestId("concern-badge")).toHaveTextContent("🔴");
  });

  it("falls back to tier 0 styling for unknown tier", () => {
    render(<ConcernBadge tier={99} label="Unknown" />);
    const badge = screen.getByTestId("concern-badge");
    expect(badge.className).toContain("bg-confidence-high/10");
  });

  it("shows tooltip on hover when showTooltip is true", async () => {
    const user = userEvent.setup();
    render(
      <TooltipPrimitive.Provider delayDuration={0}>
        <ConcernBadge tier={3} label="High concern" showTooltip />
      </TooltipPrimitive.Provider>,
    );

    await user.hover(screen.getByTestId("concern-badge"));
    const tooltip = await screen.findByRole("tooltip");
    expect(tooltip.textContent).toContain("EFSA Concern Level 3");
  });

  // ── Expandable concern details (§3.8) ─────────────────────────────────────

  it("renders as expandable when reason is provided and tier > 0", () => {
    render(
      <ConcernBadge
        tier={2}
        label="Moderate concern"
        reason="Linked to increased risk when consumed in excess."
      />,
    );
    expect(screen.getByTestId("concern-expandable")).toBeInTheDocument();
    expect(screen.getByRole("button")).toBeInTheDocument();
    expect(screen.getByRole("button")).toHaveAttribute(
      "aria-expanded",
      "false",
    );
  });

  it("expands to show concern reason on click", async () => {
    const user = userEvent.setup();
    render(
      <ConcernBadge
        tier={3}
        label="High concern"
        reason="EFSA re-evaluated in 2021, found potential genotoxicity."
      />,
    );

    expect(screen.queryByTestId("concern-detail")).not.toBeInTheDocument();

    await user.click(screen.getByRole("button"));
    expect(screen.getByTestId("concern-detail")).toBeInTheDocument();
    expect(screen.getByTestId("concern-detail")).toHaveTextContent(
      "EFSA re-evaluated in 2021",
    );
    expect(screen.getByRole("button")).toHaveAttribute("aria-expanded", "true");
  });

  it("collapses concern reason on second click", async () => {
    const user = userEvent.setup();
    render(
      <ConcernBadge tier={2} label="Moderate" reason="Some concern text" />,
    );

    await user.click(screen.getByRole("button"));
    expect(screen.getByTestId("concern-detail")).toBeInTheDocument();

    await user.click(screen.getByRole("button"));
    expect(screen.queryByTestId("concern-detail")).not.toBeInTheDocument();
  });

  it("does not render as expandable for tier 0 even with reason", () => {
    render(<ConcernBadge tier={0} label="No concern" reason="Some text" />);
    expect(screen.queryByTestId("concern-expandable")).not.toBeInTheDocument();
    expect(screen.queryByRole("button")).not.toBeInTheDocument();
  });

  it("does not render as expandable when reason is null", () => {
    render(<ConcernBadge tier={2} label="Moderate concern" reason={null} />);
    expect(screen.queryByTestId("concern-expandable")).not.toBeInTheDocument();
  });

  it("shows chevron icon on expandable badges", () => {
    render(<ConcernBadge tier={1} label="Low concern" reason="Minor risks." />);
    const badge = screen.getByTestId("concern-badge");
    // Should have CheckCircle/AlertTriangle + ChevronDown SVGs
    const svgs = badge.querySelectorAll("svg");
    expect(svgs.length).toBe(2); // tier icon + chevron
  });
});
