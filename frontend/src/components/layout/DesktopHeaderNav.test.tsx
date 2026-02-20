import { describe, expect, it, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import { DesktopHeaderNav } from "./DesktopHeaderNav";

// ─── Mocks ──────────────────────────────────────────────────────────────────

const mockPathname = vi.fn<() => string>().mockReturnValue("/app");
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

describe("DesktopHeaderNav", () => {
  it("renders all nav items including Watchlist", () => {
    render(<DesktopHeaderNav />);
    expect(screen.getByText("Home")).toBeInTheDocument();
    expect(screen.getByText("Search")).toBeInTheDocument();
    expect(screen.getByText("Scan")).toBeInTheDocument();
    expect(screen.getByText("Lists")).toBeInTheDocument();
    expect(screen.getByText("Watchlist")).toBeInTheDocument();
    expect(screen.getByText("Compare")).toBeInTheDocument();
    expect(screen.getByText("Categories")).toBeInTheDocument();
    expect(screen.getByText("Settings")).toBeInTheDocument();
  });

  it("renders the header navigation landmark", () => {
    render(<DesktopHeaderNav />);
    expect(
      screen.getByRole("navigation", { name: "Header navigation" }),
    ).toBeInTheDocument();
  });

  it("marks active item with aria-current=page", () => {
    mockPathname.mockReturnValue("/app/search");
    render(<DesktopHeaderNav />);
    const searchLink = screen.getByText("Search").closest("a");
    expect(searchLink).toHaveAttribute("aria-current", "page");
  });

  it("does not mark inactive items", () => {
    mockPathname.mockReturnValue("/app/search");
    render(<DesktopHeaderNav />);
    const homeLink = screen.getByText("Home").closest("a");
    expect(homeLink).not.toHaveAttribute("aria-current");
  });

  it("has correct hrefs", () => {
    render(<DesktopHeaderNav />);
    expect(screen.getByText("Home").closest("a")).toHaveAttribute(
      "href",
      "/app",
    );
    expect(screen.getByText("Search").closest("a")).toHaveAttribute(
      "href",
      "/app/search",
    );
    expect(screen.getByText("Compare").closest("a")).toHaveAttribute(
      "href",
      "/app/compare",
    );
  });

  it("nav has lg:flex and xl:hidden classes for responsive visibility", () => {
    render(<DesktopHeaderNav />);
    const nav = screen.getByRole("navigation", {
      name: "Header navigation",
    });
    expect(nav.className).toContain("hidden");
    expect(nav.className).toContain("lg:flex");
    expect(nav.className).toContain("xl:hidden");
  });
});
