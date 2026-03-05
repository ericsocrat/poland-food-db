import { render, screen } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";
import { SettingsNav } from "./SettingsNav";

// ─── Mocks ──────────────────────────────────────────────────────────────────

let mockPathname = "/app/settings";
vi.mock("next/navigation", () => ({
  usePathname: () => mockPathname,
}));

vi.mock("next/link", () => ({
  default: ({
    href,
    children,
    ...rest
  }: {
    href: string;
    children: React.ReactNode;
    className?: string;
    "aria-current"?: string;
  }) => (
    <a href={href} {...rest}>
      {children}
    </a>
  ),
}));

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("SettingsNav", () => {
  it("renders 4 navigation tabs", () => {
    render(<SettingsNav />);
    const links = screen.getAllByRole("link");
    expect(links).toHaveLength(4);
  });

  it("links to correct settings routes", () => {
    render(<SettingsNav />);
    const links = screen.getAllByRole("link");
    const hrefs = links.map((l) => l.getAttribute("href"));
    expect(hrefs).toContain("/app/settings");
    expect(hrefs).toContain("/app/settings/nutrition");
    expect(hrefs).toContain("/app/settings/privacy");
    expect(hrefs).toContain("/app/settings/account");
  });

  it("marks Profile tab as active when on /app/settings", () => {
    mockPathname = "/app/settings";
    render(<SettingsNav />);
    const profileLink = screen
      .getAllByRole("link")
      .find((l) => l.getAttribute("href") === "/app/settings");
    expect(profileLink).toHaveAttribute("aria-current", "page");
  });

  it("marks Nutrition tab as active on /app/settings/nutrition", () => {
    mockPathname = "/app/settings/nutrition";
    render(<SettingsNav />);
    const nutritionLink = screen
      .getAllByRole("link")
      .find((l) => l.getAttribute("href") === "/app/settings/nutrition");
    expect(nutritionLink).toHaveAttribute("aria-current", "page");
  });

  it("Profile tab is not active on sub-routes", () => {
    mockPathname = "/app/settings/privacy";
    render(<SettingsNav />);
    const profileLink = screen
      .getAllByRole("link")
      .find((l) => l.getAttribute("href") === "/app/settings");
    expect(profileLink).not.toHaveAttribute("aria-current");
  });

  it("has nav landmark with accessible label", () => {
    render(<SettingsNav />);
    expect(screen.getByRole("navigation")).toHaveAttribute(
      "aria-label",
      "Settings sections",
    );
  });
});
