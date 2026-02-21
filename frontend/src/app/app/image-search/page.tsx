"use client";

// ─── Image Search page — OCR-only prototype with privacy guardrails ──────────
// Issue #55 — Image Search v0
//
// Flow:
// 1. Privacy consent → 2. Capture/Upload → 3. OCR → 4. Review text → 5. Search
//
// All image processing is client-side. No images are ever uploaded.

import { useState, useCallback, useEffect, useRef } from "react";
import { useRouter } from "next/navigation";
import { useTranslation } from "@/lib/i18n";
import { Breadcrumbs } from "@/components/layout/Breadcrumbs";
import { LoadingSpinner } from "@/components/common/LoadingSpinner";
import { PrivacyNotice, ImageCapture, OCRResults } from "@/components/ocr";
import {
  extractText,
  buildSearchQuery,
  initOCR,
  terminateOCR,
  hasPrivacyConsent,
  acceptPrivacyConsent,
  releaseImageData,
  CONFIDENCE,
} from "@/lib/ocr";
import type { OCRResult } from "@/lib/ocr";

/* ── Step union ───────────────────────────────────────────────────────────── */

type Step = "capture" | "processing" | "results";

/* ── Component ────────────────────────────────────────────────────────────── */

export default function ImageSearchPage() {
  const { t } = useTranslation();
  const router = useRouter();

  const [showPrivacy, setShowPrivacy] = useState(false);
  const [step, setStep] = useState<Step>("capture");
  const [ocrResult, setOcrResult] = useState<OCRResult | null>(null);
  const [error, setError] = useState<string | null>(null);

  // Track object URLs for cleanup
  const objectUrlRef = useRef<string | null>(null);

  // Check privacy consent on mount (SSR-safe: hasPrivacyConsent returns true server-side)
  useEffect(() => {
    if (!hasPrivacyConsent()) {
      setShowPrivacy(true);
    }
  }, []);

  // Pre-warm OCR worker after consent
  useEffect(() => {
    if (!showPrivacy && hasPrivacyConsent()) {
      // Pre-warm in background — don't block UI
      initOCR().catch(() => {
        // Non-critical — worker will init on first capture
      });
    }
  }, [showPrivacy]);

  // Cleanup on unmount
  useEffect(() => {
    return () => {
      terminateOCR().catch(() => {});
      if (objectUrlRef.current) {
        releaseImageData({ objectUrl: objectUrlRef.current });
        objectUrlRef.current = null;
      }
    };
  }, []);

  const handleAcceptPrivacy = useCallback(() => {
    acceptPrivacyConsent();
    setShowPrivacy(false);
  }, []);

  const handleCapture = useCallback(async (blob: Blob) => {
    setStep("processing");
    setError(null);

    try {
      const result = await extractText(blob);
      setOcrResult(result);
      setStep("results");
    } catch (err) {
      setError(
        err instanceof Error ? err.message : "OCR processing failed",
      );
      setStep("capture");
    } finally {
      // Release image data immediately after OCR
      releaseImageData({ blob });
    }
  }, []);

  const handleSearch = useCallback(
    (text: string) => {
      const { query } = buildSearchQuery(text);
      if (query.length > 0) {
        router.push(`/app/search?q=${encodeURIComponent(query)}`);
      }
    },
    [router],
  );

  const handleRetry = useCallback(() => {
    setOcrResult(null);
    setError(null);
    setStep("capture");
  }, []);

  return (
    <div>
      <Breadcrumbs
        items={[
          { labelKey: "nav.home", href: "/app" },
          { labelKey: "nav.imageSearch" },
        ]}
      />

      {/* Header */}
      <div className="mb-6 flex items-center gap-3">
        <h1 className="text-xl font-bold text-foreground lg:text-2xl">
          {t("imageSearch.title")}
        </h1>
        <span className="rounded-full bg-brand/10 px-2.5 py-0.5 text-xs font-semibold text-brand" data-testid="beta-badge">
          {t("imageSearch.beta")}
        </span>
      </div>

      <p className="mb-6 text-sm text-foreground-secondary">
        {t("imageSearch.description")}
      </p>

      {/* Privacy consent dialog */}
      <PrivacyNotice open={showPrivacy} onAccept={handleAcceptPrivacy} />

      {/* Error banner */}
      {error && (
        <div
          className="mb-4 rounded-lg border border-error/20 bg-error/5 px-4 py-3 text-sm text-error"
          role="alert"
          data-testid="ocr-error"
        >
          <p className="font-medium">{t("imageSearch.ocrFailed")}</p>
          <p className="mt-1 text-xs">{error}</p>
        </div>
      )}

      {/* Step: Capture */}
      {step === "capture" && !showPrivacy && (
        <ImageCapture
          onCapture={handleCapture}
          processing={false}
        />
      )}

      {/* Step: Processing */}
      {step === "processing" && (
        <div
          className="flex flex-col items-center gap-4 py-12"
          data-testid="ocr-processing"
        >
          <LoadingSpinner size="lg" />
          <p className="text-sm text-foreground-secondary">
            {t("imageSearch.processing")}
          </p>
          <p className="text-xs text-foreground-muted">
            {t("imageSearch.processingDetail")}
          </p>
        </div>
      )}

      {/* Step: Results */}
      {step === "results" && ocrResult && (
        <OCRResults
          result={ocrResult}
          onSearch={handleSearch}
          onRetry={handleRetry}
        />
      )}

      {/* Unusable result tip */}
      {step === "results" &&
        ocrResult &&
        ocrResult.confidence < CONFIDENCE.UNUSABLE && (
          <div className="mt-4 rounded-lg border border-warning/20 bg-warning/5 px-4 py-3 text-sm text-warning">
            {t("imageSearch.unusableTip")}
          </div>
        )}
    </div>
  );
}
