import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { beforeEach, describe, expect, it, vi } from "vitest";
import { ExportDataSection } from "./ExportDataSection";

// ─── Mocks ──────────────────────────────────────────────────────────────────

const mockTrack = vi.fn();
vi.mock("@/hooks/use-analytics", () => ({
  useAnalytics: () => ({ track: mockTrack }),
}));

vi.mock("@/lib/supabase/client", () => ({
  createClient: () => ({}),
}));

const mockExportUserData = vi.fn();
vi.mock("@/lib/api", () => ({
  exportUserData: (...args: unknown[]) => mockExportUserData(...args),
}));

vi.mock("@/lib/toast", () => ({
  showToast: vi.fn(),
}));

const { mockGetCooldown, mockDownloadJson, mockSetTimestamp } = vi.hoisted(
  () => ({
    mockGetCooldown: vi.fn().mockReturnValue(0),
    mockDownloadJson: vi.fn().mockReturnValue({ size: 2048 }),
    mockSetTimestamp: vi.fn(),
  }),
);
vi.mock("@/lib/download", () => ({
  getExportCooldownRemaining: (...args: unknown[]) =>
    mockGetCooldown(...args),
  downloadJson: (...args: unknown[]) => mockDownloadJson(...args),
  setExportTimestamp: (...args: unknown[]) => mockSetTimestamp(...args),
}));

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("ExportDataSection", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mockGetCooldown.mockReturnValue(0);
  });

  it("renders section with heading and description", () => {
    render(<ExportDataSection />);
    expect(screen.getByTestId("export-data-section")).toBeInTheDocument();
    expect(screen.getByRole("heading", { level: 2 })).toBeInTheDocument();
  });

  it("renders the export button", () => {
    render(<ExportDataSection />);
    expect(screen.getByTestId("export-data-button")).toBeInTheDocument();
  });

  it("disables button after successful export (cooldown)", async () => {
    const user = userEvent.setup();
    mockExportUserData.mockResolvedValue({
      ok: true,
      data: { preferences: {} },
    });
    render(<ExportDataSection />);
    const btn = screen.getByTestId("export-data-button");
    await user.click(btn);
    await waitFor(() => {
      expect(btn).toBeDisabled();
    });
  });

  it("calls exportUserData on click and tracks event", async () => {
    const user = userEvent.setup();
    mockExportUserData.mockResolvedValue({
      ok: true,
      data: { preferences: {} },
    });

    render(<ExportDataSection />);
    const btn = screen.getByTestId("export-data-button");
    await user.click(btn);

    await waitFor(() => {
      expect(mockExportUserData).toHaveBeenCalledTimes(1);
    });
    await waitFor(() => {
      expect(mockTrack).toHaveBeenCalledWith("user_data_exported");
    });
  });

  it("shows error toast when export fails", async () => {
    const user = userEvent.setup();
    const { showToast } = await import("@/lib/toast");
    mockExportUserData.mockResolvedValue({
      ok: false,
      error: { message: "fail" },
    });

    render(<ExportDataSection />);
    await user.click(screen.getByTestId("export-data-button"));

    await waitFor(() => {
      expect(showToast).toHaveBeenCalledWith(
        expect.objectContaining({ type: "error" }),
      );
    });
  });

  it("shows error toast on exception", async () => {
    const user = userEvent.setup();
    const { showToast } = await import("@/lib/toast");
    mockExportUserData.mockRejectedValue(new Error("network"));

    render(<ExportDataSection />);
    await user.click(screen.getByTestId("export-data-button"));

    await waitFor(() => {
      expect(showToast).toHaveBeenCalledWith(
        expect.objectContaining({ type: "error" }),
      );
    });
  });

  it("calls downloadJson and setExportTimestamp on success", async () => {
    const user = userEvent.setup();
    mockExportUserData.mockResolvedValue({
      ok: true,
      data: { preferences: { country: "PL" } },
    });

    render(<ExportDataSection />);
    await user.click(screen.getByTestId("export-data-button"));

    await waitFor(() => {
      expect(mockDownloadJson).toHaveBeenCalledTimes(1);
    });
    expect(mockSetTimestamp).toHaveBeenCalledTimes(1);
  });
});
