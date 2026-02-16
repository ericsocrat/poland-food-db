import { describe, it, expect, vi, beforeEach, afterEach } from "vitest";
import { render, screen, act } from "@testing-library/react";
import { OfflineIndicator } from "./OfflineIndicator";

describe("OfflineIndicator", () => {
  let originalOnLine: boolean;

  beforeEach(() => {
    originalOnLine = navigator.onLine;
  });

  afterEach(() => {
    Object.defineProperty(navigator, "onLine", {
      value: originalOnLine,
      writable: true,
      configurable: true,
    });
  });

  it("renders nothing when online", () => {
    Object.defineProperty(navigator, "onLine", {
      value: true,
      writable: true,
      configurable: true,
    });
    const { container } = render(<OfflineIndicator />);
    expect(container.firstChild).toBeNull();
  });

  it("renders offline banner when navigator.onLine is false", () => {
    Object.defineProperty(navigator, "onLine", {
      value: false,
      writable: true,
      configurable: true,
    });
    render(<OfflineIndicator />);
    expect(screen.getByRole("status")).toBeInTheDocument();
    expect(screen.getByText(/offline/i)).toBeInTheDocument();
  });

  it("has polite aria-live attribute", () => {
    Object.defineProperty(navigator, "onLine", {
      value: false,
      writable: true,
      configurable: true,
    });
    render(<OfflineIndicator />);
    expect(screen.getByRole("status")).toHaveAttribute("aria-live", "polite");
  });

  it("shows banner on offline event", () => {
    Object.defineProperty(navigator, "onLine", {
      value: true,
      writable: true,
      configurable: true,
    });
    render(<OfflineIndicator />);
    expect(screen.queryByRole("status")).toBeNull();

    act(() => {
      window.dispatchEvent(new Event("offline"));
    });
    expect(screen.getByRole("status")).toBeInTheDocument();
  });

  it("hides banner on online event", () => {
    Object.defineProperty(navigator, "onLine", {
      value: false,
      writable: true,
      configurable: true,
    });
    render(<OfflineIndicator />);
    expect(screen.getByRole("status")).toBeInTheDocument();

    act(() => {
      window.dispatchEvent(new Event("online"));
    });
    expect(screen.queryByRole("status")).toBeNull();
  });

  it("cleans up event listeners on unmount", () => {
    const addSpy = vi.spyOn(window, "addEventListener");
    const removeSpy = vi.spyOn(window, "removeEventListener");

    Object.defineProperty(navigator, "onLine", {
      value: true,
      writable: true,
      configurable: true,
    });

    const { unmount } = render(<OfflineIndicator />);

    expect(addSpy).toHaveBeenCalledWith("offline", expect.any(Function));
    expect(addSpy).toHaveBeenCalledWith("online", expect.any(Function));

    unmount();

    expect(removeSpy).toHaveBeenCalledWith("offline", expect.any(Function));
    expect(removeSpy).toHaveBeenCalledWith("online", expect.any(Function));

    addSpy.mockRestore();
    removeSpy.mockRestore();
  });
});
