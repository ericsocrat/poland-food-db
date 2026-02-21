import { describe, it, expect, vi, beforeEach, afterEach } from "vitest";

// ─── Mocks ──────────────────────────────────────────────────────────────────

const mockRecognize = vi.fn();
const mockTerminate = vi.fn();
const mockCreateWorker = vi.fn();

vi.mock("tesseract.js", () => ({
  createWorker: (...args: unknown[]) => mockCreateWorker(...args),
}));

import {
  initOCR,
  extractText,
  terminateOCR,
  isOCRReady,
  CONFIDENCE,
  OCR_TIMEOUT_MS,
} from "./engine";

// ─── Helpers ─────────────────────────────────────────────────────────────────

function makeFakeWorker() {
  return {
    recognize: mockRecognize,
    terminate: mockTerminate,
  };
}

function makeRecognizeResult(text = "Mleko 3.2%", confidence = 85, words: Array<{ text: string; confidence: number }> = []) {
  const wordResults = words.length > 0
    ? words.map((w) => ({
        text: w.text,
        confidence: w.confidence,
        bbox: { x0: 0, y0: 0, x1: 100, y1: 20 },
      }))
    : [
        { text: "Mleko", confidence: 90, bbox: { x0: 0, y0: 0, x1: 50, y1: 20 } },
        { text: "3.2%", confidence: 80, bbox: { x0: 55, y0: 0, x1: 100, y1: 20 } },
      ];

  return {
    data: {
      text: `  ${text}  `,
      confidence,
      words: wordResults,
    },
  };
}

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("engine", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mockCreateWorker.mockResolvedValue(makeFakeWorker());
    mockRecognize.mockResolvedValue(makeRecognizeResult());
    mockTerminate.mockResolvedValue(undefined);
  });

  afterEach(async () => {
    // Ensure worker is terminated between tests to reset module state
    await terminateOCR();
  });

  // ── Constants ────────────────────────────────────────────────────────────

  describe("constants", () => {
    it("exports confidence thresholds", () => {
      expect(CONFIDENCE.HIGH).toBe(80);
      expect(CONFIDENCE.LOW).toBe(50);
      expect(CONFIDENCE.UNUSABLE).toBe(30);
    });

    it("exports OCR timeout", () => {
      expect(OCR_TIMEOUT_MS).toBe(15_000);
    });
  });

  // ── initOCR ──────────────────────────────────────────────────────────────

  describe("initOCR", () => {
    it("creates a worker on first call", async () => {
      await initOCR();
      expect(mockCreateWorker).toHaveBeenCalledOnce();
      expect(mockCreateWorker).toHaveBeenCalledWith(
        "pol+eng",
        undefined,
        expect.objectContaining({
          workerPath: expect.stringContaining("tesseract.js"),
          langPath: expect.stringContaining("tessdata"),
          corePath: expect.stringContaining("tesseract-core"),
        }),
      );
    });

    it("does not create a second worker on repeated calls", async () => {
      await initOCR();
      await initOCR();
      expect(mockCreateWorker).toHaveBeenCalledOnce();
    });

    it("marks OCR as ready after init", async () => {
      expect(isOCRReady()).toBe(false);
      await initOCR();
      expect(isOCRReady()).toBe(true);
    });
  });

  // ── extractText ──────────────────────────────────────────────────────────

  describe("extractText", () => {
    it("auto-initialises worker if not already ready", async () => {
      const blob = new Blob(["fake image"], { type: "image/png" });
      const result = await extractText(blob);

      expect(mockCreateWorker).toHaveBeenCalledOnce();
      expect(result.text).toBe("Mleko 3.2%");
    });

    it("uses existing worker without re-initialising", async () => {
      await initOCR();
      const blob = new Blob(["fake"], { type: "image/png" });
      await extractText(blob);
      // createWorker only from initOCR, not again from extractText
      expect(mockCreateWorker).toHaveBeenCalledOnce();
    });

    it("returns trimmed text", async () => {
      const blob = new Blob(["fake"], { type: "image/png" });
      const result = await extractText(blob);
      expect(result.text).toBe("Mleko 3.2%");
    });

    it("returns overall confidence", async () => {
      const blob = new Blob(["fake"], { type: "image/png" });
      const result = await extractText(blob);
      expect(result.confidence).toBe(85);
    });

    it("maps individual word results", async () => {
      mockRecognize.mockResolvedValue(
        makeRecognizeResult("cukier mąka", 78, [
          { text: "cukier", confidence: 88 },
          { text: "mąka", confidence: 68 },
        ]),
      );
      const blob = new Blob(["fake"], { type: "image/png" });
      const result = await extractText(blob);

      expect(result.words).toHaveLength(2);
      expect(result.words[0].text).toBe("cukier");
      expect(result.words[0].confidence).toBe(88);
      expect(result.words[1].text).toBe("mąka");
      expect(result.words[1].bbox).toEqual(
        expect.objectContaining({ x0: 0, y0: 0 }),
      );
    });

    it("throws if recognition fails", async () => {
      mockRecognize.mockRejectedValue(new Error("recognition error"));
      const blob = new Blob(["fake"], { type: "image/png" });
      await expect(extractText(blob)).rejects.toThrow("recognition error");
    });
  });

  // ── terminateOCR ─────────────────────────────────────────────────────────

  describe("terminateOCR", () => {
    it("terminates an active worker", async () => {
      await initOCR();
      await terminateOCR();
      expect(mockTerminate).toHaveBeenCalledOnce();
      expect(isOCRReady()).toBe(false);
    });

    it("is a no-op if no worker exists", async () => {
      await terminateOCR();
      expect(mockTerminate).not.toHaveBeenCalled();
    });

    it("allows re-initialisation after termination", async () => {
      await initOCR();
      await terminateOCR();
      await initOCR();
      expect(mockCreateWorker).toHaveBeenCalledTimes(2);
      expect(isOCRReady()).toBe(true);
    });
  });

  // ── isOCRReady ───────────────────────────────────────────────────────────

  describe("isOCRReady", () => {
    it("returns false before init", () => {
      expect(isOCRReady()).toBe(false);
    });

    it("returns true after init", async () => {
      await initOCR();
      expect(isOCRReady()).toBe(true);
    });

    it("returns false after terminate", async () => {
      await initOCR();
      await terminateOCR();
      expect(isOCRReady()).toBe(false);
    });
  });
});
