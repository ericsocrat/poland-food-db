import { describe, it, expect, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import { NutritionTip } from "./NutritionTip";

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

describe("NutritionTip", () => {
  it("renders tip section with aria-label", () => {
    render(<NutritionTip />);
    expect(
      screen.getByRole("region", { name: "Tip of the Day" }),
    ).toBeInTheDocument();
  });

  it("renders tip title", () => {
    render(<NutritionTip />);
    expect(screen.getByText("Tip of the Day")).toBeInTheDocument();
  });

  it("renders a tip text", () => {
    render(<NutritionTip />);
    // Tip text should be visible — check for a non-empty paragraph
    const section = screen.getByRole("region", { name: "Tip of the Day" });
    const paragraphs = section.querySelectorAll("p");
    // The tip text paragraph
    expect(paragraphs.length).toBeGreaterThanOrEqual(1);
  });

  it("renders a 'Learn more' link", () => {
    render(<NutritionTip />);
    const link = screen.getByText(/Learn more/);
    expect(link).toBeInTheDocument();
    expect(link.tagName).toBe("A");
    expect(link.getAttribute("href")).toMatch(/^\/learn\//);
  });

  it("learn more link points to a valid learn path", () => {
    render(<NutritionTip />);
    const link = screen.getByText(/Learn more/);
    const href = link.getAttribute("href");
    const validPaths = [
      "/learn/reading-labels",
      "/learn/nova-groups",
      "/learn/unhealthiness-score",
      "/learn/nutri-score",
      "/learn/additives",
    ];
    expect(validPaths).toContain(href);
  });
});
