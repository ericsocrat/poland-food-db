// ─── Auth callback route handler ─────────────────────────────────────────────
// Supabase redirects here after email confirmation.
// Exchanges the auth code for a session, then redirects to the app.
// Instrumented with structured logging (#183).

import { logger } from "@/lib/logger";
import { createServerSupabaseClient } from "@/lib/supabase/server";
import * as Sentry from "@sentry/nextjs";
import { type NextRequest, NextResponse } from "next/server";

export async function GET(request: NextRequest) {
  const { searchParams } = new URL(request.url);
  const code = searchParams.get("code");

  if (code) {
    try {
      const supabase = await createServerSupabaseClient();
      await supabase.auth.exchangeCodeForSession(code);
      logger.info("Auth callback success", { route: "/auth/callback", method: "GET" });
    } catch (error) {
      logger.error("Auth callback failed", {
        route: "/auth/callback",
        method: "GET",
        error:
          error instanceof Error
            ? { name: error.name, message: error.message }
            : { name: "Unknown", message: String(error) },
      });
      Sentry.captureException(error, {
        tags: { route: "/auth/callback" },
      });
    }
  }

  // After confirming email, go to onboarding (app layout will check)
  const type = searchParams.get("type");
  const destination = type === "recovery" ? "/auth/update-password" : "/app/search";
  return NextResponse.redirect(new URL(destination, request.url));
}
