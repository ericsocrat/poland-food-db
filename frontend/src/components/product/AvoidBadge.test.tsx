import { describe, it, expect, vi, beforeEach } from "vitest";
import { render, screen } from "@testing-library/react";
import { AvoidBadge } from "./AvoidBadge";

// ─── Mock the avoid store ───────────────────────────────────────────────────

const mockIsAvoided = vi.fn();

vi.mock("@/stores/avoid-store", () => ({
  useAvoidStore: (
    selector: (s: { isAvoided: typeof mockIsAvoided }) => unknown,
  ) => selector({ isAvoided: mockIsAvoided }),
}));

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("AvoidBadge", () => {
  beforeEach(() => vi.clearAllMocks());

  it("renders nothing when product is not avoided", () => {
    mockIsAvoided.mockReturnValue(false);
    const { container } = render(<AvoidBadge productId={42} />);
    expect(container.innerHTML).toBe("");
  });

  it("renders avoid badge when product is avoided", () => {
    mockIsAvoided.mockReturnValue(true);
    render(<AvoidBadge productId={42} />);
    expect(screen.getByText("Avoid")).toBeTruthy();
  });

  it("has correct title attribute", () => {
    mockIsAvoided.mockReturnValue(true);
    render(<AvoidBadge productId={42} />);
    expect(screen.getByTitle("On your Avoid list")).toBeTruthy();
  });

  it("passes productId to isAvoided", () => {
    mockIsAvoided.mockReturnValue(false);
    render(<AvoidBadge productId={99} />);
    expect(mockIsAvoided).toHaveBeenCalledWith(99);
  });
});
