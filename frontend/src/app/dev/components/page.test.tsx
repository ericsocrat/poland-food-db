import { render, screen } from "@testing-library/react";
import { beforeEach, describe, expect, it, vi } from "vitest";

// ─── Mocks ──────────────────────────────────────────────────────────────────

const mockNotFound = vi.fn();
vi.mock("next/navigation", () => ({
  notFound: () => mockNotFound(),
}));

// ─── Tests ──────────────────────────────────────────────────────────────────

beforeEach(() => {
  vi.clearAllMocks();
});

describe("DevComponentsPage", () => {
  it("renders component library heading in development", async () => {
    const { default: DevComponentsPage } = await import("./page");
    render(<DevComponentsPage />);
    expect(
      screen.getByRole("heading", { name: /Component Library/i }),
    ).toBeInTheDocument();
  });

  it("renders button section", async () => {
    const { default: DevComponentsPage } = await import("./page");
    render(<DevComponentsPage />);
    expect(
      screen.getByRole("heading", { name: /^Button$/i }),
    ).toBeInTheDocument();
  });

  it("renders toggle section with interactive toggles", async () => {
    const { default: DevComponentsPage } = await import("./page");
    render(<DevComponentsPage />);
    expect(
      screen.getByRole("heading", { name: /^Toggle$/i }),
    ).toBeInTheDocument();
  });
});
