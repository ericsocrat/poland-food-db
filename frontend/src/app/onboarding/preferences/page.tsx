// Server component wrapper — opts into dynamic rendering.

import { PreferencesForm } from "./PreferencesForm";

export const dynamic = "force-dynamic";

export default function OnboardingPreferencesPage() {
  return <PreferencesForm />;
}
