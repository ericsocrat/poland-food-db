"use client";

// ─── Camera error card — 5-state-aware messaging with actionable CTAs ───────

import { Button } from "@/components/common/Button";
import type { CameraErrorKind } from "@/hooks/use-barcode-scanner";
import { useTranslation } from "@/lib/i18n";
import { CameraOff, Keyboard, RefreshCw, ShieldAlert } from "lucide-react";

interface ScannerErrorStateProps {
  error: CameraErrorKind;
  onRetry: () => void;
  onManualEntry: () => void;
}

export function ScannerErrorState({
  error,
  onRetry,
  onManualEntry,
}: ScannerErrorStateProps) {
  const { t } = useTranslation();

  const isPermissionError =
    error === "permission-prompt" ||
    error === "permission-denied" ||
    error === "permission-unknown";

  return (
    <div className="card border-warning-border bg-warning-bg px-5 py-6 text-center">
      <div className="mb-3 flex justify-center">
        {isPermissionError ? (
          <ShieldAlert
            size={40}
            className="animate-fade-in-up text-warning-text"
            aria-hidden="true"
          />
        ) : (
          <CameraOff
            size={40}
            className="animate-fade-in-up text-warning-text"
            aria-hidden="true"
          />
        )}
      </div>
      <p className="text-sm font-semibold text-warning-text">
        {error === "no-camera"
          ? t("scan.noCameraTitle")
          : error === "permission-denied"
            ? t("scan.cameraBlocked")
            : isPermissionError
              ? t("scan.cameraPermissionRequired")
              : t("scan.cameraUnavailable")}
      </p>
      <p className="mt-1.5 text-xs leading-relaxed text-warning-text/80">
        {error === "no-camera"
          ? t("scan.noCameraHint")
          : error === "permission-denied"
            ? t("scan.cameraBlockedHint")
            : error === "permission-prompt"
              ? t("scan.cameraPermissionHint")
              : error === "permission-unknown"
                ? t("scan.cameraPermissionUnknownHint")
                : t("scan.cameraUnavailableHint")}
      </p>
      <div className="mt-4 flex flex-col gap-2">
        {(error === "permission-denied" || error === "permission-unknown") && (
          <Button
            variant="secondary"
            onClick={() => window.location.reload()}
            icon={<RefreshCw size={16} aria-hidden="true" />}
          >
            {t("scan.reloadPage")}
          </Button>
        )}
        {error === "generic" && (
          <Button
            variant="secondary"
            onClick={onRetry}
            icon={<RefreshCw size={16} aria-hidden="true" />}
          >
            {t("scan.retryCamera")}
          </Button>
        )}
        <Button
          variant={error === "permission-denied" ? "primary" : "ghost"}
          onClick={onManualEntry}
          icon={<Keyboard size={16} aria-hidden="true" />}
        >
          {t("scan.enterManually")}
        </Button>
      </div>
    </div>
  );
}
