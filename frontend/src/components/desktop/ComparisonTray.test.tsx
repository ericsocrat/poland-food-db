import { describe, it, expect, vi, beforeEach } from "vitest";
import { render, screen, fireEvent } from "@testing-library/react";
import { ComparisonTray } from "./ComparisonTray";

// ─── Mocks ──────────────────────────────────────────────────────────────────

const mockCount = vi.fn();
const mockGetIds = vi.fn();
const mockGetName = vi.fn();
const mockRemove = vi.fn();
const mockClear = vi.fn();
const mockPush = vi.fn();

vi.mock("@/stores/compare-store", () => ({
  useCompareStore: (selector: (state: Record<string, unknown>) => unknown) =>
    selector({
      count: mockCount,
      getIds: mockGetIds,
      getName: mockGetName,
      remove: mockRemove,
      clear: mockClear,
    }),
}));

vi.mock("next/navigation", () => ({
  useRouter: () => ({ push: mockPush }),
}));

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("ComparisonTray", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mockGetIds.mockReturnValue([1, 2]);
    mockGetName.mockImplementation((id: number) => `Product #${id}`);
  });

  it("renders nothing when count is 0", () => {
    mockCount.mockReturnValue(0);
    const { container } = render(<ComparisonTray />);
    expect(container.innerHTML).toBe("");
  });

  it("renders tray when products are selected", () => {
    mockCount.mockReturnValue(2);
    render(<ComparisonTray />);
    expect(screen.getByText("Compare")).toBeTruthy();
  });

  it("shows product count badge", () => {
    mockCount.mockReturnValue(2);
    render(<ComparisonTray />);
    expect(screen.getByText("2")).toBeTruthy();
  });

  it("lists product names", () => {
    mockCount.mockReturnValue(2);
    render(<ComparisonTray />);
    expect(screen.getByText("Product #1")).toBeTruthy();
    expect(screen.getByText("Product #2")).toBeTruthy();
  });

  it("calls remove when remove button clicked", () => {
    mockCount.mockReturnValue(2);
    render(<ComparisonTray />);
    // Two remove buttons for two products
    const removeBtns = screen.getAllByLabelText("Remove from comparison");
    fireEvent.click(removeBtns[0]);
    expect(mockRemove).toHaveBeenCalledWith(1);
  });

  it("calls clear on clear button click", () => {
    mockCount.mockReturnValue(2);
    render(<ComparisonTray />);
    fireEvent.click(screen.getByLabelText("Clear selection"));
    expect(mockClear).toHaveBeenCalledTimes(1);
  });

  it("navigates to compare page on Compare Now click", () => {
    mockCount.mockReturnValue(2);
    mockGetIds.mockReturnValue([1, 2]);
    render(<ComparisonTray />);
    fireEvent.click(screen.getByText("Compare Now →"));
    expect(mockPush).toHaveBeenCalledWith("/app/compare?ids=1,2");
  });

  it("shows 'select at least 2' when only 1 selected", () => {
    mockCount.mockReturnValue(1);
    mockGetIds.mockReturnValue([1]);
    render(<ComparisonTray />);
    expect(screen.getByText(/Select at least 2/)).toBeTruthy();
  });

  it("collapses and expands on toggle", () => {
    mockCount.mockReturnValue(2);
    render(<ComparisonTray />);
    // Products are visible
    expect(screen.getByText("Product #1")).toBeTruthy();

    // Click collapse
    fireEvent.click(screen.getByLabelText("Collapse comparison tray"));

    // Products should be hidden
    expect(screen.queryByText("Product #1")).toBeNull();

    // Click expand
    fireEvent.click(screen.getByLabelText("Expand comparison tray"));

    // Products visible again
    expect(screen.getByText("Product #1")).toBeTruthy();
  });

  it("has proper aria-label on the aside element", () => {
    mockCount.mockReturnValue(2);
    render(<ComparisonTray />);
    expect(screen.getByLabelText("Compare")).toBeTruthy();
  });

  // ─── Responsive visibility guard ───────────────────────────────────
  // ComparisonTray must be hidden on mobile and visible only on lg+.
  // If someone removes the hidden class, it could cause viewport overflow.

  it("has hidden and lg:block classes for desktop-only visibility", () => {
    mockCount.mockReturnValue(2);
    render(<ComparisonTray />);
    const aside = screen.getByLabelText("Compare");
    expect(aside.className).toContain("hidden");
    expect(aside.className).toContain("lg:block");
  });
});
