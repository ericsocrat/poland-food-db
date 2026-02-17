import { describe, it, expect } from "vitest";
import { render, screen } from "@testing-library/react";
import { Card } from "./Card";

describe("Card", () => {
  it("renders children", () => {
    render(<Card>Card content</Card>);
    expect(screen.getByText("Card content")).toBeTruthy();
  });

  it("applies default variant classes", () => {
    render(<Card>Default</Card>);
    const card = screen.getByText("Default").closest("div")!;
    expect(card.className).toContain("rounded-xl");
    expect(card.className).toContain("border");
    expect(card.className).toContain("bg-surface");
    expect(card.className).toContain("shadow-sm");
  });

  it("applies elevated variant", () => {
    render(<Card variant="elevated">Elevated</Card>);
    const card = screen.getByText("Elevated").closest("div")!;
    expect(card.className).toContain("shadow-md");
    expect(card.className).not.toContain("border");
  });

  it("applies outlined variant", () => {
    render(<Card variant="outlined">Outlined</Card>);
    const card = screen.getByText("Outlined").closest("div")!;
    expect(card.className).toContain("border-2");
    expect(card.className).toContain("bg-transparent");
  });

  it("applies padding presets", () => {
    const { rerender } = render(<Card padding="none">None</Card>);
    expect(screen.getByText("None").closest("div")!.className).not.toContain(
      "p-",
    );
    rerender(<Card padding="sm">Small</Card>);
    expect(screen.getByText("Small").closest("div")!.className).toContain(
      "p-3",
    );
    rerender(<Card padding="lg">Large</Card>);
    expect(screen.getByText("Large").closest("div")!.className).toContain(
      "p-6",
    );
  });

  it("renders as semantic element via as prop", () => {
    render(<Card as="article">Article card</Card>);
    const el = screen.getByText("Article card");
    expect(el.tagName).toBe("ARTICLE");
  });

  it("renders as section element", () => {
    render(<Card as="section">Section card</Card>);
    const el = screen.getByText("Section card");
    expect(el.tagName).toBe("SECTION");
  });

  it("merges custom className", () => {
    render(<Card className="custom-class">Custom</Card>);
    const card = screen.getByText("Custom").closest("div")!;
    expect(card.className).toContain("custom-class");
  });
});
