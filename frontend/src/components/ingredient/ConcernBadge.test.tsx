import { describe, it, expect } from "vitest";
import { render, screen } from "@testing-library/react";
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
    expect(screen.getByTestId("concern-badge")).toHaveTextContent("✅");
  });

  it("shows ⚠️ icon for tier 1", () => {
    render(<ConcernBadge tier={1} label="Low concern" />);
    expect(screen.getByTestId("concern-badge")).toHaveTextContent("⚠️");
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
});
