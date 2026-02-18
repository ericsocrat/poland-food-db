import { describe, it, expect, vi, beforeEach } from "vitest";
import { render, screen, fireEvent } from "@testing-library/react";
import { CompareCheckbox } from "./CompareCheckbox";

// ─── Mock the compare store ─────────────────────────────────────────────────

const mockIsSelected = vi.fn();
const mockIsFull = vi.fn();
const mockToggle = vi.fn();

vi.mock("@/stores/compare-store", () => ({
  useCompareStore: (selector: (state: Record<string, unknown>) => unknown) =>
    selector({
      isSelected: mockIsSelected,
      isFull: mockIsFull,
      toggle: mockToggle,
    }),
}));

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("CompareCheckbox", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mockIsSelected.mockReturnValue(false);
    mockIsFull.mockReturnValue(false);
  });

  it("renders add label when not selected", () => {
    render(<CompareCheckbox productId={42} />);
    expect(screen.getByLabelText("Add to comparison")).toBeTruthy();
  });

  it("renders remove label when selected", () => {
    mockIsSelected.mockReturnValue(true);
    render(<CompareCheckbox productId={42} />);
    expect(screen.getByLabelText("Remove from comparison")).toBeTruthy();
  });

  it("calls toggle on click when not disabled", () => {
    render(<CompareCheckbox productId={42} />);
    fireEvent.click(screen.getByRole("button"));
    expect(mockToggle).toHaveBeenCalledWith(42, undefined);
  });

  it("does not call toggle when disabled (full + not selected)", () => {
    mockIsFull.mockReturnValue(true);
    render(<CompareCheckbox productId={42} />);
    fireEvent.click(screen.getByRole("button"));
    expect(mockToggle).not.toHaveBeenCalled();
  });

  it("is disabled when full and not selected", () => {
    mockIsFull.mockReturnValue(true);
    render(<CompareCheckbox productId={42} />);
    const btn = screen.getByRole("button");
    expect(btn).toBeDisabled();
    expect(btn.title).toBe("Max 4 products — deselect one first");
  });

  it("is not disabled when full but already selected", () => {
    mockIsSelected.mockReturnValue(true);
    mockIsFull.mockReturnValue(true);
    render(<CompareCheckbox productId={42} />);
    const btn = screen.getByRole("button");
    expect(btn).not.toBeDisabled();
  });

  it("shows selected styling when selected", () => {
    mockIsSelected.mockReturnValue(true);
    render(<CompareCheckbox productId={42} />);
    const btn = screen.getByRole("button");
    expect(btn.className).toContain("bg-brand-600");
  });

  it("shows disabled styling when disabled", () => {
    mockIsFull.mockReturnValue(true);
    render(<CompareCheckbox productId={42} />);
    const btn = screen.getByRole("button");
    expect(btn.className).toContain("cursor-not-allowed");
  });

  it("stops event propagation on click", () => {
    const parentClick = vi.fn();
    render(
      // eslint-disable-next-line jsx-a11y/click-events-have-key-events, jsx-a11y/no-static-element-interactions
      <div onClick={parentClick}>
        <CompareCheckbox productId={42} />
      </div>,
    );
    fireEvent.click(screen.getByRole("button"));
    expect(parentClick).not.toHaveBeenCalled();
  });
});
