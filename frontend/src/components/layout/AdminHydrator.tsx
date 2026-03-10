"use client";

// ─── AdminHydrator ──────────────────────────────────────────────────────────
// Invisible component rendered in the server layout to hydrate the Zustand
// admin store. Admin status is computed server-side from ADMIN_EMAILS env var,
// then passed as a prop — the email list is never exposed to the client.

import { useAdminStore } from "@/stores/admin-store";
import { useEffect, useRef } from "react";

export function AdminHydrator({ isAdmin }: Readonly<{ isAdmin: boolean }>) {
  const setIsAdmin = useAdminStore((s) => s.setIsAdmin);
  const hydrated = useRef(false);

  // Immediate hydration on first render (before paint)
  if (!hydrated.current) {
    hydrated.current = true;
    setIsAdmin(isAdmin);
  }

  // Re-sync if prop changes (e.g. session refresh)
  useEffect(() => {
    setIsAdmin(isAdmin);
  }, [isAdmin, setIsAdmin]);

  return null;
}
