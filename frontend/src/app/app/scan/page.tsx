"use client";

// ─── Barcode scanner page — ZXing camera + manual EAN fallback ──────────────
// State machine: idle → scanning → looking-up → found / not-found / error
// Enhancements: records scans to history, batch mode, submission CTA,
// scan history link.

import { Button, ButtonLink } from "@/components/common/Button";
import { LoadingSpinner } from "@/components/common/LoadingSpinner";
import { PullToRefresh } from "@/components/common/PullToRefresh";
import { Breadcrumbs } from "@/components/layout/Breadcrumbs";
import { useAnalytics } from "@/hooks/use-analytics";
import { recordScan } from "@/lib/api";
import { NUTRI_COLORS } from "@/lib/constants";
import { eventBus } from "@/lib/events";
import { useTranslation } from "@/lib/i18n";
import { getScoreBand, toTryVitScore } from "@/lib/score-utils";
import { createClient } from "@/lib/supabase/client";
import { showToast } from "@/lib/toast";
import type {
    FormSubmitEvent,
    RecordScanFoundResponse,
    RecordScanResponse,
} from "@/lib/types";
import { isValidEan, stripNonDigits } from "@/lib/validation";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import {
    AlertTriangle,
    Camera,
    CameraOff,
    CheckCircle,
    ClipboardList,
    ClipboardPaste,
    Clock,
    FileText,
    Flashlight,
    Keyboard,
    RefreshCw,
    Search,
    ShieldAlert,
} from "lucide-react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useCallback, useEffect, useRef, useState } from "react";

type ScanState = "idle" | "looking-up" | "found" | "not-found" | "error";
type CameraErrorKind = "permission-denied" | "no-camera" | "generic";

/** Torch extensions not yet in the standard MediaTrack types. */
interface TorchCapabilities extends MediaTrackCapabilities {
  torch?: boolean;
}

interface TorchConstraintSet extends MediaTrackConstraintSet {
  torch?: boolean;
}

function isTorchCapable(
  caps: MediaTrackCapabilities,
): caps is TorchCapabilities {
  return "torch" in caps;
}

/** Reader instance from @zxing/library (dynamically imported). */
interface BarcodeReader {
  listVideoInputDevices: () => Promise<MediaDeviceInfo[]>;
  decodeFromVideoDevice: (
    deviceId: string,
    videoElement: HTMLVideoElement | null,
    callback: (
      result: { getText: () => string } | null,
      error: unknown,
    ) => void,
  ) => void;
  reset: () => void;
}

export default function ScanPage() {
  const router = useRouter();
  const supabase = createClient();
  const queryClient = useQueryClient();
  const { track } = useAnalytics();
  const { t } = useTranslation();
  const [ean, setEan] = useState("");
  const [manualEan, setManualEan] = useState("");
  const [mode, setMode] = useState<"camera" | "manual">("manual");
  const [cameraError, setCameraError] = useState<CameraErrorKind | null>(null);
  const [torchOn, setTorchOn] = useState(false);
  const [scanState, setScanState] = useState<ScanState>("idle");
  const [scanResult, setScanResult] = useState<RecordScanResponse | null>(null);
  const [batchMode, setBatchMode] = useState(false);
  const [batchResults, setBatchResults] = useState<RecordScanFoundResponse[]>(
    [],
  );
  const [scanTimeout, setScanTimeout] = useState(false);
  const [foundProduct, setFoundProduct] = useState<RecordScanFoundResponse | null>(null);

  const videoRef = useRef<HTMLVideoElement>(null);
  const readerRef = useRef<BarcodeReader | null>(null);
  const streamRef = useRef<MediaStream | null>(null);
  const timeoutRef = useRef<ReturnType<typeof setTimeout> | null>(null);

  // Default to camera mode on touch devices (mobile/tablet)
  useEffect(() => {
    if (window.matchMedia("(pointer: coarse)").matches) {
      setMode("camera");
    }
  }, []);

  // ─── Record scan mutation ─────────────────────────────────────────────────

  const scanMutation = useMutation({
    mutationFn: async (scanEan: string) => {
      const result = await recordScan(supabase, scanEan);
      if (!result.ok) throw new Error(result.error.message);
      return result.data;
    },
    onSuccess: (data, scanEan) => {
      setScanResult(data);
      track("scanner_used", { ean: scanEan, found: data.found, method: mode });
      void eventBus.emit({
        type: "product.scanned",
        payload: { ean: scanEan },
      });
      // Haptic feedback on successful scan
      if (typeof navigator !== "undefined" && navigator.vibrate) {
        navigator.vibrate(100);
      }
      // Invalidate scan history
      queryClient.invalidateQueries({
        queryKey: ["scan-history"],
      });

      if (data.found) {
        const found = data;
        if (batchMode) {
          // Batch mode: add to list, keep scanning
          setBatchResults((prev) => [found, ...prev]);
          showToast({
            type: "success",
            message: `✓ ${found.product_name_display ?? found.product_name}`,
          });
          handleReset(true); // reset but stay in camera mode
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

  // ─── ZXing barcode scanning ───────────────────────────────────────────────

  const stopScanner = useCallback(() => {
    if (readerRef.current) {
      readerRef.current.reset();
      readerRef.current = null;
    }
    if (streamRef.current) {
      streamRef.current.getTracks().forEach((t: MediaStreamTrack) => t.stop());
      streamRef.current = null;
    }
    setTorchOn(false);
  }, []);

  const startScanner = useCallback(async () => {
    setCameraError(null);

    try {
      const { BrowserMultiFormatReader, DecodeHintType, BarcodeFormat } =
        await import("@zxing/library");

      const hints = new Map();
      hints.set(DecodeHintType.POSSIBLE_FORMATS, [
        BarcodeFormat.EAN_13,
        BarcodeFormat.EAN_8,
        BarcodeFormat.UPC_A,
        BarcodeFormat.UPC_E,
      ]);

      const reader = new BrowserMultiFormatReader(hints);
      readerRef.current = reader;

      const devices = await reader.listVideoInputDevices();
      if (devices.length === 0) {
        setCameraError("no-camera");
        return;
      }

      const backCamera = devices.find(
        (d) =>
          d.label.toLowerCase().includes("back") ||
          d.label.toLowerCase().includes("rear") ||
          d.label.toLowerCase().includes("environment"),
      );
      const deviceId = backCamera?.deviceId || devices[0].deviceId;

      reader.decodeFromVideoDevice(
        deviceId,
        videoRef.current,
        (result, _error) => {
          if (result) {
            const code = result.getText();
            if (isValidEan(code)) {
              setScanState("looking-up");
              setEan(code);
              stopScanner();
              scanMutateRef.current(code);
            }
          }
        },
      );

      if (videoRef.current?.srcObject instanceof MediaStream) {
        streamRef.current = videoRef.current.srcObject;
      }
    } catch (err: unknown) {
      let errName = "";
      if (err instanceof Error) {
        errName = err.name;
      } else if (err && typeof err === "object" && "name" in err) {
        errName = String(err.name);
      }
      if (
        errName === "NotAllowedError" ||
        errName === "PermissionDeniedError"
      ) {
        setCameraError("permission-denied");
        showToast({ type: "error", messageKey: "scan.permissionDenied" });
      } else {
        setCameraError("generic");
      }
    }
  }, [stopScanner]);

  async function toggleTorch() {
    if (!streamRef.current) return;
    const track = streamRef.current.getVideoTracks()[0];
    if (!track) return;

    try {
      const capabilities = track.getCapabilities();
      if (isTorchCapable(capabilities) && capabilities.torch) {
        const newState = !torchOn;
        const constraint: TorchConstraintSet = { torch: newState };
        await track.applyConstraints({ advanced: [constraint] });
        setTorchOn(newState);
      } else {
        showToast({ type: "error", messageKey: "scan.torchNotSupported" });
      }
    } catch {
      showToast({ type: "error", messageKey: "scan.torchError" });
    }
  }

  useEffect(() => {
    if (mode === "camera" && scanState === "idle") {
      startScanner();
    }
    return () => stopScanner();
  }, [mode, scanState, startScanner, stopScanner]);

  // ─── Scan timeout — "Having trouble?" after 15 seconds ──────────────────
  useEffect(() => {
    if (mode === "camera" && scanState === "idle" && !cameraError) {
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
  }, [mode, scanState, cameraError]);

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

  // ─── Render ─────────────────────────────────────────────────────────────────

  // Error state
  if (scanState === "error") {
    return (
      <div className="space-y-4">
        <div className="card border-error-border bg-error-bg text-center">
          <div className="mb-2 flex justify-center">
            <AlertTriangle
              size={40}
              className="text-error"
              aria-hidden="true"
            />
          </div>
          <p className="text-lg font-semibold text-foreground">
            {t("scan.lookupFailed")}
          </p>
          <p className="mt-1 text-sm text-foreground-secondary">
            {t("scan.lookupError", { ean })}
          </p>
        </div>
        <div className="flex gap-2">
          <Button
            variant="secondary"
            onClick={() => {
              setScanState("looking-up");
              scanMutation.mutate(ean);
            }}
            className="flex-1"
            icon={<RefreshCw size={16} aria-hidden="true" />}
          >
            {t("common.retry")}
          </Button>
          <Button onClick={() => handleReset()} className="flex-1">
            {t("scan.scanAnother")}
          </Button>
        </div>
      </div>
    );
  }

  // Not found state — with submission CTA
  if (scanState === "not-found" && scanResult && !scanResult.found) {
    const hasPending = scanResult.has_pending_submission;

    return (
      <div className="space-y-4">
        <div className="card text-center">
          <div className="mb-2 flex justify-center">
            <Search
              size={40}
              className="text-foreground-muted"
              aria-hidden="true"
            />
          </div>
          <p className="text-lg font-semibold text-foreground">
            {t("scan.notFound")}
          </p>
          <p className="mt-1 text-sm text-foreground-secondary">
            {t("scan.notFoundMessage", { ean })}
          </p>
        </div>

        {hasPending ? (
          <div className="card border-warning-border bg-warning-bg">
            <p className="text-sm text-warning-text">
              <span className="inline-flex items-center gap-1">
                <Clock size={16} aria-hidden="true" />{" "}
                {t("scan.alreadySubmitted")}
              </span>
            </p>
          </div>
        ) : (
          <ButtonLink
            href={`/app/scan/submit?ean=${ean}`}
            fullWidth
            icon={<FileText size={16} aria-hidden="true" />}
          >
            {t("scan.helpAdd")}
          </ButtonLink>
        )}

        <div className="flex gap-2">
          <Button
            variant="secondary"
            onClick={() => handleReset()}
            className="flex-1"
          >
            {t("scan.scanAnother")}
          </Button>
          <ButtonLink
            href="/app/scan/history"
            variant="secondary"
            className="flex-1"
            icon={<ClipboardList size={16} aria-hidden="true" />}
          >
            {t("scan.history")}
          </ButtonLink>
        </div>
      </div>
    );
  }

  // Looking-up state
  if (scanState === "looking-up" && scanMutation.isPending) {
    return (
      <div className="flex flex-col items-center gap-3 py-12">
        <LoadingSpinner />
        <p className="text-sm text-foreground-secondary">
          {t("scan.lookingUp", { ean })}
        </p>
      </div>
    );
  }

  // Found state — preview overlay before navigating
  if (scanState === "found" && foundProduct) {
    const band = getScoreBand(foundProduct.unhealthiness_score);
    const tryVitScore = toTryVitScore(foundProduct.unhealthiness_score);

    return (
      <div className="space-y-4">
        <div className="card text-center">
          <div className="mb-3 flex justify-center">
            <CheckCircle
              size={48}
              className="text-success"
              aria-hidden="true"
            />
          </div>
          <p className="text-lg font-bold text-foreground">
            {t("scan.productFound")}
          </p>
          <p className="mt-2 text-base font-semibold text-foreground">
            {foundProduct.product_name_display ?? foundProduct.product_name}
          </p>
          {foundProduct.brand && (
            <p className="text-sm text-foreground-secondary">
              {foundProduct.brand}
            </p>
          )}
          {band && (
            <div className="mt-3 flex items-center justify-center gap-2">
              <span
                className="inline-flex items-center gap-1 rounded-full px-3 py-1 text-sm font-semibold"
                style={{ backgroundColor: band.bgColor, color: band.textColor }}
              >
                {tryVitScore}
              </span>
              <span className="text-sm text-foreground-secondary">
                {band.label}
              </span>
            </div>
          )}
          {foundProduct.nutri_score && (
            <div className="mt-2 flex items-center justify-center gap-1">
              <span
                className={`inline-flex h-6 w-6 items-center justify-center rounded text-xs font-bold text-white ${
                  NUTRI_COLORS[foundProduct.nutri_score] ?? "bg-foreground-muted"
                }`}
              >
                {foundProduct.nutri_score}
              </span>
              <span className="text-xs text-foreground-muted">Nutri-Score</span>
            </div>
          )}
        </div>
        <div className="flex gap-2">
          <Button
            onClick={() => router.push(`/app/scan/result/${foundProduct.product_id}`)}
            className="flex-1"
          >
            {t("scan.viewDetails")}
          </Button>
          <Button
            variant="secondary"
            onClick={() => handleReset()}
            className="flex-1"
          >
            {t("scan.scanNext")}
          </Button>
        </div>
      </div>
    );
  }

  return (
    <PullToRefresh onRefresh={handleRefresh}>
    <div className="space-y-6">
      <Breadcrumbs
        items={[
          { labelKey: "nav.home", href: "/app" },
          { labelKey: "nav.scan" },
        ]}
      />
      {/* Header */}
      <div className="flex items-center justify-between">
        <h1 className="flex items-center gap-2 text-xl font-bold text-foreground lg:text-2xl">
          <Camera size={22} aria-hidden="true" /> {t("scan.title")}
        </h1>
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

      {/* Batch mode toggle */}
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

      {/* Mode toggle */}
      <div className="flex gap-1 rounded-lg bg-surface-muted p-1">
        <button
          onClick={() => setMode("camera")}
          className={`flex-1 rounded-md px-3 py-2.5 text-sm font-medium transition-colors ${
            mode === "camera"
              ? "bg-surface text-brand shadow-sm"
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
            <div className="card border-warning-border bg-warning-bg text-center">
              <div className="mb-2 flex justify-center">
                {cameraError === "permission-denied" ? (
                  <ShieldAlert
                    size={36}
                    className="text-warning-text"
                    aria-hidden="true"
                  />
                ) : (
                  <CameraOff
                    size={36}
                    className="text-warning-text"
                    aria-hidden="true"
                  />
                )}
              </div>
              <p className="text-sm font-semibold text-warning-text">
                {cameraError === "no-camera"
                  ? t("scan.noCameraTitle")
                  : cameraError === "permission-denied"
                    ? t("scan.cameraBlocked")
                    : t("scan.cameraError")}
              </p>
              <p className="mt-1 text-xs text-warning-text/80">
                {cameraError === "no-camera"
                  ? t("scan.noCameraHint")
                  : cameraError === "permission-denied"
                    ? t("scan.cameraBlockedHint")
                    : t("scan.cameraError")}
              </p>
              {cameraError !== "no-camera" && (
                <Button
                  variant="secondary"
                  onClick={() => {
                    setCameraError(null);
                    setMode("camera");
                    startScanner();
                  }}
                  className="mt-3"
                  icon={<RefreshCw size={16} aria-hidden="true" />}
                >
                  {t("scan.retryCamera")}
                </Button>
              )}
            </div>
          ) : (
            <>
              <div className="relative overflow-hidden rounded-xl bg-black">
                <video
                  ref={videoRef}
                  className="aspect-4/3 w-full object-cover"
                  playsInline
                  muted
                />
                {/* Viewfinder overlay with alignment guides */}
                <div className="pointer-events-none absolute inset-0 flex items-center justify-center">
                  <div className="relative h-32 w-64">
                    <div className="absolute inset-0 rounded-xl border-2 border-white/60" />
                    {/* Corner guides */}
                    <div className="absolute -left-0.5 -top-0.5 h-4 w-4 border-l-[3px] border-t-[3px] border-white rounded-tl" />
                    <div className="absolute -right-0.5 -top-0.5 h-4 w-4 border-r-[3px] border-t-[3px] border-white rounded-tr" />
                    <div className="absolute -bottom-0.5 -left-0.5 h-4 w-4 border-b-[3px] border-l-[3px] border-white rounded-bl" />
                    <div className="absolute -bottom-0.5 -right-0.5 h-4 w-4 border-b-[3px] border-r-[3px] border-white rounded-br" />
                    {/* Animated scan line */}
                    <div
                      className="absolute left-2 right-2 h-0.5 bg-error/70"
                      style={{
                        animation: "scanLine 2s ease-in-out infinite",
                        top: "50%",
                      }}
                    />
                    <style>{`@keyframes scanLine { 0%,100% { top: 15%; } 50% { top: 85%; } }`}</style>
                  </div>
                </div>
                {/* Batch mode indicator */}
                {batchMode && (
                  <div className="absolute left-3 top-3 rounded-full bg-brand px-2 py-0.5 text-xs font-medium text-white">
                    {t("scan.scannedCount", { count: batchResults.length })}
                  </div>
                )}
              </div>
              <div className="flex gap-2">
                <Button variant="secondary" onClick={toggleTorch} className="flex-1"
                  icon={<Flashlight size={16} aria-hidden="true" />}
                >
                  {torchOn ? t("scan.off") : t("scan.torch")}
                </Button>
                <Button
                  variant="secondary"
                  onClick={() => {
                    stopScanner();
                    startScanner();
                  }}
                  className="flex-1"
                  icon={<RefreshCw size={16} aria-hidden="true" />}
                >
                  {t("scan.restart")}
                </Button>
              </div>

              {/* Scanning status */}
              {!scanTimeout && (
                <p className="animate-pulse text-center text-sm text-foreground-secondary">
                  {t("scan.scanningStatus")}
                </p>
              )}

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
          <p className="text-center text-xs text-foreground-muted">
            {t("scan.cameraHint")}
          </p>
        </div>
      ) : (
        <form onSubmit={handleManualSubmit} className="space-y-3">
          <div className="flex gap-2">
            <input
              type="text"
              value={manualEan}
              onChange={(e) => setManualEan(stripNonDigits(e.target.value))}
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
              {t("scan.pasteBarcode")}
            </Button>
          </div>
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
    </div>
    </PullToRefresh>
  );
}
