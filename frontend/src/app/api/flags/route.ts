// ─── Feature Flags API Route ─────────────────────────────────────────────────
// GET /api/flags — Returns evaluated flags for the current user context.
// Called by FlagProvider on client side (#191).

import { NextResponse } from "next/server";
import { createServerSupabaseClient } from "@/lib/supabase/server";
import { evaluateAllFlags } from "@/lib/flags/server";
import type { FlagContext } from "@/lib/flags/types";

export const dynamic = "force-dynamic";

export async function GET() {
  try {
    // Build context from current request
    const supabase = await createServerSupabaseClient();
    const {
      data: { user },
    } = await supabase.auth.getUser();

    // Resolve country from user_preferences (DB-driven, same as rest of app)
    let country = "PL";
    if (user) {
      const { data: prefs } = await supabase
        .from("user_preferences")
        .select("country")
        .eq("user_id", user.id)
        .maybeSingle();
      if (prefs?.country) {
        country = prefs.country as string;
      }
    }

    const ctx: FlagContext = {
      userId: user?.id,
      country,
      environment: process.env.VERCEL_ENV ?? process.env.NODE_ENV ?? "development",
    };

    const result = await evaluateAllFlags(ctx);

    return NextResponse.json(result, {
      headers: {
        "Cache-Control": "private, max-age=5",
      },
    });
  } catch {
    // On error, return empty flags (safe default — all features disabled)
    return NextResponse.json(
      { flags: {}, variants: {} },
      { status: 200 },
    );
  }
}
