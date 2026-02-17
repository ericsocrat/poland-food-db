// Legacy route — redirects to the unified onboarding wizard (Issue #42).

import { redirect } from "next/navigation";

export default function OnboardingRegionPage() {
  redirect("/onboarding");
}
