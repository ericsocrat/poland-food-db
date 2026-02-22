// ─── Supabase admin client (service_role — for Route Handlers only) ──────────
// Uses the service_role key which bypasses RLS. NEVER use in client components.
// Only import this in server-side Route Handlers (/api/*).

import { createClient } from "@supabase/supabase-js";

/**
 * Creates a Supabase client using the service_role key.
 * This client bypasses RLS — use only in server-side API routes.
 *
 * Requires env vars:
 * - NEXT_PUBLIC_SUPABASE_URL
 * - SUPABASE_SERVICE_ROLE_KEY
 */
export function createServiceRoleClient() {
  const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const key = process.env.SUPABASE_SERVICE_ROLE_KEY;

  if (!url || !key) {
    throw new Error(
      "Missing NEXT_PUBLIC_SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY. " +
        "Service role client requires both environment variables.",
    );
  }

  return createClient(url, key, {
    auth: {
      autoRefreshToken: false,
      persistSession: false,
    },
  });
}
