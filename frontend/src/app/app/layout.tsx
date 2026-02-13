// ─── Protected app layout ────────────────────────────────────────────────────
// Server component that checks onboarding_complete via api_get_user_preferences().
// If onboarding is incomplete, redirects to /onboarding/region.
// This is the ONLY place where onboarding gating happens.

import { redirect } from "next/navigation";
import { createServerSupabaseClient } from "@/lib/supabase/server";
import { Navigation } from "@/components/layout/Navigation";
import { CountryChip } from "@/components/common/CountryChip";

export default async function AppLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const supabase = createServerSupabaseClient();

  // Double-check auth (middleware should have caught this, but belt-and-suspenders)
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect("/auth/login");

  // Check onboarding status via backend RPC
  const { data, error } = await supabase.rpc("api_get_user_preferences");

  if (error || !data) {
    // If we can't fetch preferences, redirect to onboarding as safe default
    redirect("/onboarding/region");
  }

  const prefs = data as {
    onboarding_complete: boolean;
    country: string | null;
  };

  if (!prefs.onboarding_complete) {
    redirect("/onboarding/region");
  }

  return (
    <div className="flex min-h-screen flex-col">
      <header className="sticky top-0 z-40 border-b border-gray-200 bg-white/80 backdrop-blur">
        <div className="mx-auto flex h-14 max-w-5xl items-center justify-between px-4">
          <span className="text-lg font-bold text-brand-700">🥗 FoodDB</span>
          <CountryChip country={prefs.country} />
        </div>
      </header>

      <main className="mx-auto w-full max-w-5xl flex-1 px-4 py-6">
        {children}
      </main>

      <Navigation />
    </div>
  );
}
