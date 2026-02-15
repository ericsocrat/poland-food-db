"use client";

// ─── ListsHydrator ──────────────────────────────────────────────────────────
// Invisible component that runs in the app layout to hydrate the Zustand
// avoid + favorites stores on login. This replaces the need for per-page
// hydration hooks and ensures badges are ready immediately.

import { useAvoidProductIds, useFavoriteProductIds } from "@/hooks/use-lists";

export function ListsHydrator() {
  // These hooks fetch IDs and sync to Zustand stores via useEffect
  useAvoidProductIds();
  useFavoriteProductIds();

  return null; // Render-invisible
}
