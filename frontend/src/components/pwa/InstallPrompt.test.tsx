import { describe, it, expect, vi, beforeEach, afterEach } from "vitest";
import { render, screen, act } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { InstallPrompt } from "./InstallPrompt";
import {
  STORAGE_KEY_DISMISSED,
  STORAGE_KEY_VISITS,
  type BeforeInstallPromptEvent,
} from "@/hooks/use-install-prompt";

// ─── Mocks ──────────────────────────────────────────────────────────────────

const mockTrack = vi.fn();
vi.mock("@/hooks/use-analytics", () => ({
  useAnalytics: () => ({ track: mockTrack }),
}));

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

function createBIP(
  outcome: "accepted" | "dismissed" = "dismissed",
): BeforeInstallPromptEvent {
  const event = new Event("beforeinstallprompt", {
    cancelable: true,
  }) as unknown as BeforeInstallPromptEvent;
  (event as { prompt: () => Promise<void> }).prompt = vi
    .fn()
    .mockResolvedValue(undefined);
  (
    event as {
      userChoice: Promise<{ outcome: "accepted" | "dismissed" }>;
    }
  ).userChoice = Promise.resolve({ outcome });
  return event;
}

/** Preset visits so mount increments to ≥ 2. */
function presetVisits(count = 1) {
  localStorage.setItem(STORAGE_KEY_VISITS, String(count));
}

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("InstallPrompt", () => {
  beforeEach(() => {
    localStorage.clear();
    mockStandalone(false);
    mockTrack.mockClear();
  });

  afterEach(() => {
    vi.restoreAllMocks();
  });

  it("renders nothing on first visit (not enough visits)", () => {
    const { container } = render(<InstallPrompt />);
    expect(container.firstChild).toBeNull();
  });

  it("renders nothing when running in standalone mode", () => {
    mockStandalone(true);
    presetVisits(5);
    render(<InstallPrompt />);

    act(() => {
      globalThis.dispatchEvent(createBIP());
    });

    expect(screen.queryByTestId("install-prompt")).toBeNull();
  });

  it("shows prompt when ≥ 2 visits and beforeinstallprompt fires", () => {
    presetVisits();
    render(<InstallPrompt />);

    act(() => {
      globalThis.dispatchEvent(createBIP());
    });

    expect(screen.getByTestId("install-prompt")).toBeInTheDocument();
    expect(screen.getByText("Install FoodDB")).toBeInTheDocument();
    expect(screen.getByTestId("install-button")).toBeInTheDocument();
  });

  it("calls prompt() and tracks analytics when Install is clicked", async () => {
    presetVisits();
    const user = userEvent.setup();
    render(<InstallPrompt />);

    const bip = createBIP("accepted");
    act(() => {
      globalThis.dispatchEvent(bip);
    });

    await user.click(screen.getByTestId("install-button"));
    expect(bip.prompt).toHaveBeenCalled();
    expect(mockTrack).toHaveBeenCalledWith("pwa_install_prompted");
    expect(mockTrack).toHaveBeenCalledWith("pwa_install_accepted");
  });

  it("dismisses banner and stores cooldown timestamp", async () => {
    presetVisits();
    const user = userEvent.setup();
    render(<InstallPrompt />);

    act(() => {
      globalThis.dispatchEvent(createBIP());
    });

    expect(screen.getByTestId("install-prompt")).toBeInTheDocument();

    await user.click(screen.getByTestId("dismiss-install-prompt"));

    expect(screen.queryByTestId("install-prompt")).toBeNull();
    expect(localStorage.getItem(STORAGE_KEY_DISMISSED)).toBeTruthy();
    expect(mockTrack).toHaveBeenCalledWith("pwa_install_dismissed");
  });

  it("does not show if dismissed less than 30 days ago", () => {
    presetVisits(5);
    localStorage.setItem(
      STORAGE_KEY_DISMISSED,
      String(Date.now() - 10 * 24 * 60 * 60 * 1000),
    );

    render(<InstallPrompt />);

    act(() => {
      globalThis.dispatchEvent(createBIP());
    });

    expect(screen.queryByTestId("install-prompt")).toBeNull();
  });

  it("shows again after 30-day cooldown expires", () => {
    presetVisits(5);
    localStorage.setItem(
      STORAGE_KEY_DISMISSED,
      String(Date.now() - 31 * 24 * 60 * 60 * 1000),
    );

    render(<InstallPrompt />);

    act(() => {
      globalThis.dispatchEvent(createBIP());
    });

    expect(screen.getByTestId("install-prompt")).toBeInTheDocument();
  });

  it("cleans up event listeners on unmount", () => {
    presetVisits();
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
