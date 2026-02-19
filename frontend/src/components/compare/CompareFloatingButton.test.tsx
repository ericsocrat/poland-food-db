import { describe, it, expect, vi, beforeEach } from "vitest";
import { render, screen, fireEvent } from "@testing-library/react";
import { CompareFloatingButton } from "./CompareFloatingButton";

// ─── Mocks ──────────────────────────────────────────────────────────────────

const mockCount = vi.fn();
const mockGetIds = vi.fn();
const mockClear = vi.fn();
const mockPush = vi.fn();

vi.mock("@/stores/compare-store", () => ({
  useCompareStore: (selector: (state: Record<string, unknown>) => unknown) =>
    selector({
      count: mockCount,
      getIds: mockGetIds,
      clear: mockClear,
    }),
}));

vi.mock("next/navigation", () => ({
  useRouter: () => ({ push: mockPush }),
}));

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("CompareFloatingButton", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mockGetIds.mockReturnValue([1, 2, 3]);
  });

  it("renders nothing when fewer than 2 selected", () => {
    mockCount.mockReturnValue(1);
    const { container } = render(<CompareFloatingButton />);
    expect(container.innerHTML).toBe("");
  });

  it("renders nothing when 0 selected", () => {
    mockCount.mockReturnValue(0);
    const { container } = render(<CompareFloatingButton />);
    expect(container.innerHTML).toBe("");
  });

  it("renders compare button when 2+ selected", () => {
    mockCount.mockReturnValue(2);
    render(<CompareFloatingButton />);
    expect(screen.getByText("Compare 2")).toBeTruthy();
  });

  it("navigates to compare page with sorted IDs on click", () => {
    mockCount.mockReturnValue(3);
    mockGetIds.mockReturnValue([1, 2, 3]);
    render(<CompareFloatingButton />);
    fireEvent.click(screen.getByText("Compare 3"));
    expect(mockPush).toHaveBeenCalledWith("/app/compare?ids=1,2,3");
  });

  it("clears selection on clear button click", () => {
    mockCount.mockReturnValue(2);
    render(<CompareFloatingButton />);
    fireEvent.click(screen.getByTitle("Clear selection"));
    expect(mockClear).toHaveBeenCalledTimes(1);
  });

  it("shows count badge", () => {
    mockCount.mockReturnValue(4);
    render(<CompareFloatingButton />);
    // The count appears multiple times (text + badge)
    const badges = screen.getAllByText("4");
    expect(badges.length).toBeGreaterThanOrEqual(1);
  });

  // ─── Responsive visibility guard ───────────────────────────────────
  // CompareFloatingButton is mobile-only (lg:hidden). If someone removes
  // the lg:hidden class, it would overlap with the ComparisonTray on desktop.

  it("has lg:hidden class for mobile-only visibility", () => {
    mockCount.mockReturnValue(2);
    const { container } = render(<CompareFloatingButton />);
    const wrapper = container.firstElementChild!;
    expect(wrapper.className).toContain("lg:hidden");
  });
});
