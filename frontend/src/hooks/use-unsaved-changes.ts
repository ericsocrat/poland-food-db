"use client";

// ─── useUnsavedChanges — navigation guard for dirty forms ───────────────────
// Prevents accidental navigation when a form has unsaved changes.
//
//  1. Adds a `beforeunload` listener → browser shows native "Leave page?" dialog.
//  2. Patches `history.pushState` → intercepts Next.js client-side <Link> clicks
//     and router.push() calls, returning dialog state for a custom confirmation.
//
// On discard-confirmation the hook navigates via `window.location.assign()`,
// which triggers a full load. This is intentional: the user explicitly chose to
// discard their changes, so a clean page load is acceptable.

import { useEffect, useRef, useState, useCallback } from "react";

export interface UnsavedChangesResult {
  /** Whether the "Discard changes?" dialog should be shown. */
  showConfirmDialog: boolean;
  /** Call to confirm discarding changes and proceed with navigation. */
  confirmNavigation: () => void;
  /** Call to cancel the pending navigation and stay on the page. */
  cancelNavigation: () => void;
}

/**
 * Guards against accidental navigation when a form has unsaved changes.
 *
 * @param isDirty — `true` while the form has unsaved changes.
 * @returns dialog state and handlers for a custom confirmation dialog.
 */
export function useUnsavedChanges(isDirty: boolean): UnsavedChangesResult {
  const [pendingHref, setPendingHref] = useState<string | null>(null);
  const guardRef = useRef(false);

  // Keep ref in sync so event handlers always see the latest value.
  useEffect(() => {
    guardRef.current = isDirty;
    if (!isDirty) setPendingHref(null);
  }, [isDirty]);

  // ─── beforeunload: browser / tab close guard ────────────────────────
  useEffect(() => {
    if (!isDirty) return;

    const handler = (e: BeforeUnloadEvent) => {
      e.preventDefault();
    };

    window.addEventListener("beforeunload", handler);
    return () => window.removeEventListener("beforeunload", handler);
  }, [isDirty]);

  // ─── pushState: intercept Next.js Link / router.push navigation ────
  useEffect(() => {
    const original = history.pushState.bind(history);

    history.pushState = function (
      data: unknown,
      unused: string,
      url?: string | URL | null,
    ) {
      if (guardRef.current && url) {
        setPendingHref(String(url));
        return; // Block — the caller will see the confirm dialog
      }
      return original(data, unused, url);
    };

    return () => {
      history.pushState = original;
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps -- intentionally runs once; dirty check uses ref
  }, []);

  // ─── Confirm / Cancel handlers ──────────────────────────────────────

  const confirmNavigation = useCallback(() => {
    const href = pendingHref;
    setPendingHref(null);
    guardRef.current = false; // Disable guard before navigating
    if (href) {
      window.location.assign(href);
    }
  }, [pendingHref]);

  const cancelNavigation = useCallback(() => {
    setPendingHref(null);
  }, []);

  return {
    showConfirmDialog: pendingHref !== null,
    confirmNavigation,
    cancelNavigation,
  };
}
