import { describe, expect, it } from "vitest";
import { render, screen } from "@testing-library/react";
import { SkipLink } from "./SkipLink";

describe("SkipLink", () => {
  it("renders a link targeting #main-content", () => {
    render(<SkipLink />);
    const link = screen.getByRole("link", { name: /skip to content/i });
    expect(link).toBeInTheDocument();
    expect(link).toHaveAttribute("href", "#main-content");
  });

  it("is visually hidden by default (translated off-screen)", () => {
    render(<SkipLink />);
    const link = screen.getByRole("link", { name: /skip to content/i });
    // The link should have the -translate-y-full class making it hidden
    expect(link.className).toContain("-translate-y-full");
  });

  it("becomes visible on focus (has focus:translate-y-0)", () => {
    render(<SkipLink />);
    const link = screen.getByRole("link", { name: /skip to content/i });
    expect(link.className).toContain("focus:translate-y-0");
  });
});
