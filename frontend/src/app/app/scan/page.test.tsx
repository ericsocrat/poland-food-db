import { describe, expect, it, vi, beforeEach } from "vitest";
import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { useState } from "react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import ScanPage from "./page";

// ─── Mocks ──────────────────────────────────────────────────────────────────

const { mockPush, mockRecordScan, mockToast } = vi.hoisted(() => ({
  mockPush: vi.fn(),
  mockRecordScan: vi.fn(),
  mockToast: { error: vi.fn(), success: vi.fn() },
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

// Mock sonner toast
vi.mock("sonner", () => ({
  toast: mockToast,
}));

// Mock ZXing library — prevent actual camera access
vi.mock("@zxing/library", () => ({
  BrowserMultiFormatReader: vi.fn().mockImplementation(() => ({
    listVideoInputDevices: vi.fn().mockResolvedValue([]),
    decodeFromVideoDevice: vi.fn(),
    reset: vi.fn(),
  })),
  DecodeHintType: { POSSIBLE_FORMATS: 0 },
  BarcodeFormat: {
    EAN_13: 0,
    EAN_8: 1,
    UPC_A: 2,
    UPC_E: 3,
  },
}));

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
    brand: "TestBrand",
    category: "chips",
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
});

describe("ScanPage", () => {
  it("renders scan barcode heading", () => {
    render(<ScanPage />, { wrapper: createWrapper() });
    expect(screen.getByText("📷 Scan Barcode")).toBeInTheDocument();
  });

  it("renders camera and manual mode toggle", () => {
    render(<ScanPage />, { wrapper: createWrapper() });
    expect(screen.getByText("📷 Camera")).toBeInTheDocument();
    expect(screen.getByText("⌨️ Manual")).toBeInTheDocument();
  });

  it("renders batch mode checkbox", () => {
    render(<ScanPage />, { wrapper: createWrapper() });
    expect(
      screen.getByText("Batch mode — scan multiple without stopping"),
    ).toBeInTheDocument();
  });

  it("renders history link", () => {
    render(<ScanPage />, { wrapper: createWrapper() });
    const historyLinks = screen.getAllByText("📋 History");
    expect(historyLinks.length).toBeGreaterThan(0);
    expect(historyLinks[0].closest("a")).toHaveAttribute(
      "href",
      "/app/scan/history",
    );
  });

  it("renders submissions link", () => {
    render(<ScanPage />, { wrapper: createWrapper() });
    expect(screen.getByText("📝 My Submissions")).toBeInTheDocument();
    expect(screen.getByText("📝 My Submissions").closest("a")).toHaveAttribute(
      "href",
      "/app/scan/submissions",
    );
  });

  it("switches to manual mode and shows input", async () => {
    const user = userEvent.setup();
    render(<ScanPage />, { wrapper: createWrapper() });

    await user.click(screen.getByText("⌨️ Manual"));

    expect(
      screen.getByPlaceholderText("Enter EAN barcode (8 or 13 digits)"),
    ).toBeInTheDocument();
    expect(screen.getByText("Look up")).toBeInTheDocument();
  });

  it("disables look up button when EAN is too short", async () => {
    const user = userEvent.setup();
    render(<ScanPage />, { wrapper: createWrapper() });

    await user.click(screen.getByText("⌨️ Manual"));

    const input = screen.getByPlaceholderText(
      "Enter EAN barcode (8 or 13 digits)",
    );
    await user.type(input, "123");

    expect(screen.getByText("Look up")).toBeDisabled();
  });

  it("enables look up button when EAN is valid (8+ digits)", async () => {
    const user = userEvent.setup();
    render(<ScanPage />, { wrapper: createWrapper() });

    await user.click(screen.getByText("⌨️ Manual"));

    const input = screen.getByPlaceholderText(
      "Enter EAN barcode (8 or 13 digits)",
    );
    await user.type(input, "12345678");

    expect(screen.getByText("Look up")).toBeEnabled();
  });

  it("submits manual EAN and navigates to product on found", async () => {
    mockRecordScan.mockResolvedValue(mockFoundResponse);
    const user = userEvent.setup();

    render(<ScanPage />, { wrapper: createWrapper() });

    await user.click(screen.getByText("⌨️ Manual"));
    const input = screen.getByPlaceholderText(
      "Enter EAN barcode (8 or 13 digits)",
    );
    await user.type(input, "5901234123457");
    await user.click(screen.getByText("Look up"));

    await waitFor(() => {
      expect(mockPush).toHaveBeenCalledWith("/app/product/42");
    });
  });

  it("shows not-found state with submission CTA", async () => {
    mockRecordScan.mockResolvedValue(mockNotFoundResponse);
    const user = userEvent.setup();

    render(<ScanPage />, { wrapper: createWrapper() });

    await user.click(screen.getByText("⌨️ Manual"));
    const input = screen.getByPlaceholderText(
      "Enter EAN barcode (8 or 13 digits)",
    );
    await user.type(input, "5901234123457");
    await user.click(screen.getByText("Look up"));

    await waitFor(() => {
      expect(screen.getByText("Product not found")).toBeInTheDocument();
    });
    expect(screen.getByText("5901234123457")).toBeInTheDocument();
    expect(screen.getByText("📝 Help us add it!")).toBeInTheDocument();
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

    await user.click(screen.getByText("⌨️ Manual"));
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

    await user.click(screen.getByText("⌨️ Manual"));
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

    await user.click(screen.getByText("⌨️ Manual"));
    await user.type(
      screen.getByPlaceholderText("Enter EAN barcode (8 or 13 digits)"),
      "5901234123457",
    );
    await user.click(screen.getByText("Look up"));

    await waitFor(() => {
      expect(screen.getByText("Lookup failed")).toBeInTheDocument();
    });

    mockRecordScan.mockResolvedValue(mockFoundResponse);
    await user.click(screen.getByText("🔄 Retry"));

    await waitFor(() => {
      expect(mockPush).toHaveBeenCalledWith("/app/product/42");
    });
  });

  it("resets from error state to scan another", async () => {
    mockRecordScan.mockRejectedValueOnce(new Error("fail"));
    const user = userEvent.setup();

    render(<ScanPage />, { wrapper: createWrapper() });

    await user.click(screen.getByText("⌨️ Manual"));
    await user.type(
      screen.getByPlaceholderText("Enter EAN barcode (8 or 13 digits)"),
      "5901234123457",
    );
    await user.click(screen.getByText("Look up"));

    await waitFor(() => {
      expect(screen.getByText("Lookup failed")).toBeInTheDocument();
    });

    await user.click(screen.getByText("Scan another"));

    expect(screen.getByText("📷 Scan Barcode")).toBeInTheDocument();
  });

  it("shows toast error for invalid manual EAN", async () => {
    const user = userEvent.setup();

    render(<ScanPage />, { wrapper: createWrapper() });
    await user.click(screen.getByText("⌨️ Manual"));

    const input = screen.getByPlaceholderText(
      "Enter EAN barcode (8 or 13 digits)",
    );
    // Type exactly 9 digits — not valid (not 8 or 13)
    await user.type(input, "123456789");
    await user.click(screen.getByText("Look up"));

    expect(mockToast.error).toHaveBeenCalledWith(
      "Please enter a valid 8 or 13 digit barcode",
    );
  });

  it("strips non-digits from manual input", async () => {
    const user = userEvent.setup();

    render(<ScanPage />, { wrapper: createWrapper() });
    await user.click(screen.getByText("⌨️ Manual"));

    const input = screen.getByPlaceholderText(
      "Enter EAN barcode (8 or 13 digits)",
    );
    await user.type(input, "590-123-412");

    expect(input).toHaveValue("590123412");
  });

  it("supports barcode format info text", () => {
    render(<ScanPage />, { wrapper: createWrapper() });
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

    await user.click(screen.getByText("⌨️ Manual"));
    await user.type(
      screen.getByPlaceholderText("Enter EAN barcode (8 or 13 digits)"),
      "5901234123457",
    );
    await user.click(screen.getByText("Look up"));

    await waitFor(() => {
      expect(screen.getByText("📝 Help us add it!")).toBeInTheDocument();
    });
    expect(screen.getByText("📝 Help us add it!").closest("a")).toHaveAttribute(
      "href",
      "/app/scan/submit?ean=5901234123457",
    );
  });

  it("shows manual entry hint text", async () => {
    const user = userEvent.setup();
    render(<ScanPage />, { wrapper: createWrapper() });

    await user.click(screen.getByText("⌨️ Manual"));

    expect(
      screen.getByText("Enter 8 digits (EAN-8) or 13 digits (EAN-13)"),
    ).toBeInTheDocument();
  });

  it("disables look up button when EAN is too short", async () => {
    const user = userEvent.setup();
    render(<ScanPage />, { wrapper: createWrapper() });

    await user.click(screen.getByText("⌨️ Manual"));

    await user.type(
      screen.getByPlaceholderText("Enter EAN barcode (8 or 13 digits)"),
      "1234",
    );

    expect(screen.getByRole("button", { name: "Look up" })).toBeDisabled();
  });

  it("enables look up button when EAN has 8+ digits", async () => {
    const user = userEvent.setup();
    render(<ScanPage />, { wrapper: createWrapper() });

    await user.click(screen.getByText("⌨️ Manual"));

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
      },
    });
    const user = userEvent.setup();

    render(<ScanPage />, { wrapper: createWrapper() });
    await user.click(screen.getByText("⌨️ Manual"));
    await user.type(
      screen.getByPlaceholderText("Enter EAN barcode (8 or 13 digits)"),
      "5901234123457",
    );
    await user.click(screen.getByText("Look up"));

    await waitFor(() => {
      expect(mockPush).toHaveBeenCalledWith("/app/product/42");
    });
  });

  it("shows looking-up state with spinner while scan is pending", async () => {
    // Make scan hang indefinitely
    mockRecordScan.mockReturnValue(new Promise(() => {}));
    const user = userEvent.setup();

    render(<ScanPage />, { wrapper: createWrapper() });
    await user.click(screen.getByText("⌨️ Manual"));
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
    await user.click(screen.getByText("⌨️ Manual"));
    await user.type(
      screen.getByPlaceholderText("Enter EAN barcode (8 or 13 digits)"),
      "5901234123457",
    );
    await user.click(screen.getByText("Look up"));

    await waitFor(() => {
      expect(screen.getByText("Batch Product")).toBeInTheDocument();
    });
    expect(screen.getByText("Scanned (1)")).toBeInTheDocument();
    expect(mockToast.success).toHaveBeenCalledWith("✓ Batch Product");
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
    await user.click(screen.getByText("⌨️ Manual"));
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
    await user.click(screen.getByText("⌨️ Manual"));
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
    await user.click(screen.getByText("⌨️ Manual"));
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

  it("shows camera info text in camera mode", () => {
    render(<ScanPage />, { wrapper: createWrapper() });
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
    await user.click(screen.getByText("⌨️ Manual"));
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
});
