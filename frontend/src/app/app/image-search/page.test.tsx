import { describe, it, expect, vi, beforeEach } from "vitest";
import { render, screen, fireEvent, waitFor, act } from "@testing-library/react";

// ─── Mocks ──────────────────────────────────────────────────────────────────

vi.mock("@/lib/i18n", () => ({
  useTranslation: () => ({
    t: (key: string) => key,
  }),
}));

const mockPush = vi.fn();
vi.mock("next/navigation", () => ({
  useRouter: () => ({ push: mockPush }),
}));

// Privacy mocks
const mockHasConsent = vi.fn().mockReturnValue(true);
const mockAcceptConsent = vi.fn();
const mockRevokeConsent = vi.fn();
const mockReleaseImageData = vi.fn();
const mockInitOCR = vi.fn().mockResolvedValue(undefined);
const mockTerminateOCR = vi.fn().mockResolvedValue(undefined);
const mockExtractText = vi.fn();
const mockBuildSearchQuery = vi.fn();

vi.mock("@/lib/ocr", () => ({
  hasPrivacyConsent: () => mockHasConsent(),
  acceptPrivacyConsent: () => mockAcceptConsent(),
  revokePrivacyConsent: () => mockRevokeConsent(),
  releaseImageData: (...args: unknown[]) => mockReleaseImageData(...args),
  initOCR: () => mockInitOCR(),
  terminateOCR: () => mockTerminateOCR(),
  extractText: (...args: unknown[]) => mockExtractText(...args),
  buildSearchQuery: (...args: unknown[]) => mockBuildSearchQuery(...args),
  isOCRReady: () => true,
  CONFIDENCE: { HIGH: 80, LOW: 50, UNUSABLE: 30 },
  OCR_TIMEOUT_MS: 15000,
}));

vi.mock("@/components/layout/Breadcrumbs", () => ({
  Breadcrumbs: () => <nav data-testid="breadcrumbs" />,
}));

vi.mock("@/components/common/LoadingSpinner", () => ({
  LoadingSpinner: () => <div data-testid="loading-spinner" />,
}));

// Mock components with functional implementations
vi.mock("@/components/ocr", () => ({
  PrivacyNotice: ({
    open,
    onAccept,
  }: {
    open: boolean;
    onAccept: () => void;
  }) =>
    open ? (
      <div data-testid="privacy-notice">
        <button data-testid="accept-privacy" onClick={onAccept}>
          Accept
        </button>
      </div>
    ) : null,
  ImageCapture: ({
    onCapture,
    processing,
  }: {
    onCapture: (blob: Blob) => void;
    processing: boolean;
  }) => (
    <div data-testid="image-capture">
      <button
        data-testid="mock-capture"
        disabled={processing}
        onClick={() => onCapture(new Blob(["fake"], { type: "image/jpeg" }))}
      >
        Capture
      </button>
    </div>
  ),
  OCRResults: ({
    result,
    onSearch,
    onRetry,
  }: {
    result: { text: string; confidence: number };
    onSearch: (text: string) => void;
    onRetry: () => void;
  }) => (
    <div data-testid="ocr-results">
      <span data-testid="result-text">{result.text}</span>
      <span data-testid="result-confidence">{result.confidence}</span>
      <button data-testid="mock-search" onClick={() => onSearch(result.text)}>
        Search
      </button>
      <button data-testid="mock-retry" onClick={onRetry}>
        Retry
      </button>
    </div>
  ),
}));

import ImageSearchPage from "./page";

// ─── Helpers ─────────────────────────────────────────────────────────────────

function makeOCRResult(text = "Cukier mąka", confidence = 85) {
  return {
    text,
    confidence,
    words: [
      {
        text: "Cukier",
        confidence: 90,
        bbox: { x0: 0, y0: 0, x1: 50, y1: 20 },
      },
    ],
  };
}

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("ImageSearchPage", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mockHasConsent.mockReturnValue(true);
    mockExtractText.mockResolvedValue(makeOCRResult());
    mockBuildSearchQuery.mockReturnValue({
      cleaned: "cukier mąka",
      tokens: ["cukier", "mąka"],
      query: "cukier mąka",
    });
  });

  it("renders page title", () => {
    render(<ImageSearchPage />);
    expect(screen.getByText("imageSearch.title")).toBeInTheDocument();
  });

  it("renders beta badge", () => {
    render(<ImageSearchPage />);
    expect(screen.getByTestId("beta-badge")).toBeInTheDocument();
    expect(screen.getByTestId("beta-badge")).toHaveTextContent("imageSearch.beta");
  });

  it("renders description", () => {
    render(<ImageSearchPage />);
    expect(screen.getByText("imageSearch.description")).toBeInTheDocument();
  });

  it("renders breadcrumbs", () => {
    render(<ImageSearchPage />);
    expect(screen.getByTestId("breadcrumbs")).toBeInTheDocument();
  });

  // ── Privacy consent flow ──────────────────────────────────────────────

  it("shows privacy notice when no consent", async () => {
    mockHasConsent.mockReturnValue(false);
    render(<ImageSearchPage />);

    await waitFor(() => {
      expect(screen.getByTestId("privacy-notice")).toBeInTheDocument();
    });
  });

  it("hides privacy notice and shows capture after accepting", async () => {
    mockHasConsent.mockReturnValue(false);
    render(<ImageSearchPage />);

    await waitFor(() => {
      expect(screen.getByTestId("privacy-notice")).toBeInTheDocument();
    });

    fireEvent.click(screen.getByTestId("accept-privacy"));
    expect(mockAcceptConsent).toHaveBeenCalledOnce();

    await waitFor(() => {
      expect(screen.queryByTestId("privacy-notice")).not.toBeInTheDocument();
      expect(screen.getByTestId("image-capture")).toBeInTheDocument();
    });
  });

  it("skips privacy notice when consent exists", () => {
    mockHasConsent.mockReturnValue(true);
    render(<ImageSearchPage />);
    expect(screen.queryByTestId("privacy-notice")).not.toBeInTheDocument();
    expect(screen.getByTestId("image-capture")).toBeInTheDocument();
  });

  // ── Capture → OCR flow ────────────────────────────────────────────────

  it("shows processing state during OCR", async () => {
    // Make extractText hang
    mockExtractText.mockReturnValue(new Promise(() => {}));
    render(<ImageSearchPage />);

    await act(async () => {
      fireEvent.click(screen.getByTestId("mock-capture"));
    });

    expect(screen.getByTestId("ocr-processing")).toBeInTheDocument();
    expect(screen.getByText("imageSearch.processing")).toBeInTheDocument();
  });

  it("shows OCR results after successful extraction", async () => {
    render(<ImageSearchPage />);

    await act(async () => {
      fireEvent.click(screen.getByTestId("mock-capture"));
    });

    await waitFor(() => {
      expect(screen.getByTestId("ocr-results")).toBeInTheDocument();
    });

    expect(screen.getByTestId("result-text")).toHaveTextContent("Cukier mąka");
  });

  it("releases image data after OCR", async () => {
    render(<ImageSearchPage />);

    await act(async () => {
      fireEvent.click(screen.getByTestId("mock-capture"));
    });

    await waitFor(() => {
      expect(mockReleaseImageData).toHaveBeenCalled();
    });
  });

  it("shows error and returns to capture on OCR failure", async () => {
    mockExtractText.mockRejectedValue(new Error("OCR failed"));
    render(<ImageSearchPage />);

    await act(async () => {
      fireEvent.click(screen.getByTestId("mock-capture"));
    });

    await waitFor(() => {
      expect(screen.getByTestId("ocr-error")).toBeInTheDocument();
      expect(screen.getByTestId("image-capture")).toBeInTheDocument();
    });
  });

  // ── Search navigation ─────────────────────────────────────────────────

  it("navigates to search page with query on search", async () => {
    render(<ImageSearchPage />);

    await act(async () => {
      fireEvent.click(screen.getByTestId("mock-capture"));
    });

    await waitFor(() => {
      expect(screen.getByTestId("ocr-results")).toBeInTheDocument();
    });

    fireEvent.click(screen.getByTestId("mock-search"));
    expect(mockBuildSearchQuery).toHaveBeenCalled();
    expect(mockPush).toHaveBeenCalledWith(
      "/app/search?q=cukier%20m%C4%85ka",
    );
  });

  it("does not navigate when query is empty", async () => {
    mockBuildSearchQuery.mockReturnValue({
      cleaned: "",
      tokens: [],
      query: "",
    });
    render(<ImageSearchPage />);

    await act(async () => {
      fireEvent.click(screen.getByTestId("mock-capture"));
    });

    await waitFor(() => {
      expect(screen.getByTestId("ocr-results")).toBeInTheDocument();
    });

    fireEvent.click(screen.getByTestId("mock-search"));
    expect(mockPush).not.toHaveBeenCalled();
  });

  // ── Retry flow ────────────────────────────────────────────────────────

  it("returns to capture step on retry", async () => {
    render(<ImageSearchPage />);

    await act(async () => {
      fireEvent.click(screen.getByTestId("mock-capture"));
    });

    await waitFor(() => {
      expect(screen.getByTestId("ocr-results")).toBeInTheDocument();
    });

    fireEvent.click(screen.getByTestId("mock-retry"));
    expect(screen.getByTestId("image-capture")).toBeInTheDocument();
  });

  // ── OCR worker lifecycle ──────────────────────────────────────────────

  it("pre-warms OCR worker after privacy consent", async () => {
    mockHasConsent.mockReturnValue(true);
    render(<ImageSearchPage />);

    await waitFor(() => {
      expect(mockInitOCR).toHaveBeenCalled();
    });
  });

  it("terminates OCR worker on unmount", () => {
    const { unmount } = render(<ImageSearchPage />);
    unmount();
    expect(mockTerminateOCR).toHaveBeenCalled();
  });
});
