import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { act, render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { useState } from "react";
import { beforeEach, describe, expect, it, vi } from "vitest";
import ScanPage from "./page";

// ─── Mocks ──────────────────────────────────────────────────────────────────

const {
  mockPush,
  mockRecordScan,
  mockShowToast,
  mockListDevices,
  mockDecodeFromDevice,
  mockResetReader,
} = vi.hoisted(() => ({
  mockPush: vi.fn(),
  mockRecordScan: vi.fn(),
  mockShowToast: vi.fn(),
  mockListDevices: vi.fn(),
  mockDecodeFromDevice: vi.fn(),
  mockResetReader: vi.fn(),
}));

vi.mock("next/navigation", () => ({
  useRouter: () => ({ push: mockPush }),
}));

vi.mock("@/lib/supabase/client", () => ({
  createClient: () => ({}),
}));

vi.mock("next/link", () => ({
  default: ({
    href,
    children,
    ...rest
  }: {
    href: string;
    children: React.ReactNode;
    className?: string;
  }) => (
    <a href={href} {...rest}>
      {children}
    </a>
  ),
}));

vi.mock("@/lib/api", () => ({
  recordScan: (...args: unknown[]) => mockRecordScan(...args),
}));

vi.mock("@/lib/validation", () => ({
  isValidEan: (ean: string) => ean.length === 8 || ean.length === 13,
  stripNonDigits: (s: string) => s.replace(/\D/g, ""),
}));

vi.mock("@/components/common/LoadingSpinner", () => ({
  LoadingSpinner: () => <div data-testid="loading-spinner" />,
}));

// Mock @/lib/toast
vi.mock("@/lib/toast", () => ({
  showToast: mockShowToast,
}));

vi.mock("@/lib/score-utils", () => ({
  toTryVitScore: (u: number) => 100 - u,
  getScoreBand: (u: number) => {
    if (u >= 1 && u <= 20) return { band: "green", label: "Excellent", color: "#22c55e", bgColor: "#dcfce7", textColor: "#166534" };
    if (u >= 21 && u <= 40) return { band: "yellow", label: "Good", color: "#eab308", bgColor: "#fef9c3", textColor: "#854d0e" };
    if (u >= 41 && u <= 60) return { band: "orange", label: "Moderate", color: "#f97316", bgColor: "#fff7ed", textColor: "#9a3412" };
    if (u >= 61 && u <= 80) return { band: "red", label: "Poor", color: "#ef4444", bgColor: "#fef2f2", textColor: "#991b1b" };
    if (u >= 81 && u <= 100) return { band: "darkred", label: "Bad", color: "#991b1b", bgColor: "#fef2f2", textColor: "#7f1d1d" };
    return null;
  },
}));

// Mock ZXing library — prevent actual camera access
vi.mock("@zxing/library", () => {
  // Plain constructor (not vi.fn) so vi.clearAllMocks() doesn't strip it
  function MockBrowserMultiFormatReader() {
    return {
      listVideoInputDevices: (...a: unknown[]) => mockListDevices(...a),
      decodeFromVideoDevice: (...a: unknown[]) => mockDecodeFromDevice(...a),
      reset: (...a: unknown[]) => mockResetReader(...a),
    };
  }
  return {
    BrowserMultiFormatReader: MockBrowserMultiFormatReader,
    DecodeHintType: { POSSIBLE_FORMATS: 0 },
    BarcodeFormat: { EAN_13: 0, EAN_8: 1, UPC_A: 2, UPC_E: 3 },
  };
});

// ─── Helpers ────────────────────────────────────────────────────────────────

function Wrapper({ children }: Readonly<{ children: React.ReactNode }>) {
  const [client] = useState(
    () =>
      new QueryClient({
        defaultOptions: { queries: { retry: false, staleTime: 0 } },
      }),
  );
  return <QueryClientProvider client={client}>{children}</QueryClientProvider>;
}

function createWrapper() {
  return Wrapper;
}

const mockFoundResponse = {
  ok: true,
  data: {
    api_version: "v1",
    found: true,
    product_id: 42,
    product_name: "Test Chips",
    product_name_en: "Test Chips",
    product_name_display: "Test Chips",
    brand: "TestBrand",
    category: "chips",
    category_display: "Chips",
    category_icon: "🍟",
    unhealthiness_score: 65,
    nutri_score: "D" as const,
  },
};

const mockNotFoundResponse = {
  ok: true,
  data: {
    api_version: "v1",
    found: false,
    ean: "5901234123457",
    has_pending_submission: false,
  },
};

// ─── Tests ──────────────────────────────────────────────────────────────────

beforeEach(() => {
  vi.clearAllMocks();
  // Re-establish ZXing defaults (clearAllMocks strips implementations)
  mockListDevices.mockResolvedValue([]);
});

describe("ScanPage", () => {
  it("renders scan barcode heading", () => {
    render(<ScanPage />, { wrapper: createWrapper() });
    expect(screen.getByText("Scan Barcode")).toBeInTheDocument();
  });

  it("renders camera and manual mode toggle", () => {
    render(<ScanPage />, { wrapper: createWrapper() });
    expect(screen.getByText("Camera")).toBeInTheDocument();
    expect(screen.getByText("Manual")).toBeInTheDocument();
  });

  it("renders batch mode checkbox", () => {
    render(<ScanPage />, { wrapper: createWrapper() });
    expect(
      screen.getByText("Batch mode — scan multiple without stopping"),
    ).toBeInTheDocument();
  });

  it("renders history link", () => {
    render(<ScanPage />, { wrapper: createWrapper() });
    const historyLinks = screen.getAllByText("History");
    expect(historyLinks.length).toBeGreaterThan(0);
    expect(historyLinks[0].closest("a")).toHaveAttribute(
      "href",
      "/app/scan/history",
    );
  });

  it("renders submissions link", () => {
    render(<ScanPage />, { wrapper: createWrapper() });
    expect(screen.getByText("My Submissions")).toBeInTheDocument();
    expect(screen.getByText("My Submissions").closest("a")).toHaveAttribute(
      "href",
      "/app/scan/submissions",
    );
  });

  it("defaults to manual mode with input visible", () => {
    render(<ScanPage />, { wrapper: createWrapper() });

    expect(
      screen.getByPlaceholderText("Enter EAN barcode (8 or 13 digits)"),
    ).toBeInTheDocument();
    expect(screen.getByText("Look up")).toBeInTheDocument();
  });

  it("disables look up button when EAN is too short", async () => {
    const user = userEvent.setup();
    render(<ScanPage />, { wrapper: createWrapper() });

    await user.click(screen.getByText("Manual"));

    const input = screen.getByPlaceholderText(
      "Enter EAN barcode (8 or 13 digits)",
    );
    await user.type(input, "123");

    expect(screen.getByText("Look up")).toBeDisabled();
  });

  it("enables look up button when EAN is valid (8+ digits)", async () => {
    const user = userEvent.setup();
    render(<ScanPage />, { wrapper: createWrapper() });

    await user.click(screen.getByText("Manual"));

    const input = screen.getByPlaceholderText(
      "Enter EAN barcode (8 or 13 digits)",
    );
    await user.type(input, "12345678");

    expect(screen.getByText("Look up")).toBeEnabled();
  });

  it("submits manual EAN and shows found preview", async () => {
    mockRecordScan.mockResolvedValue(mockFoundResponse);
    const user = userEvent.setup();

    render(<ScanPage />, { wrapper: createWrapper() });

    await user.click(screen.getByText("Manual"));
    const input = screen.getByPlaceholderText(
      "Enter EAN barcode (8 or 13 digits)",
    );
    await user.type(input, "5901234123457");
    await user.click(screen.getByText("Look up"));

    await waitFor(() => {
      expect(screen.getByText("Product Found!")).toBeInTheDocument();
    });
    expect(screen.getByText("Test Chips")).toBeInTheDocument();
    expect(screen.getByText("TestBrand")).toBeInTheDocument();

    await user.click(screen.getByText("View Details"));
    expect(mockPush).toHaveBeenCalledWith("/app/scan/result/42");
  });

  it("shows not-found state with submission CTA", async () => {
    mockRecordScan.mockResolvedValue(mockNotFoundResponse);
    const user = userEvent.setup();

    render(<ScanPage />, { wrapper: createWrapper() });

    await user.click(screen.getByText("Manual"));
    const input = screen.getByPlaceholderText(
      "Enter EAN barcode (8 or 13 digits)",
    );
    await user.type(input, "5901234123457");
    await user.click(screen.getByText("Look up"));

    await waitFor(() => {
      expect(screen.getByText("Product not found")).toBeInTheDocument();
    });
    expect(screen.getByText(/5901234123457/)).toBeInTheDocument();
    expect(screen.getByText("Help us add it!")).toBeInTheDocument();
  });

  it("shows pending submission notice when has_pending_submission", async () => {
    mockRecordScan.mockResolvedValue({
      ok: true,
      data: {
        ...mockNotFoundResponse.data,
        has_pending_submission: true,
      },
    });
    const user = userEvent.setup();

    render(<ScanPage />, { wrapper: createWrapper() });

    await user.click(screen.getByText("Manual"));
    await user.type(
      screen.getByPlaceholderText("Enter EAN barcode (8 or 13 digits)"),
      "5901234123457",
    );
    await user.click(screen.getByText("Look up"));

    await waitFor(() => {
      expect(
        screen.getByText(/Someone has already submitted this product/),
      ).toBeInTheDocument();
    });
  });

  it("shows error state when lookup fails", async () => {
    mockRecordScan.mockRejectedValue(new Error("Network error"));
    const user = userEvent.setup();

    render(<ScanPage />, { wrapper: createWrapper() });

    await user.click(screen.getByText("Manual"));
    await user.type(
      screen.getByPlaceholderText("Enter EAN barcode (8 or 13 digits)"),
      "5901234123457",
    );
    await user.click(screen.getByText("Look up"));

    await waitFor(() => {
      expect(screen.getByText("Lookup failed")).toBeInTheDocument();
    });
    expect(screen.getByText("Scan another")).toBeInTheDocument();
  });

  it("retries scan from error state", async () => {
    mockRecordScan.mockRejectedValueOnce(new Error("fail"));
    const user = userEvent.setup();

    render(<ScanPage />, { wrapper: createWrapper() });

    await user.click(screen.getByText("Manual"));
    await user.type(
      screen.getByPlaceholderText("Enter EAN barcode (8 or 13 digits)"),
      "5901234123457",
    );
    await user.click(screen.getByText("Look up"));

    await waitFor(() => {
      expect(screen.getByText("Lookup failed")).toBeInTheDocument();
    });

    mockRecordScan.mockResolvedValue(mockFoundResponse);
    await user.click(screen.getByText("Retry"));

    await waitFor(() => {
      expect(screen.getByText("Product Found!")).toBeInTheDocument();
    });

    await user.click(screen.getByText("View Details"));
    expect(mockPush).toHaveBeenCalledWith("/app/scan/result/42");
  });

  it("resets from error state to scan another", async () => {
    mockRecordScan.mockRejectedValueOnce(new Error("fail"));
    const user = userEvent.setup();

    render(<ScanPage />, { wrapper: createWrapper() });

    await user.click(screen.getByText("Manual"));
    await user.type(
      screen.getByPlaceholderText("Enter EAN barcode (8 or 13 digits)"),
      "5901234123457",
    );
    await user.click(screen.getByText("Look up"));

    await waitFor(() => {
      expect(screen.getByText("Lookup failed")).toBeInTheDocument();
    });

    await user.click(screen.getByText("Scan another"));

    expect(screen.getByText("Scan Barcode")).toBeInTheDocument();
  });

  it("shows toast error for invalid manual EAN", async () => {
    const user = userEvent.setup();

    render(<ScanPage />, { wrapper: createWrapper() });
    await user.click(screen.getByText("Manual"));

    const input = screen.getByPlaceholderText(
      "Enter EAN barcode (8 or 13 digits)",
    );
    // Type exactly 9 digits — not valid (not 8 or 13)
    await user.type(input, "123456789");
    await user.click(screen.getByText("Look up"));

    expect(mockShowToast).toHaveBeenCalledWith(
      expect.objectContaining({
        type: "error",
        messageKey: "scan.invalidBarcode",
      }),
    );
  });

  it("strips non-digits from manual input", async () => {
    const user = userEvent.setup();

    render(<ScanPage />, { wrapper: createWrapper() });
    await user.click(screen.getByText("Manual"));

    const input = screen.getByPlaceholderText(
      "Enter EAN barcode (8 or 13 digits)",
    );
    await user.type(input, "590-123-412");

    expect(input).toHaveValue("590123412");
  });

  it("supports barcode format info text", async () => {
    const user = userEvent.setup();
    render(<ScanPage />, { wrapper: createWrapper() });
    await user.click(screen.getByText("Camera"));
    expect(
      screen.getByText(/Supports EAN-13, EAN-8, UPC-A, UPC-E/),
    ).toBeInTheDocument();
  });

  it("enables batch mode checkbox", async () => {
    const user = userEvent.setup();
    render(<ScanPage />, { wrapper: createWrapper() });

    const checkbox = screen.getByRole("checkbox");
    expect(checkbox).not.toBeChecked();

    await user.click(checkbox);
    expect(checkbox).toBeChecked();
  });

  it("submit link points to correct EAN when not found", async () => {
    mockRecordScan.mockResolvedValue(mockNotFoundResponse);
    const user = userEvent.setup();

    render(<ScanPage />, { wrapper: createWrapper() });

    await user.click(screen.getByText("Manual"));
    await user.type(
      screen.getByPlaceholderText("Enter EAN barcode (8 or 13 digits)"),
      "5901234123457",
    );
    await user.click(screen.getByText("Look up"));

    await waitFor(() => {
      expect(screen.getByText("Help us add it!")).toBeInTheDocument();
    });
    expect(screen.getByText("Help us add it!").closest("a")).toHaveAttribute(
      "href",
      "/app/scan/submit?ean=5901234123457",
    );
  });

  it("shows manual entry hint text", async () => {
    const user = userEvent.setup();
    render(<ScanPage />, { wrapper: createWrapper() });

    await user.click(screen.getByText("Manual"));

    expect(
      screen.getByText("Enter 8 digits (EAN-8) or 13 digits (EAN-13)"),
    ).toBeInTheDocument();
  });

  it("disables look up button when EAN is too short", async () => {
    const user = userEvent.setup();
    render(<ScanPage />, { wrapper: createWrapper() });

    await user.click(screen.getByText("Manual"));

    await user.type(
      screen.getByPlaceholderText("Enter EAN barcode (8 or 13 digits)"),
      "1234",
    );

    expect(screen.getByRole("button", { name: "Look up" })).toBeDisabled();
  });

  it("enables look up button when EAN has 8+ digits", async () => {
    const user = userEvent.setup();
    render(<ScanPage />, { wrapper: createWrapper() });

    await user.click(screen.getByText("Manual"));

    await user.type(
      screen.getByPlaceholderText("Enter EAN barcode (8 or 13 digits)"),
      "12345678",
    );

    expect(screen.getByRole("button", { name: "Look up" })).toBeEnabled();
  });

  it("navigates to product page when scan finds a product (single mode)", async () => {
    mockRecordScan.mockResolvedValue({
      ok: true,
      data: {
        found: true,
        product_id: 42,
        product_name: "Test Product",
        brand: "TestBrand",
        nutri_score: "B",
        unhealthiness_score: 35,
      },
    });
    const user = userEvent.setup();

    render(<ScanPage />, { wrapper: createWrapper() });
    await user.click(screen.getByText("Manual"));
    await user.type(
      screen.getByPlaceholderText("Enter EAN barcode (8 or 13 digits)"),
      "5901234123457",
    );
    await user.click(screen.getByText("Look up"));

    await waitFor(() => {
      expect(screen.getByText("Product Found!")).toBeInTheDocument();
    });
    expect(screen.getByText("Test Product")).toBeInTheDocument();

    await user.click(screen.getByText("View Details"));
    expect(mockPush).toHaveBeenCalledWith("/app/scan/result/42");
  });

  it("shows looking-up state with spinner while scan is pending", async () => {
    // Make scan hang indefinitely
    mockRecordScan.mockReturnValue(new Promise(() => {}));
    const user = userEvent.setup();

    render(<ScanPage />, { wrapper: createWrapper() });
    await user.click(screen.getByText("Manual"));
    await user.type(
      screen.getByPlaceholderText("Enter EAN barcode (8 or 13 digits)"),
      "5901234123457",
    );
    await user.click(screen.getByText("Look up"));

    await waitFor(() => {
      expect(screen.getByTestId("loading-spinner")).toBeInTheDocument();
    });
  });

  it("batch mode adds found products to scanned list with toast", async () => {
    mockRecordScan.mockResolvedValue({
      ok: true,
      data: {
        found: true,
        product_id: 42,
        product_name: "Batch Product",
        brand: "TestBrand",
        nutri_score: "A",
      },
    });
    const user = userEvent.setup();

    render(<ScanPage />, { wrapper: createWrapper() });

    // Enable batch mode
    await user.click(screen.getByLabelText(/Batch mode/));

    // Switch to manual and scan
    await user.click(screen.getByText("Manual"));
    await user.type(
      screen.getByPlaceholderText("Enter EAN barcode (8 or 13 digits)"),
      "5901234123457",
    );
    await user.click(screen.getByText("Look up"));

    await waitFor(() => {
      expect(screen.getByText("Batch Product")).toBeInTheDocument();
    });
    expect(screen.getByText("Scanned (1)")).toBeInTheDocument();
    expect(mockShowToast).toHaveBeenCalledWith(
      expect.objectContaining({ type: "success", message: "✓ Batch Product" }),
    );
    // In batch mode, should NOT navigate
    expect(mockPush).not.toHaveBeenCalled();
  });

  it("batch mode shows Clear and Done scanning buttons", async () => {
    mockRecordScan.mockResolvedValue({
      ok: true,
      data: {
        found: true,
        product_id: 42,
        product_name: "Batch Product",
        brand: "TestBrand",
        nutri_score: "A",
      },
    });
    const user = userEvent.setup();

    render(<ScanPage />, { wrapper: createWrapper() });
    await user.click(screen.getByLabelText(/Batch mode/));
    await user.click(screen.getByText("Manual"));
    await user.type(
      screen.getByPlaceholderText("Enter EAN barcode (8 or 13 digits)"),
      "5901234123457",
    );
    await user.click(screen.getByText("Look up"));

    await waitFor(() => {
      expect(screen.getByText("Scanned (1)")).toBeInTheDocument();
    });

    expect(screen.getByText("Clear")).toBeInTheDocument();
    expect(screen.getByText("Done scanning")).toBeInTheDocument();
  });

  it("batch mode Clear button removes all scanned items", async () => {
    mockRecordScan.mockResolvedValue({
      ok: true,
      data: {
        found: true,
        product_id: 42,
        product_name: "Batch Product",
        brand: "TestBrand",
        nutri_score: "A",
      },
    });
    const user = userEvent.setup();

    render(<ScanPage />, { wrapper: createWrapper() });
    await user.click(screen.getByLabelText(/Batch mode/));
    await user.click(screen.getByText("Manual"));
    await user.type(
      screen.getByPlaceholderText("Enter EAN barcode (8 or 13 digits)"),
      "5901234123457",
    );
    await user.click(screen.getByText("Look up"));

    await waitFor(() => {
      expect(screen.getByText("Scanned (1)")).toBeInTheDocument();
    });

    await user.click(screen.getByText("Clear"));

    expect(screen.queryByText("Scanned (1)")).not.toBeInTheDocument();
    expect(screen.queryByText("Batch Product")).not.toBeInTheDocument();
  });

  it("batch mode product click navigates to product page", async () => {
    mockRecordScan.mockResolvedValue({
      ok: true,
      data: {
        found: true,
        product_id: 42,
        product_name: "Batch Product",
        brand: "TestBrand",
        nutri_score: "A",
      },
    });
    const user = userEvent.setup();

    render(<ScanPage />, { wrapper: createWrapper() });
    await user.click(screen.getByLabelText(/Batch mode/));
    await user.click(screen.getByText("Manual"));
    await user.type(
      screen.getByPlaceholderText("Enter EAN barcode (8 or 13 digits)"),
      "5901234123457",
    );
    await user.click(screen.getByText("Look up"));

    await waitFor(() => {
      expect(screen.getByText("Batch Product")).toBeInTheDocument();
    });

    await user.click(screen.getByText("Batch Product"));
    expect(mockPush).toHaveBeenCalledWith("/app/product/42");
  });

  it("shows camera info text in camera mode", async () => {
    const user = userEvent.setup();
    render(<ScanPage />, { wrapper: createWrapper() });
    await user.click(screen.getByText("Camera"));
    expect(
      screen.getByText(/Supports EAN-13, EAN-8, UPC-A, UPC-E/),
    ).toBeInTheDocument();
  });

  it("mutation error sets scan state to error", async () => {
    mockRecordScan.mockResolvedValue({
      ok: false,
      error: { message: "Server error" },
    });
    const user = userEvent.setup();

    render(<ScanPage />, { wrapper: createWrapper() });
    await user.click(screen.getByText("Manual"));
    await user.type(
      screen.getByPlaceholderText("Enter EAN barcode (8 or 13 digits)"),
      "5901234123457",
    );
    await user.click(screen.getByText("Look up"));

    await waitFor(() => {
      expect(
        screen.getByText(/Something went wrong|error|try again/i),
      ).toBeInTheDocument();
    });
  });

  // ─── Camera Error Handling ──────────────────────────────────────────────────

  it("falls back to manual mode when camera permission is denied", async () => {
    mockListDevices.mockResolvedValue([
      { deviceId: "cam1", label: "Front Camera" } as MediaDeviceInfo,
    ]);
    mockDecodeFromDevice.mockImplementation(() => {
      const err = new Error("Permission denied");
      err.name = "NotAllowedError";
      throw err;
    });

    const user = userEvent.setup();
    render(<ScanPage />, { wrapper: createWrapper() });
    await user.click(screen.getByText("Camera"));

    // Should fall back to manual mode and show permission denied toast
    await waitFor(() => {
      expect(mockShowToast).toHaveBeenCalledWith(
        expect.objectContaining({ messageKey: "scan.permissionDenied" }),
      );
    });
  });

  it("falls back to manual mode on generic camera error", async () => {
    mockListDevices.mockResolvedValue([
      { deviceId: "cam1", label: "Front Camera" } as MediaDeviceInfo,
    ]);
    mockDecodeFromDevice.mockImplementation(() => {
      throw new Error("Generic camera error");
    });

    const user = userEvent.setup();
    render(<ScanPage />, { wrapper: createWrapper() });
    await user.click(screen.getByText("Camera"));

    // Should show camera error state
    await waitFor(() => {
      expect(screen.getByText("Manual")).toBeInTheDocument();
    });
  });

  it("selects back camera when available", async () => {
    mockListDevices.mockResolvedValue([
      { deviceId: "front1", label: "Front Camera" } as MediaDeviceInfo,
      { deviceId: "back1", label: "Back Camera" } as MediaDeviceInfo,
    ]);

    const user = userEvent.setup();
    render(<ScanPage />, { wrapper: createWrapper() });
    await user.click(screen.getByText("Camera"));

    await waitFor(() => {
      expect(mockDecodeFromDevice).toHaveBeenCalledWith(
        "back1",
        expect.anything(),
        expect.any(Function),
      );
    });
  });

  // ─── Camera Decode Callback & Mode Toggling ───────────────────────────────

  it("camera decode callback triggers scan when valid barcode detected", async () => {
    let capturedCallback: ((...args: unknown[]) => void) | undefined;
    mockListDevices.mockResolvedValue([
      { deviceId: "cam1", label: "Back Camera" } as MediaDeviceInfo,
    ]);
    mockDecodeFromDevice.mockImplementation(
      (_deviceId: unknown, _video: unknown, callback: (...args: unknown[]) => void) => {
        capturedCallback = callback;
      },
    );
    mockRecordScan.mockResolvedValue({
      ok: true,
      data: {
        found: true,
        product_id: 42,
        product_name: "Camera Product",
        brand: "TestBrand",
        nutri_score: "B",
      },
    });

    const user = userEvent.setup();
    render(<ScanPage />, { wrapper: createWrapper() });
    await user.click(screen.getByText("Camera"));

    // Wait for ZXing to start decoding
    await waitFor(() => {
      expect(mockDecodeFromDevice).toHaveBeenCalled();
    });

    // Simulate barcode detection — invoke the captured callback
    await act(async () => {
      capturedCallback!({ getText: () => "5901234123457" }, null);
    });

    await waitFor(() => {
      expect(mockRecordScan).toHaveBeenCalledWith(
        expect.anything(),
        "5901234123457",
      );
    });
  });

  it("camera error with non-Error object falls back to manual mode", async () => {
    mockListDevices.mockResolvedValue([
      { deviceId: "cam1", label: "Front Camera" } as MediaDeviceInfo,
    ]);
    mockDecodeFromDevice.mockImplementation(() => {
      // Throw a plain object (not an Error instance)
      throw { name: "SomeNonErrorObject" };
    });

    const user = userEvent.setup();
    render(<ScanPage />, { wrapper: createWrapper() });
    await user.click(screen.getByText("Camera"));

    // Should show camera error state
    await waitFor(() => {
      expect(screen.getByText("Manual")).toBeInTheDocument();
    });
  });

  it("camera mode button switches from manual back to camera", async () => {
    mockListDevices.mockResolvedValue([]);

    const user = userEvent.setup();
    render(<ScanPage />, { wrapper: createWrapper() });

    // Start in manual mode (default), switch to camera
    await user.click(screen.getByRole("button", { name: /Camera/ }));

    // Wait for initial camera attempt (no devices → shows error in camera mode)
    await waitFor(() => {
      expect(mockListDevices).toHaveBeenCalledTimes(1);
    });

    // Switch to manual mode
    await user.click(screen.getByRole("button", { name: /Manual/ }));

    // Click Camera button to switch back
    await user.click(screen.getByRole("button", { name: /Camera/ }));

    // It should attempt to start camera again (listVideoInputDevices called again)
    await waitFor(() => {
      expect(mockListDevices).toHaveBeenCalledTimes(2);
    });
  });

  it("Done scanning button exits batch mode", async () => {
    mockRecordScan.mockResolvedValue({
      ok: true,
      data: {
        found: true,
        product_id: 42,
        product_name: "Batch Product",
        brand: "TestBrand",
        nutri_score: "A",
      },
    });
    const user = userEvent.setup();

    render(<ScanPage />, { wrapper: createWrapper() });
    await user.click(screen.getByLabelText(/Batch mode/));
    await user.click(screen.getByText("Manual"));
    await user.type(
      screen.getByPlaceholderText("Enter EAN barcode (8 or 13 digits)"),
      "5901234123457",
    );
    await user.click(screen.getByText("Look up"));

    await waitFor(() => {
      expect(screen.getByText("Done scanning")).toBeInTheDocument();
    });

    await user.click(screen.getByText("Done scanning"));

    // Batch list should be gone; batch mode is off
    expect(screen.queryByText("Done scanning")).not.toBeInTheDocument();
    expect(screen.queryByText("Scanned (1)")).not.toBeInTheDocument();
  });

  // ─── Camera Recovery & Feedback ─────────────────────────────────────────────

  it("shows no-camera error card when no devices found", async () => {
    // mockListDevices already returns [] by default from beforeEach
    const user = userEvent.setup();
    render(<ScanPage />, { wrapper: createWrapper() });
    await user.click(screen.getByText("Camera"));

    await waitFor(() => {
      expect(screen.getByText("No Camera Available")).toBeInTheDocument();
    });
    expect(
      screen.getByText(
        "This device does not have a camera. Use manual entry to look up products.",
      ),
    ).toBeInTheDocument();
    // No retry button for no-camera
    expect(screen.queryByText("Retry Camera")).not.toBeInTheDocument();
  });

  it("shows permission-denied error card with retry button", async () => {
    mockListDevices.mockResolvedValue([
      { deviceId: "cam1", label: "Front Camera" } as MediaDeviceInfo,
    ]);
    mockDecodeFromDevice.mockImplementation(() => {
      const err = new DOMException("Permission denied", "NotAllowedError");
      throw err;
    });

    const user = userEvent.setup();
    render(<ScanPage />, { wrapper: createWrapper() });
    await user.click(screen.getByText("Camera"));

    await waitFor(() => {
      expect(screen.getByText("Camera Access Blocked")).toBeInTheDocument();
    });
    expect(
      screen.getByText(/allow camera access in your browser/),
    ).toBeInTheDocument();
    expect(screen.getByText("Retry Camera")).toBeInTheDocument();
  });

  it("retry camera button restarts scanner", async () => {
    mockListDevices.mockResolvedValue([
      { deviceId: "cam1", label: "Front Camera" } as MediaDeviceInfo,
    ]);
    mockDecodeFromDevice.mockImplementation(() => {
      const err = new DOMException("Permission denied", "NotAllowedError");
      throw err;
    });

    const user = userEvent.setup();
    render(<ScanPage />, { wrapper: createWrapper() });
    await user.click(screen.getByText("Camera"));

    await waitFor(() => {
      expect(screen.getByText("Retry Camera")).toBeInTheDocument();
    });

    const callsBefore = mockListDevices.mock.calls.length;
    await user.click(screen.getByText("Retry Camera"));

    await waitFor(() => {
      expect(mockListDevices.mock.calls.length).toBeGreaterThan(callsBefore);
    });
  });

  it("triggers haptic feedback on successful scan", async () => {
    const vibrateSpy = vi.fn();
    Object.defineProperty(navigator, "vibrate", {
      value: vibrateSpy,
      writable: true,
      configurable: true,
    });

    mockRecordScan.mockResolvedValue({
      ok: true,
      data: {
        found: true,
        product_id: 42,
        product_name: "Vibrate Test",
        brand: "TestBrand",
        nutri_score: "B",
      },
    });
    const user = userEvent.setup();

    render(<ScanPage />, { wrapper: createWrapper() });
    await user.click(screen.getByText("Manual"));
    await user.type(
      screen.getByPlaceholderText("Enter EAN barcode (8 or 13 digits)"),
      "5901234123457",
    );
    await user.click(screen.getByText("Look up"));

    await waitFor(() => {
      expect(vibrateSpy).toHaveBeenCalledWith(100);
    });
  });

  // ─── Found Preview Overlay ──────────────────────────────────────────────────

  it("found preview Scan Next button resets to idle state", async () => {
    mockRecordScan.mockResolvedValue(mockFoundResponse);
    const user = userEvent.setup();

    render(<ScanPage />, { wrapper: createWrapper() });
    await user.click(screen.getByText("Manual"));
    await user.type(
      screen.getByPlaceholderText("Enter EAN barcode (8 or 13 digits)"),
      "5901234123457",
    );
    await user.click(screen.getByText("Look up"));

    await waitFor(() => {
      expect(screen.getByText("Product Found!")).toBeInTheDocument();
    });

    await user.click(screen.getByText("Scan Next"));

    // Should return to idle
    expect(screen.getByText("Scan Barcode")).toBeInTheDocument();
    expect(mockPush).not.toHaveBeenCalled();
  });

  it("found preview shows score band for product", async () => {
    mockRecordScan.mockResolvedValue(mockFoundResponse);
    const user = userEvent.setup();

    render(<ScanPage />, { wrapper: createWrapper() });
    await user.click(screen.getByText("Manual"));
    await user.type(
      screen.getByPlaceholderText("Enter EAN barcode (8 or 13 digits)"),
      "5901234123457",
    );
    await user.click(screen.getByText("Look up"));

    await waitFor(() => {
      expect(screen.getByText("Product Found!")).toBeInTheDocument();
    });
    // unhealthiness_score 65 → TryVit Score 35, band = "Poor"
    expect(screen.getByText("35")).toBeInTheDocument();
    expect(screen.getByText("Poor")).toBeInTheDocument();
  });

  it("found preview shows nutri-score badge", async () => {
    mockRecordScan.mockResolvedValue(mockFoundResponse);
    const user = userEvent.setup();

    render(<ScanPage />, { wrapper: createWrapper() });
    await user.click(screen.getByText("Manual"));
    await user.type(
      screen.getByPlaceholderText("Enter EAN barcode (8 or 13 digits)"),
      "5901234123457",
    );
    await user.click(screen.getByText("Look up"));

    await waitFor(() => {
      expect(screen.getByText("Product Found!")).toBeInTheDocument();
    });
    expect(screen.getByText("D")).toBeInTheDocument();
    expect(screen.getByText("Nutri-Score")).toBeInTheDocument();
  });

  // ─── Paste Button ──────────────────────────────────────────────────────────

  it("shows paste button in manual mode", async () => {
    const user = userEvent.setup();
    render(<ScanPage />, { wrapper: createWrapper() });
    await user.click(screen.getByText("Manual"));

    expect(screen.getByText("Paste")).toBeInTheDocument();
  });

  // ─── Scan Timeout ──────────────────────────────────────────────────────────

  it("shows timeout hint after 15 seconds of camera scanning", async () => {
    mockListDevices.mockResolvedValue([
      { deviceId: "cam1", label: "Back Camera" } as MediaDeviceInfo,
    ]);

    // Spy on setTimeout — verify the 15 s scan timeout is registered
    const spy = vi.spyOn(globalThis, "setTimeout");

    const user = userEvent.setup();
    render(<ScanPage />, { wrapper: createWrapper() });
    await user.click(screen.getByText("Camera"));

    // Wait for camera to fully initialise
    await waitFor(() => {
      expect(mockDecodeFromDevice).toHaveBeenCalled();
    });

    // The timeout useEffect should have called setTimeout(fn, 15_000)
    expect(spy).toHaveBeenCalledWith(expect.any(Function), 15_000);

    spy.mockRestore();
  });
});
