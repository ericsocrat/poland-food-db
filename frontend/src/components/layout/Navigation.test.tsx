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

const mockUseLists = vi.fn().mockReturnValue({ data: undefined });
vi.mock("@/hooks/use-lists", () => ({
  useLists: () => mockUseLists(),
}));

describe("Navigation", () => {
  it("renders all 5 nav items", () => {
    render(<Navigation />);
    expect(screen.getByText("Home")).toBeInTheDocument();
    expect(screen.getByText("Search")).toBeInTheDocument();
    expect(screen.getByText("Scan")).toBeInTheDocument();
    expect(screen.getByText("Lists")).toBeInTheDocument();
    expect(screen.getByText("Settings")).toBeInTheDocument();
  });

  it("has correct hrefs", () => {
    render(<Navigation />);
    expect(screen.getByLabelText("Home").closest("a")).toHaveAttribute(
      "href",
      "/app",
    );
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
    expect(screen.getByLabelText("Home")).not.toHaveAttribute("aria-current");
  });

  it("matches nested route as active", () => {
    mockPathname.mockReturnValue("/app/search/results");
    render(<Navigation />);
    expect(screen.getByLabelText("Search")).toHaveAttribute(
      "aria-current",
      "page",
    );
  });

  it("marks Home active only on exact /app path", () => {
    mockPathname.mockReturnValue("/app");
    render(<Navigation />);
    expect(screen.getByLabelText("Home")).toHaveAttribute(
      "aria-current",
      "page",
    );
  });

  it("does not mark Home active for nested paths", () => {
    mockPathname.mockReturnValue("/app/search");
    render(<Navigation />);
    expect(screen.getByLabelText("Home")).not.toHaveAttribute("aria-current");
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

  it("is hidden on desktop (lg+ breakpoint)", () => {
    render(<Navigation />);
    const nav = screen.getByRole("navigation", { name: "Main navigation" });
    expect(nav.className).toContain("lg:hidden");
  });

  // ── Badge counts (§4.6) ──────────────────────────────────────────────

  it("shows badge count on Lists when user has lists", () => {
    mockUseLists.mockReturnValue({
      data: [
        { list_id: "1", name: "Favorites" },
        { list_id: "2", name: "Avoid" },
        { list_id: "3", name: "Keto" },
      ],
    });
    render(<Navigation />);
    const badge = screen.getByTestId("nav-badge-lists");
    expect(badge).toHaveTextContent("3");
  });

  it("hides badge on Lists when user has no lists", () => {
    mockUseLists.mockReturnValue({ data: [] });
    render(<Navigation />);
    expect(screen.queryByTestId("nav-badge-lists")).not.toBeInTheDocument();
  });

  it("hides badge when lists data is undefined (loading)", () => {
    mockUseLists.mockReturnValue({ data: undefined });
    render(<Navigation />);
    expect(screen.queryByTestId("nav-badge-lists")).not.toBeInTheDocument();
  });

  it("caps badge display at 99+", () => {
    const manyLists = Array.from({ length: 150 }, (_, i) => ({
      list_id: String(i),
      name: `List ${i}`,
    }));
    mockUseLists.mockReturnValue({ data: manyLists });
    render(<Navigation />);
    const badge = screen.getByTestId("nav-badge-lists");
    expect(badge).toHaveTextContent("99+");
  });
});
