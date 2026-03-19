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
});
