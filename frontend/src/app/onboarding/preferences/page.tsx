// Server component wrapper — opts into dynamic rendering.

// Legacy route — redirects to the unified onboarding wizard (Issue #42).

import { redirect } from "next/navigation";

export default function OnboardingPreferencesPage() {
  redirect("/onboarding");
}
