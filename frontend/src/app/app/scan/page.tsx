"use client";

// ─── Barcode scanner page — ZXing camera + manual EAN fallback ──────────────

import { useState, useEffect, useRef, useCallback } from "react";
import { useRouter } from "next/navigation";
import { useQuery } from "@tanstack/react-query";
import { toast } from "sonner";
import { createClient } from "@/lib/supabase/client";
import { lookupByEan } from "@/lib/api";
import { queryKeys, staleTimes } from "@/lib/query-keys";
import { LoadingSpinner } from "@/components/common/LoadingSpinner";

export default function ScanPage() {
  const router = useRouter();
  const supabase = createClient();
  const [ean, setEan] = useState("");
  const [manualEan, setManualEan] = useState("");
  const [mode, setMode] = useState<"camera" | "manual">("camera");
  const [cameraError, setCameraError] = useState<string | null>(null);
  const [torchOn, setTorchOn] = useState(false);

  const videoRef = useRef<HTMLVideoElement>(null);
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const readerRef = useRef<any>(null);
  const streamRef = useRef<MediaStream | null>(null);

  // ZXing barcode scanning
  const startScanner = useCallback(async () => {
    setCameraError(null);

    try {
      // Dynamically import ZXing to avoid SSR issues
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

      // Prefer back camera
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
            // Validate EAN format (8 or 13 digits)
            if (/^\d{8}$|^\d{13}$/.test(code)) {
              setEan(code);
              stopScanner();
            }
          }
          // Silently ignore decode errors (continuous scanning)
        },
      );

      // Track the stream for torch control
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
    if (mode === "camera") {
      startScanner();
    }
    return () => stopScanner();
  }, [mode, startScanner]);

  // EAN lookup query
  const {
    data: lookupResult,
    isLoading: lookingUp,
    error: lookupError,
  } = useQuery({
    queryKey: queryKeys.scan(ean),
    queryFn: async () => {
      const result = await lookupByEan(supabase, ean);
      if (!result.ok) throw new Error(result.error.message);
      return result.data;
    },
    enabled: ean.length > 0,
    staleTime: staleTimes.scan,
  });

  // Auto-redirect if product found
  useEffect(() => {
    if (lookupResult && "product_id" in lookupResult) {
      router.push(`/app/product/${lookupResult.product_id}`);
    }
  }, [lookupResult, router]);

  function handleManualSubmit(e: React.FormEvent) {
    e.preventDefault();
    const cleaned = manualEan.trim();
    if (!/^\d{8}$|^\d{13}$/.test(cleaned)) {
      toast.error("Please enter a valid 8 or 13 digit barcode");
      return;
    }
    setEan(cleaned);
  }

  function handleReset() {
    setEan("");
    setManualEan("");
    setMode("camera");
  }

  // ─── Render ─────────────────────────────────────────────────────────────────

  // Show result if EAN was looked up but not found
  if (ean && lookupResult && "found" in lookupResult && !lookupResult.found) {
    return (
      <div className="space-y-4">
        <div className="card text-center">
          <p className="mb-2 text-4xl">🔍</p>
          <p className="text-lg font-semibold text-gray-900">
            Product not found
          </p>
          <p className="mt-1 text-sm text-gray-500">
            EAN: {ean} was not found in our database.
          </p>
        </div>
        <button onClick={handleReset} className="btn-primary w-full">
          Scan another
        </button>
      </div>
    );
  }

  // Loading state
  if (ean && lookingUp) {
    return (
      <div className="flex flex-col items-center gap-3 py-12">
        <LoadingSpinner />
        <p className="text-sm text-gray-500">Looking up {ean}…</p>
      </div>
    );
  }

  return (
    <div className="space-y-4">
      <h1 className="text-xl font-bold text-gray-900">Scan Barcode</h1>

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
                {/* Scanning indicator overlay */}
                <div className="pointer-events-none absolute inset-0 flex items-center justify-center">
                  <div className="h-32 w-64 rounded-xl border-2 border-white/50" />
                </div>
              </div>
              <div className="flex gap-2">
                <button onClick={toggleTorch} className="btn-secondary flex-1">
                  {torchOn ? "🔦 Torch Off" : "🔦 Torch On"}
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
            onChange={(e) => setManualEan(e.target.value.replaceAll(/\D/g, ""))}
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
        </form>
      )}

      {lookupError && (
        <p className="text-center text-sm text-red-500">
          Lookup failed. Please try again.
        </p>
      )}
    </div>
  );
}
