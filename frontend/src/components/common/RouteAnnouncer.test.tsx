import { describe, expect, it, vi, beforeEach } from "vitest";
import { render } from "@testing-library/react";

// ─── Mock next/navigation ───────────────────────────────────────────────────

let mockPathname = "/";
const _listeners: Array<() => void> = [];

vi.mock("next/navigation", () => ({
  usePathname: () => mockPathname,
}));

import { RouteAnnouncer } from "./RouteAnnouncer";

// ─── Helpers ────────────────────────────────────────────────────────────────

function renderAnnouncer() {
  return render(<RouteAnnouncer />);
}

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("RouteAnnouncer", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mockPathname = "/";
  });

  it("renders an aria-live region", () => {
    const { container } = renderAnnouncer();
    const region = container.querySelector("[aria-live]");
    expect(region).toBeInTheDocument();
    expect(region).toHaveAttribute("aria-live", "assertive");
    expect(region).toHaveAttribute("aria-atomic", "true");
    expect(region).toHaveAttribute("role", "status");
  });

  it("is visually hidden with sr-only", () => {
    const { container } = renderAnnouncer();
    const region = container.querySelector("[aria-live]");
    expect(region?.className).toContain("sr-only");
  });

  it("does not announce on initial render", () => {
    const { container } = renderAnnouncer();
    const region = container.querySelector("[aria-live]");
    expect(region?.textContent).toBe("");
  });

  it("announces after pathname change", () => {
    const { container, rerender } = render(<RouteAnnouncer />);

    // Simulate navigation
    mockPathname = "/app/categories";
    rerender(<RouteAnnouncer />);

    const region = container.querySelector("[aria-live]");
    expect(region?.textContent).toBe("Navigated to Categories");
  });

  it("maps /app/search to Search", () => {
    const { container, rerender } = render(<RouteAnnouncer />);
    mockPathname = "/app/search";
    rerender(<RouteAnnouncer />);

    expect(container.querySelector("[aria-live]")?.textContent).toBe(
      "Navigated to Search",
    );
  });

  it("maps /app/product/123 to Product Detail", () => {
    const { container, rerender } = render(<RouteAnnouncer />);
    mockPathname = "/app/product/123";
    rerender(<RouteAnnouncer />);

    expect(container.querySelector("[aria-live]")?.textContent).toBe(
      "Navigated to Product Detail",
    );
  });

  it("maps /app/compare to Comparisons", () => {
    const { container, rerender } = render(<RouteAnnouncer />);
    mockPathname = "/app/compare";
    rerender(<RouteAnnouncer />);

    expect(container.querySelector("[aria-live]")?.textContent).toBe(
      "Navigated to Comparisons",
    );
  });

  it("maps /app/settings to Settings", () => {
    const { container, rerender } = render(<RouteAnnouncer />);
    mockPathname = "/app/settings";
    rerender(<RouteAnnouncer />);

    expect(container.querySelector("[aria-live]")?.textContent).toBe(
      "Navigated to Settings",
    );
  });

  it("maps / to Home", () => {
    mockPathname = "/app/categories";
    const { container, rerender } = render(<RouteAnnouncer />);

    mockPathname = "/";
    rerender(<RouteAnnouncer />);

    expect(container.querySelector("[aria-live]")?.textContent).toBe(
      "Navigated to Home",
    );
  });

  it("maps public routes (auth, privacy, terms)", () => {
    const { container, rerender } = render(<RouteAnnouncer />);

    mockPathname = "/auth/login";
    rerender(<RouteAnnouncer />);
    expect(container.querySelector("[aria-live]")?.textContent).toBe(
      "Navigated to Sign In",
    );

    mockPathname = "/privacy";
    rerender(<RouteAnnouncer />);
    expect(container.querySelector("[aria-live]")?.textContent).toBe(
      "Navigated to Privacy Policy",
    );
  });

  it("falls back to capitalized segment for unknown routes", () => {
    const { container, rerender } = render(<RouteAnnouncer />);
    mockPathname = "/app/unknown-page";
    rerender(<RouteAnnouncer />);

    expect(container.querySelector("[aria-live]")?.textContent).toBe(
      "Navigated to Unknown-page",
    );
  });
});
