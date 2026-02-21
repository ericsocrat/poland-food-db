/**
 * OCR Engine — Client-side text extraction via Tesseract.js (WASM).
 * Issue #55 — Image Search v0
 *
 * Images are NEVER uploaded to any server. All processing is ephemeral.
 * Tesseract.js is lazily loaded only when the user initiates OCR.
 *
 * Supports Polish (pol) and English (eng) for accurate diacritics
 * (ą, ć, ę, ł, ń, ó, ś, ź, ż).
 */

import type { Worker } from "tesseract.js";

/* ── Types ────────────────────────────────────────────────────────────────── */

export interface OCRWord {
  text: string;
  confidence: number;
  bbox: { x0: number; y0: number; x1: number; y1: number };
}

export interface OCRResult {
  /** Full extracted text, trimmed */
  text: string;
  /** Overall confidence 0–100 */
  confidence: number;
  /** Individual word results with bounding boxes */
  words: OCRWord[];
}

/* ── Constants ────────────────────────────────────────────────────────────── */

/** Languages to load — Polish + English */
const OCR_LANGUAGES = "pol+eng";

/** Maximum time (ms) before OCR times out */
export const OCR_TIMEOUT_MS = 15_000;

/** Confidence thresholds for UI indicators */
export const CONFIDENCE = {
  HIGH: 80,
  LOW: 50,
  UNUSABLE: 30,
} as const;

/* ── Worker lifecycle ─────────────────────────────────────────────────────── */

let worker: Worker | null = null;

/**
 * Lazily initialise the Tesseract OCR worker.
 * Downloads WASM + trained data from CDN on first call.
 */
export async function initOCR(): Promise<void> {
  if (worker) return;
  const { createWorker } = await import("tesseract.js");
  worker = await createWorker(OCR_LANGUAGES, undefined, {
    workerPath:
      "https://cdn.jsdelivr.net/npm/tesseract.js@5/dist/worker.min.js",
    langPath: "https://tessdata.projectnaptha.com/4.0.0",
    corePath:
      "https://cdn.jsdelivr.net/npm/tesseract.js-core@5/tesseract-core-simd-lstm.wasm.js",
  });
}

/**
 * Run OCR on the given image source.
 * Initialises the worker lazily if not already running.
 *
 * @throws Error if worker cannot be created or recognition fails
 */
export async function extractText(
  imageData: Blob | File | HTMLCanvasElement,
): Promise<OCRResult> {
  if (!worker) await initOCR();

  const result = await worker!.recognize(imageData);

  return {
    text: result.data.text.trim(),
    confidence: result.data.confidence,
    words: result.data.words.map((w) => ({
      text: w.text,
      confidence: w.confidence,
      bbox: w.bbox,
    })),
  };
}

/**
 * Terminate the OCR worker and release WASM memory.
 * Safe to call multiple times (no-op if already terminated).
 */
export async function terminateOCR(): Promise<void> {
  if (worker) {
    await worker.terminate();
    worker = null;
  }
}

/**
 * Check if the OCR worker is currently initialised.
 * Useful for showing loading indicators.
 */
export function isOCRReady(): boolean {
  return worker !== null;
}
