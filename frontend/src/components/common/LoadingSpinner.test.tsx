import { describe, it, expect } from "vitest";
import { render, screen } from "@testing-library/react";
import { LoadingSpinner } from "./LoadingSpinner";

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("LoadingSpinner", () => {
  it("renders with aria-label Loading", () => {
    render(<LoadingSpinner />);
    expect(screen.getByLabelText("Loading…")).toBeTruthy();
  });

  it("renders sr-only text", () => {
    render(<LoadingSpinner />);
    expect(screen.getByText("Loading…")).toBeTruthy();
  });

  it("applies sm size class", () => {
    render(<LoadingSpinner size="sm" />);
    const spinner = screen.getByLabelText("Loading…").querySelector("div");
    expect(spinner?.className).toContain("h-4");
    expect(spinner?.className).toContain("w-4");
  });

  it("applies md size class by default", () => {
    render(<LoadingSpinner />);
    const spinner = screen.getByLabelText("Loading…").querySelector("div");
    expect(spinner?.className).toContain("h-8");
    expect(spinner?.className).toContain("w-8");
  });

  it("applies lg size class", () => {
    render(<LoadingSpinner size="lg" />);
    const spinner = screen.getByLabelText("Loading…").querySelector("div");
    expect(spinner?.className).toContain("h-12");
    expect(spinner?.className).toContain("w-12");
  });

  it("applies custom className", () => {
    render(<LoadingSpinner className="mt-4" />);
    const wrapper = screen.getByLabelText("Loading…");
    expect(wrapper.className).toContain("mt-4");
  });
});
