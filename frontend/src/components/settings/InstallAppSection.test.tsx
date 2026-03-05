import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { beforeEach, describe, expect, it, vi } from "vitest";
import { InstallAppSection } from "./InstallAppSection";

// ─── Mocks ──────────────────────────────────────────────────────────────────

const mockTrack = vi.fn();
vi.mock("@/hooks/use-analytics", () => ({
  useAnalytics: () => ({ track: mockTrack }),
}));

const mockTriggerInstall = vi.fn();
const mockInstallPrompt = {
  isIOS: false,
  isInstalled: false,
  triggerInstall: mockTriggerInstall,
  deferredPrompt: {} as Event,
};
vi.mock("@/hooks/use-install-prompt", () => ({
  useInstallPrompt: () => mockInstallPrompt,
}));

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("InstallAppSection", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mockInstallPrompt.isIOS = false;
    mockInstallPrompt.isInstalled = false;
    mockInstallPrompt.deferredPrompt = {} as Event;
    mockTriggerInstall.mockResolvedValue("dismissed");
  });

  it("renders the install section when not installed", () => {
    render(<InstallAppSection />);
    expect(screen.getByTestId("install-app-section")).toBeInTheDocument();
    expect(screen.getByRole("heading", { level: 2 })).toBeInTheDocument();
  });

  it("renders nothing when already installed", () => {
    mockInstallPrompt.isInstalled = true;
    const { container } = render(<InstallAppSection />);
    expect(container.innerHTML).toBe("");
  });

  it("shows install button on Android/desktop", () => {
    render(<InstallAppSection />);
    expect(screen.getByTestId("settings-install-button")).toBeInTheDocument();
  });

  it("shows iOS hint instead of button on iOS", () => {
    mockInstallPrompt.isIOS = true;
    render(<InstallAppSection />);
    expect(
      screen.queryByTestId("settings-install-button"),
    ).not.toBeInTheDocument();
  });

  it("disables button when no deferred prompt", () => {
    mockInstallPrompt.deferredPrompt = null as unknown as Event;
    render(<InstallAppSection />);
    expect(screen.getByTestId("settings-install-button")).toBeDisabled();
  });

  it("calls triggerInstall and tracks event on click", async () => {
    const user = userEvent.setup();
    mockTriggerInstall.mockResolvedValue("accepted");
    render(<InstallAppSection />);
    await user.click(screen.getByTestId("settings-install-button"));
    expect(mockTrack).toHaveBeenCalledWith("pwa_install_prompted");
    expect(mockTrack).toHaveBeenCalledWith("pwa_install_accepted");
    expect(mockTriggerInstall).toHaveBeenCalledTimes(1);
  });

  it("tracks dismissed event when user dismisses prompt", async () => {
    const user = userEvent.setup();
    mockTriggerInstall.mockResolvedValue("dismissed");
    render(<InstallAppSection />);
    await user.click(screen.getByTestId("settings-install-button"));
    expect(mockTrack).toHaveBeenCalledWith("pwa_install_prompted");
    expect(mockTrack).toHaveBeenCalledWith("pwa_install_dismissed");
  });
});
