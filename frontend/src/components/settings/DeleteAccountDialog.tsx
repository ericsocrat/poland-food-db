"use client";

// ─── DeleteAccountDialog — GDPR Art.17 account deletion confirmation ────────
// Multi-step dialog: warning → type "DELETE" → processing → redirect.
// Uses <dialog> for native focus-trapping and Escape handling.
//
// ⚠️  Conditionally rendered (unmounted when closed) to avoid Android Chrome
// closed-dialog layout inflation. See PR #92.

import { useRef, useEffect, useCallback, useState } from "react";
import { useTranslation } from "@/lib/i18n";
import { AlertTriangle } from "lucide-react";

interface DeleteAccountDialogProps {
  /** Whether the dialog is open */
  open: boolean;
  /** Whether deletion is in progress */
  loading: boolean;
  /** Called when user confirms deletion */
  onConfirm: () => void;
  /** Called when user cancels or closes */
  onCancel: () => void;
}

/**
 * Conditionally rendered wrapper — prevents closed <dialog> from expanding
 * the mobile layout viewport on Android Chrome. See PR #92.
 */
export function DeleteAccountDialog(props: Readonly<DeleteAccountDialogProps>) {
  if (!props.open) return null;
  return <DeleteAccountDialogInner {...props} />;
}

function DeleteAccountDialogInner({
  loading,
  onConfirm,
  onCancel,
}: Readonly<DeleteAccountDialogProps>) {
  const { t } = useTranslation();
  const dialogRef = useRef<HTMLDialogElement>(null);
  const [confirmText, setConfirmText] = useState("");

  const isConfirmed = confirmText === "DELETE";

  // Show as modal immediately on mount
  useEffect(() => {
    const el = dialogRef.current;
    if (el && !el.open) {
      el.showModal();
    }
  }, []);

  const handleCancel = useCallback(() => {
    if (!loading) onCancel();
  }, [onCancel, loading]);

  // Native <dialog> fires "cancel" on Escape
  useEffect(() => {
    const el = dialogRef.current;
    if (!el) return;
    el.addEventListener("cancel", handleCancel);
    return () => el.removeEventListener("cancel", handleCancel);
  }, [handleCancel]);

  return (
    <dialog
      ref={dialogRef}
      aria-labelledby="delete-account-dialog-title"
      className="fixed inset-0 z-50 m-auto w-full max-w-md rounded-2xl bg-surface p-6 shadow-xl backdrop:bg-black/30 open:animate-[dialogIn_200ms_var(--ease-decelerate)] open:backdrop:animate-[backdropIn_150ms_var(--ease-standard)]"
      data-testid="delete-account-dialog"
    >
      {/* Header */}
      <div className="mb-3 flex items-center gap-2">
        <AlertTriangle
          size={20}
          className="text-error"
          aria-hidden="true"
        />
        <h3
          id="delete-account-dialog-title"
          className="text-base font-semibold text-foreground"
        >
          {t("settings.deleteAccount")}
        </h3>
      </div>

      {/* Warning */}
      <p className="mb-3 text-sm text-foreground-secondary">
        {t("settings.deleteAccountWarning")}
      </p>

      {/* Export-first suggestion */}
      <p className="mb-4 text-sm font-medium text-brand">
        {t("settings.deleteAccountExportFirst")}
      </p>

      {/* Confirmation input */}
      <label
        htmlFor="delete-confirm-input"
        className="mb-1 block text-sm font-medium text-foreground-secondary"
      >
        {t("settings.deleteAccountConfirmLabel")}
      </label>
      <input
        id="delete-confirm-input"
        type="text"
        autoComplete="off"
        spellCheck={false}
        value={confirmText}
        onChange={(e) => setConfirmText(e.target.value)}
        disabled={loading}
        placeholder={t("settings.deleteAccountConfirmPlaceholder")}
        className="mb-4 w-full rounded-lg border border-border bg-surface-muted px-3 py-2 text-sm text-foreground placeholder:text-foreground-secondary/50 focus:outline-none focus:ring-2 focus:ring-error/50 disabled:opacity-50"
        data-testid="delete-confirm-input"
      />

      {/* Actions */}
      <div className="flex justify-end gap-2">
        <button
          type="button"
          onClick={onCancel}
          disabled={loading}
          className="btn-secondary px-4 py-2 text-sm"
        >
          {t("common.cancel")}
        </button>
        <button
          type="button"
          onClick={onConfirm}
          disabled={!isConfirmed || loading}
          className="rounded-lg bg-error px-4 py-2 text-sm font-medium text-foreground-inverse hover:bg-error/90 disabled:opacity-50 disabled:cursor-not-allowed"
          data-testid="delete-account-confirm-button"
        >
          {loading
            ? t("settings.deleteAccountProcessing")
            : t("settings.deleteAccount")}
        </button>
      </div>
    </dialog>
  );
}
