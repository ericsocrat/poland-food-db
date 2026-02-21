/**
 * ImageCapture — File upload (+ optional camera capture) for OCR input.
 * Issue #55 — Image Search v0
 *
 * Two input modes:
 * 1. File upload — always available (`` with accept="image/*")
 * 2. Live camera — via getUserMedia (shows if browser supports it)
 *
 * After an image is selected/captured, it fires `onCapture` with a Blob.
 * The blob is ephemeral — the parent handles OCR processing and cleanup.
 */

"use client";

import { useRef, useState, useCallback, useEffect } from "react";
import { Camera, Upload, X, SwitchCamera } from "lucide-react";
import { useTranslation } from "@/lib/i18n";
import { Icon } from "@/components/common/Icon";

interface ImageCaptureProps {
  /** Called when user has selected/captured an image. */
  readonly onCapture: (blob: Blob) => void;
  /** Whether OCR is currently processing (disables controls). */
  readonly processing: boolean;
}

export function ImageCapture({ onCapture, processing }: ImageCaptureProps) {
  const { t } = useTranslation();
  const fileInputRef = useRef<HTMLInputElement>(null);
  const videoRef = useRef<HTMLVideoElement>(null);
  const canvasRef = useRef<HTMLCanvasElement>(null);

  const [cameraActive, setCameraActive] = useState(false);
  const [cameraSupported, setCameraSupported] = useState(false);
  const [cameraError, setCameraError] = useState<string | null>(null);
  const streamRef = useRef<MediaStream | null>(null);

  // Check camera support on mount
  useEffect(() => {
    const supported =
      typeof navigator !== "undefined" &&
      !!navigator.mediaDevices?.getUserMedia;
    setCameraSupported(supported);
  }, []);

  // Cleanup camera stream on unmount
  useEffect(() => {
    return () => {
      if (streamRef.current) {
        streamRef.current.getTracks().forEach((t) => t.stop());
        streamRef.current = null;
      }
    };
  }, []);

  const startCamera = useCallback(async () => {
    setCameraError(null);
    try {
      const stream = await navigator.mediaDevices.getUserMedia({
        video: { facingMode: "environment" },
      });
      streamRef.current = stream;
      if (videoRef.current) {
        videoRef.current.srcObject = stream;
        await videoRef.current.play();
      }
      setCameraActive(true);
    } catch {
      setCameraError(t("imageSearch.cameraError"));
      setCameraActive(false);
    }
  }, [t]);

  const stopCamera = useCallback(() => {
    if (streamRef.current) {
      streamRef.current.getTracks().forEach((t) => t.stop());
      streamRef.current = null;
    }
    if (videoRef.current) {
      videoRef.current.srcObject = null;
    }
    setCameraActive(false);
  }, []);

  const captureFrame = useCallback(() => {
    const video = videoRef.current;
    const canvas = canvasRef.current;
    if (!video || !canvas) return;

    canvas.width = video.videoWidth;
    canvas.height = video.videoHeight;
    const ctx = canvas.getContext("2d");
    if (!ctx) return;

    ctx.drawImage(video, 0, 0);
    canvas.toBlob(
      (blob) => {
        if (blob) {
          stopCamera();
          onCapture(blob);
        }
      },
      "image/jpeg",
      0.9,
    );
    // Canvas is cleared after capture (privacy)
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    canvas.width = 0;
    canvas.height = 0;
  }, [onCapture, stopCamera]);

  const handleFileChange = useCallback(
    (e: React.ChangeEvent<HTMLInputElement>) => {
      const file = e.target.files?.[0];
      if (file) onCapture(file);
      // Reset input so re-selecting the same file works
      if (fileInputRef.current) fileInputRef.current.value = "";
    },
    [onCapture],
  );

  return (
    <div className="space-y-4">
      {/* Camera view (when active) */}
      {cameraActive && (
        <div className="relative overflow-hidden rounded-xl border border-border">
          <video
            ref={videoRef}
            autoPlay
            playsInline
            muted
            className="w-full"
            data-testid="camera-preview"
          />
          {/* Alignment guide */}
          <div className="pointer-events-none absolute inset-4 rounded-lg border-2 border-dashed border-white/50" />
          <div className="absolute bottom-4 left-0 right-0 flex justify-center gap-3">
            <button
              type="button"
              onClick={captureFrame}
              disabled={processing}
              className="btn-primary rounded-full px-6 py-2.5 text-sm font-medium shadow-lg"
              data-testid="capture-btn"
            >
              <Icon icon={Camera} size="sm" className="mr-1.5" />
              {t("imageSearch.capture")}
            </button>
            <button
              type="button"
              onClick={stopCamera}
              className="rounded-full bg-surface/80 p-2.5 shadow-lg backdrop-blur-sm"
              aria-label={t("common.cancel")}
            >
              <Icon icon={X} size="sm" />
            </button>
          </div>
        </div>
      )}

      {/* Action buttons (when camera not active) */}
      {!cameraActive && (
        <div className="flex flex-col items-center gap-3 rounded-xl border-2 border-dashed border-border p-8">
          <p className="text-center text-sm text-foreground-secondary">
            {t("imageSearch.instructions")}
          </p>

          <div className="flex gap-3">
            {cameraSupported && (
              <button
                type="button"
                onClick={startCamera}
                disabled={processing}
                className="btn-primary flex items-center gap-2 px-4 py-2.5 text-sm"
                data-testid="open-camera-btn"
              >
                <Icon icon={SwitchCamera} size="sm" />
                {t("imageSearch.openCamera")}
              </button>
            )}
            <button
              type="button"
              onClick={() => fileInputRef.current?.click()}
              disabled={processing}
              className="btn-secondary flex items-center gap-2 px-4 py-2.5 text-sm"
              data-testid="upload-btn"
            >
              <Icon icon={Upload} size="sm" />
              {t("imageSearch.uploadPhoto")}
            </button>
          </div>

          {cameraError && (
            <p className="text-xs text-error" role="alert">
              {cameraError}
            </p>
          )}

          <p className="mt-2 text-center text-xs text-foreground-secondary">
            {t("imageSearch.tips")}
          </p>
        </div>
      )}

      {/* Hidden file input */}
      <input
        ref={fileInputRef}
        type="file"
        accept="image/*"
        capture="environment"
        onChange={handleFileChange}
        className="hidden"
        data-testid="file-input"
      />

      {/* Hidden canvas for frame capture */}
      <canvas ref={canvasRef} className="hidden" />
    </div>
  );
}
