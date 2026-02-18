"use client";

// ─── ShortcutsHelp — keyboard shortcuts help overlay ────────────────────────
// Triggered by "?" key. Shows all available keyboard shortcuts.
// Desktop only (lg+). Uses native <dialog>.

import { useRef, useEffect, useCallback } from "react";
import { X } from "lucide-react";
import { useTranslation } from "@/lib/i18n";

// ─── Shortcut definitions ───────────────────────────────────────────────────

interface Shortcut {
  keys: string[];
  labelKey: string;
}

const NAVIGATION_SHORTCUTS: Shortcut[] = [
  { keys: ["Ctrl", "K"], labelKey: "shortcuts.commandPalette" },
  { keys: ["/"], labelKey: "shortcuts.focusSearch" },
  { keys: ["H"], labelKey: "shortcuts.goHome" },
  { keys: ["L"], labelKey: "shortcuts.goLists" },
  { keys: ["S"], labelKey: "shortcuts.openScanner" },
];

const GENERAL_SHORTCUTS: Shortcut[] = [
  { keys: ["?"], labelKey: "shortcuts.showShortcuts" },
  { keys: ["Esc"], labelKey: "shortcuts.closeOverlay" },
];

// ─── Props ──────────────────────────────────────────────────────────────────

interface ShortcutsHelpProps {
  open: boolean;
  onClose: () => void;
}

// ─── Component ──────────────────────────────────────────────────────────────

export function ShortcutsHelp({ open, onClose }: Readonly<ShortcutsHelpProps>) {
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
    onClose();
  }, [onClose]);

  useEffect(() => {
    const el = dialogRef.current;
    if (!el) return;
    el.addEventListener("cancel", handleCancel);
    return () => el.removeEventListener("cancel", handleCancel);
  }, [handleCancel]);

  const handleBackdropClick = useCallback(
    (e: React.MouseEvent<HTMLDialogElement>) => {
      if (e.target === dialogRef.current) {
        onClose();
      }
    },
    [onClose],
  );

  return (
    // eslint-disable-next-line jsx-a11y/click-events-have-key-events, jsx-a11y/no-noninteractive-element-interactions
    <dialog
      ref={dialogRef}
      aria-labelledby="shortcuts-help-title"
      onClick={handleBackdropClick}
      className="fixed inset-0 z-50 m-auto w-full max-w-sm rounded-2xl bg-surface p-6 shadow-xl backdrop:bg-black/30"
    >
      {/* Header */}
      <div className="mb-5 flex items-center justify-between">
        <h2
          id="shortcuts-help-title"
          className="text-base font-semibold text-foreground"
        >
          {t("shortcuts.title")}
        </h2>
        <button
          type="button"
          onClick={onClose}
          className="flex h-8 w-8 cursor-pointer items-center justify-center rounded-full text-foreground-secondary transition-colors hover:bg-surface-subtle hover:text-foreground"
          aria-label={t("common.close")}
        >
          <X size={18} aria-hidden="true" />
        </button>
      </div>

      {/* Navigation section */}
      <div className="mb-4">
        <h3 className="mb-2 text-xs font-semibold uppercase tracking-wider text-foreground-secondary/70">
          {t("shortcuts.navigation")}
        </h3>
        <div className="space-y-2">
          {NAVIGATION_SHORTCUTS.map((shortcut) => (
            <ShortcutRow
              key={shortcut.labelKey}
              keys={shortcut.keys}
              label={t(shortcut.labelKey)}
            />
          ))}
        </div>
      </div>

      {/* General section */}
      <div>
        <h3 className="mb-2 text-xs font-semibold uppercase tracking-wider text-foreground-secondary/70">
          {t("shortcuts.general")}
        </h3>
        <div className="space-y-2">
          {GENERAL_SHORTCUTS.map((shortcut) => (
            <ShortcutRow
              key={shortcut.labelKey}
              keys={shortcut.keys}
              label={t(shortcut.labelKey)}
            />
          ))}
        </div>
      </div>
    </dialog>
  );
}

// ─── ShortcutRow ────────────────────────────────────────────────────────────

function ShortcutRow({
  keys,
  label,
}: Readonly<{ keys: string[]; label: string }>) {
  return (
    <div className="flex items-center justify-between py-1">
      <span className="text-sm text-foreground">{label}</span>
      <span className="flex items-center gap-1">
        {keys.map((key, i) => (
          <span key={`${key}-${i}`}>
            <kbd className="inline-block min-w-[1.5rem] rounded border border-border bg-surface-muted px-1.5 py-0.5 text-center text-xs font-medium text-foreground-secondary">
              {key}
            </kbd>
            {i < keys.length - 1 && (
              <span className="mx-0.5 text-xs text-foreground-secondary/50">
                +
              </span>
            )}
          </span>
        ))}
      </span>
    </div>
  );
}
