"use client";

// ─── Scan result views — error, not-found, looking-up, found states ─────────

import { Button, ButtonLink } from "@/components/common/Button";
import { EmptyStateIllustration } from "@/components/common/EmptyStateIllustration";
import { LoadingSpinner } from "@/components/common/LoadingSpinner";
import { ScanMissSubmitCTA } from "@/components/scan/ScanMissSubmitCTA";
import { useReducedMotion } from "@/hooks/use-reduced-motion";
import { getCountryFlag, getCountryName, NUTRI_COLORS } from "@/lib/constants";
import { gs1CountryHint } from "@/lib/gs1";
import { useTranslation } from "@/lib/i18n";
import { getScoreBand, toTryVitScore } from "@/lib/score-utils";
import type {
    RecordScanFoundResponse,
    RecordScanNotFoundResponse,
} from "@/lib/types";
import {
    AlertTriangle,
    CheckCircle,
    ClipboardList,
    RefreshCw,
} from "lucide-react";
import { useEffect, useState } from "react";

// ─── Shared animation wrapper ───────────────────────────────────────────────

export function FadeSlideIn({ children }: Readonly<{ children: React.ReactNode }>) {
  const prefersReduced = useReducedMotion();
  const [visible, setVisible] = useState(false);
  useEffect(() => { setVisible(true); }, []);

  if (prefersReduced) return <>{children}</>;

  return (
    <div
      className="transition-all duration-300 ease-out"
      style={{
        opacity: visible ? 1 : 0,
        transform: visible ? "translateY(0)" : "translateY(12px)",
      }}
    >
      {children}
    </div>
  );
}

// ─── Error state ────────────────────────────────────────────────────────────

interface ScanErrorProps {
  ean: string;
  onRetry: () => void;
  onReset: () => void;
}

export function ScanErrorView({ ean, onRetry, onReset }: ScanErrorProps) {
  const { t } = useTranslation();

  return (
    <FadeSlideIn>
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
            onClick={onRetry}
            className="flex-1"
            icon={<RefreshCw size={16} aria-hidden="true" />}
          >
            {t("common.retry")}
          </Button>
          <Button onClick={onReset} className="flex-1">
            {t("scan.scanAnother")}
          </Button>
        </div>
      </div>
    </FadeSlideIn>
  );
}

// ─── Not-found state ────────────────────────────────────────────────────────

interface ScanNotFoundProps {
  ean: string;
  scanResult: RecordScanNotFoundResponse;
  onReset: () => void;
  country?: string;
}

export function ScanNotFoundView({
  ean,
  scanResult,
  onReset,
  country,
}: ScanNotFoundProps) {
  const { t } = useTranslation();
  const gs1Hint = gs1CountryHint(ean);

  return (
    <FadeSlideIn>
      <div className="mx-auto max-w-md space-y-4">
        <div className="card text-center">
          <div className="mb-2 flex animate-shake justify-center">
            <EmptyStateIllustration type="no-results" titleKey="scan.notFound" />
          </div>
          <p className="mt-1 text-sm text-foreground-secondary">
            {t("scan.notFoundMessage", { ean })}
          </p>
          {gs1Hint && (
            <>
              <p className="mt-2 inline-flex items-center gap-1 rounded-full bg-gray-100 px-3 py-1 text-xs text-foreground-secondary dark:bg-gray-800">
                <span aria-hidden="true">{getCountryFlag(gs1Hint.code)}</span>
                {t("scan.gs1Hint", { country: gs1Hint.name })}
              </p>
              <p className="mt-1 text-xs text-foreground-muted">
                {t("scan.gs1CoverageNote")}
              </p>
            </>
          )}
        </div>

        <ScanMissSubmitCTA
          ean={ean}
          hasPendingSubmission={scanResult.has_pending_submission}
          country={country}
        />

        <div className="flex gap-2">
          <ButtonLink
            href="/app/scan/history"
            className="flex-1"
            icon={<ClipboardList size={16} aria-hidden="true" />}
          >
            {t("scan.history")}
          </ButtonLink>
          <Button
            onClick={onReset}
            variant="secondary"
            className="flex-1"
          >
            {t("scan.scanAnother")}
          </Button>
        </div>
      </div>
    </FadeSlideIn>
  );
}

// ─── Looking-up state ───────────────────────────────────────────────────────

interface ScanLookingUpProps {
  ean: string;
}

export function ScanLookingUpView({ ean }: ScanLookingUpProps) {
  const { t } = useTranslation();

  return (
    <FadeSlideIn>
      <div className="flex flex-col items-center gap-3 py-12">
        <LoadingSpinner />
        <p className="text-sm text-foreground-secondary">
          {t("scan.lookingUp", { ean })}
        </p>
      </div>
    </FadeSlideIn>
  );
}

// ─── Found state ────────────────────────────────────────────────────────────

interface ScanFoundProps {
  product: RecordScanFoundResponse;
  onViewDetails: () => void;
  onReset: () => void;
}

export function ScanFoundView({
  product,
  onViewDetails,
  onReset,
}: ScanFoundProps) {
  const { t } = useTranslation();
  const prefersReduced = useReducedMotion();
  const band = getScoreBand(product.unhealthiness_score);
  const tryVitScore = toTryVitScore(product.unhealthiness_score);
  const [displayScore, setDisplayScore] = useState(0);

  // Animated score count-up
  useEffect(() => {
    if (prefersReduced || tryVitScore === 0) {
      setDisplayScore(tryVitScore);
      return;
    }
    let frame: number;
    const start = performance.now();
    const duration = 600; // ms
    function tick(now: number) {
      const progress = Math.min((now - start) / duration, 1);
      setDisplayScore(Math.round(progress * tryVitScore));
      if (progress < 1) frame = requestAnimationFrame(tick);
    }
    frame = requestAnimationFrame(tick);
    return () => cancelAnimationFrame(frame);
  }, [tryVitScore, prefersReduced]);

  return (
    <FadeSlideIn>
      <div className="space-y-4">
        <div className="card text-center">
          <div className="mb-3 flex justify-center">
            <CheckCircle
              size={48}
              className={`text-success${
                prefersReduced ? "" : " animate-[bounceIn_0.5s_ease-out]"
              }`}
              aria-hidden="true"
            />
          </div>
        <p className="text-lg font-bold text-foreground">
          {t("scan.productFound")}
        </p>
        <p className="mt-2 text-base font-semibold text-foreground">
          {product.product_name_display ?? product.product_name}
        </p>
        {product.brand && (
          <p className="text-sm text-foreground-secondary">
            {product.brand}
          </p>
        )}
        {product.is_cross_country && (
          <p className="mt-2 inline-flex items-center gap-1 rounded-full bg-gray-100 px-3 py-1 text-xs text-foreground-secondary dark:bg-gray-800">
            <span aria-hidden="true">{getCountryFlag(product.product_country)}</span>
            {t("scan.crossCountryBadge", { country: getCountryName(product.product_country) })}
          </p>
        )}
        {band && (
          <div className="mt-3 flex items-center justify-center gap-2">
            <span
              className="inline-flex items-center gap-1 rounded-full px-3 py-1 text-sm font-semibold"
              style={{ backgroundColor: band.bgColor, color: band.textColor }}
            >
              {displayScore}
            </span>
            <span className="text-sm text-foreground-secondary">
              {t(band.labelKey)}
            </span>
          </div>
        )}
        {product.nutri_score && (
          <div className="mt-2 flex items-center justify-center gap-1">
            <span
              className={`inline-flex h-6 w-6 items-center justify-center rounded text-xs font-bold text-white ${
                NUTRI_COLORS[product.nutri_score] ?? "bg-foreground-muted"
              }`}
            >
              {product.nutri_score}
            </span>
            <span className="text-xs text-foreground-muted">Nutri-Score</span>
          </div>
        )}
      </div>
      <div className="flex gap-2">
        <Button onClick={onViewDetails} className="flex-1">
          {t("scan.viewDetails")}
        </Button>
        <Button
          variant="secondary"
          onClick={onReset}
          className="flex-1"
        >
          {t("scan.scanNext")}
        </Button>
      </div>
    </div>
    </FadeSlideIn>
  );
}
