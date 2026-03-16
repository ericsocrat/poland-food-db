"use client";

// ─── Barcode scanner hook — encapsulates ZXing camera lifecycle ─────────────
// Manages camera access, barcode detection, torch control, and error handling.
// Returns a stable API for the scan page to consume.

import {
    classifyScannerError,
    getBrowserSummary,
    getFacingMode,
} from "@/lib/scanner-errors";
import { showToast } from "@/lib/toast";
import type { AnalyticsEventName } from "@/lib/types";
import { isValidEan } from "@/lib/validation";
import { useCallback, useEffect, useRef, useState } from "react";

// ─── Types ──────────────────────────────────────────────────────────────────

export type CameraErrorKind =
  | "permission-prompt"
  | "permission-denied"
  | "permission-unknown"
  | "no-camera"
  | "generic";

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
  ) => Promise<void>;
  reset: () => void;
}

export interface UseBarcodeScanner {
  /** Ref to attach to the <video> element. */
  videoRef: React.RefObject<HTMLVideoElement | null>;
  /** Current camera error state, or null if no error. */
  cameraError: CameraErrorKind | null;
  /** Whether the torch (flashlight) is currently on. */
  torchOn: boolean;
  /** Whether the camera feed is actively streaming. */
  feedActive: boolean;
  /** Start (or restart) the barcode scanner. */
  startScanner: () => Promise<void>;
  /** Stop the scanner and release camera resources. */
  stopScanner: () => void;
  /** Toggle the device torch on/off. */
  toggleTorch: () => Promise<void>;
  /** Clear the current camera error. */
  clearError: () => void;
  /** Time reference for when stream became ready (for telemetry). */
  streamReadyTime: number;
}

interface UseBarcodeOptions {
  /** Called when a valid EAN barcode is detected. */
  onBarcodeDetected: (code: string) => void;
  /** Whether the scanner should be active (start scanning). */
  enabled: boolean;
  /** Analytics tracking function. */
  track: (event: AnalyticsEventName, data?: Record<string, unknown>) => void;
}

// ─── Hook ───────────────────────────────────────────────────────────────────

export function useBarcodeScanner({
  onBarcodeDetected,
  enabled,
  track,
}: UseBarcodeOptions): UseBarcodeScanner {
  const [cameraError, setCameraError] = useState<CameraErrorKind | null>(null);
  const [torchOn, setTorchOn] = useState(false);
  const [feedActive, setFeedActive] = useState(false);

  const videoRef = useRef<HTMLVideoElement>(null);
  const readerRef = useRef<BarcodeReader | null>(null);
  const streamRef = useRef<MediaStream | null>(null);
  const isMountedRef = useRef(true);
  const initStartTimeRef = useRef(0);
  const streamReadyTimeRef = useRef(0);
  const streamReadyFiredRef = useRef(false);
  const onBarcodeDetectedRef = useRef(onBarcodeDetected);
  onBarcodeDetectedRef.current = onBarcodeDetected;

  // ─── Lifecycle ──────────────────────────────────────────────────────────

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
    setFeedActive(false);
    streamReadyFiredRef.current = false;
  }, []);

  const startScanner = useCallback(async () => {
    setCameraError(null);
    initStartTimeRef.current = Date.now();
    track("scanner_init_start", { browser: getBrowserSummary() });

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
        track("scanner_init_error", {
          error_type: "no-camera",
          browser: getBrowserSummary(),
        });
        return;
      }

      const backCamera = devices.find(
        (d) =>
          d.label.toLowerCase().includes("back") ||
          d.label.toLowerCase().includes("rear") ||
          d.label.toLowerCase().includes("environment"),
      );
      const deviceId = backCamera?.deviceId || devices[0].deviceId;

      // Attach video feed listeners before starting decode
      const videoEl = videoRef.current;
      const onPlaying = () => {
        if (!isMountedRef.current) return;
        if (!videoEl || videoEl.readyState < 2 || videoEl.videoWidth === 0)
          return;
        setFeedActive(true);

        // Fire stream-ready telemetry exactly once per scanner start
        if (!streamReadyFiredRef.current) {
          streamReadyFiredRef.current = true;
          streamReadyTimeRef.current = Date.now();
          if (videoEl.srcObject instanceof MediaStream) {
            streamRef.current = videoEl.srcObject;
            const videoTrack = streamRef.current.getVideoTracks()[0];
            track("scanner_stream_ready", {
              camera_count: devices.length,
              has_multiple_cameras: devices.length > 1,
              facing_mode: videoTrack
                ? getFacingMode(videoTrack)
                : "unknown",
              browser: getBrowserSummary(),
              time_to_ready_ms: Date.now() - initStartTimeRef.current,
            });
          }
        }
      };
      if (videoEl) {
        videoEl.addEventListener("playing", onPlaying);
      }

      await reader.decodeFromVideoDevice(
        deviceId,
        videoRef.current,
        (result, _error) => {
          if (result) {
            const code = result.getText();
            if (isValidEan(code)) {
              onBarcodeDetectedRef.current(code);
            }
          }
        },
      );

      // Watchdog: if feed is still not active after 5 s, flag camera error
      setTimeout(() => {
        if (!isMountedRef.current) return;
        if (videoEl && (videoEl.readyState < 2 || videoEl.videoWidth === 0)) {
          setCameraError("generic");
          track("scanner_init_error", {
            error_type: "feed-timeout",
            browser: getBrowserSummary(),
          });
        }
      }, 5_000);
    } catch (err: unknown) {
      const errorType = classifyScannerError(err);
      track("scanner_init_error", {
        error_type: errorType,
        browser: getBrowserSummary(),
      });
      if (errorType === "permission-denied") {
        // Best-effort permission state detection
        let permKind: CameraErrorKind = "permission-unknown";
        try {
          if (navigator.permissions?.query) {
            const result = await navigator.permissions.query({
              name: "camera" as PermissionName,
            });
            permKind =
              result.state === "denied"
                ? "permission-denied"
                : "permission-prompt";
          }
        } catch {
          // Permissions API unavailable or 'camera' not supported
        }
        setCameraError(permKind);
      } else {
        setCameraError("generic");
      }
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps -- track is fire-and-forget
  }, [stopScanner]);

  // ─── Torch ──────────────────────────────────────────────────────────────

  const toggleTorch = useCallback(async () => {
    if (!streamRef.current) return;
    const videoTrack = streamRef.current.getVideoTracks()[0];
    if (!videoTrack) return;

    try {
      const capabilities = videoTrack.getCapabilities();
      if (isTorchCapable(capabilities) && capabilities.torch) {
        const newState = !torchOn;
        const constraint: TorchConstraintSet = { torch: newState };
        await videoTrack.applyConstraints({ advanced: [constraint] });
        setTorchOn(newState);
      } else {
        showToast({ type: "error", messageKey: "scan.torchNotSupported" });
      }
    } catch {
      showToast({ type: "error", messageKey: "scan.torchError" });
    }
  }, [torchOn]);

  // ─── Effects ────────────────────────────────────────────────────────────

  // Mounted guard for async telemetry reliability
  useEffect(() => {
    isMountedRef.current = true;
    return () => {
      isMountedRef.current = false;
    };
  }, []);

  // Auto-start/stop based on enabled flag
  useEffect(() => {
    if (enabled) {
      startScanner();
    }
    return () => stopScanner();
  }, [enabled, startScanner, stopScanner]);

  // ─── Public API ─────────────────────────────────────────────────────────

  const clearError = useCallback(() => {
    setCameraError(null);
  }, []);

  return {
    videoRef,
    cameraError,
    torchOn,
    feedActive,
    startScanner,
    stopScanner,
    toggleTorch,
    clearError,
    streamReadyTime: streamReadyTimeRef.current,
  };
}
