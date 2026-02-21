import { describe, it, expect, vi } from "vitest";
import { render, screen, fireEvent } from "@testing-library/react";

// ── Mocks ────────────────────────────────────────────────────────────────────

vi.mock("@/lib/i18n", () => ({
  useTranslation: () => ({
    t: (key: string, params?: Record<string, unknown>) => {
      if (params) {
        return Object.entries(params).reduce(
          (acc, [k, v]) => acc.replace(`{${k}}`, String(v)),
          key,
        );
      }
      return key;
    },
  }),
}));

import { OCRResults } from "./OCRResults";
import type { OCRResult } from "@/lib/ocr";

// ── Helpers ──────────────────────────────────────────────────────────────────

function makeResult(overrides?: Partial<OCRResult>): OCRResult {
  return {
    text: "Cukier mąka masło",
    confidence: 85,
    words: [
      { text: "Cukier", confidence: 90, bbox: { x0: 0, y0: 0, x1: 50, y1: 20 } },
      { text: "mąka", confidence: 80, bbox: { x0: 55, y0: 0, x1: 100, y1: 20 } },
      { text: "masło", confidence: 85, bbox: { x0: 105, y0: 0, x1: 150, y1: 20 } },
    ],
    ...overrides,
  };
}

// ── Tests ────────────────────────────────────────────────────────────────────

describe("OCRResults", () => {
  it("renders extracted text title", () => {
    render(
      <OCRResults result={makeResult()} onSearch={vi.fn()} onRetry={vi.fn()} />,
    );
    expect(screen.getByText("imageSearch.results.title")).toBeInTheDocument();
  });

  it("renders confidence badge", () => {
    render(
      <OCRResults result={makeResult()} onSearch={vi.fn()} onRetry={vi.fn()} />,
    );
    const badge = screen.getByTestId("confidence-badge");
    expect(badge).toBeInTheDocument();
    // Mock t returns key with params interpolated
    expect(badge).toHaveTextContent("confidence");
  });

  it("renders extracted text in textarea", () => {
    render(
      <OCRResults result={makeResult()} onSearch={vi.fn()} onRetry={vi.fn()} />,
    );
    const textarea = screen.getByTestId("ocr-text");
    expect(textarea).toHaveValue("Cukier mąka masło");
  });

  it("allows editing extracted text", () => {
    render(
      <OCRResults result={makeResult()} onSearch={vi.fn()} onRetry={vi.fn()} />,
    );
    const textarea = screen.getByTestId("ocr-text");
    fireEvent.change(textarea, { target: { value: "mleko cukier" } });
    expect(textarea).toHaveValue("mleko cukier");
  });

  it("calls onSearch with edited text when search button clicked", () => {
    const onSearch = vi.fn();
    render(
      <OCRResults result={makeResult()} onSearch={onSearch} onRetry={vi.fn()} />,
    );

    const textarea = screen.getByTestId("ocr-text");
    fireEvent.change(textarea, { target: { value: "mleko" } });
    fireEvent.click(screen.getByTestId("search-btn"));

    expect(onSearch).toHaveBeenCalledWith("mleko");
  });

  it("calls onRetry when retry button clicked", () => {
    const onRetry = vi.fn();
    render(
      <OCRResults result={makeResult()} onSearch={vi.fn()} onRetry={onRetry} />,
    );
    fireEvent.click(screen.getByTestId("retry-btn"));
    expect(onRetry).toHaveBeenCalledOnce();
  });

  it("disables search button when text is empty", () => {
    render(
      <OCRResults
        result={makeResult({ text: "" })}
        onSearch={vi.fn()}
        onRetry={vi.fn()}
      />,
    );
    expect(screen.getByTestId("search-btn")).toBeDisabled();
  });

  it("shows low confidence warning when below threshold", () => {
    render(
      <OCRResults
        result={makeResult({ confidence: 40 })}
        onSearch={vi.fn()}
        onRetry={vi.fn()}
      />,
    );
    expect(screen.getByTestId("low-confidence-warning")).toBeInTheDocument();
  });

  it("does not show low confidence warning when above threshold", () => {
    render(
      <OCRResults
        result={makeResult({ confidence: 85 })}
        onSearch={vi.fn()}
        onRetry={vi.fn()}
      />,
    );
    expect(screen.queryByTestId("low-confidence-warning")).not.toBeInTheDocument();
  });

  it("shows empty text warning when no text extracted", () => {
    render(
      <OCRResults
        result={makeResult({ text: "   " })}
        onSearch={vi.fn()}
        onRetry={vi.fn()}
      />,
    );
    expect(screen.getByTestId("empty-text-warning")).toBeInTheDocument();
  });

  it("renders privacy confirmation message", () => {
    render(
      <OCRResults result={makeResult()} onSearch={vi.fn()} onRetry={vi.fn()} />,
    );
    expect(
      screen.getByText("imageSearch.results.imageDeleted"),
    ).toBeInTheDocument();
  });

  it("applies green class for high confidence", () => {
    render(
      <OCRResults
        result={makeResult({ confidence: 90 })}
        onSearch={vi.fn()}
        onRetry={vi.fn()}
      />,
    );
    const badge = screen.getByTestId("confidence-badge");
    expect(badge.className).toContain("text-success");
  });

  it("applies yellow class for medium confidence", () => {
    render(
      <OCRResults
        result={makeResult({ confidence: 65 })}
        onSearch={vi.fn()}
        onRetry={vi.fn()}
      />,
    );
    const badge = screen.getByTestId("confidence-badge");
    expect(badge.className).toContain("text-warning");
  });

  it("applies red class for low confidence", () => {
    render(
      <OCRResults
        result={makeResult({ confidence: 30 })}
        onSearch={vi.fn()}
        onRetry={vi.fn()}
      />,
    );
    const badge = screen.getByTestId("confidence-badge");
    expect(badge.className).toContain("text-error");
  });
});
