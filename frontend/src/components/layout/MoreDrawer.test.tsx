import { describe, expect, it, vi } from "vitest";
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

  beforeEach(() => onClose.mockClear());

  it("renders nothing when closed", () => {
    const { container } = render(
      <MoreDrawer open={false} onClose={onClose} />,
    );
    expect(container.innerHTML).toBe("");
  });

  it("renders all 5 drawer nav items when open", () => {
    render(<MoreDrawer open={true} onClose={onClose} />);
    expect(screen.getByText("Compare")).toBeInTheDocument();
    expect(screen.getByText("Categories")).toBeInTheDocument();
    expect(screen.getByText("Watchlist")).toBeInTheDocument();
    expect(screen.getByText("Settings")).toBeInTheDocument();
    expect(screen.getByText("Admin")).toBeInTheDocument();
  });

  it("renders correct hrefs for drawer items", () => {
    render(<MoreDrawer open={true} onClose={onClose} />);
    expect(screen.getByText("Compare").closest("a")).toHaveAttribute(
      "href",
      "/app/compare",
    );
    expect(screen.getByText("Categories").closest("a")).toHaveAttribute(
      "href",
      "/app/categories",
    );
    expect(screen.getByText("Watchlist").closest("a")).toHaveAttribute(
      "href",
      "/app/watchlist",
    );
    expect(screen.getByText("Settings").closest("a")).toHaveAttribute(
      "href",
      "/app/settings",
    );
    expect(screen.getByText("Admin").closest("a")).toHaveAttribute(
      "href",
      "/app/admin/submissions",
    );
  });

  it("has a dialog role with aria-modal", () => {
    render(<MoreDrawer open={true} onClose={onClose} />);
    const dialog = screen.getByRole("dialog");
    expect(dialog).toHaveAttribute("aria-modal", "true");
  });

  it("has the More navigation landmark", () => {
    render(<MoreDrawer open={true} onClose={onClose} />);
    expect(
      screen.getByRole("navigation", { name: "More navigation" }),
    ).toBeInTheDocument();
  });

  it("calls onClose when close button is clicked", () => {
    render(<MoreDrawer open={true} onClose={onClose} />);
    const closeBtn = screen.getByLabelText("Close");
    fireEvent.click(closeBtn);
    expect(onClose).toHaveBeenCalledTimes(1);
  });

  it("calls onClose when backdrop is clicked", () => {
    render(<MoreDrawer open={true} onClose={onClose} />);
    // The backdrop is the outermost div with aria-hidden="true"
    const backdrop = screen.getByRole("dialog").parentElement!;
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

  it("renders More heading text", () => {
    render(<MoreDrawer open={true} onClose={onClose} />);
    // The drawer header shows "More"
    expect(screen.getByText("More")).toBeInTheDocument();
  });
});
