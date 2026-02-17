import { describe, it, expect } from "vitest";
import { render, screen } from "@testing-library/react";
import { Badge } from "./Badge";

describe("Badge", () => {
  it("renders children", () => {
    render(<Badge>New</Badge>);
    expect(screen.getByText("New")).toBeTruthy();
  });

  it("applies neutral variant by default", () => {
    render(<Badge>Tag</Badge>);
    const badge = screen.getByText("Tag");
    expect(badge.className).toContain("bg-surface-muted");
  });

  it.each(["info", "success", "warning", "error"] as const)(
    "applies %s variant",
    (variant) => {
      render(<Badge variant={variant}>{variant}</Badge>);
      const badge = screen.getByText(variant);
      expect(badge.className).toContain(`bg-${variant}/10`);
      expect(badge.className).toContain(`text-${variant}`);
    },
  );

  it("renders dot indicator", () => {
    const { container } = render(<Badge dot>Status</Badge>);
    const dotEl = container.querySelector('[aria-hidden="true"]');
    expect(dotEl).toBeTruthy();
    expect(dotEl!.className).toContain("rounded-full");
  });

  it("applies size classes", () => {
    const { rerender } = render(<Badge size="sm">S</Badge>);
    expect(screen.getByText("S").className).toContain("text-xs");
    rerender(<Badge size="md">M</Badge>);
    expect(screen.getByText("M").className).toContain("text-sm");
  });

  it("merges custom className", () => {
    render(<Badge className="custom">Tag</Badge>);
    expect(screen.getByText("Tag").className).toContain("custom");
  });
});
