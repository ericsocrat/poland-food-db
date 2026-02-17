"use client";

// ─── ConfirmDialog — accessible replacement for native confirm() ────────────
// Renders a modal dialog with confirm/cancel buttons.
// Uses <dialog> for native focus-trapping and Escape handling.

import { useRef, useEffect, useCallback } from "react";
import { useTranslation } from "@/lib/i18n";

interface ConfirmDialogProps {
  /** Whether the dialog is open */
  open: boolean;
  /** Title text */
  title: string;
  /** Description / body text */
  description?: string;
  /** Label for the confirm button (default: "Confirm") */
  confirmLabel?: string;
  /** Visual style of the confirm button */
  variant?: "danger" | "default";
  /** Called when user confirms */
  onConfirm: () => void;
  /** Called when user cancels or closes */
  onCancel: () => void;
}

export function ConfirmDialog({
  open,
  title,
  description,
  confirmLabel,
  variant = "default",
  onConfirm,
  onCancel,
}: Readonly<ConfirmDialogProps>) {
  const { t } = useTranslation();
  const dialogRef = useRef<HTMLDialogElement>(null);

  useEffect(() => {
    const el = dialogRef.current;
    if (!el) return;
    if (open && !el.open) {
      el.showModal();
    } else if (!open && el.open) {
      el.close();
    }
  }, [open]);

  const handleCancel = useCallback(() => {
    onCancel();
  }, [onCancel]);

  // Native <dialog> fires "cancel" on Escape
  useEffect(() => {
    const el = dialogRef.current;
    if (!el) return;
    el.addEventListener("cancel", handleCancel);
    return () => el.removeEventListener("cancel", handleCancel);
  }, [handleCancel]);

  const confirmBtnClass =
    variant === "danger"
      ? "rounded-lg bg-error px-4 py-2 text-sm font-medium text-foreground-inverse hover:bg-error/90"
      : "btn-primary px-4 py-2 text-sm";

  return (
    <dialog
      ref={dialogRef}
      aria-labelledby="confirm-dialog-title"
      className="fixed inset-0 z-50 m-auto w-full max-w-sm rounded-2xl bg-surface p-6 shadow-xl backdrop:bg-black/30 open:animate-[dialogIn_200ms_var(--ease-decelerate)] open:backdrop:animate-[backdropIn_150ms_var(--ease-standard)]"
    >
      <h3
        id="confirm-dialog-title"
        className="mb-1 text-base font-semibold text-foreground"
      >
        {title}
      </h3>
      {description && (
        <p className="mb-4 text-sm text-foreground-secondary">{description}</p>
      )}

      <div className="flex justify-end gap-2">
        <button
          type="button"
          onClick={onCancel}
          className="btn-secondary px-4 py-2 text-sm"
        >
          {t("common.cancel")}
        </button>
        <button type="button" onClick={onConfirm} className={confirmBtnClass}>
          {confirmLabel ?? t("common.confirm")}
        </button>
      </div>
    </dialog>
  );
}
