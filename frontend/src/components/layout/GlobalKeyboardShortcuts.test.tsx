import { describe, it, expect, vi, beforeEach } from "vitest";
import { render, fireEvent } from "@testing-library/react";
import { GlobalKeyboardShortcuts } from "./GlobalKeyboardShortcuts";

// Mock next/navigation
const mockPush = vi.fn();
let mockPathname = "/app";
vi.mock("next/navigation", () => ({
  useRouter: () => ({ push: mockPush }),
  usePathname: () => mockPathname,
}));

describe("GlobalKeyboardShortcuts", () => {
  beforeEach(() => {
    mockPush.mockClear();
    mockPathname = "/app";
  });

  it("navigates to /app/search when / is pressed", () => {
    render(<GlobalKeyboardShortcuts />);
    fireEvent.keyDown(document, { key: "/" });
    expect(mockPush).toHaveBeenCalledWith("/app/search");
  });

  it("focuses input instead of navigating when already on search page", () => {
    mockPathname = "/app/search";
    const input = document.createElement("input");
    input.type = "text";
    input.setAttribute("aria-label", "Search");
    document.body.appendChild(input);

    render(<GlobalKeyboardShortcuts />);
    fireEvent.keyDown(document, { key: "/" });

    expect(mockPush).not.toHaveBeenCalled();
    expect(document.activeElement).toBe(input);

    document.body.removeChild(input);
  });

  it("does not trigger when typing in an input", () => {
    render(<GlobalKeyboardShortcuts />);
    const input = document.createElement("input");
    document.body.appendChild(input);

    fireEvent.keyDown(input, { key: "/" });
    expect(mockPush).not.toHaveBeenCalled();

    document.body.removeChild(input);
  });

  it("does not trigger when typing in a textarea", () => {
    render(<GlobalKeyboardShortcuts />);
    const textarea = document.createElement("textarea");
    document.body.appendChild(textarea);

    fireEvent.keyDown(textarea, { key: "/" });
    expect(mockPush).not.toHaveBeenCalled();

    document.body.removeChild(textarea);
  });

  it("does not trigger for other keys", () => {
    render(<GlobalKeyboardShortcuts />);
    fireEvent.keyDown(document, { key: "a" });
    fireEvent.keyDown(document, { key: "Escape" });
    expect(mockPush).not.toHaveBeenCalled();
  });
});
