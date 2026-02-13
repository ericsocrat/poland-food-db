// ─── Auth callback route handler ─────────────────────────────────────────────
// Supabase redirects here after email confirmation.
// Exchanges the auth code for a session, then redirects to the app.

import { NextRequest, NextResponse } from "next/server";
import { createServerSupabaseClient } from "@/lib/supabase/server";

export async function GET(request: NextRequest) {
  const { searchParams } = new URL(request.url);
  const code = searchParams.get("code");

  if (code) {
    const supabase = createServerSupabaseClient();
    await supabase.auth.exchangeCodeForSession(code);
  }

  // After confirming email, go to onboarding (app layout will check)
  return NextResponse.redirect(new URL("/app/search", request.url));
}
