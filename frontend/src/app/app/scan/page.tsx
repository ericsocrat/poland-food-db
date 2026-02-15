"use client";

// ─── Barcode scanner page — ZXing camera + manual EAN fallback ──────────────
// State machine: idle → scanning → looking-up → found / not-found / error
// Enhancements: records scans to history, batch mode, submission CTA,
// scan history link.

import { useState, useEffect, useRef, useCallback } from "react";
import { useRouter } from "next/navigation";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { toast } from "sonner";
import Link from "next/link";
import { createClient } from "@/lib/supabase/client";
import { recordScan } from "@/lib/api";
import { isValidEan, stripNonDigits } from "@/lib/validation";
import { NUTRI_COLORS } from "@/lib/constants";
import { LoadingSpinner } from "@/components/common/LoadingSpinner";
import type { RecordScanResponse, RecordScanFoundResponse } from "@/lib/types";

type ScanState = "idle" | "looking-up" | "found" | "not-found" | "error";

export default function ScanPage() {
  const router = useRouter();
  const supabase = createClient();
  const queryClient = useQueryClient();
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
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const readerRef = useRef<any>(null);
  const streamRef = useRef<MediaStream | null>(null);

  // ─── Record scan mutation ─────────────────────────────────────────────────

  const scanMutation = useMutation({
    mutationFn: async (scanEan: string) => {
      const result = await recordScan(supabase, scanEan);
      if (!result.ok) throw new Error(result.error.message);
      return result.data;
    },
    onSuccess: (data) => {
      setScanResult(data);
      // Invalidate scan history
      queryClient.invalidateQueries({
        queryKey: ["scan-history"],
      });

      if (data.found) {
        const found = data as RecordScanFoundResponse;
        if (batchMode) {
          // Batch mode: add to list, keep scanning
          setBatchResults((prev) => [found, ...prev]);
          toast.success(`✓ ${found.product_name}`);
          handleReset(true); // reset but stay in camera mode
        } else {
          setScanState("found");
          router.push(`/app/product/${found.product_id}`);
        }
      } else {
        setScanState("not-found");
      }
    },
    onError: () => {
      setScanState("error");
    },
  });

  // ─── ZXing barcode scanning ───────────────────────────────────────────────

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
        setCameraError("No camera found on this device.");
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
              scanMutation.mutate(code);
            }
          }
        },
      );

      if (videoRef.current?.srcObject) {
        streamRef.current = videoRef.current.srcObject as MediaStream;
      }
    } catch (err: unknown) {
      const errObj = err as { name?: string };
      if (
        errObj.name === "NotAllowedError" ||
        errObj.name === "PermissionDeniedError"
      ) {
        setCameraError(
          "Camera permission denied. Please allow camera access in your browser settings.",
        );
        toast.error("Camera permission denied");
      } else {
        setCameraError("Could not start camera. Try manual entry instead.");
      }
      setMode("manual");
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  function stopScanner() {
    if (readerRef.current) {
      readerRef.current.reset();
      readerRef.current = null;
    }
    if (streamRef.current) {
      streamRef.current.getTracks().forEach((t: MediaStreamTrack) => t.stop());
      streamRef.current = null;
    }
    setTorchOn(false);
  }

  async function toggleTorch() {
    if (!streamRef.current) return;
    const track = streamRef.current.getVideoTracks()[0];
    if (!track) return;

    try {
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      const capabilities = track.getCapabilities() as any;
      if (capabilities.torch) {
        const newState = !torchOn;
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        await (track as any).applyConstraints({
          advanced: [{ torch: newState }],
        });
        setTorchOn(newState);
      } else {
        toast.error("Torch not supported on this device");
      }
    } catch {
      toast.error("Could not toggle torch");
    }
  }

  useEffect(() => {
    if (mode === "camera" && scanState === "idle") {
      startScanner();
    }
    return () => stopScanner();
  }, [mode, scanState, startScanner]);

  function handleManualSubmit(e: React.FormEvent) {
    e.preventDefault();
    const cleaned = manualEan.trim();
    if (!isValidEan(cleaned)) {
      toast.error("Please enter a valid 8 or 13 digit barcode");
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
          <p className="mb-2 text-4xl">⚠️</p>
          <p className="text-lg font-semibold text-gray-900">Lookup failed</p>
          <p className="mt-1 text-sm text-gray-500">
            Could not look up EAN {ean}. Please check your connection and try
            again.
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
            🔄 Retry
          </button>
          <button onClick={() => handleReset()} className="btn-primary flex-1">
            Scan another
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
          <p className="mb-2 text-4xl">🔍</p>
          <p className="text-lg font-semibold text-gray-900">
            Product not found
          </p>
          <p className="mt-1 text-sm text-gray-500">
            EAN: <span className="font-mono">{ean}</span> is not in our database
            yet.
          </p>
        </div>

        {hasPending ? (
          <div className="card border-amber-200 bg-amber-50">
            <p className="text-sm text-amber-700">
              ⏳ Someone has already submitted this product. It&apos;s pending
              review.
            </p>
          </div>
        ) : (
          <Link
            href={`/app/scan/submit?ean=${ean}`}
            className="btn-primary block w-full text-center"
          >
            📝 Help us add it!
          </Link>
        )}

        <div className="flex gap-2">
          <button
            onClick={() => handleReset()}
            className="btn-secondary flex-1"
          >
            Scan another
          </button>
          <Link
            href="/app/scan/history"
            className="btn-secondary flex-1 text-center"
          >
            📋 History
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
        <p className="text-sm text-gray-500">Looking up {ean}…</p>
      </div>
    );
  }

  return (
    <div className="space-y-4">
      {/* Header */}
      <div className="flex items-center justify-between">
        <h1 className="text-xl font-bold text-gray-900">📷 Scan Barcode</h1>
        <div className="flex gap-2">
          <Link
            href="/app/scan/history"
            className="text-sm text-brand-600 hover:text-brand-700"
          >
            📋 History
          </Link>
          <Link
            href="/app/scan/submissions"
            className="text-sm text-brand-600 hover:text-brand-700"
          >
            📝 My Submissions
          </Link>
        </div>
      </div>

      {/* Batch mode toggle */}
      <label className="flex cursor-pointer items-center gap-2 rounded-lg border border-gray-200 px-3 py-2">
        <input
          type="checkbox"
          checked={batchMode}
          onChange={(e) => {
            setBatchMode(e.target.checked);
            if (!e.target.checked) setBatchResults([]);
          }}
          className="h-4 w-4 rounded border-gray-300 text-brand-600"
        />
        <span className="text-sm text-gray-700">
          Batch mode — scan multiple without stopping
        </span>
      </label>

      {/* Mode toggle */}
      <div className="flex gap-1 rounded-lg bg-gray-100 p-1">
        <button
          onClick={() => setMode("camera")}
          className={`flex-1 rounded-md px-3 py-2 text-sm font-medium transition-colors ${
            mode === "camera"
              ? "bg-white text-brand-700 shadow-sm"
              : "text-gray-500 hover:text-gray-700"
          }`}
        >
          📷 Camera
        </button>
        <button
          onClick={() => {
            stopScanner();
            setMode("manual");
          }}
          className={`flex-1 rounded-md px-3 py-2 text-sm font-medium transition-colors ${
            mode === "manual"
              ? "bg-white text-brand-700 shadow-sm"
              : "text-gray-500 hover:text-gray-700"
          }`}
        >
          ⌨️ Manual
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
                  <div className="absolute left-3 top-3 rounded-full bg-brand-600 px-2 py-0.5 text-xs font-medium text-white">
                    Batch: {batchResults.length} scanned
                  </div>
                )}
              </div>
              <div className="flex gap-2">
                <button onClick={toggleTorch} className="btn-secondary flex-1">
                  {torchOn ? "🔦 Off" : "🔦 Torch"}
                </button>
                <button
                  onClick={() => {
                    stopScanner();
                    startScanner();
                  }}
                  className="btn-secondary flex-1"
                >
                  🔄 Restart
                </button>
              </div>
            </>
          )}
          <p className="text-center text-xs text-gray-400">
            Point camera at a barcode. Supports EAN-13, EAN-8, UPC-A, UPC-E.
          </p>
        </div>
      ) : (
        <form onSubmit={handleManualSubmit} className="space-y-3">
          <input
            type="text"
            value={manualEan}
            onChange={(e) => setManualEan(stripNonDigits(e.target.value))}
            placeholder="Enter EAN barcode (8 or 13 digits)"
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
            Look up
          </button>
          <p className="text-center text-xs text-gray-400">
            Enter 8 digits (EAN-8) or 13 digits (EAN-13)
          </p>
        </form>
      )}

      {/* Batch results tally */}
      {batchMode && batchResults.length > 0 && (
        <div className="space-y-2">
          <div className="flex items-center justify-between">
            <h2 className="text-sm font-semibold text-gray-900">
              Scanned ({batchResults.length})
            </h2>
            <button
              onClick={() => setBatchResults([])}
              className="text-xs text-gray-400 hover:text-gray-600"
            >
              Clear
            </button>
          </div>
          <ul className="max-h-48 space-y-1 overflow-y-auto">
            {batchResults.map((p, i) => (
              <li
                key={`${p.product_id}-${i}`}
                className="flex items-center gap-2 rounded-lg border border-gray-100 px-3 py-2"
              >
                <span
                  className={`inline-flex h-5 w-5 items-center justify-center rounded text-xs font-bold text-white ${
                    (p.nutri_score && NUTRI_COLORS[p.nutri_score]) ?? "bg-gray-400"
                  }`}
                >
                  {p.nutri_score}
                </span>
                <button
                  onClick={() => router.push(`/app/product/${p.product_id}`)}
                  className="min-w-0 flex-1 truncate text-left text-sm text-gray-800 hover:text-brand-600"
                >
                  {p.product_name}
                </button>
                <span className="flex-shrink-0 text-xs text-gray-400">
                  {p.brand}
                </span>
              </li>
            ))}
          </ul>
          <button
            onClick={() => setBatchMode(false)}
            className="btn-primary w-full"
          >
            Done scanning
          </button>
        </div>
      )}
    </div>
  );
}
