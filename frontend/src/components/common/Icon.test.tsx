import { describe, it, expect } from "vitest";
import { render, screen } from "@testing-library/react";
import { Icon } from "./Icon";
import { Search, AlertTriangle } from "lucide-react";

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("Icon", () => {
  // ─── Sizing ───────────────────────────────────────────────────────────────

  it("renders at default size (lg = 24px)", () => {
    const { container } = render(<Icon icon={Search} />);
    const svg = container.querySelector("svg");
    expect(svg).toBeInTheDocument();
    expect(svg).toHaveAttribute("width", "24");
    expect(svg).toHaveAttribute("height", "24");
  });

  it("renders at sm size (16px)", () => {
    const { container } = render(<Icon icon={Search} size="sm" />);
    const svg = container.querySelector("svg");
    expect(svg).toHaveAttribute("width", "16");
    expect(svg).toHaveAttribute("height", "16");
  });

  it("renders at xl size (32px)", () => {
    const { container } = render(<Icon icon={Search} size="xl" />);
    const svg = container.querySelector("svg");
    expect(svg).toHaveAttribute("width", "32");
    expect(svg).toHaveAttribute("height", "32");
  });

  // ─── Accessibility ────────────────────────────────────────────────────────

  it("marks decorative icons as aria-hidden", () => {
    const { container } = render(<Icon icon={Search} />);
    const svg = container.querySelector("svg");
    expect(svg).toHaveAttribute("aria-hidden", "true");
    expect(svg).not.toHaveAttribute("role");
    expect(svg).not.toHaveAttribute("aria-label");
  });

  it("marks informational icons with aria-label and role=img", () => {
    render(<Icon icon={AlertTriangle} label="Warning" />);
    const svg = screen.getByRole("img", { name: "Warning" });
    expect(svg).toBeInTheDocument();
    expect(svg).toHaveAttribute("aria-label", "Warning");
    expect(svg).not.toHaveAttribute("aria-hidden");
  });

  // ─── Class passthrough ────────────────────────────────────────────────────

  it("forwards className to the SVG element", () => {
    const { container } = render(
      <Icon icon={Search} className="text-red-500" />,
    );
    const svg = container.querySelector("svg");
    expect(svg).toHaveClass("text-red-500");
  });
});
