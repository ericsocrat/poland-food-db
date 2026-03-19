import { render, screen } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";
import { QuickActions } from "./QuickActions";
import type { DashboardStats } from "@/lib/types";

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
    style?: React.CSSProperties;
  }) => (
    <a href={href} {...rest}>
      {children}
    </a>
  ),
}));

// ─── Helpers ────────────────────────────────────────────────────────────────

const mockStats: DashboardStats = {
  total_scanned: 12,
  total_viewed: 30,
  lists_count: 5,
  favorites_count: 8,
  most_viewed_category: "Dairy",
};

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

  // ─── New tests: colored icons, badges, animation ──────────────────────────

  it("renders colored icon backgrounds for each action", () => {
    const { container } = render(<QuickActions />);
    const iconSpans = container.querySelectorAll("span.rounded-xl[aria-hidden='true']");
    expect(iconSpans[0]?.className).toContain("bg-emerald-100");
    expect(iconSpans[1]?.className).toContain("bg-blue-100");
    expect(iconSpans[2]?.className).toContain("bg-amber-100");
    expect(iconSpans[3]?.className).toContain("bg-purple-100");
  });

  it("shows count badge when stats has lists_count > 0", () => {
    render(<QuickActions stats={mockStats} />);
    const badge = screen.getByLabelText("5");
    expect(badge).toBeInTheDocument();
    expect(badge.textContent).toBe("5");
  });

  it("hides count badge when stats is undefined", () => {
    const { container } = render(<QuickActions />);
    const badges = container.querySelectorAll('[aria-label]');
    // Only the section aria-label, no count badges
    const countBadges = Array.from(badges).filter((el) =>
      /^\d+$/.test(el.getAttribute("aria-label") ?? ""),
    );
    expect(countBadges).toHaveLength(0);
  });

  it("hides count badge when lists_count is 0", () => {
    const zeroStats: DashboardStats = { ...mockStats, lists_count: 0 };
    const { container } = render(<QuickActions stats={zeroStats} />);
    const countBadges = Array.from(
      container.querySelectorAll('[aria-label]'),
    ).filter((el) => /^\d+$/.test(el.getAttribute("aria-label") ?? ""));
    expect(countBadges).toHaveLength(0);
  });

  it("renders staggered bounceIn animation delays", () => {
    render(<QuickActions />);
    const links = screen.getAllByRole("link");
    expect((links[0] as HTMLElement).style.animation).toContain("0ms");
    expect((links[1] as HTMLElement).style.animation).toContain("100ms");
    expect((links[2] as HTMLElement).style.animation).toContain("200ms");
    expect((links[3] as HTMLElement).style.animation).toContain("300ms");
  });

  it("caps badge display at 99+", () => {
    const bigStats: DashboardStats = { ...mockStats, lists_count: 150 };
    render(<QuickActions stats={bigStats} />);
    const badge = screen.getByLabelText("150");
    expect(badge.textContent).toBe("99+");
  });
});
