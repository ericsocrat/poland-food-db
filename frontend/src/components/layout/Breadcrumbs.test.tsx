import { render, screen } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";
import { Breadcrumbs } from "./Breadcrumbs";

// ─── Mocks ──────────────────────────────────────────────────────────────────

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

describe("Breadcrumbs", () => {
  it("renders nothing when items array is empty", () => {
    const { container } = render(<Breadcrumbs items={[]} />);
    expect(container.innerHTML).toBe("");
  });

  it("renders a nav landmark with Breadcrumb label", () => {
    render(
      <Breadcrumbs
        items={[
          { labelKey: "nav.home", href: "/app" },
          { label: "Current Page" },
        ]}
      />,
    );
    expect(
      screen.getByRole("navigation", { name: "Breadcrumb" }),
    ).toBeInTheDocument();
  });

  it("renders items in an ordered list", () => {
    render(
      <Breadcrumbs
        items={[
          { labelKey: "nav.home", href: "/app" },
          { labelKey: "nav.search", href: "/app/search" },
          { label: "Chips" },
        ]}
      />,
    );
    const list = screen.getByRole("list");
    const items = screen.getAllByRole("listitem");
    expect(list).toBeInTheDocument();
    expect(items).toHaveLength(3);
  });

  it("renders links for non-last items with href", () => {
    render(
      <Breadcrumbs
        items={[
          { labelKey: "nav.home", href: "/app" },
          { labelKey: "nav.search", href: "/app/search" },
          { label: "Product X" },
        ]}
      />,
    );
    // Desktop breadcrumb links (2) + mobile compact parent link (1)
    const links = screen.getAllByRole("link");
    expect(links).toHaveLength(3);
    // Mobile compact link points to parent (Search)
    expect(links[0]).toHaveAttribute("href", "/app/search");
    // Desktop breadcrumb links
    expect(links[1]).toHaveAttribute("href", "/app");
    expect(links[2]).toHaveAttribute("href", "/app/search");
  });

  it("renders the last item as text with aria-current=page", () => {
    render(
      <Breadcrumbs
        items={[
          { labelKey: "nav.home", href: "/app" },
          { label: "Current Page" },
        ]}
      />,
    );
    const current = screen.getByText("Current Page");
    expect(current).toHaveAttribute("aria-current", "page");
    expect(current.tagName).toBe("SPAN");
  });

  it("does not render aria-current on non-last items", () => {
    render(
      <Breadcrumbs
        items={[
          { labelKey: "nav.home", href: "/app" },
          { labelKey: "nav.search", href: "/app/search" },
          { label: "Detail" },
        ]}
      />,
    );
    const homeLink = screen.getAllByRole("link")[0];
    expect(homeLink).not.toHaveAttribute("aria-current");
  });

  it("renders labelKey items using translated text", () => {
    render(
      <Breadcrumbs
        items={[
          { labelKey: "nav.home", href: "/app" },
          { labelKey: "nav.search" },
        ]}
      />,
    );
    // "Dashboard" appears in both mobile compact link and desktop trail
    expect(screen.getAllByText("Dashboard").length).toBeGreaterThanOrEqual(1);
    expect(screen.getByText("Search")).toBeInTheDocument();
  });

  it("renders raw label items as-is", () => {
    render(
      <Breadcrumbs
        items={[
          { labelKey: "nav.home", href: "/app" },
          { label: "My Custom List" },
        ]}
      />,
    );
    expect(screen.getByText("My Custom List")).toBeInTheDocument();
  });

  it("renders separator between items", () => {
    render(
      <Breadcrumbs
        items={[
          { labelKey: "nav.home", href: "/app" },
          { labelKey: "nav.search", href: "/app/search" },
          { label: "Detail" },
        ]}
      />,
    );
    const separators = screen.getAllByText("/");
    expect(separators).toHaveLength(2);
    // Separators should be hidden from screen readers
    for (const sep of separators) {
      expect(sep).toHaveAttribute("aria-hidden", "true");
    }
  });

  it("truncates long labels", () => {
    render(
      <Breadcrumbs
        items={[
          { labelKey: "nav.home", href: "/app" },
          {
            label:
              "A very long product name that should be truncated in the UI",
          },
        ]}
      />,
    );
    const current = screen.getByText(
      "A very long product name that should be truncated in the UI",
    );
    expect(current).toHaveAttribute(
      "title",
      "A very long product name that should be truncated in the UI",
    );
  });

  it("hides desktop breadcrumb trail on mobile via hidden md:flex", () => {
    render(
      <Breadcrumbs
        items={[
          { labelKey: "nav.home", href: "/app" },
          { label: "Current" },
        ]}
      />,
    );
    const ol = screen.getByRole("list");
    expect(ol.className).toContain("hidden");
    expect(ol.className).toContain("md:flex");
  });

  // ─── Mobile compact breadcrumb ──────────────────────────────────────────

  it("renders compact parent link on mobile when parent has href", () => {
    render(
      <Breadcrumbs
        items={[
          { labelKey: "nav.home", href: "/app" },
          { labelKey: "nav.lists", href: "/app/lists" },
          { label: "My Favorites" },
        ]}
      />,
    );
    // Parent is "Lists" (second-to-last)
    const mobileLink = screen.getAllByRole("link").find(
      (el) => el.className.includes("md:hidden"),
    );
    expect(mobileLink).toBeDefined();
    expect(mobileLink).toHaveAttribute("href", "/app/lists");
    expect(mobileLink).toHaveTextContent("Lists");
  });

  it("mobile compact link has min-h-[44px] for touch target", () => {
    render(
      <Breadcrumbs
        items={[
          { labelKey: "nav.home", href: "/app" },
          { labelKey: "nav.lists", href: "/app/lists" },
          { label: "My Favorites" },
        ]}
      />,
    );
    const mobileLink = screen.getAllByRole("link").find(
      (el) => el.className.includes("md:hidden"),
    );
    expect(mobileLink?.className).toContain("min-h-[44px]");
  });

  it("does not render mobile compact link for single-item breadcrumb", () => {
    render(
      <Breadcrumbs
        items={[{ label: "Dashboard" }]}
      />,
    );
    const nav = screen.getByRole("navigation", { name: "Breadcrumb" });
    const mobileLink = nav.querySelector("a.md\\:hidden");
    expect(mobileLink).toBeNull();
  });
});
