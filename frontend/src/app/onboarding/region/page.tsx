// Server component wrapper — opts into dynamic rendering.

import { RegionForm } from "./RegionForm";

export const dynamic = "force-dynamic";

export default function OnboardingRegionPage() {
  return <RegionForm />;
}
