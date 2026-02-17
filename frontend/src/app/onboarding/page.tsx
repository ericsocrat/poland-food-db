// ─── Onboarding wizard entry page ────────────────────────────────────────────
// Issue #42: Multi-step onboarding wizard.
// Server component wrapper — redirects already-onboarded users to /app.

import { redirect } from "next/navigation";
import { createServerSupabaseClient } from "@/lib/supabase/server";
import { OnboardingWizard } from "./OnboardingWizard";

export const dynamic = "force-dynamic";

export default async function OnboardingPage() {
  const supabase = await createServerSupabaseClient();

  // Must be authenticated to onboard
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect("/auth/login");

  // If already onboarded, go to app
  const { data } = await supabase.rpc("api_get_user_preferences");
  const prefs = data as { onboarding_complete?: boolean } | null;
  if (prefs?.onboarding_complete) {
    redirect("/app/search");
  }

  return <OnboardingWizard />;
}
