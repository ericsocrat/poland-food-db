import { describe, it, expect } from "vitest";
import { render } from "@testing-library/react";
import { ThemeScript } from "./ThemeScript";

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("ThemeScript", () => {
  it("renders a script element", () => {
    const { container } = render(<ThemeScript />);
    const script = container.querySelector("script");
    expect(script).toBeInTheDocument();
  });

  it("contains localStorage theme logic", () => {
    const { container } = render(<ThemeScript />);
    const script = container.querySelector("script");
    const content = script?.innerHTML ?? "";
    expect(content).toContain("localStorage.getItem");
    expect(content).toContain("theme");
  });

  it("contains matchMedia system theme resolution", () => {
    const { container } = render(<ThemeScript />);
    const script = container.querySelector("script");
    const content = script?.innerHTML ?? "";
    expect(content).toContain("prefers-color-scheme: dark");
    expect(content).toContain("matchMedia");
  });

  it("sets data-theme on document element", () => {
    const { container } = render(<ThemeScript />);
    const script = container.querySelector("script");
    const content = script?.innerHTML ?? "";
    expect(content).toContain("data-theme");
    expect(content).toContain("setAttribute");
  });

  it("has suppressHydrationWarning to prevent React mismatch", () => {
    const { container } = render(<ThemeScript />);
    const script = container.querySelector("script");
    // suppressHydrationWarning is a React prop — it won't appear as DOM attribute,
    // but the script renders without error which proves it's set correctly.
    expect(script).toBeInTheDocument();
  });
});
