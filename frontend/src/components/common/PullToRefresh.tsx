"use client";

// ─── PullToRefresh — native-feel pull-to-refresh gesture wrapper ────────────
// Wraps page content and shows a spinner indicator when the user pulls down
// from the top of the page. Triggers the provided `onRefresh` callback which
// should return a Promise (typically TanStack Query refetch / invalidation).

import { useReducedMotion } from "@/hooks/use-reduced-motion";
import { useTranslation } from "@/lib/i18n";
import { useCallback, useRef, useState } from "react";

// ─── Constants ──────────────────────────────────────────────────────────────

const PULL_THRESHOLD = 60;
const MAX_PULL = 120;
const INDICATOR_SIZE = 32;

type PullState = "idle" | "pulling" | "triggered" | "refreshing";

// ─── Component ──────────────────────────────────────────────────────────────

export function PullToRefresh({
  onRefresh,
  children,
  className = "",
}: Readonly<{
  onRefresh: () => Promise<void>;
  children: React.ReactNode;
  className?: string;
}>) {
  const { t } = useTranslation();
  const prefersReduced = useReducedMotion();
  const [pullState, setPullState] = useState<PullState>("idle");
  const [pullDistance, setPullDistance] = useState(0);
  const touchStartY = useRef(0);
  const containerRef = useRef<HTMLDivElement>(null);

  const isAtTop = useCallback((): boolean => {
    // Check if the page is scrolled to the very top
    if (window.scrollY > 0) return false;
    // Also check if the container itself is scrolled
    if (containerRef.current && containerRef.current.scrollTop > 0)
      return false;
    return true;
  }, []);

  const handleTouchStart = useCallback(
    (e: React.TouchEvent) => {
      if (pullState === "refreshing") return;
      if (!isAtTop()) return;
      touchStartY.current = e.touches[0].clientY;
      setPullState("pulling");
    },
    [pullState, isAtTop],
  );

  const handleTouchMove = useCallback(
    (e: React.TouchEvent) => {
      if (pullState !== "pulling" && pullState !== "triggered") return;
      const currentY = e.touches[0].clientY;
      const delta = currentY - touchStartY.current;

      if (delta <= 0) {
        setPullDistance(0);
        setPullState("pulling");
        return;
      }

      // Dampen the pull for a rubber-band feel
      const dampened = Math.min(delta * 0.5, MAX_PULL);
      setPullDistance(dampened);
      setPullState(dampened >= PULL_THRESHOLD ? "triggered" : "pulling");
    },
    [pullState],
  );

  const handleTouchEnd = useCallback(async () => {
    if (pullState === "refreshing") return;

    if (pullState === "triggered") {
      setPullState("refreshing");
      setPullDistance(PULL_THRESHOLD);

      // Haptic feedback if available
      if (typeof navigator !== "undefined" && "vibrate" in navigator) {
        navigator.vibrate(10);
      }

      try {
        await onRefresh();
      } finally {
        setPullState("idle");
        setPullDistance(0);
      }
    } else {
      setPullState("idle");
      setPullDistance(0);
    }
  }, [pullState, onRefresh]);

  const progress = Math.min(pullDistance / PULL_THRESHOLD, 1);
  const showIndicator = pullState !== "idle";

  // Accessible status text
  const statusText =
    pullState === "refreshing"
      ? t("pwa.refreshing")
      : pullState === "triggered"
        ? t("pwa.releaseToRefresh")
        : t("pwa.pullToRefresh");

  return (
    <div
      ref={containerRef}
      className={`relative ${className}`}
      onTouchStart={handleTouchStart}
      onTouchMove={handleTouchMove}
      onTouchEnd={handleTouchEnd}
    >
      {/* Pull indicator */}
      {showIndicator && (
        <div
          className="pointer-events-none flex items-center justify-center overflow-hidden"
          style={{
            height: pullDistance,
            transition:
              pullState === "refreshing"
                ? prefersReduced
                  ? "none"
                  : "height 200ms ease-out"
                : "none",
          }}
          aria-live="polite"
          aria-atomic="true"
        >
          <div
            className="flex flex-col items-center gap-1"
            style={{
              opacity: progress,
              transform: `scale(${0.5 + progress * 0.5})`,
              transition: prefersReduced ? "none" : undefined,
            }}
          >
            {/* Spinner circle */}
            <svg
              width={INDICATOR_SIZE}
              height={INDICATOR_SIZE}
              viewBox="0 0 32 32"
              className={
                pullState === "refreshing" && !prefersReduced
                  ? "animate-spin"
                  : ""
              }
              aria-hidden="true"
            >
              <circle
                cx="16"
                cy="16"
                r="12"
                fill="none"
                stroke="currentColor"
                strokeWidth="2.5"
                className="text-border"
              />
              <circle
                cx="16"
                cy="16"
                r="12"
                fill="none"
                stroke="currentColor"
                strokeWidth="2.5"
                strokeLinecap="round"
                className="text-brand"
                strokeDasharray={`${progress * 75.4} 75.4`}
                style={{
                  transform: "rotate(-90deg)",
                  transformOrigin: "center",
                }}
              />
            </svg>
            <span className="text-[11px] text-foreground-muted">
              {statusText}
            </span>
          </div>
        </div>
      )}

      {/* Announce refreshing state to screen readers */}
      {pullState === "refreshing" && (
        <div className="sr-only" role="status">
          {t("pwa.refreshing")}
        </div>
      )}

      {/* Page content */}
      {children}
    </div>
  );
}
