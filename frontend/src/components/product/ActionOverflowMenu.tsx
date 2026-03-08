"use client";

// ─── ActionOverflowMenu — kebab overflow for secondary product actions ──────
// On mobile, WatchButton and PrintButton move into this dropdown to prevent
// the action bar from overflowing on 320px screens (Issue #690).

import { useTranslation } from "@/lib/i18n";
import { MoreVertical } from "lucide-react";
import { useCallback, useEffect, useRef, useState } from "react";

interface ActionOverflowMenuProps {
  readonly children: React.ReactNode;
  readonly className?: string;
}

export function ActionOverflowMenu({
  children,
  className = "",
}: ActionOverflowMenuProps) {
  const { t } = useTranslation();
  const [open, setOpen] = useState(false);
  const containerRef = useRef<HTMLDivElement>(null);

  const toggle = useCallback(() => setOpen((prev) => !prev), []);

  // Close on click outside
  useEffect(() => {
    if (!open) return;
    function handleClick(e: MouseEvent) {
      if (
        containerRef.current &&
        !containerRef.current.contains(e.target as Node)
      ) {
        setOpen(false);
      }
    }
    document.addEventListener("mousedown", handleClick);
    return () => document.removeEventListener("mousedown", handleClick);
  }, [open]);

  // Close on Escape
  useEffect(() => {
    if (!open) return;
    function handleKey(e: KeyboardEvent) {
      if (e.key === "Escape") setOpen(false);
    }
    document.addEventListener("keydown", handleKey);
    return () => document.removeEventListener("keydown", handleKey);
  }, [open]);

  return (
    <div ref={containerRef} className={`relative ${className}`}>
      <button
        type="button"
        onClick={toggle}
        aria-expanded={open}
        aria-haspopup="true"
        aria-label={t("productActions.moreActions")}
        className="touch-target flex h-10 w-10 items-center justify-center rounded-lg border border-border text-foreground-secondary transition-colors hover:bg-surface-subtle"
        data-testid="action-overflow-trigger"
      >
        <MoreVertical size={18} aria-hidden="true" />
      </button>

      {open && (
        <div
          role="menu"
          className="absolute right-0 top-full z-30 mt-1 min-w-[180px] rounded-xl border border-border bg-surface-primary py-1 shadow-lg"
          data-testid="action-overflow-menu"
        >
          {children}
        </div>
      )}
    </div>
  );
}
