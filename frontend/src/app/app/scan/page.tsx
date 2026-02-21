"use client";

// ─── Barcode scanner page — ZXing camera + manual EAN fallback ──────────────
// State machine: idle → scanning → looking-up → found / not-found / error
// Enhancements: records scans to history, batch mode, submission CTA,
// scan history link.

import { useState, useEffect, useRef, useCallback } from "react";
import { useRouter } from "next/navigation";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { showToast } from "@/lib/toast";
import Link from "next/link";
import { createClient } from "@/lib/supabase/client";
import { recordScan } from "@/lib/api";
import { isValidEan, stripNonDigits } from "@/lib/validation";
import { NUTRI_COLORS } from "@/lib/constants";
import { Breadcrumbs } from "@/components/layout/Breadcrumbs";
import { LoadingSpinner } from "@/components/common/LoadingSpinner";
import { useAnalytics } from "@/hooks/use-analytics";
import { useTranslation } from "@/lib/i18n";
import { eventBus } from "@/lib/events";
import {
  AlertTriangle,
  RefreshCw,
  Search,
  Clock,
  FileText,
  ClipboardList,
  Camera,
  Keyboard,
  Flashlight,
} from "lucide-react";
import type {
  RecordScanResponse,
  RecordScanFoundResponse,
  FormSubmitEvent,
} from "@/lib/types";

type ScanState = "idle" | "looking-up" | "found" | "not-found" | "error";

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
  const [mode, setMode] = useState<"camera" | "manual">("camera");
  const [cameraError, setCameraError] = useState<string | null>(null);
  const [torchOn, setTorchOn] = useState(false);
  const [scanState, setScanState] = useState<ScanState>("idle");
  const [scanResult, setScanResult] = useState<RecordScanResponse | null>(null);
  const [batchMode, setBatchMode] = useState(false);
  const [batchResults, setBatchResults] = useState<RecordScanFoundResponse[]>(
    [],
  );

  const videoRef = useRef<HTMLVideoElement>(null);
  const readerRef = useRef<BarcodeReader | null>(null);
  const streamRef = useRef<MediaStream | null>(null);

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
          router.push(`/app/scan/result/${found.product_id}`);
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
        setCameraError(t("scan.noCamera"));
        setMode("manual");
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
        setCameraError(t("scan.permissionDenied"));
        showToast({ type: "error", messageKey: "scan.permissionDenied" });
      } else {
        setCameraError(t("scan.cameraError"));
      }
      setMode("manual");
    }
  }, [stopScanner, t]);

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
    if (!keepCamera) {
      setMode("camera");
    }
  }

  // ─── Render ─────────────────────────────────────────────────────────────────

  // Error state
  if (scanState === "error") {
    return (
      <div className="space-y-4">
        <div className="card border-red-200 bg-red-50 text-center">
          <div className="mb-2 flex justify-center">
            <AlertTriangle
              size={40}
              className="text-red-500"
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
          <button
            onClick={() => {
              setScanState("looking-up");
              scanMutation.mutate(ean);
            }}
            className="btn-secondary flex-1"
          >
            <span className="inline-flex items-center gap-1">
              <RefreshCw size={16} aria-hidden="true" /> {t("common.retry")}
            </span>
          </button>
          <button onClick={() => handleReset()} className="btn-primary flex-1">
            {t("scan.scanAnother")}
          </button>
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
          <div className="card border-amber-200 bg-amber-50">
            <p className="text-sm text-amber-700">
              <span className="inline-flex items-center gap-1">
                <Clock size={16} aria-hidden="true" />{" "}
                {t("scan.alreadySubmitted")}
              </span>
            </p>
          </div>
        ) : (
          <Link
            href={`/app/scan/submit?ean=${ean}`}
            className="btn-primary block w-full text-center"
          >
            <span className="inline-flex items-center gap-1">
              <FileText size={16} aria-hidden="true" /> {t("scan.helpAdd")}
            </span>
          </Link>
        )}

        <div className="flex gap-2">
          <button
            onClick={() => handleReset()}
            className="btn-secondary flex-1"
          >
            {t("scan.scanAnother")}
          </button>
          <Link
            href="/app/scan/history"
            className="btn-secondary flex-1 text-center"
          >
            <span className="inline-flex items-center gap-1">
              <ClipboardList size={16} aria-hidden="true" /> {t("scan.history")}
            </span>
          </Link>
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

  return (
    <div className="space-y-4">
      <Breadcrumbs
        items={[
          { labelKey: "nav.home", href: "/app" },
          { labelKey: "nav.scan" },
        ]}
      />
      {/* Header */}
      <div className="flex items-center justify-between">
        <h1 className="flex items-center gap-2 text-xl font-bold text-foreground">
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
            <div className="card border-amber-200 bg-amber-50 text-center">
              <p className="text-sm text-amber-700">{cameraError}</p>
            </div>
          ) : (
            <>
              <div className="relative overflow-hidden rounded-xl bg-black">
                <video
                  ref={videoRef}
                  className="aspect-[4/3] w-full object-cover"
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
                    {/* Center scan line */}
                    <div className="absolute left-2 right-2 top-1/2 h-0.5 bg-red-400/70" />
                  </div>
                </div>
                {/* Batch mode indicator */}
                {batchMode && (
                  <div className="absolute left-3 top-3 rounded-full bg-brand px-2 py-0.5 text-xs font-medium text-white">
                    Batch: {batchResults.length} scanned
                  </div>
                )}
              </div>
              <div className="flex gap-2">
                <button onClick={toggleTorch} className="btn-secondary flex-1">
                  {torchOn ? (
                    <>
                      <Flashlight
                        size={16}
                        className="inline-block"
                        aria-hidden="true"
                      />{" "}
                      {t("scan.off")}
                    </>
                  ) : (
                    <>
                      <Flashlight
                        size={16}
                        className="inline-block"
                        aria-hidden="true"
                      />{" "}
                      {t("scan.torch")}
                    </>
                  )}
                </button>
                <button
                  onClick={() => {
                    stopScanner();
                    startScanner();
                  }}
                  className="btn-secondary flex-1"
                >
                  <span className="inline-flex items-center gap-1">
                    <RefreshCw size={16} aria-hidden="true" />{" "}
                    {t("scan.restart")}
                  </span>
                </button>
              </div>
            </>
          )}
          <p className="text-center text-xs text-foreground-muted">
            {t("scan.cameraHint")}
          </p>
        </div>
      ) : (
        <form onSubmit={handleManualSubmit} className="space-y-3">
          <input
            type="text"
            value={manualEan}
            onChange={(e) => setManualEan(stripNonDigits(e.target.value))}
            placeholder={t("scan.manualPlaceholder")}
            className="input-field text-center text-lg tracking-widest"
            maxLength={13}
            inputMode="numeric"
            autoFocus
          />
          <button
            type="submit"
            disabled={manualEan.length < 8}
            className="btn-primary w-full"
          >
            {t("scan.lookUp")}
          </button>
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
                <span className="flex-shrink-0 text-xs text-foreground-muted">
                  {p.brand}
                </span>
              </li>
            ))}
          </ul>
          <button
            onClick={() => setBatchMode(false)}
            className="btn-primary w-full"
          >
            {t("scan.doneScan")}
          </button>
        </div>
      )}
    </div>
  );
}
