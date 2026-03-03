import { fireEvent, render, screen } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";
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

// ─── Primary inline links ───────────────────────────────────────────────────

describe("DesktopHeaderNav", () => {
  describe("primary inline links", () => {
    it("renders all primary nav items", () => {
      render(<DesktopHeaderNav />);
      expect(screen.getByText("Dashboard")).toBeInTheDocument();
      expect(screen.getByText("Search")).toBeInTheDocument();
      expect(screen.getByText("Scan")).toBeInTheDocument();
      expect(screen.getByText("Lists")).toBeInTheDocument();
      expect(screen.getByText("Watchlist")).toBeInTheDocument();
      expect(screen.getByText("Compare")).toBeInTheDocument();
      expect(screen.getByText("Categories")).toBeInTheDocument();
    });

    it("has correct hrefs for primary items", () => {
      render(<DesktopHeaderNav />);
      expect(screen.getByText("Dashboard").closest("a")).toHaveAttribute(
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

    it("marks active item with aria-current=page", () => {
      mockPathname.mockReturnValue("/app/search");
      render(<DesktopHeaderNav />);
      const searchLink = screen.getByText("Search").closest("a");
      expect(searchLink).toHaveAttribute("aria-current", "page");
    });

    it("does not mark inactive items", () => {
      mockPathname.mockReturnValue("/app/search");
      render(<DesktopHeaderNav />);
      const homeLink = screen.getByText("Dashboard").closest("a");
      expect(homeLink).not.toHaveAttribute("aria-current");
    });
  });

  // ─── More dropdown ──────────────────────────────────────────────────────

  describe("More dropdown", () => {
    it("renders a More button", () => {
      render(<DesktopHeaderNav />);
      expect(
        screen.getByRole("button", { name: /more/i }),
      ).toBeInTheDocument();
    });

    it("does not show dropdown items initially", () => {
      render(<DesktopHeaderNav />);
      expect(screen.queryByRole("menu")).not.toBeInTheDocument();
    });

    it("opens dropdown on click and shows secondary items", () => {
      render(<DesktopHeaderNav />);
      fireEvent.click(screen.getByRole("button", { name: /more/i }));

      expect(screen.getByRole("menu")).toBeInTheDocument();
      expect(screen.getByText("Achievements")).toBeInTheDocument();
      expect(screen.getByText("Recipes")).toBeInTheDocument();
      expect(screen.getByText("Image Search")).toBeInTheDocument();
      expect(screen.getByText("Learn")).toBeInTheDocument();
      expect(screen.getByText("Settings")).toBeInTheDocument();
      expect(screen.getByText("Admin")).toBeInTheDocument();
    });

    it("has correct hrefs for dropdown items", () => {
      render(<DesktopHeaderNav />);
      fireEvent.click(screen.getByRole("button", { name: /more/i }));

      expect(screen.getByText("Achievements").closest("a")).toHaveAttribute(
        "href",
        "/app/achievements",
      );
      expect(screen.getByText("Settings").closest("a")).toHaveAttribute(
        "href",
        "/app/settings",
      );
      expect(screen.getByText("Admin").closest("a")).toHaveAttribute(
        "href",
        "/app/admin/submissions",
      );
      expect(screen.getByText("Learn").closest("a")).toHaveAttribute(
        "href",
        "/learn",
      );
    });

    it("closes dropdown when an item is clicked", () => {
      render(<DesktopHeaderNav />);
      fireEvent.click(screen.getByRole("button", { name: /more/i }));
      expect(screen.getByRole("menu")).toBeInTheDocument();

      fireEvent.click(screen.getByText("Settings"));
      expect(screen.queryByRole("menu")).not.toBeInTheDocument();
    });

    it("marks More button active when a dropdown item route is active", () => {
      mockPathname.mockReturnValue("/app/achievements");
      render(<DesktopHeaderNav />);
      const moreButton = screen.getByRole("button", { name: /more/i });
      expect(moreButton.className).toContain("text-brand");
    });

    it("marks dropdown item active inside menu", () => {
      mockPathname.mockReturnValue("/app/settings");
      render(<DesktopHeaderNav />);
      fireEvent.click(screen.getByRole("button", { name: /more/i }));
      const settingsLink = screen.getByText("Settings").closest("a");
      expect(settingsLink).toHaveAttribute("aria-current", "page");
    });

    it("sets aria-expanded on More button", () => {
      render(<DesktopHeaderNav />);
      const btn = screen.getByRole("button", { name: /more/i });
      expect(btn).toHaveAttribute("aria-expanded", "false");

      fireEvent.click(btn);
      expect(btn).toHaveAttribute("aria-expanded", "true");
    });

    it("marks Admin as active on /app/admin paths", () => {
      mockPathname.mockReturnValue("/app/admin/metrics");
      render(<DesktopHeaderNav />);
      fireEvent.click(screen.getByRole("button", { name: /more/i }));
      const adminLink = screen.getByText("Admin").closest("a");
      expect(adminLink).toHaveAttribute("aria-current", "page");
    });
  });

  // ─── Responsive visibility ─────────────────────────────────────────────

  describe("responsive visibility", () => {
    it("renders header navigation landmark", () => {
      render(<DesktopHeaderNav />);
      expect(
        screen.getByRole("navigation", { name: "Header navigation" }),
      ).toBeInTheDocument();
    });

    it("has lg:flex and xl:hidden classes for responsive visibility", () => {
      render(<DesktopHeaderNav />);
      const nav = screen.getByRole("navigation", {
        name: "Header navigation",
      });
      expect(nav.className).toContain("hidden");
      expect(nav.className).toContain("lg:flex");
      expect(nav.className).toContain("xl:hidden");
    });
  });
});
