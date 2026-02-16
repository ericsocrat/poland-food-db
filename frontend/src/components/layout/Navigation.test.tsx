import { describe, expect, it, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import { Navigation } from "./Navigation";

// ─── Mocks ──────────────────────────────────────────────────────────────────

const mockPathname = vi.fn<() => string>().mockReturnValue("/app/search");
vi.mock("next/navigation", () => ({ usePathname: () => mockPathname() }));

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

describe("Navigation", () => {
  it("renders all 5 nav items", () => {
    render(<Navigation />);
    expect(screen.getByText("Search")).toBeInTheDocument();
    expect(screen.getByText("Categories")).toBeInTheDocument();
    expect(screen.getByText("Scan")).toBeInTheDocument();
    expect(screen.getByText("Lists")).toBeInTheDocument();
    expect(screen.getByText("Settings")).toBeInTheDocument();
  });

  it("has correct hrefs", () => {
    render(<Navigation />);
    expect(screen.getByLabelText("Search").closest("a")).toHaveAttribute(
      "href",
      "/app/search",
    );
    expect(screen.getByLabelText("Scan").closest("a")).toHaveAttribute(
      "href",
      "/app/scan",
    );
  });

  it("marks active item with aria-current=page", () => {
    mockPathname.mockReturnValue("/app/search");
    render(<Navigation />);
    expect(screen.getByLabelText("Search")).toHaveAttribute(
      "aria-current",
      "page",
    );
    expect(screen.getByLabelText("Categories")).not.toHaveAttribute(
      "aria-current",
    );
  });

  it("matches nested route as active", () => {
    mockPathname.mockReturnValue("/app/categories/chips");
    render(<Navigation />);
    expect(screen.getByLabelText("Categories")).toHaveAttribute(
      "aria-current",
      "page",
    );
  });

  it("no item active for unmatched path", () => {
    mockPathname.mockReturnValue("/onboarding");
    render(<Navigation />);
    const links = screen.getAllByRole("link");
    for (const link of links) {
      expect(link).not.toHaveAttribute("aria-current");
    }
  });

  it("renders the nav landmark", () => {
    render(<Navigation />);
    expect(
      screen.getByRole("navigation", { name: "Main navigation" }),
    ).toBeInTheDocument();
  });
});
