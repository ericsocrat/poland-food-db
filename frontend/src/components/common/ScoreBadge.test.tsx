import { describe, it, expect } from "vitest";
import { render, screen } from "@testing-library/react";
import { ScoreBadge } from "./ScoreBadge";

describe("ScoreBadge", () => {
  it("renders score value", () => {
    render(<ScoreBadge score={42} />);
    expect(screen.getByText("42")).toBeTruthy();
  });

  it("maps score 1–20 to green band", () => {
    render(<ScoreBadge score={15} />);
    const badge = screen.getByText("15");
    expect(badge.className).toContain("text-score-green");
    expect(badge.className).toContain("bg-score-green/10");
  });

  it("maps score 21–40 to yellow band", () => {
    render(<ScoreBadge score={30} />);
    const badge = screen.getByText("30");
    expect(badge.className).toContain("text-score-yellow");
  });

  it("maps score 41–60 to orange band", () => {
    render(<ScoreBadge score={50} />);
    const badge = screen.getByText("50");
    expect(badge.className).toContain("text-score-orange");
  });

  it("maps score 61–80 to red band", () => {
    render(<ScoreBadge score={75} />);
    const badge = screen.getByText("75");
    expect(badge.className).toContain("text-score-red");
  });

  it("maps score 81–100 to darkred band", () => {
    render(<ScoreBadge score={95} />);
    const badge = screen.getByText("95");
    expect(badge.className).toContain("text-score-darkred");
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
    render(<ScoreBadge score={50} size="lg" />);
    expect(screen.getByText("50").className).toContain("text-base");
  });

  it("has accessible aria-label", () => {
    render(<ScoreBadge score={42} />);
    expect(screen.getByLabelText("Score: 42")).toBeTruthy();
  });
});
