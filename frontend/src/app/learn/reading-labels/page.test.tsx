import { render, screen } from "@testing-library/react";
import { beforeEach, describe, expect, it, vi } from "vitest";
import ReadingLabelsPage from "./page";

// ─── Tests ──────────────────────────────────────────────────────────────────

beforeEach(() => {
  vi.clearAllMocks();
});

describe("ReadingLabelsPage", () => {
  it("renders the page title heading", () => {
    render(<ReadingLabelsPage />);
    expect(
      screen.getByRole("heading", { name: /Reading Polish Food Labels/i }),
    ).toBeInTheDocument();
  });

  it("renders all 9 mandatory items", () => {
    render(<ReadingLabelsPage />);
    const listItems = screen.getAllByRole("listitem");
    // 9 mandatory items + 5 tips = 14 total list items
    expect(listItems.length).toBeGreaterThanOrEqual(14);
  });

  it("renders the disclaimer", () => {
    render(<ReadingLabelsPage />);
    expect(screen.getByRole("note")).toBeInTheDocument();
  });

  it("renders back to hub link", () => {
    render(<ReadingLabelsPage />);
    const backLink = screen.getByText(/Back to Learn/i);
    expect(backLink).toBeInTheDocument();
    expect(backLink.closest("a")).toHaveAttribute("href", "/learn");
  });
});
