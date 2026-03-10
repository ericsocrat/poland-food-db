import { render, screen } from "@testing-library/react";
import { beforeEach, describe, expect, it, vi } from "vitest";
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

const mockIsAdmin = vi.fn<() => boolean>().mockReturnValue(false);
vi.mock("@/stores/admin-store", () => ({
  useAdminStore: (selector: (s: { isAdmin: boolean }) => boolean) =>
    selector({ isAdmin: mockIsAdmin() }),
}));

describe("DesktopSidebar", () => {
  beforeEach(() => {
    mockPathname.mockReturnValue("/app");
    mockIsAdmin.mockReturnValue(false);
  });

  it("renders all primary nav items", () => {
    render(<DesktopSidebar />);
    expect(screen.getByText("Dashboard")).toBeInTheDocument();
    expect(screen.getByText("Search")).toBeInTheDocument();
    expect(screen.getByText("Scan")).toBeInTheDocument();
    expect(screen.getByText("Lists")).toBeInTheDocument();
    expect(screen.getByText("Compare")).toBeInTheDocument();
    expect(screen.getByText("Categories")).toBeInTheDocument();
    expect(screen.getByText("Achievements")).toBeInTheDocument();
  });

  it("renders settings in secondary section", () => {
    render(<DesktopSidebar />);
    expect(screen.getByText("Settings")).toBeInTheDocument();
  });

  // ─── Admin section ─────────────────────────────────────────────────────────

  it("hides admin section when user is not admin", () => {
    mockIsAdmin.mockReturnValue(false);
    render(<DesktopSidebar />);
    expect(screen.queryByText("Submissions")).not.toBeInTheDocument();
    expect(screen.queryByText("Metrics")).not.toBeInTheDocument();
    expect(screen.queryByText("Monitoring")).not.toBeInTheDocument();
  });

  it("renders admin section with heading and three sub-links when admin", () => {
    mockIsAdmin.mockReturnValue(true);
    render(<DesktopSidebar />);
    expect(screen.getByText("Admin")).toBeInTheDocument();
    expect(screen.getByText("Submissions")).toBeInTheDocument();
    expect(screen.getByText("Metrics")).toBeInTheDocument();
    expect(screen.getByText("Monitoring")).toBeInTheDocument();
  });

  it("has correct hrefs for admin sub-links", () => {
    mockIsAdmin.mockReturnValue(true);
    render(<DesktopSidebar />);
    expect(screen.getByText("Submissions").closest("a")).toHaveAttribute(
      "href",
      "/app/admin/submissions",
    );
    expect(screen.getByText("Metrics").closest("a")).toHaveAttribute(
      "href",
      "/app/admin/metrics",
    );
    expect(screen.getByText("Monitoring").closest("a")).toHaveAttribute(
      "href",
      "/app/admin/monitoring",
    );
  });

  it("marks admin sub-link as active on /app/admin/submissions", () => {
    mockIsAdmin.mockReturnValue(true);
    mockPathname.mockReturnValue("/app/admin/submissions");
    render(<DesktopSidebar />);
    const submissionsLink = screen.getByText("Submissions").closest("a");
    expect(submissionsLink).toHaveAttribute("aria-current", "page");
  });

  it("does not mark admin sub-links as active on non-admin route", () => {
    mockIsAdmin.mockReturnValue(true);
    mockPathname.mockReturnValue("/app/search");
    render(<DesktopSidebar />);
    const submissionsLink = screen.getByText("Submissions").closest("a");
    expect(submissionsLink).not.toHaveAttribute("aria-current");
  });

  it("renders the sidebar navigation landmark", () => {
    render(<DesktopSidebar />);
    expect(
      screen.getByRole("navigation", { name: "Sidebar navigation" }),
    ).toBeInTheDocument();
  });

  it("renders the app logo link", () => {
    render(<DesktopSidebar />);
    const logoImg = screen.getByAltText("TryVit");
    expect(logoImg.closest("a")).toHaveAttribute("href", "/app");
  });

  it("marks Dashboard as active on /app", () => {
    mockPathname.mockReturnValue("/app");
    render(<DesktopSidebar />);
    const homeLink = screen.getByText("Dashboard").closest("a");
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

  it("does not mark Dashboard active on /app/search", () => {
    mockPathname.mockReturnValue("/app/search");
    render(<DesktopSidebar />);
    const homeLink = screen.getByText("Dashboard").closest("a");
    expect(homeLink).not.toHaveAttribute("aria-current");
  });

  it("has correct hrefs for all primary items", () => {
    render(<DesktopSidebar />);
    const expectedHrefs = [
      { label: "Dashboard", href: "/app" },
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
