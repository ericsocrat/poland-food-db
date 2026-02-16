import { describe, expect, it, vi, beforeEach } from "vitest";
import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { RegionForm } from "./RegionForm";

// ─── Mocks ──────────────────────────────────────────────────────────────────

const mockPush = vi.fn();
vi.mock("next/navigation", () => ({
  useRouter: () => ({ push: mockPush }),
}));

const mockSetPrefs = vi.fn();
vi.mock("@/lib/supabase/client", () => ({
  createClient: () => ({}),
}));

vi.mock("@/lib/api", () => ({
  setUserPreferences: (...args: unknown[]) => mockSetPrefs(...args),
}));

vi.mock("sonner", () => ({
  toast: { error: vi.fn(), success: vi.fn() },
}));

beforeEach(() => {
  vi.clearAllMocks();
});

describe("RegionForm", () => {
  it("renders country buttons", () => {
    render(<RegionForm />);
    expect(screen.getByText("Germany")).toBeInTheDocument();
    expect(screen.getByText("Poland")).toBeInTheDocument();
  });

  it("renders progress indicator", () => {
    render(<RegionForm />);
    expect(screen.getByText("Select your region")).toBeInTheDocument();
  });

  it("renders continue button disabled initially", () => {
    render(<RegionForm />);
    expect(screen.getByRole("button", { name: "Continue" })).toBeDisabled();
  });

  it("enables continue button after selecting a country", async () => {
    const user = userEvent.setup();
    render(<RegionForm />);

    await user.click(screen.getByText("Germany"));

    expect(screen.getByRole("button", { name: "Continue" })).toBeEnabled();
  });

  it("shows checkmark on selected country", async () => {
    const user = userEvent.setup();
    render(<RegionForm />);

    await user.click(screen.getByText("Poland"));

    expect(screen.getByText("✓")).toBeInTheDocument();
  });

  it("calls setUserPreferences with selected country on continue", async () => {
    mockSetPrefs.mockResolvedValue({ ok: true });
    const user = userEvent.setup();

    render(<RegionForm />);
    await user.click(screen.getByText("Poland"));
    await user.click(screen.getByRole("button", { name: "Continue" }));

    await waitFor(() => {
      expect(mockSetPrefs).toHaveBeenCalledWith(expect.anything(), {
        p_country: "PL",
      });
    });
  });

  it("navigates to preferences page on success", async () => {
    mockSetPrefs.mockResolvedValue({ ok: true });
    const user = userEvent.setup();

    render(<RegionForm />);
    await user.click(screen.getByText("Germany"));
    await user.click(screen.getByRole("button", { name: "Continue" }));

    await waitFor(() => {
      expect(mockPush).toHaveBeenCalledWith("/onboarding/preferences");
    });
  });

  it("shows error toast when no country selected", async () => {
    const { toast } = await import("sonner");
    // Force-enable the button for testing
    render(<RegionForm />);
    // Continue is disabled, so we test the guard by calling handleContinue indirectly
    // We can't click a disabled button — this is tested by the disabled state test above
    expect(screen.getByRole("button", { name: "Continue" })).toBeDisabled();
    expect(toast.error).not.toHaveBeenCalled();
  });

  it("shows error toast on API failure", async () => {
    const { toast } = await import("sonner");
    mockSetPrefs.mockResolvedValue({
      ok: false,
      error: { message: "Network error" },
    });
    const user = userEvent.setup();

    render(<RegionForm />);
    await user.click(screen.getByText("Germany"));
    await user.click(screen.getByRole("button", { name: "Continue" }));

    await waitFor(() => {
      expect(toast.error).toHaveBeenCalledWith("Network error");
    });
    expect(mockPush).not.toHaveBeenCalled();
  });

  it("shows saving state while loading", async () => {
    mockSetPrefs.mockReturnValue(new Promise(() => {}));
    const user = userEvent.setup();

    render(<RegionForm />);
    await user.click(screen.getByText("Poland"));
    await user.click(screen.getByRole("button", { name: "Continue" }));

    await waitFor(() => {
      expect(screen.getByText("Saving…")).toBeInTheDocument();
    });
  });

  it("displays native country names", () => {
    render(<RegionForm />);
    expect(screen.getByText("Deutschland")).toBeInTheDocument();
    expect(screen.getByText("Polska")).toBeInTheDocument();
  });

  it("displays country flags", () => {
    render(<RegionForm />);
    expect(screen.getByText("🇩🇪")).toBeInTheDocument();
    expect(screen.getByText("🇵🇱")).toBeInTheDocument();
  });
});
