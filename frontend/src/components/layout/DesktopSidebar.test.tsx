import { describe, expect, it, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import { DesktopSidebar } from "./DesktopSidebar";

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

describe("DesktopSidebar", () => {
  it("renders all primary nav items", () => {
    render(<DesktopSidebar />);
    expect(screen.getByText("Home")).toBeInTheDocument();
    expect(screen.getByText("Search")).toBeInTheDocument();
    expect(screen.getByText("Scan")).toBeInTheDocument();
    expect(screen.getByText("Lists")).toBeInTheDocument();
    expect(screen.getByText("Compare")).toBeInTheDocument();
    expect(screen.getByText("Categories")).toBeInTheDocument();
  });

  it("renders settings in secondary section", () => {
    render(<DesktopSidebar />);
    expect(screen.getByText("Settings")).toBeInTheDocument();
  });

  it("renders the sidebar navigation landmark", () => {
    render(<DesktopSidebar />);
    expect(
      screen.getByRole("navigation", { name: "Sidebar navigation" }),
    ).toBeInTheDocument();
  });

  it("renders the app logo link", () => {
    render(<DesktopSidebar />);
    const logoLink = screen.getAllByText("🥗 FoodDB")[0];
    expect(logoLink.closest("a")).toHaveAttribute("href", "/app");
  });

  it("marks Home as active on /app", () => {
    mockPathname.mockReturnValue("/app");
    render(<DesktopSidebar />);
    const homeLink = screen.getByText("Home").closest("a");
    expect(homeLink).toHaveAttribute("aria-current", "page");
  });

  it("marks Search as active on /app/search", () => {
    mockPathname.mockReturnValue("/app/search");
    render(<DesktopSidebar />);
    const searchLink = screen.getByText("Search").closest("a");
    expect(searchLink).toHaveAttribute("aria-current", "page");
  });

  it("marks Search as active on nested route /app/search/saved", () => {
    mockPathname.mockReturnValue("/app/search/saved");
    render(<DesktopSidebar />);
    const searchLink = screen.getByText("Search").closest("a");
    expect(searchLink).toHaveAttribute("aria-current", "page");
  });

  it("does not mark Home active on /app/search", () => {
    mockPathname.mockReturnValue("/app/search");
    render(<DesktopSidebar />);
    const homeLink = screen.getByText("Home").closest("a");
    expect(homeLink).not.toHaveAttribute("aria-current");
  });

  it("has correct hrefs for all primary items", () => {
    render(<DesktopSidebar />);
    const expectedHrefs = [
      { label: "Home", href: "/app" },
      { label: "Search", href: "/app/search" },
      { label: "Scan", href: "/app/scan" },
      { label: "Lists", href: "/app/lists" },
      { label: "Compare", href: "/app/compare" },
      { label: "Categories", href: "/app/categories" },
      { label: "Settings", href: "/app/settings" },
    ];

    for (const { label, href } of expectedHrefs) {
      expect(screen.getByText(label).closest("a")).toHaveAttribute(
        "href",
        href,
      );
    }
  });

  it("sidebar has xl:flex class for responsive visibility", () => {
    render(<DesktopSidebar />);
    const nav = screen.getByRole("navigation", {
      name: "Sidebar navigation",
    });
    expect(nav.className).toContain("hidden");
    expect(nav.className).toContain("xl:flex");
  });
});
