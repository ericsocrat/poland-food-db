"use client";

// ─── Settings — Profile & Preferences (Country, Language, Theme) ────────────

import { LoadingSpinner } from "@/components/common/LoadingSpinner";
import { ConfirmDialog } from "@/components/common/ConfirmDialog";
import { Breadcrumbs } from "@/components/layout/Breadcrumbs";
import { ThemeToggle } from "@/components/settings/ThemeToggle";
import { useAnalytics } from "@/hooks/use-analytics";
import { useUnsavedChanges } from "@/hooks/use-unsaved-changes";
import { getUserPreferences, setUserPreferences } from "@/lib/api";
import {
    COUNTRIES,
    COUNTRY_DEFAULT_LANGUAGES,
    getLanguagesForCountry,
} from "@/lib/constants";
import { useTranslation } from "@/lib/i18n";
import { queryKeys, staleTimes } from "@/lib/query-keys";
import { createClient } from "@/lib/supabase/client";
import { showToast } from "@/lib/toast";
import {
    useLanguageStore,
    type SupportedLanguage,
} from "@/stores/language-store";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { useCallback, useEffect, useState } from "react";

export default function ProfileSettingsPage() {
  const supabase = createClient();
  const queryClient = useQueryClient();
  const { track } = useAnalytics();
  const { t } = useTranslation();
  const setStoreLanguage = useLanguageStore((s) => s.setLanguage);

  const { data: prefs, isLoading } = useQuery({
    queryKey: queryKeys.preferences,
    queryFn: async () => {
      const result = await getUserPreferences(supabase);
      if (!result.ok) throw new Error(result.error.message);
      return result.data;
    },
    staleTime: staleTimes.preferences,
  });

  const [country, setCountry] = useState("");
  const [language, setLanguage] = useState<SupportedLanguage>("en");
  const [saving, setSaving] = useState(false);
  const [dirty, setDirty] = useState(false);

  const { showConfirmDialog, confirmNavigation, cancelNavigation } =
    useUnsavedChanges(dirty);

  // Populate from fetched prefs
  useEffect(() => {
    if (prefs) {
      setCountry(prefs.country ?? "");
      setLanguage((prefs.preferred_language ?? "en") as SupportedLanguage);
    }
  }, [prefs]);

  function markDirty() {
    setDirty(true);
  }

  // Warn on tab close / reload when form has unsaved changes
  const handleBeforeUnload = useCallback(
    (e: BeforeUnloadEvent) => {
      if (dirty) {
        e.preventDefault();
      }
    },
    [dirty],
  );

  useEffect(() => {
    window.addEventListener("beforeunload", handleBeforeUnload);
    return () => window.removeEventListener("beforeunload", handleBeforeUnload);
  }, [handleBeforeUnload]);

  async function handleSave() {
    setSaving(true);
    const result = await setUserPreferences(supabase, {
      p_country: country,
      p_preferred_language: language,
      // Pass through existing diet/allergen values (managed on Nutrition page)
      p_diet_preference: prefs?.diet_preference ?? "none",
      p_avoid_allergens:
        prefs?.avoid_allergens && prefs.avoid_allergens.length > 0
          ? prefs.avoid_allergens
          : undefined,
      p_strict_diet: prefs?.strict_diet ?? false,
      p_strict_allergen: prefs?.strict_allergen ?? false,
      p_treat_may_contain_as_unsafe:
        prefs?.treat_may_contain_as_unsafe ?? false,
    });
    setSaving(false);

    if (!result.ok) {
      showToast({ type: "error", message: result.error.message });
      return;
    }

    // Sync the language store so the entire UI re-renders in the new language
    setStoreLanguage(language);

    // Invalidate caches since country/language may have changed
    await queryClient.invalidateQueries({ queryKey: queryKeys.preferences });
    await queryClient.invalidateQueries({ queryKey: ["search"] });
    await queryClient.invalidateQueries({ queryKey: ["category-listing"] });
    await queryClient.invalidateQueries({
      queryKey: queryKeys.categoryOverview,
    });

    setDirty(false);
    track("preferences_updated", { country, language });
    showToast({ type: "success", messageKey: "settings.preferencesSaved" });
  }

  if (isLoading) {
    return (
      <div className="flex justify-center py-12">
        <LoadingSpinner />
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <Breadcrumbs
        items={[
          { labelKey: "nav.home", href: "/app" },
          { labelKey: "nav.settings", href: "/app/settings" },
          { labelKey: "settings.tabProfile" },
        ]}
      />
      <h1 className="text-xl font-bold text-foreground lg:text-2xl">
        {t("settings.tabProfile")}
      </h1>

      {/* Country */}
      <section className="card">
        <h2 className="mb-3 text-sm font-semibold text-foreground-secondary lg:text-base">
          {t("settings.country")}
        </h2>
        <div className="grid grid-cols-2 gap-2">
          {COUNTRIES.map((c) => (
            <button
              key={c.code}
              onClick={() => {
                setCountry(c.code);
                // Auto-switch language to new country's default
                const newDefault = (COUNTRY_DEFAULT_LANGUAGES[c.code] ??
                  "en") as SupportedLanguage;
                setLanguage(newDefault);
                markDirty();
              }}
              className={`rounded-lg border-2 px-3 py-3 text-center transition-colors ${
                country === c.code
                  ? "border-brand bg-brand-subtle text-brand"
                  : "border text-foreground-secondary hover:border-strong"
              }`}
            >
              <span className="text-2xl">{c.flag}</span>
              <p className="mt-1 text-sm font-medium">{c.native}</p>
            </button>
          ))}
        </div>
      </section>

      {/* Language — filtered by selected country (native + English) */}
      <section className="card">
        <h2 className="mb-3 text-sm font-semibold text-foreground-secondary lg:text-base">
          {t("settings.language")}
        </h2>
        <div className="grid grid-cols-2 gap-2">
          {getLanguagesForCountry(country).map((lang) => (
            <button
              key={lang.code}
              onClick={() => {
                setLanguage(lang.code as SupportedLanguage);
                markDirty();
              }}
              className={`rounded-lg border-2 px-3 py-3 text-center transition-colors ${
                language === lang.code
                  ? "border-brand bg-brand-subtle text-brand"
                  : "border text-foreground-secondary hover:border-strong"
              }`}
            >
              <span className="text-2xl">{lang.flag}</span>
              <p className="mt-1 text-sm font-medium">{lang.native}</p>
            </button>
          ))}
        </div>
      </section>

      {/* Theme */}
      <section className="card">
        <h2 className="mb-3 text-sm font-semibold text-foreground-secondary lg:text-base">
          {t("settings.theme")}
        </h2>
        <ThemeToggle />
      </section>

      {/* Save button — sticky bar at bottom when dirty */}
      {dirty && (
        <div className="sticky bottom-0 z-30 -mx-4 animate-slide-in-up border-t border-border bg-surface/95 px-4 py-3 backdrop-blur sm:-mx-6 sm:px-6">
          <p className="mb-2 text-center text-xs font-medium text-warning">
            {t("settings.unsavedIndicator")}
          </p>
          <button
            onClick={handleSave}
            disabled={saving}
            className="btn-primary w-full"
          >
            {saving ? t("common.saving") : t("settings.saveChanges")}
          </button>
        </div>
      )}

      {/* Discard changes confirmation dialog */}
      <ConfirmDialog
        open={showConfirmDialog}
        title={t("settings.unsavedTitle")}
        description={t("settings.unsavedDescription")}
        confirmLabel={t("settings.unsavedDiscard")}
        variant="danger"
        onConfirm={confirmNavigation}
        onCancel={cancelNavigation}
      />
    </div>
  );
}
