/**
 * PrivacyNotice — First-use dialog informing users that image processing is
 * entirely client-side and no images are uploaded.
 * Issue #55 — Image Search v0
 */

"use client";

import { useRef, useEffect, useCallback } from "react";
import { useTranslation } from "@/lib/i18n";
import { Shield, Smartphone, EyeOff, Lock, CheckCircle } from "lucide-react";
import { Icon } from "@/components/common/Icon";
import type { LucideIcon } from "lucide-react";

interface PrivacyNoticeProps {
  readonly open: boolean;
  readonly onAccept: () => void;
}

const BULLETS: ReadonlyArray<{ icon: LucideIcon; key: string }> = [
  { icon: Smartphone, key: "imageSearch.privacy.bullet1" },
  { icon: EyeOff, key: "imageSearch.privacy.bullet2" },
  { icon: Lock, key: "imageSearch.privacy.bullet3" },
  { icon: CheckCircle, key: "imageSearch.privacy.bullet4" },
];

export function PrivacyNotice({ open, onAccept }: PrivacyNoticeProps) {
  if (!open) return null;
  return <PrivacyNoticeInner onAccept={onAccept} />;
}

function PrivacyNoticeInner({
  onAccept,
}: Readonly<{ onAccept: () => void }>) {
  const { t } = useTranslation();
  const dialogRef = useRef<HTMLDialogElement>(null);

  useEffect(() => {
    const el = dialogRef.current;
    if (el && !el.open) el.showModal();
  }, []);

  const handleCancel = useCallback(
    (e: Event) => {
      e.preventDefault(); // don't let Escape dismiss without accepting
    },
    [],
  );

  useEffect(() => {
    const el = dialogRef.current;
    if (!el) return;
    el.addEventListener("cancel", handleCancel);
    return () => el.removeEventListener("cancel", handleCancel);
  }, [handleCancel]);

  return (
    <dialog
      ref={dialogRef}
      aria-labelledby="privacy-notice-title"
      className="mx-auto w-full max-w-md rounded-xl border border-border bg-surface p-0 shadow-lg backdrop:bg-black/40"
    >
      <div className="p-6">
        <div className="mb-4 flex items-center gap-2">
          <Icon icon={Shield} size="lg" className="text-brand" />
          <h2
            id="privacy-notice-title"
            className="text-lg font-semibold text-foreground"
          >
            {t("imageSearch.privacy.title")}
          </h2>
        </div>

        <p className="mb-4 text-sm text-foreground-secondary">
          {t("imageSearch.privacy.body")}
        </p>

        <ul className="mb-6 space-y-3">
          {BULLETS.map((b) => (
            <li key={b.key} className="flex items-start gap-2 text-sm">
              <Icon
                icon={b.icon}
                size="sm"
                className="mt-0.5 shrink-0 text-brand"
              />
              <span className="text-foreground">{t(b.key)}</span>
            </li>
          ))}
        </ul>

        <button
          type="button"
          onClick={onAccept}
          className="btn-primary w-full py-2.5 text-sm font-medium"
          data-testid="privacy-accept-btn"
        >
          {t("imageSearch.privacy.accept")}
        </button>
      </div>
    </dialog>
  );
}
