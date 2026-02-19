// ─── Protected app layout ────────────────────────────────────────────────────
// Server component that checks onboarding_complete via api_get_user_preferences().
// If onboarding is incomplete, redirects to /onboarding.
// This is the AUTHORITATIVE onboarding gate (server-side).
// RouteGuard provides a secondary client-side gate for UX + session expiry handling.

import { redirect } from "next/navigation";
import { AlertTriangle } from "lucide-react";
import { createServerSupabaseClient } from "@/lib/supabase/server";
import { translate } from "@/lib/i18n";
import { Navigation } from "@/components/layout/Navigation";
import { DesktopSidebar } from "@/components/layout/DesktopSidebar";
import { DesktopHeaderNav } from "@/components/layout/DesktopHeaderNav";
import { SkipLink } from "@/components/common/SkipLink";
import { CountryChip } from "@/components/common/CountryChip";
import { ListsHydrator } from "@/components/product/ListsHydrator";
import { LanguageHydrator } from "@/components/i18n/LanguageHydrator";
import { CompareFloatingButton } from "@/components/compare/CompareFloatingButton";
import { ComparisonTray } from "@/components/desktop/ComparisonTray";
import { OfflineIndicator } from "@/components/pwa/OfflineIndicator";
import { InstallPrompt } from "@/components/pwa/InstallPrompt";
import { GlobalKeyboardShortcuts } from "@/components/layout/GlobalKeyboardShortcuts";

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
        <AlertTriangle
          size={40}
          aria-hidden="true"
          className="mb-2 text-amber-500"
        />
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
    redirect("/onboarding");
  }

  return (
    <div className="flex min-h-screen flex-col overflow-x-hidden xl:flex-row">
      <SkipLink />
      <div className="no-print">
        <OfflineIndicator />
      </div>

      {/* Sidebar — xl+ only (hidden below xl via CSS) */}
      <DesktopSidebar />

      {/* Main column — offset by sidebar width on xl+ */}
      <div className="flex min-h-screen max-w-full flex-1 flex-col overflow-x-hidden pb-16 lg:pb-0 xl:pl-56">
        {/* Header — visible below xl. Hidden at xl+ where sidebar takes over. */}
        <header className="sticky top-0 z-40 border-b border-border bg-surface/80 pt-[env(safe-area-inset-top)] backdrop-blur xl:hidden">
          <div className="mx-auto flex h-12 md:h-14 max-w-5xl items-center justify-between px-4">
            <span className="text-lg font-bold text-brand-700 dark:text-brand-400">
              {translate("en", "layout.appNameWithEmoji")}
            </span>
            {/* Desktop header nav — lg to xl only */}
            <DesktopHeaderNav />
            <CountryChip country={prefs.country} />
          </div>
        </header>

        <main
          id="main-content"
          className="mx-auto w-full max-w-5xl flex-1 px-4 py-4 md:py-6 lg:py-8"
        >
          <ListsHydrator />
          <LanguageHydrator />
          {children}
        </main>

        {/* ⚠️  No <dialog> elements should be unconditionally rendered here.
            Android Chrome resolves their box dimensions even when closed,
            inflating the mobile viewport. See PR #92. */}
        <div className="no-print">
          <CompareFloatingButton />
          <ComparisonTray />
          <InstallPrompt />
          <GlobalKeyboardShortcuts />
        </div>
        <Navigation />
      </div>
    </div>
  );
}
