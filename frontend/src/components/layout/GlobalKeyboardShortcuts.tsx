"use client";

// ─── Global keyboard shortcuts for the app shell ────────────────────────────
// Handles all keyboard shortcuts and renders desktop-only overlays
// (CommandPalette, ShortcutsHelp). Desktop features hidden on mobile via CSS.

import { useEffect, useState, useCallback } from "react";
import { useRouter, usePathname } from "next/navigation";
import { CommandPalette } from "@/components/desktop/CommandPalette";
import { ShortcutsHelp } from "@/components/desktop/ShortcutsHelp";

/**
 * Global keyboard shortcuts:
 * - Ctrl+K / Cmd+K — Open command palette
 * - `/` — Focus search input (or navigate to /app/search)
 * - `H` — Navigate to Dashboard
 * - `L` — Navigate to Lists
 * - `S` — Open scanner
 * - `?` — Show keyboard shortcuts help
 * - `Escape` — Close any open overlay
 */
export function GlobalKeyboardShortcuts() {
  const router = useRouter();
  const pathname = usePathname();
  const [paletteOpen, setPaletteOpen] = useState(false);
  const [shortcutsOpen, setShortcutsOpen] = useState(false);

  const closePalette = useCallback(() => setPaletteOpen(false), []);
  const closeShortcuts = useCallback(() => setShortcutsOpen(false), []);

  useEffect(() => {
    function handleCtrlK(e: KeyboardEvent): boolean {
      if ((e.ctrlKey || e.metaKey) && e.key === "k") {
        e.preventDefault();
        setPaletteOpen((prev) => !prev);
        setShortcutsOpen(false);
        return true;
      }
      return false;
    }

    function handleSlash() {
      if (pathname === "/app/search") {
        const input = document.querySelector<HTMLInputElement>(
          'input[type="text"][aria-label]',
        );
        input?.focus();
      } else {
        router.push("/app/search");
      }
    }

    function handleSingleKey(e: KeyboardEvent) {
      if (e.ctrlKey || e.metaKey || e.altKey) return;

      switch (e.key) {
        case "/":
          e.preventDefault();
          handleSlash();
          break;
        case "H":
        case "h":
          router.push("/app");
          break;
        case "L":
        case "l":
          router.push("/app/lists");
          break;
        case "S":
        case "s":
          router.push("/app/scan");
          break;
        case "?":
          setShortcutsOpen((prev) => !prev);
          setPaletteOpen(false);
          break;
        case "Escape":
          setPaletteOpen(false);
          setShortcutsOpen(false);
          break;
      }
    }

    function handleKeyDown(e: KeyboardEvent) {
      if (handleCtrlK(e)) return;

      const target = e.target as HTMLElement;
      const isTyping =
        target.tagName === "INPUT" ||
        target.tagName === "TEXTAREA" ||
        target.tagName === "SELECT" ||
        target.isContentEditable;

      if (!isTyping) handleSingleKey(e);
    }

    document.addEventListener("keydown", handleKeyDown);
    return () => document.removeEventListener("keydown", handleKeyDown);
  }, [router, pathname]);

  return (
    <>
      <CommandPalette open={paletteOpen} onClose={closePalette} />
      <ShortcutsHelp open={shortcutsOpen} onClose={closeShortcuts} />
    </>
  );
}
