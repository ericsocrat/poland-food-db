import { describe, it, expect, vi, beforeEach, afterEach } from "vitest";
import { render, screen, act } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { InstallPrompt } from "./InstallPrompt";

// ─── Helpers ────────────────────────────────────────────────────────────────

function mockStandalone(isStandalone: boolean) {
  Object.defineProperty(globalThis, "matchMedia", {
    writable: true,
    configurable: true,
    value: vi.fn().mockImplementation((query: string) => ({
      matches: query === "(display-mode: standalone)" ? isStandalone : false,
      media: query,
      addEventListener: vi.fn(),
      removeEventListener: vi.fn(),
    })),
  });
}

function createBeforeInstallPromptEvent(): Event & {
  prompt: ReturnType<typeof vi.fn>;
  userChoice: Promise<{ outcome: "accepted" | "dismissed" }>;
} {
  const event = new Event("beforeinstallprompt", {
    cancelable: true,
  }) as Event & {
    prompt: ReturnType<typeof vi.fn>;
    userChoice: Promise<{ outcome: "accepted" | "dismissed" }>;
  };
  event.prompt = vi.fn().mockResolvedValue(undefined);
  event.userChoice = Promise.resolve({ outcome: "dismissed" as const });
  return event;
}

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("InstallPrompt", () => {
  beforeEach(() => {
    localStorage.clear();
    mockStandalone(false);
    vi.useFakeTimers({ shouldAdvanceTime: true });
  });

  afterEach(() => {
    vi.useRealTimers();
    vi.restoreAllMocks();
  });

  it("renders nothing initially (no beforeinstallprompt event)", () => {
    const { container } = render(<InstallPrompt />);
    expect(container.firstChild).toBeNull();
  });

  it("renders nothing when running in standalone mode", () => {
    mockStandalone(true);
    render(<InstallPrompt />);

    const event = createBeforeInstallPromptEvent();
    act(() => {
      globalThis.dispatchEvent(event);
    });

    // Advance past the 30 s delay
    act(() => {
      vi.advanceTimersByTime(31_000);
    });

    expect(screen.queryByText("Install FoodDB")).toBeNull();
  });

  it("shows prompt after 30 s delay when beforeinstallprompt fires", () => {
    render(<InstallPrompt />);

    const event = createBeforeInstallPromptEvent();
    act(() => {
      globalThis.dispatchEvent(event);
    });

    // Not visible immediately
    expect(screen.queryByText("Install FoodDB")).toBeNull();

    // Advance past the 30 s delay
    act(() => {
      vi.advanceTimersByTime(31_000);
    });

    expect(screen.getByText("Install FoodDB")).toBeInTheDocument();
    expect(screen.getByText("Install")).toBeInTheDocument();
  });

  it("calls prompt() when Install button is clicked", async () => {
    const user = userEvent.setup({ advanceTimers: vi.advanceTimersByTime });
    render(<InstallPrompt />);

    const event = createBeforeInstallPromptEvent();
    act(() => {
      globalThis.dispatchEvent(event);
    });

    act(() => {
      vi.advanceTimersByTime(31_000);
    });

    await user.click(screen.getByText("Install"));
    expect(event.prompt).toHaveBeenCalled();
  });

  it("dismisses and stores timestamp in localStorage", async () => {
    const user = userEvent.setup({ advanceTimers: vi.advanceTimersByTime });
    vi.setSystemTime(new Date("2026-03-01T12:00:00Z"));

    render(<InstallPrompt />);

    const event = createBeforeInstallPromptEvent();
    act(() => {
      globalThis.dispatchEvent(event);
    });

    act(() => {
      vi.advanceTimersByTime(31_000);
    });

    expect(screen.getByText("Install FoodDB")).toBeInTheDocument();

    await user.click(screen.getByLabelText("Dismiss install prompt"));

    expect(screen.queryByText("Install FoodDB")).toBeNull();
    expect(localStorage.getItem("pwa-install-dismissed-at")).toBeTruthy();
  });

  it("does not show if dismissed less than 14 days ago", () => {
    // Dismissed 10 days ago
    localStorage.setItem(
      "pwa-install-dismissed-at",
      String(Date.now() - 10 * 24 * 60 * 60 * 1000),
    );

    render(<InstallPrompt />);

    const event = createBeforeInstallPromptEvent();
    act(() => {
      globalThis.dispatchEvent(event);
    });

    act(() => {
      vi.advanceTimersByTime(31_000);
    });

    expect(screen.queryByText("Install FoodDB")).toBeNull();
  });

  it("shows again after 14-day cooldown expires", () => {
    // Dismissed 15 days ago
    localStorage.setItem(
      "pwa-install-dismissed-at",
      String(Date.now() - 15 * 24 * 60 * 60 * 1000),
    );

    render(<InstallPrompt />);

    const event = createBeforeInstallPromptEvent();
    act(() => {
      globalThis.dispatchEvent(event);
    });

    act(() => {
      vi.advanceTimersByTime(31_000);
    });

    expect(screen.getByText("Install FoodDB")).toBeInTheDocument();
  });

  it("cleans up event listener on unmount", () => {
    const addSpy = vi.spyOn(globalThis, "addEventListener");
    const removeSpy = vi.spyOn(globalThis, "removeEventListener");

    const { unmount } = render(<InstallPrompt />);

    expect(addSpy).toHaveBeenCalledWith(
      "beforeinstallprompt",
      expect.any(Function),
    );

    unmount();

    expect(removeSpy).toHaveBeenCalledWith(
      "beforeinstallprompt",
      expect.any(Function),
    );

    addSpy.mockRestore();
    removeSpy.mockRestore();
  });
});
