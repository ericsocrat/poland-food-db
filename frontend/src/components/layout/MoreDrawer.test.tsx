import { describe, expect, it, vi, beforeEach } from "vitest";
import { render, screen, fireEvent } from "@testing-library/react";
import { MoreDrawer } from "./MoreDrawer";

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

describe("MoreDrawer", () => {
  const onClose = vi.fn();

  beforeEach(() => {
    onClose.mockClear();
    mockPathname.mockReturnValue("/app");
  });

  // ─── Closed state ──────────────────────────────────────────────────────

  it("renders nothing when closed", () => {
    const { container } = render(<MoreDrawer open={false} onClose={onClose} />);
    expect(container.innerHTML).toBe("");
  });

  // ─── All 9 nav items ──────────────────────────────────────────────────

  it("renders all 9 drawer nav items when open", () => {
    render(<MoreDrawer open={true} onClose={onClose} />);
    expect(screen.getByText("Categories")).toBeInTheDocument();
    expect(screen.getByText("Recipes")).toBeInTheDocument();
    expect(screen.getByText("Image Search")).toBeInTheDocument();
    expect(screen.getByText("Compare")).toBeInTheDocument();
    expect(screen.getByText("Watchlist")).toBeInTheDocument();
    expect(screen.getByText("Achievements")).toBeInTheDocument();
    expect(screen.getByText("Learn")).toBeInTheDocument();
    expect(screen.getByText("Settings")).toBeInTheDocument();
    // Admin appears as both a section label and nav item text
    const adminElements = screen.getAllByText("Admin");
    expect(adminElements.length).toBeGreaterThanOrEqual(1);
  });

  // ─── Section headers ──────────────────────────────────────────────────

  it("renders section headers", () => {
    render(<MoreDrawer open={true} onClose={onClose} />);
    expect(screen.getByText("Browse")).toBeInTheDocument();
    expect(screen.getByText("Your Stuff")).toBeInTheDocument();
    expect(screen.getByText("App")).toBeInTheDocument();
  });

  // ─── Correct hrefs ────────────────────────────────────────────────────

  it("renders correct hrefs for all drawer items", () => {
    render(<MoreDrawer open={true} onClose={onClose} />);
    const linkMap: Record<string, string> = {
      Categories: "/app/categories",
      Recipes: "/app/recipes",
      "Image Search": "/app/image-search",
      Compare: "/app/compare",
      Watchlist: "/app/watchlist",
      Achievements: "/app/achievements",
      Learn: "/learn",
      Settings: "/app/settings",
    };
    for (const [label, href] of Object.entries(linkMap)) {
      expect(screen.getByText(label).closest("a")).toHaveAttribute(
        "href",
        href,
      );
    }
    // Admin link
    const adminLink = screen.getByRole("link", { name: /admin/i });
    expect(adminLink).toHaveAttribute("href", "/app/admin/submissions");
  });

  // ─── Dialog element ───────────────────────────────────────────────────

  it("renders a dialog element", () => {
    render(<MoreDrawer open={true} onClose={onClose} />);
    const dialog = screen.getByRole("dialog");
    expect(dialog).toBeInTheDocument();
    expect(dialog.tagName).toBe("DIALOG");
  });

  // ─── Drag handle ──────────────────────────────────────────────────────

  it("renders a drag handle indicator", () => {
    render(<MoreDrawer open={true} onClose={onClose} />);
    const dialog = screen.getByRole("dialog");
    const handle = dialog.querySelector(".rounded-full.bg-border");
    expect(handle).toBeInTheDocument();
  });

  // ─── A11y landmark ────────────────────────────────────────────────────

  it("has the More navigation landmark", () => {
    render(<MoreDrawer open={true} onClose={onClose} />);
    expect(
      screen.getByRole("navigation", { name: "More navigation" }),
    ).toBeInTheDocument();
  });

  // ─── Close interactions ───────────────────────────────────────────────

  it("calls onClose when close button is clicked", () => {
    render(<MoreDrawer open={true} onClose={onClose} />);
    const closeBtn = screen.getByLabelText("Close");
    fireEvent.click(closeBtn);
    expect(onClose).toHaveBeenCalledTimes(1);
  });

  it("calls onClose when backdrop is clicked", () => {
    render(<MoreDrawer open={true} onClose={onClose} />);
    const backdrop = screen.getByLabelText("Close modal / overlay");
    fireEvent.click(backdrop);
    expect(onClose).toHaveBeenCalledTimes(1);
  });

  it("calls onClose on Escape key", () => {
    render(<MoreDrawer open={true} onClose={onClose} />);
    fireEvent.keyDown(document, { key: "Escape" });
    expect(onClose).toHaveBeenCalledTimes(1);
  });

  it("calls onClose when a nav link is clicked", () => {
    render(<MoreDrawer open={true} onClose={onClose} />);
    fireEvent.click(screen.getByText("Compare"));
    expect(onClose).toHaveBeenCalledTimes(1);
  });

  // ─── Active route ─────────────────────────────────────────────────────

  it("marks active route with aria-current=page", () => {
    mockPathname.mockReturnValue("/app/settings");
    render(<MoreDrawer open={true} onClose={onClose} />);
    const settingsLink = screen.getByText("Settings").closest("a");
    expect(settingsLink).toHaveAttribute("aria-current", "page");
  });

  it("does not mark inactive items with aria-current", () => {
    mockPathname.mockReturnValue("/app/settings");
    render(<MoreDrawer open={true} onClose={onClose} />);
    const compareLink = screen.getByText("Compare").closest("a");
    expect(compareLink).not.toHaveAttribute("aria-current");
  });

  // ─── Heading ──────────────────────────────────────────────────────────

  it("renders More heading text", () => {
    render(<MoreDrawer open={true} onClose={onClose} />);
    expect(screen.getByText("More")).toBeInTheDocument();
  });

  // ─── 48px touch targets ───────────────────────────────────────────────

  it("nav items have min-h-[48px] for touch targets", () => {
    render(<MoreDrawer open={true} onClose={onClose} />);
    const categoriesLink = screen.getByText("Categories").closest("a");
    expect(categoriesLink?.className).toContain("min-h-[48px]");
  });
});
