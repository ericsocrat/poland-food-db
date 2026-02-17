import { describe, expect, it } from "vitest";
import { render, screen } from "@testing-library/react";
import { LiveRegion } from "./LiveRegion";

describe("LiveRegion", () => {
  it("renders announcement text in an output element", () => {
    render(<LiveRegion message="5 results found" />);
    const region = screen.getByText("5 results found");
    expect(region).toBeInTheDocument();
    expect(region.tagName).toBe("OUTPUT");
  });

  it("has aria-live=polite by default", () => {
    render(<LiveRegion message="test" />);
    const region = screen.getByText("test");
    expect(region).toHaveAttribute("aria-live", "polite");
  });

  it("supports assertive politeness", () => {
    render(<LiveRegion message="Error!" politeness="assertive" />);
    const region = screen.getByText("Error!");
    expect(region).toHaveAttribute("aria-live", "assertive");
  });

  it("has aria-atomic=true for complete re-announcements", () => {
    render(<LiveRegion message="test" />);
    const region = screen.getByText("test");
    expect(region).toHaveAttribute("aria-atomic", "true");
  });

  it("is visually hidden (sr-only)", () => {
    render(<LiveRegion message="hidden text" />);
    const region = screen.getByText("hidden text");
    expect(region.className).toContain("sr-only");
  });

  it("updates text when message prop changes", () => {
    const { rerender } = render(<LiveRegion message="3 results" />);
    expect(screen.getByText("3 results")).toBeInTheDocument();

    rerender(<LiveRegion message="10 results" />);
    expect(screen.getByText("10 results")).toBeInTheDocument();
    expect(screen.queryByText("3 results")).not.toBeInTheDocument();
  });
});
