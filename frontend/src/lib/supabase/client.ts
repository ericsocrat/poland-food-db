// ─── Supabase browser client (for Client Components) ────────────────────────
// Uses @supabase/ssr — the recommended package for Next.js App Router.
// Never import this in server components; use ./server.ts instead.

import { createBrowserClient } from "@supabase/ssr";

export function createClient() {
  return createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL ?? "",
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY ?? "",
  );
}
