"use client";

// ─── Settings page — view/edit preferences, logout ──────────────────────────

import { useState, useEffect, useCallback } from "react";
import { useRouter } from "next/navigation";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { showToast } from "@/lib/toast";
import { createClient } from "@/lib/supabase/client";
import { getUserPreferences, setUserPreferences } from "@/lib/api";
import { queryKeys, staleTimes } from "@/lib/query-keys";
import { ChevronDown, Copy, Check } from "lucide-react";
import {
  COUNTRIES,
  COUNTRY_DEFAULT_LANGUAGES,
  DIET_OPTIONS,
  ALLERGEN_TAGS,
  ALLERGEN_PRESETS,
  getLanguagesForCountry,
} from "@/lib/constants";
import { LoadingSpinner } from "@/components/common/LoadingSpinner";
import { HealthProfileSection } from "@/components/settings/HealthProfileSection";
import { ThemeToggle } from "@/components/settings/ThemeToggle";
import { useAnalytics } from "@/hooks/use-analytics";
import { Breadcrumbs } from "@/components/layout/Breadcrumbs";
import { useTranslation } from "@/lib/i18n";
import {
  useLanguageStore,
  type SupportedLanguage,
} from "@/stores/language-store";

export default function SettingsPage() {
  const router = useRouter();
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
  const [diet, setDiet] = useState("none");
  const [allergens, setAllergens] = useState<string[]>([]);
  const [strictDiet, setStrictDiet] = useState(false);
  const [strictAllergen, setStrictAllergen] = useState(false);
  const [treatMayContain, setTreatMayContain] = useState(false);
  const [saving, setSaving] = useState(false);
  const [dirty, setDirty] = useState(false);
  const [email, setEmail] = useState<string | null>(null);
  const [showDetails, setShowDetails] = useState(false);
  const [copied, setCopied] = useState(false);

  // Fetch user email from auth session
  useEffect(() => {
    supabase.auth.getUser().then(({ data }) => {
      setEmail(data.user?.email ?? null);
    });
  }, [supabase]);

  const handleCopyUserId = useCallback(async () => {
    if (!prefs?.user_id) return;
    await navigator.clipboard.writeText(prefs.user_id);
    setCopied(true);
    showToast({ type: "success", messageKey: "settings.copiedToClipboard" });
    setTimeout(() => setCopied(false), 2000);
  }, [prefs?.user_id]);

  // Populate from fetched prefs
  useEffect(() => {
    if (prefs) {
      setCountry(prefs.country ?? "");
      setLanguage((prefs.preferred_language ?? "en") as SupportedLanguage);
      setDiet(prefs.diet_preference ?? "none");
      setAllergens(prefs.avoid_allergens ?? []);
      setStrictDiet(prefs.strict_diet);
      setStrictAllergen(prefs.strict_allergen);
      setTreatMayContain(prefs.treat_may_contain_as_unsafe);
    }
  }, [prefs]);

  function markDirty() {
    setDirty(true);
  }

  function toggleAllergen(tag: string) {
    setAllergens((prev) =>
      prev.includes(tag) ? prev.filter((t) => t !== tag) : [...prev, tag],
    );
    markDirty();
  }

  function togglePreset(tags: readonly string[], allSelected: boolean) {
    setAllergens((prev) => {
      const newSet = new Set(prev);
      if (allSelected) {
        tags.forEach((tag) => newSet.delete(tag));
      } else {
        tags.forEach((tag) => newSet.add(tag));
      }
      return Array.from(newSet);
    });
    markDirty();
  }

  async function handleSave() {
    setSaving(true);
    const result = await setUserPreferences(supabase, {
      p_country: country,
      p_preferred_language: language,
      p_diet_preference: diet,
      p_avoid_allergens: allergens.length > 0 ? allergens : undefined,
      p_strict_diet: strictDiet,
      p_strict_allergen: strictAllergen,
      p_treat_may_contain_as_unsafe: treatMayContain,
    });
    setSaving(false);

    if (!result.ok) {
      showToast({ type: "error", message: result.error.message });
      return;
    }

    // Sync the language store so the entire UI re-renders in the new language
    setStoreLanguage(language);

    // Invalidate all product-related caches since country/diet/language may have changed
    await queryClient.invalidateQueries({ queryKey: queryKeys.preferences });
    await queryClient.invalidateQueries({ queryKey: ["search"] });
    await queryClient.invalidateQueries({ queryKey: ["category-listing"] });
    await queryClient.invalidateQueries({
      queryKey: queryKeys.categoryOverview,
    });

    setDirty(false);
    track("preferences_updated", {
      country,
      language,
      diet,
      allergen_count: allergens.length,
    });
    showToast({ type: "success", messageKey: "settings.preferencesSaved" });
  }

  async function handleLogout() {
    await supabase.auth.signOut();
    queryClient.clear();
    router.push("/auth/login");
    router.refresh();
  }

  if (isLoading) {
    return (
      <div className="flex justify-center py-12">
        <LoadingSpinner />
      </div>
    );
  }

  return (
    <div className="max-w-2xl space-y-6 lg:space-y-8">
      <Breadcrumbs
        items={[
          { labelKey: "nav.home", href: "/app" },
          { labelKey: "nav.settings" },
        ]}
      />
      <h1 className="text-xl font-bold text-foreground lg:text-2xl">
        {t("settings.title")}
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

      {/* Diet */}
      <section className="card">
        <h2 className="mb-3 text-sm font-semibold text-foreground-secondary lg:text-base">
          {t("settings.dietPreference")}
        </h2>
        <div className="grid grid-cols-3 gap-2">
          {DIET_OPTIONS.map((opt) => (
            <button
              key={opt.value}
              onClick={() => {
                setDiet(opt.value);
                markDirty();
              }}
              className={`rounded-lg border-2 px-3 py-2 text-sm transition-colors ${
                diet === opt.value
                  ? "border-brand bg-brand-subtle font-medium text-brand"
                  : "border text-foreground-secondary hover:border-strong"
              }`}
            >
              {opt.label}
            </button>
          ))}
        </div>
        {diet !== "none" && (
          <label className="mt-3 flex cursor-pointer items-center gap-3">
            <input
              type="checkbox"
              checked={strictDiet}
              onChange={(e) => {
                setStrictDiet(e.target.checked);
                markDirty();
              }}
              className="h-4 w-4 rounded border-strong text-brand focus:ring-brand"
            />
            <span className="text-sm text-foreground-secondary">
              {t("settings.strictDiet")}
            </span>
          </label>
        )}
      </section>

      {/* Allergens */}
      <section className="card">
        <h2 className="mb-3 text-sm font-semibold text-foreground-secondary lg:text-base">
          {t("settings.allergensToAvoid")}
        </h2>

        {/* Quick presets */}
        <div
          className="mb-3 flex flex-wrap gap-2"
          data-testid="allergen-presets"
        >
          {ALLERGEN_PRESETS.map((preset) => {
            const allSelected = preset.tags.every((tag) =>
              allergens.includes(tag),
            );
            return (
              <button
                key={preset.key}
                onClick={() => togglePreset(preset.tags, allSelected)}
                className={`rounded-full border px-3 py-1.5 text-xs font-medium transition-colors ${
                  allSelected
                    ? "border-brand bg-brand-subtle text-brand"
                    : "border-dashed border-foreground-muted text-foreground-secondary hover:border-strong"
                }`}
              >
                {t(preset.labelKey)}
              </button>
            );
          })}
        </div>

        <div className="flex flex-wrap gap-2">
          {ALLERGEN_TAGS.map((a) => (
            <button
              key={a.tag}
              onClick={() => toggleAllergen(a.tag)}
              className={`rounded-full border px-3 py-1.5 text-sm transition-colors ${
                allergens.includes(a.tag)
                  ? "border-red-300 bg-red-50 text-red-700"
                  : "border text-foreground-secondary hover:border-strong"
              }`}
            >
              {a.label}
            </button>
          ))}
        </div>
        {allergens.length > 0 && (
          <div className="mt-3 space-y-2">
            <label className="flex cursor-pointer items-center gap-3">
              <input
                type="checkbox"
                checked={strictAllergen}
                onChange={(e) => {
                  setStrictAllergen(e.target.checked);
                  markDirty();
                }}
                className="h-4 w-4 rounded border-strong text-brand focus:ring-brand"
              />
              <span className="text-sm text-foreground-secondary">
                {t("settings.strictAllergen")}
              </span>
            </label>
            <label className="flex cursor-pointer items-center gap-3">
              <input
                type="checkbox"
                checked={treatMayContain}
                onChange={(e) => {
                  setTreatMayContain(e.target.checked);
                  markDirty();
                }}
                className="h-4 w-4 rounded border-strong text-brand focus:ring-brand"
              />
              <span className="text-sm text-foreground-secondary">
                {t("settings.treatMayContain")}
              </span>
            </label>
          </div>
        )}
      </section>

      {/* Health Profiles */}
      <HealthProfileSection />

      {/* Save button */}
      {dirty && (
        <button
          onClick={handleSave}
          disabled={saving}
          className="btn-primary w-full"
        >
          {saving ? t("common.saving") : t("settings.saveChanges")}
        </button>
      )}

      {/* Account section */}
      <section className="card border-red-100">
        <h2 className="mb-3 text-sm font-semibold text-foreground-secondary lg:text-base">
          {t("settings.account")}
        </h2>

        {/* Primary identifier: email */}
        {email && (
          <p className="mb-3 text-sm text-foreground-secondary">{email}</p>
        )}

        {/* Expandable account details with masked UUID + copy */}
        {prefs?.user_id && (
          <div className="mb-3">
            <button
              type="button"
              onClick={() => setShowDetails((prev) => !prev)}
              className="flex items-center gap-1 text-xs text-foreground-secondary hover:text-foreground-primary transition-colors"
              aria-expanded={showDetails}
            >
              <ChevronDown
                size={14}
                aria-hidden="true"
                className={`transition-transform ${showDetails ? "rotate-180" : ""}`}
              />
              {t("settings.accountDetails")}
            </button>

            {showDetails && (
              <div
                className="mt-2 flex items-center gap-2"
                data-testid="account-details"
              >
                <code className="text-xs text-foreground-secondary">
                  {prefs.user_id.slice(0, 4)}…{prefs.user_id.slice(-4)}
                </code>
                <button
                  type="button"
                  onClick={handleCopyUserId}
                  className="flex items-center gap-1 rounded border border-gray-200 px-2 py-0.5 text-xs text-foreground-secondary hover:bg-gray-50 transition-colors"
                  aria-label={t("settings.copyUserId")}
                >
                  {copied ? (
                    <Check size={12} aria-hidden="true" />
                  ) : (
                    <Copy size={12} aria-hidden="true" />
                  )}
                  {t("settings.copyUserId")}
                </button>
              </div>
            )}
          </div>
        )}

        <button
          onClick={handleLogout}
          className="w-full rounded-lg border border-red-200 px-4 py-2 text-sm font-medium text-red-600 transition-colors hover:bg-red-50"
        >
          {t("settings.signOut")}
        </button>
      </section>
    </div>
  );
}
