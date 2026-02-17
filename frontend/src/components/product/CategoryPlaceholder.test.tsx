import { describe, it, expect } from "vitest";
import { render, screen } from "@testing-library/react";
import { CategoryPlaceholder } from "./CategoryPlaceholder";

describe("CategoryPlaceholder", () => {
  it("renders the category icon", () => {
    render(<CategoryPlaceholder icon="🍕" productName="Test Pizza" />);
    expect(screen.getByText("🍕")).toBeTruthy();
  });

  it("has correct aria-label", () => {
    const { container } = render(
      <CategoryPlaceholder icon="🧀" productName="Cheese Snack" />,
    );
    const el = container.firstElementChild!;
    expect(el.getAttribute("aria-label")).toBe(
      "Cheese Snack — no image available",
    );
  });

  it("applies sm size class", () => {
    const { container } = render(
      <CategoryPlaceholder icon="📦" productName="Box" size="sm" />,
    );
    const el = container.firstElementChild!;
    expect(el.className).toContain("h-10");
    expect(el.className).toContain("w-10");
  });

  it("applies lg size class", () => {
    const { container } = render(
      <CategoryPlaceholder icon="📦" productName="Box" size="lg" />,
    );
    const el = container.firstElementChild!;
    expect(el.className).toContain("aspect-square");
    expect(el.className).toContain("w-full");
  });

  it("defaults to md size", () => {
    const { container } = render(
      <CategoryPlaceholder icon="📦" productName="Box" />,
    );
    const el = container.firstElementChild!;
    expect(el.className).toContain("h-16");
    expect(el.className).toContain("w-16");
  });
});
