// ─── Protected app layout ────────────────────────────────────────────────────
// Server component that checks onboarding_complete via api_get_user_preferences().
// If onboarding is incomplete, redirects to /onboarding/region.
// This is the AUTHORITATIVE onboarding gate (server-side).
// RouteGuard provides a secondary client-side gate for UX + session expiry handling.

import { redirect } from "next/navigation";
import { createServerSupabaseClient } from "@/lib/supabase/server";
import { translate } from "@/lib/i18n";
import { Navigation } from "@/components/layout/Navigation";
import { CountryChip } from "@/components/common/CountryChip";
import { ListsHydrator } from "@/components/product/ListsHydrator";
import { LanguageHydrator } from "@/components/i18n/LanguageHydrator";
import { CompareFloatingButton } from "@/components/compare/CompareFloatingButton";
import { OfflineIndicator } from "@/components/pwa/OfflineIndicator";
import { InstallPrompt } from "@/components/pwa/InstallPrompt";

export default async function AppLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  const supabase = await createServerSupabaseClient();

  // Double-check auth (middleware should have caught this, but belt-and-suspenders)
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect("/auth/login");

  // Check onboarding status via backend RPC
  const { data, error } = await supabase.rpc("api_get_user_preferences");

  // Transient RPC / network failure — show error instead of wrongly redirecting
  // an onboarded user back to region selection.
  if (error || !data) {
    return (
      <div className="flex min-h-screen flex-col items-center justify-center px-4 text-center">
        <p className="mb-2 text-4xl">⚠️</p>
        <h1 className="mb-1 text-lg font-bold text-foreground">
          {translate("en", "layout.errorTitle")}
        </h1>
        <p className="mb-6 text-sm text-foreground-secondary">
          {translate("en", "layout.errorMessage")}
        </p>
        <a href="/app/search" className="btn-primary inline-block px-6">
          {translate("en", "common.tryAgain")}
        </a>
      </div>
    );
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
      <OfflineIndicator />
      <header className="sticky top-0 z-40 border-b bg-white/80 pt-[env(safe-area-inset-top)] backdrop-blur">
        <div className="mx-auto flex h-14 max-w-5xl items-center justify-between px-4">
          <span className="text-lg font-bold text-brand-700">
            {translate("en", "layout.appNameWithEmoji")}
          </span>
          <CountryChip country={prefs.country} />
        </div>
      </header>

      <main className="mx-auto w-full max-w-5xl flex-1 px-4 py-6">
        <ListsHydrator />
        <LanguageHydrator />
        {children}
      </main>

      <CompareFloatingButton />
      <InstallPrompt />
      <Navigation />
    </div>
  );
}
