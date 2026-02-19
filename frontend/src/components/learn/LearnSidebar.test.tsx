import { describe, it, expect, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import { LearnSidebar, TOPICS } from "./LearnSidebar";

// ─── Mocks ──────────────────────────────────────────────────────────────────

let mockPathname = "/learn";

vi.mock("next/navigation", () => ({
  usePathname: () => mockPathname,
}));

vi.mock("@/lib/i18n", () => ({
  useTranslation: () => ({
    t: (key: string) => key,
  }),
}));

describe("LearnSidebar", () => {
  it("renders navigation landmark", () => {
    render(<LearnSidebar />);
    expect(
      screen.getByRole("navigation", { name: "learn.sidebarLabel" }),
    ).toBeInTheDocument();
  });

  it("renders hub link", () => {
    render(<LearnSidebar />);
    const hubLink = screen.getByRole("link", { name: /learn\.hubTitle/ });
    expect(hubLink).toHaveAttribute("href", "/learn");
  });

  it("renders all topic links", () => {
    render(<LearnSidebar />);
    for (const topic of TOPICS) {
      const link = screen.getByRole("link", {
        name: new RegExp(topic.labelKey),
      });
      expect(link).toHaveAttribute("href", `/learn/${topic.slug}`);
    }
  });

  it("highlights active hub link", () => {
    mockPathname = "/learn";
    render(<LearnSidebar />);
    const hubLink = screen.getByRole("link", { name: /learn\.hubTitle/ });
    expect(hubLink.className).toContain("bg-brand-50");
  });

  it("highlights active topic link", () => {
    mockPathname = "/learn/additives";
    render(<LearnSidebar />);
    const link = screen.getByRole("link", { name: /learn\.additives\.title/ });
    expect(link).toHaveAttribute("aria-current", "page");
    expect(link.className).toContain("bg-brand-50");
  });

  it("does not highlight non-active topic links", () => {
    mockPathname = "/learn/additives";
    render(<LearnSidebar />);
    const link = screen.getByRole("link", { name: /learn\.nutriScore\.title/ });
    expect(link).not.toHaveAttribute("aria-current");
  });

  it("is hidden on mobile (md breakpoint)", () => {
    render(<LearnSidebar />);
    const nav = screen.getByRole("navigation", { name: "learn.sidebarLabel" });
    expect(nav.className).toContain("hidden");
    expect(nav.className).toContain("md:block");
  });

  it("applies custom className", () => {
    render(<LearnSidebar className="w-56" />);
    const nav = screen.getByRole("navigation", { name: "learn.sidebarLabel" });
    expect(nav.className).toContain("w-56");
  });

  it("exports TOPICS array with correct structure", () => {
    expect(TOPICS).toHaveLength(7);
    for (const topic of TOPICS) {
      expect(topic).toHaveProperty("slug");
      expect(topic).toHaveProperty("labelKey");
      expect(topic).toHaveProperty("icon");
    }
  });
});
