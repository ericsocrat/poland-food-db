import { render, screen } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";
import { QuickActions } from "./QuickActions";

// ─── Mocks ──────────────────────────────────────────────────────────────────

vi.mock("next/link", () => ({
  default: ({
    href,
    children,
    ...rest
  }: {
    href: string;
    children: React.ReactNode;
    className?: string;
  }) => (
    <a href={href} {...rest}>
      {children}
    </a>
  ),
}));

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("QuickActions", () => {
  it("renders all 4 action links", () => {
    render(<QuickActions />);
    const links = screen.getAllByRole("link");
    expect(links).toHaveLength(4);
  });

  it("links to scan, search, compare, and lists routes", () => {
    render(<QuickActions />);
    const links = screen.getAllByRole("link");
    const hrefs = links.map((l) => l.getAttribute("href"));
    expect(hrefs).toContain("/app/scan");
    expect(hrefs).toContain("/app/search");
    expect(hrefs).toContain("/app/compare");
    expect(hrefs).toContain("/app/lists");
  });

  it("wraps actions in a section with aria-label", () => {
    render(<QuickActions />);
    expect(screen.getByRole("region")).toBeInTheDocument();
  });

  it("renders icon spans as decorative (aria-hidden)", () => {
    const { container } = render(<QuickActions />);
    const decorativeSpans = container.querySelectorAll(
      '[aria-hidden="true"]',
    );
    expect(decorativeSpans.length).toBeGreaterThanOrEqual(4);
  });
});
