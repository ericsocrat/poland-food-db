import { describe, it, expect, vi, beforeEach, afterEach } from "vitest";
import { render, screen, act } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { InstallPrompt } from "./InstallPrompt";

// ─── Helpers ────────────────────────────────────────────────────────────────

function mockStandalone(isStandalone: boolean) {
  Object.defineProperty(window, "matchMedia", {
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
    sessionStorage.clear();
    mockStandalone(false);
  });

  afterEach(() => {
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
      window.dispatchEvent(event);
    });

    expect(screen.queryByText("Install FoodDB")).toBeNull();
  });

  it("shows prompt when beforeinstallprompt fires", () => {
    render(<InstallPrompt />);

    const event = createBeforeInstallPromptEvent();
    act(() => {
      window.dispatchEvent(event);
    });

    expect(screen.getByText("Install FoodDB")).toBeInTheDocument();
    expect(screen.getByText("Install")).toBeInTheDocument();
  });

  it("calls prompt() when Install button is clicked", async () => {
    const user = userEvent.setup();
    render(<InstallPrompt />);

    const event = createBeforeInstallPromptEvent();
    act(() => {
      window.dispatchEvent(event);
    });

    await user.click(screen.getByText("Install"));
    expect(event.prompt).toHaveBeenCalled();
  });

  it("dismisses and stores flag in sessionStorage", async () => {
    const user = userEvent.setup();
    render(<InstallPrompt />);

    const event = createBeforeInstallPromptEvent();
    act(() => {
      window.dispatchEvent(event);
    });

    expect(screen.getByText("Install FoodDB")).toBeInTheDocument();

    await user.click(screen.getByLabelText("Dismiss install prompt"));

    expect(screen.queryByText("Install FoodDB")).toBeNull();
    expect(sessionStorage.getItem("pwa-install-dismissed")).toBe("1");
  });

  it("does not show if previously dismissed in session", () => {
    sessionStorage.setItem("pwa-install-dismissed", "1");
    render(<InstallPrompt />);

    const event = createBeforeInstallPromptEvent();
    act(() => {
      window.dispatchEvent(event);
    });

    expect(screen.queryByText("Install FoodDB")).toBeNull();
  });

  it("cleans up event listener on unmount", () => {
    const addSpy = vi.spyOn(window, "addEventListener");
    const removeSpy = vi.spyOn(window, "removeEventListener");

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
