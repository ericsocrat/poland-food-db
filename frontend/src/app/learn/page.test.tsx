import { render, screen } from "@testing-library/react";
import { beforeEach, describe, expect, it, vi } from "vitest";
import LearnHubPage from "./page";

// ─── Mocks ──────────────────────────────────────────────────────────────────

vi.mock("@/lib/events", () => ({
  eventBus: { emit: vi.fn().mockResolvedValue(undefined) },
}));

// ─── Tests ──────────────────────────────────────────────────────────────────

beforeEach(() => {
  vi.clearAllMocks();
});

describe("LearnHubPage", () => {
  it("renders the hub title heading", () => {
    render(<LearnHubPage />);
    expect(
      screen.getByRole("heading", { name: /^Learn$/i }),
    ).toBeInTheDocument();
  });

  it("renders all topic cards", () => {
    render(<LearnHubPage />);
    expect(screen.getAllByRole("link").length).toBeGreaterThanOrEqual(7);
  });

  it("renders the disclaimer component", () => {
    render(<LearnHubPage />);
    expect(screen.getByRole("note")).toBeInTheDocument();
  });

  it("emits learn.page_viewed event on mount", async () => {
    const { eventBus } = await import("@/lib/events");
    render(<LearnHubPage />);
    expect(eventBus.emit).toHaveBeenCalledWith(
      expect.objectContaining({ type: "learn.page_viewed" }),
    );
  });
});
