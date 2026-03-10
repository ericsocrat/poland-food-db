// ─── Zustand store for admin role state ──────────────────────────────────────
// Hydrated from server layout via AdminHydrator. Admin status is determined
// server-side from ADMIN_EMAILS env var — never exposed to the client bundle.

import { create } from "zustand";

interface AdminState {
  /** Whether the current user is an admin. */
  isAdmin: boolean;
  /** Set admin status (called by AdminHydrator). */
  setIsAdmin: (val: boolean) => void;
}

export const useAdminStore = create<AdminState>((set) => ({
  isAdmin: false,
  setIsAdmin: (val) => set({ isAdmin: val }),
}));
