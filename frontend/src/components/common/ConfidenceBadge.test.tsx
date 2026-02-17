import { describe, it, expect } from "vitest";
import { render, screen } from "@testing-library/react";
import { ConfidenceBadge } from "./ConfidenceBadge";

describe("ConfidenceBadge", () => {
  it.each(["high", "medium", "low"] as const)("renders %s level", (level) => {
    render(<ConfidenceBadge level={level} />);
    const label = level.charAt(0).toUpperCase() + level.slice(1);
    expect(screen.getByText(label)).toBeTruthy();
  });

  it("maps high to confidence-high color", () => {
    render(<ConfidenceBadge level="high" />);
    const badge = screen.getByText("High");
    expect(badge.className).toContain("text-confidence-high");
    expect(badge.className).toContain("bg-confidence-high/10");
  });

  it("maps low to confidence-low color", () => {
    render(<ConfidenceBadge level="low" />);
    expect(screen.getByText("Low").className).toContain("text-confidence-low");
  });

  it("renders Unknown for null level", () => {
    render(<ConfidenceBadge level={null} />);
    expect(screen.getByText("Unknown")).toBeTruthy();
    expect(screen.getByText("Unknown").className).toContain(
      "text-foreground-muted",
    );
  });

  it("shows percentage when provided", () => {
    render(<ConfidenceBadge level="high" percentage={85} />);
    expect(screen.getByText("85%")).toBeTruthy();
  });

  it("hides percentage for invalid values", () => {
    render(<ConfidenceBadge level="high" percentage={-1} />);
    expect(screen.queryByText("-1%")).toBeNull();
  });

  it("has accessible aria-label", () => {
    render(<ConfidenceBadge level="medium" percentage={60} />);
    expect(screen.getByLabelText("Confidence: Medium (60%)")).toBeTruthy();
  });

  it("has accessible aria-label without percentage", () => {
    render(<ConfidenceBadge level="high" />);
    expect(screen.getByLabelText("Confidence: High")).toBeTruthy();
  });
});
