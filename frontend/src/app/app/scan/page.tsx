"use client";

// ─── Barcode scanner page — ZXing camera + manual EAN fallback ──────────────
// State machine: idle → scanning → looking-up → found / not-found / error
// Camera lifecycle extracted to useBarcodeScanner hook.
// Error and result views extracted to ScannerErrorState/ScanResultView.

import { Button } from "@/components/common/Button";
import { PullToRefresh } from "@/components/common/PullToRefresh";
import { usePreferences } from "@/components/common/RouteGuard";
import { Breadcrumbs } from "@/components/layout/Breadcrumbs";
import { ScannerErrorState } from "@/components/scan/ScannerErrorState";
import {
    FadeSlideIn,
    ScanErrorView,
    ScanFoundView,
    ScanLookingUpView,
    ScanNotFoundView,
} from "@/components/scan/ScanResultView";
import { useAnalytics } from "@/hooks/use-analytics";
import { useBarcodeScanner } from "@/hooks/use-barcode-scanner";
import { recordScan } from "@/lib/api";
import { NUTRI_COLORS } from "@/lib/constants";
import { eventBus } from "@/lib/events";
import { useTranslation } from "@/lib/i18n";
import { createClient } from "@/lib/supabase/client";
import { showToast } from "@/lib/toast";
import type {
    FormSubmitEvent,
    RecordScanFoundResponse,
    RecordScanNotFoundResponse,
} from "@/lib/types";
import { isValidEan, isValidEanChecksum, stripNonDigits } from "@/lib/validation";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import {
    ArrowLeft,
    Camera,
    ClipboardList,
    ClipboardPaste,
    FileText,
    Flashlight,
    Keyboard,
    RefreshCw,
} from "lucide-react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useCallback, useEffect, useRef, useState } from "react";

type ScanState = "idle" | "looking-up" | "found" | "not-found" | "error";

export default function ScanPage() {
  const router = useRouter();
  const supabase = createClient();
  const queryClient = useQueryClient();
  const { track } = useAnalytics();
  const { t } = useTranslation();
  const prefs = usePreferences();
  const userCountry = prefs?.country ?? undefined;
  const [ean, setEan] = useState("");
  const [manualEan, setManualEan] = useState("");
  const [mode, setMode] = useState<"camera" | "manual">("camera");
  const [scanState, setScanState] = useState<ScanState>("idle");
  const [scanResult, setScanResult] = useState<RecordScanFoundResponse | { found: false; has_pending_submission: boolean } | null>(null);
  const [batchMode, setBatchMode] = useState(false);
  const [batchResults, setBatchResults] = useState<RecordScanFoundResponse[]>(
    [],
  );
  const [scanTimeout, setScanTimeout] = useState(false);
  const [foundProduct, setFoundProduct] = useState<RecordScanFoundResponse | null>(null);
  const [checksumWarn, setChecksumWarn] = useState(false);

  const timeoutRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  const streamReadyTimeRef = useRef(0);

  // ─── Record scan mutation ─────────────────────────────────────────────────

  const scanMutation = useMutation({
    mutationFn: async (scanEan: string) => {
      const result = await recordScan(supabase, scanEan, userCountry);
      if (!result.ok) throw new Error(result.error.message);
      return result.data;
    },
    onSuccess: (data, scanEan) => {
      setScanResult(data);
      track("scanner_used", { ean: scanEan, found: data.found, method: mode });
      track(data.found ? "scanner_scan_success" : "scanner_scan_not_found", {
        ean: scanEan,
        found: data.found,
        time_to_scan_ms: streamReadyTimeRef.current
          ? Date.now() - streamReadyTimeRef.current
          : undefined,
      });
      void eventBus.emit({
        type: "product.scanned",
        payload: { ean: scanEan },
      });
      if (typeof navigator !== "undefined" && navigator.vibrate) {
        navigator.vibrate(100);
      }
      queryClient.invalidateQueries({ queryKey: ["scan-history"] });

      if (data.found) {
        const found = data;
        if (batchMode) {
          setBatchResults((prev) => [found, ...prev]);
          showToast({
            type: "success",
            message: `✓ ${found.product_name_display ?? found.product_name}`,
          });
          handleReset(true);
        } else {
          setScanState("found");
          setFoundProduct(found);
        }
      } else {
        setScanState("not-found");
      }
    },
    onError: () => {
      setScanState("error");
    },
  });

  // Stable ref for mutation — avoids stale closure in ZXing callback
  const scanMutateRef = useRef(scanMutation.mutate);
  scanMutateRef.current = scanMutation.mutate;

  // ─── Barcode scanner hook ─────────────────────────────────────────────────

  const {
    videoRef, cameraError, torchOn, feedActive,
    startScanner, stopScanner, toggleTorch, clearError, streamReadyTime,
  } = useBarcodeScanner({
    onBarcodeDetected: (code) => {
      setScanState("looking-up");
      setEan(code);
      scanMutateRef.current(code);
    },
    enabled: mode === "camera" && scanState === "idle",
    track,
  });
  streamReadyTimeRef.current = streamReadyTime;

  // ─── Scan timeout — "Having trouble?" after 15 seconds ──────────────────
  useEffect(() => {
    if (mode === "camera" && scanState === "idle" && !cameraError && feedActive) {
      setScanTimeout(false);
      timeoutRef.current = setTimeout(() => setScanTimeout(true), 15_000);
      return () => {
        if (timeoutRef.current) {
          clearTimeout(timeoutRef.current);
          timeoutRef.current = null;
        }
      };
    }
    setScanTimeout(false);
  }, [mode, scanState, cameraError, feedActive]);

  function handleManualSubmit(e: FormSubmitEvent) {
    e.preventDefault();
    const cleaned = manualEan.trim();
    if (!isValidEan(cleaned)) {
      showToast({ type: "error", messageKey: "scan.invalidBarcode" });
      return;
    }
    setScanState("looking-up");
    setEan(cleaned);
    scanMutation.mutate(cleaned);
  }

  function handleReset(keepCamera = false) {
    setEan("");
    setManualEan("");
    setScanState("idle");
    setScanResult(null);
    setFoundProduct(null);
    setScanTimeout(false);
    setChecksumWarn(false);
    if (timeoutRef.current) {
      clearTimeout(timeoutRef.current);
      timeoutRef.current = null;
    }
    if (!keepCamera) {
      setMode("camera");
    }
  }

  const handleRefresh = useCallback(async () => {
    await queryClient.invalidateQueries({ queryKey: ["scan-history"] });
  }, [queryClient]);

  // ─── Idle-state flag — scanState is "idle" and not transitioning ────────────
  const isIdle =
    scanState === "idle" ||
    (scanState === "looking-up" && !scanMutation.isPending) ||
    (scanState === "found" && !foundProduct);

  return (
    <PullToRefresh onRefresh={handleRefresh}>
    <div className="space-y-6">
      <div className="hidden md:block">
        <Breadcrumbs
          items={[
            { labelKey: "nav.home", href: "/app" },
            { labelKey: "nav.scan" },
          ]}
        />
      </div>
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-2">
          <button
            onClick={() => router.back()}
            className="md:hidden rounded-lg p-1.5 text-foreground-secondary hover:bg-surface-muted"
            aria-label={t("common.back")}
          >
            <ArrowLeft size={20} />
          </button>
          <h1 className="flex items-center gap-2 text-xl font-bold text-foreground lg:text-2xl">
            <Camera size={22} aria-hidden="true" /> {t("scan.title")}
          </h1>
        </div>
        <div className="flex gap-2">
          <Link
            href="/app/scan/history"
            className="text-sm text-brand hover:text-brand-hover"
          >
            <span className="inline-flex items-center gap-1">
              <ClipboardList size={14} aria-hidden="true" /> {t("scan.history")}
            </span>
          </Link>
          <Link
            href="/app/scan/submissions"
            className="text-sm text-brand hover:text-brand-hover"
          >
            <span className="inline-flex items-center gap-1">
              <FileText size={16} aria-hidden="true" />{" "}
              {t("scan.mySubmissions")}
            </span>
          </Link>
        </div>
      </div>

      {/* ── Result states ─────────────────────────────────────────────────── */}

      {scanState === "error" && (
        <ScanErrorView
          ean={ean}
          onRetry={() => { setScanState("looking-up"); scanMutation.mutate(ean); }}
          onReset={() => handleReset()}
        />
      )}

      {scanState === "not-found" && scanResult && !scanResult.found && (
        <ScanNotFoundView
          ean={ean}
          scanResult={scanResult as RecordScanNotFoundResponse}
          onReset={() => handleReset()}
          country={userCountry}
        />
      )}

      {scanState === "looking-up" && scanMutation.isPending && (
        <ScanLookingUpView ean={ean} />
      )}

      {scanState === "found" && foundProduct && (
        <ScanFoundView
          product={foundProduct}
          onViewDetails={() => router.push(`/app/scan/result/${foundProduct.product_id}`)}
          onReset={() => handleReset()}
        />
      )}

      {/* ── Idle scanner UI ───────────────────────────────────────────────── */}

      {isIdle && (
        <>

      {/* Batch mode toggle (hidden when camera has an error) */}
      {!(mode === "camera" && cameraError) && (
      <label className="touch-target flex cursor-pointer items-center gap-2 rounded-lg border border-border px-3 py-2.5">
        <input
          type="checkbox"
          checked={batchMode}
          onChange={(e) => {
            setBatchMode(e.target.checked);
            if (!e.target.checked) setBatchResults([]);
          }}
          className="h-5 w-5 rounded border-strong text-brand"
        />
        <span className="text-sm text-foreground">{t("scan.batchMode")}</span>
      </label>
      )}

      {/* Mode toggle */}
      <div className="flex gap-1 rounded-lg bg-surface-muted p-1">
        <button
          onClick={() => setMode("camera")}
          className={`flex-1 rounded-md px-3 py-2.5 text-sm font-medium transition-colors ${
            mode === "camera"
              ? cameraError
                ? "bg-surface text-warning-text shadow-sm"
                : "bg-surface text-brand shadow-sm"
              : "text-foreground-secondary hover:text-foreground"
          }`}
        >
          <span className="inline-flex items-center gap-1">
            <Camera size={16} aria-hidden="true" /> {t("scan.camera")}
          </span>
        </button>
        <button
          onClick={() => {
            stopScanner();
            setMode("manual");
          }}
          className={`flex-1 rounded-md px-3 py-2.5 text-sm font-medium transition-colors ${
            mode === "manual"
              ? "bg-surface text-brand shadow-sm"
              : "text-foreground-secondary hover:text-foreground"
          }`}
        >
          <span className="inline-flex items-center gap-1">
            <Keyboard size={16} aria-hidden="true" /> {t("scan.manual")}
          </span>
        </button>
      </div>

      {mode === "camera" ? (
        <div className="space-y-3">
          {cameraError ? (
            <FadeSlideIn>
              <ScannerErrorState
                error={cameraError}
                onRetry={() => { clearError(); startScanner(); }}
                onManualEntry={() => { clearError(); setMode("manual"); }}
              />
            </FadeSlideIn>
          ) : (
            <>
              <div className="relative overflow-hidden rounded-xl bg-black">
                <video
                  ref={videoRef}
                  className="aspect-4/3 w-full object-cover"
                  playsInline
                  muted
                  autoPlay
                />
                {/* Viewfinder overlay with alignment guides */}
                <div className="pointer-events-none absolute inset-0 flex items-center justify-center">
                  <div className={`relative h-36 w-72 transition-colors duration-300 ${scanState === "looking-up" ? "[&>div:first-child]:border-green-400" : ""}`}>
                    <div className="absolute inset-0 rounded-xl border-2 border-white/60 transition-colors duration-300" />
                    {/* Corner guides */}
                    <div className="absolute -left-0.5 -top-0.5 h-5 w-5 border-l-[3px] border-t-[3px] border-white rounded-tl" />
                    <div className="absolute -right-0.5 -top-0.5 h-5 w-5 border-r-[3px] border-t-[3px] border-white rounded-tr" />
                    <div className="absolute -bottom-0.5 -left-0.5 h-5 w-5 border-b-[3px] border-l-[3px] border-white rounded-bl" />
                    <div className="absolute -bottom-0.5 -right-0.5 h-5 w-5 border-b-[3px] border-r-[3px] border-white rounded-br" />
                    {/* Animated scan line — brand color */}
                    <div
                      className="absolute left-2 right-2 h-0.5 bg-brand/70"
                      style={{
                        animation: "scanLine 2s ease-in-out infinite",
                        top: "50%",
                      }}
                    />
                    <style>{`@keyframes scanLine { 0%,100% { top: 15%; } 50% { top: 85%; } }`}</style>
                  </div>
                </div>
                {/* Torch floating pill — inside viewfinder */}
                <button
                  type="button"
                  onClick={toggleTorch}
                  className={`absolute bottom-3 right-3 z-10 flex items-center gap-1.5 rounded-full px-3 py-1.5 text-xs font-medium text-white backdrop-blur-sm transition-all duration-300 ${
                    torchOn
                      ? "bg-yellow-500/80 shadow-[0_0_12px_rgba(234,179,8,0.5)]"
                      : "bg-white/20 hover:bg-white/30"
                  }`}
                  aria-label={torchOn ? t("scan.off") : t("scan.torch")}
                >
                  <Flashlight size={14} aria-hidden="true" />
                  {torchOn ? t("scan.off") : t("scan.torch")}
                </button>
                {/* Batch mode indicator */}
                {batchMode && (
                  <div className="absolute left-3 top-3 rounded-full bg-brand px-2 py-0.5 text-xs font-medium text-white">
                    {t("scan.scannedCount", { count: batchResults.length })}
                  </div>
                )}
              </div>
              <Button
                variant="secondary"
                onClick={() => {
                  stopScanner();
                  startScanner();
                }}
                fullWidth
                icon={<RefreshCw size={16} aria-hidden="true" />}
              >
                {t("scan.restart")}
              </Button>

              {/* Scanning status */}
              {!scanTimeout && feedActive && (
                <p className="animate-pulse text-center text-sm text-foreground-secondary">
                  {t("scan.scanningStatus")}
                </p>
              )}
              {!scanTimeout && !feedActive && !cameraError && (
                <p className="animate-pulse text-center text-sm text-foreground-muted">
                  {t("scan.cameraStarting")}
                </p>
              )}

              <p className="text-center text-xs text-foreground-muted">
                {t("scan.cameraHint")}
              </p>

              {/* Timeout hint */}
              {scanTimeout && (
                <div className="card border-warning-border bg-warning-bg text-center">
                  <p className="text-sm font-semibold text-warning-text">
                    {t("scan.timeoutTitle")}
                  </p>
                  <p className="mt-1 text-xs text-warning-text/80">
                    {t("scan.timeoutHint")}
                  </p>
                </div>
              )}
            </>
          )}
        </div>
      ) : (
        <form onSubmit={handleManualSubmit} className="space-y-3">
          <div className="flex gap-2">
            <input
              type="text"
              value={manualEan}
              onChange={(e) => {
                const v = stripNonDigits(e.target.value);
                setManualEan(v);
                setChecksumWarn(v.length >= 8 && isValidEan(v) && !isValidEanChecksum(v));
              }}
              placeholder={t("scan.manualPlaceholder")}
              aria-label={t("scan.manualPlaceholder")}
              className="input-field min-w-0 flex-1 text-center text-lg tracking-widest"
              maxLength={13}
              inputMode="numeric"
              autoFocus
            />
            <Button
              type="button"
              variant="secondary"
              onClick={async () => {
                try {
                  const text = await navigator.clipboard.readText();
                  const digits = stripNonDigits(text).slice(0, 13);
                  if (digits) setManualEan(digits);
                } catch {
                  /* clipboard not available */
                }
              }}
              icon={<ClipboardPaste size={16} aria-hidden="true" />}
              aria-label={t("scan.pasteBarcode")}
            >
              <span className="hidden sm:inline">{t("scan.pasteBarcode")}</span>
            </Button>
          </div>
          {checksumWarn && (
            <p className="text-center text-xs text-warning-text">
              {t("scan.checksumWarning")}
            </p>
          )}
          <Button
            type="submit"
            disabled={manualEan.length < 8}
            fullWidth
          >
            {t("scan.lookUp")}
          </Button>
          <p className="text-center text-xs text-foreground-muted">
            {t("scan.digitHint")}
          </p>

          {/* Manual mode tips */}
          <div className="rounded-lg border border-border bg-surface-muted/50 p-3">
            <p className="mb-2 text-xs font-semibold text-foreground-secondary">
              {t("scan.manualTipsTitle")}
            </p>
            <ul className="space-y-1.5 text-xs text-foreground-muted">
              <li className="flex items-start gap-2">
                <span aria-hidden="true">📦</span>
                <span>{t("scan.manualTip1")}</span>
              </li>
              <li className="flex items-start gap-2">
                <span aria-hidden="true">🔢</span>
                <span>{t("scan.manualTip2")}</span>
              </li>
              <li className="flex items-start gap-2">
                <span aria-hidden="true">📋</span>
                <span>{t("scan.manualTip3")}</span>
              </li>
            </ul>
          </div>
        </form>
      )}

      {/* Batch results tally */}
      {batchMode && batchResults.length > 0 && (
        <div className="space-y-2">
          <div className="flex items-center justify-between">
            <h2 className="text-sm font-semibold text-foreground">
              {t("scan.scannedCount", { count: batchResults.length })}
            </h2>
            <button
              onClick={() => setBatchResults([])}
              className="text-xs text-foreground-muted hover:text-foreground-secondary"
            >
              {t("common.clear")}
            </button>
          </div>
          <ul className="max-h-48 space-y-1 overflow-y-auto">
            {batchResults.map((p, i) => (
              <li
                key={`${p.product_id}-${i}`}
                className="flex items-center gap-2 rounded-lg border border-border px-3 py-2"
              >
                <span
                  className={`inline-flex h-5 w-5 items-center justify-center rounded text-xs font-bold text-white ${
                    (p.nutri_score && NUTRI_COLORS[p.nutri_score]) ??
                    "bg-foreground-muted"
                  }`}
                >
                  {p.nutri_score}
                </span>
                <button
                  onClick={() => router.push(`/app/product/${p.product_id}`)}
                  className="min-w-0 flex-1 truncate text-left text-sm text-foreground hover:text-brand"
                >
                  {p.product_name_display ?? p.product_name}
                </button>
                <span className="shrink-0 text-xs text-foreground-muted">
                  {p.brand}
                </span>
              </li>
            ))}
          </ul>
          <Button
            onClick={() => setBatchMode(false)}
            fullWidth
          >
            {t("scan.doneScan")}
          </Button>
        </div>
      )}
        </>
      )}
    </div>
    </PullToRefresh>
  );
}
