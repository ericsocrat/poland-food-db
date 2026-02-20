import { describe, expect, it, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import NotFound from "./not-found";

vi.mock("next/link", () => ({
  default: ({
    href,
    children,
    ...rest
  }: {
    href: string;
    children: React.ReactNode;
  }) => (
    <a href={href} {...rest}>
      {children}
    </a>
  ),
}));

describe("NotFound (404)", () => {
  it("renders 404 heading", () => {
    render(<NotFound />);
    expect(screen.getByText("404")).toBeInTheDocument();
  });

  it("renders explanation text", () => {
    render(<NotFound />);
    expect(screen.getByText(/page not found/i)).toBeInTheDocument();
  });

  it("renders Go home link", () => {
    render(<NotFound />);
    const link = screen.getByText("Go home");
    expect(link.closest("a")).toHaveAttribute("href", "/");
  });

  it("renders FileQuestion icon", () => {
    const { container } = render(<NotFound />);
    const svg = container.querySelector("svg");
    expect(svg).toBeTruthy();
    expect(svg?.getAttribute("aria-hidden")).toBe("true");
  });
});
