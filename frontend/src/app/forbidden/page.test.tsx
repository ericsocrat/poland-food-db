import { render, screen } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";
import ForbiddenPage from "./page";

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

describe("ForbiddenPage (403)", () => {
  it("renders 403 heading", () => {
    render(<ForbiddenPage />);
    expect(screen.getByText("403")).toBeInTheDocument();
  });

  it("renders access denied title", () => {
    render(<ForbiddenPage />);
    expect(screen.getByText("Access denied")).toBeInTheDocument();
  });

  it("renders friendly message", () => {
    render(<ForbiddenPage />);
    expect(
      screen.getByText(/don't have permission/i),
    ).toBeInTheDocument();
  });

  it("renders Go to Dashboard link pointing to /app", () => {
    render(<ForbiddenPage />);
    const link = screen.getByText("Go to Dashboard");
    expect(link.closest("a")).toHaveAttribute("href", "/app");
  });

  it("renders ShieldOff icon", () => {
    const { container } = render(<ForbiddenPage />);
    const svg = container.querySelector("svg");
    expect(svg).toBeTruthy();
    expect(svg?.getAttribute("aria-hidden")).toBe("true");
  });

  it("renders Browse Categories link pointing to /app/categories", () => {
    render(<ForbiddenPage />);
    const link = screen.getByText("Browse Categories");
    expect(link.closest("a")).toHaveAttribute("href", "/app/categories");
  });

  it("renders Search Products link pointing to /app/search", () => {
    render(<ForbiddenPage />);
    const link = screen.getByText("Search Products");
    expect(link.closest("a")).toHaveAttribute("href", "/app/search");
  });
});
