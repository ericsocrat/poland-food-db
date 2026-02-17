"use client";

// ─── Global keyboard shortcuts for the app shell ────────────────────────────
// Phase 3 of #62: "/" to focus search

import { useEffect } from "react";
import { useRouter, usePathname } from "next/navigation";

/**
 * Global keyboard shortcuts:
 * - `/` — Focus the search input (or navigate to /app/search)
 */
export function GlobalKeyboardShortcuts() {
  const router = useRouter();
  const pathname = usePathname();

  useEffect(() => {
    function handleKeyDown(e: KeyboardEvent) {
      // Ignore when typing in an input, textarea or contenteditable
      const tag = (e.target as HTMLElement)?.tagName;
      if (
        tag === "INPUT" ||
        tag === "TEXTAREA" ||
        (e.target as HTMLElement)?.isContentEditable
      ) {
        return;
      }

      if (e.key === "/") {
        e.preventDefault();

        if (pathname === "/app/search") {
          // Already on search page — focus the input
          const input = document.querySelector<HTMLInputElement>(
            'input[type="text"][aria-label]',
          );
          input?.focus();
        } else {
          // Navigate to search (will auto-focus via autoFocus prop)
          router.push("/app/search");
        }
      }
    }

    document.addEventListener("keydown", handleKeyDown);
    return () => document.removeEventListener("keydown", handleKeyDown);
  }, [router, pathname]);

  return null;
}
