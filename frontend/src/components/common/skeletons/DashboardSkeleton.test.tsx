import { describe, it, expect } from "vitest";
import { render, screen } from "@testing-library/react";
import { DashboardSkeleton } from "./DashboardSkeleton";

// ─── DashboardSkeleton ─────────────────────────────────────────────────────

describe("DashboardSkeleton", () => {
  it("renders with accessible loading status", () => {
    render(<DashboardSkeleton />);
    const container = screen.getByRole("status");
    expect(container).toHaveAttribute("aria-busy", "true");
    expect(container).toHaveAttribute("aria-label", "Loading dashboard");
  });

  it("uses vertical space-y layout (not grid)", () => {
    render(<DashboardSkeleton />);
    const container = screen.getByRole("status");
    expect(container.className).toContain("space-y-6");
    expect(container.className).not.toContain("grid-cols-12");
  });

  it("renders greeting skeleton with pill chip", () => {
    render(<DashboardSkeleton />);
    const container = screen.getByRole("status");
    // Greeting section: first child has rounded-full chip skeleton
    const firstSection = container.firstElementChild;
    expect(firstSection).toBeInTheDocument();
    const chip = firstSection?.querySelector('[class*="rounded-full"]');
    expect(chip).toBeInTheDocument();
  });

  it("renders 3 recently viewed placeholder rows", () => {
    render(<DashboardSkeleton />);
    const container = screen.getByRole("status");
    // Card rows inside recently viewed section (4th child)
    const cards = container.querySelectorAll(".card.flex.items-center.gap-3");
    expect(cards.length).toBe(3);
  });

  it("renders 4 quick action placeholders", () => {
    render(<DashboardSkeleton />);
    const container = screen.getByRole("status");
    const grid = container.querySelector(".grid.grid-cols-2");
    expect(grid).toBeInTheDocument();
    expect(grid?.children.length).toBe(4);
  });

  it("renders health insights skeleton with 3 rounded-xl blocks", () => {
    render(<DashboardSkeleton />);
    const container = screen.getByRole("status");
    // Insights section: 3rd child (after greeting and health summary)
    const insightsSection = container.children[2];
    expect(insightsSection).toBeInTheDocument();
    const blocks = insightsSection.querySelectorAll('[class*="rounded-xl"]');
    expect(blocks.length).toBe(3);
  });

  it("renders nutrition tip skeleton with bordered card", () => {
    render(<DashboardSkeleton />);
    const container = screen.getByRole("status");
    const tipCard = container.querySelector(".rounded-xl.border.bg-surface");
    expect(tipCard).toBeInTheDocument();
  });

  it("renders categories browse skeleton with 6 chip placeholders", () => {
    render(<DashboardSkeleton />);
    const container = screen.getByRole("status");
    const chipContainer = container.querySelector(".flex.gap-3.overflow-hidden");
    expect(chipContainer).toBeInTheDocument();
    expect(chipContainer?.children.length).toBe(6);
  });

  it("renders all 8 sections in correct order", () => {
    render(<DashboardSkeleton />);
    const container = screen.getByRole("status");
    // 8 visible sections + 1 sr-only span from SkeletonContainer
    expect(container.children.length).toBe(9);
    // Quick actions is the 8th section (index 7), before sr-only span
    const quickActions = container.children[7] as HTMLElement;
    expect(quickActions.matches(".grid.grid-cols-2")).toBe(true);
  });
});
