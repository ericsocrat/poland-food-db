"use client";

// ─── ConfirmDialog — accessible replacement for native confirm() ────────────
// Renders a modal dialog with confirm/cancel buttons.
// Uses <dialog> for native focus-trapping and Escape handling.
//
// ⚠️  IMPORTANT: The <dialog> element is conditionally rendered (mounted only
// when open, unmounted when closed). Android Chrome resolves box dimensions of
// closed <dialog> elements, inflating the layout viewport on mobile devices.
// See PR #92.

import { Button } from "@/components/common/Button";
import { useTranslation } from "@/lib/i18n";
import { useCallback, useEffect, useRef } from "react";

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

/**
 * Conditionally rendered wrapper — prevents closed <dialog> elements from
 * expanding the mobile layout viewport on Android Chrome. See PR #92.
 */
export function ConfirmDialog(props: Readonly<ConfirmDialogProps>) {
  if (!props.open) return null;
  return <ConfirmDialogInner {...props} />;
}

function ConfirmDialogInner({
  title,
  description,
  confirmLabel,
  variant = "default",
  onConfirm,
  onCancel,
}: Readonly<ConfirmDialogProps>) {
  const { t } = useTranslation();
  const dialogRef = useRef<HTMLDialogElement>(null);

  // Show as modal immediately on mount
  useEffect(() => {
    const el = dialogRef.current;
    if (el && !el.open) {
      el.showModal();
    }
  }, []);

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
        <Button variant="secondary" onClick={onCancel}>
          {t("common.cancel")}
        </Button>
        <Button
          variant={variant === "danger" ? "danger" : "primary"}
          onClick={onConfirm}
        >
          {confirmLabel ?? t("common.confirm")}
        </Button>
      </div>
    </dialog>
  );
}
