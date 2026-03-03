"use client";

// ─── Settings — Nutrition & Diet (Diet, Allergens, Health Profiles) ─────────

import { LoadingSpinner } from "@/components/common/LoadingSpinner";
import { Breadcrumbs } from "@/components/layout/Breadcrumbs";
import { HealthProfileSection } from "@/components/settings/HealthProfileSection";
import { useAnalytics } from "@/hooks/use-analytics";
import { getUserPreferences, setUserPreferences } from "@/lib/api";
import { ALLERGEN_PRESETS, ALLERGEN_TAGS, DIET_OPTIONS } from "@/lib/constants";
import { useTranslation } from "@/lib/i18n";
import { queryKeys, staleTimes } from "@/lib/query-keys";
import { createClient } from "@/lib/supabase/client";
import { showToast } from "@/lib/toast";
import { useLanguageStore } from "@/stores/language-store";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { useEffect, useState } from "react";

export default function NutritionSettingsPage() {
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

  const [diet, setDiet] = useState("none");
  const [allergens, setAllergens] = useState<string[]>([]);
  const [strictDiet, setStrictDiet] = useState(false);
  const [strictAllergen, setStrictAllergen] = useState(false);
  const [treatMayContain, setTreatMayContain] = useState(false);
  const [saving, setSaving] = useState(false);
  const [dirty, setDirty] = useState(false);

  // Populate from fetched prefs
  useEffect(() => {
    if (prefs) {
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
      // Pass through existing country/language (managed on Profile page)
      p_country: prefs?.country ?? "PL",
      p_preferred_language: prefs?.preferred_language ?? "en",
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

    // Sync the language store (in case prefs changed upstream)
    setStoreLanguage(
      (prefs?.preferred_language ?? "en") as Parameters<
        typeof setStoreLanguage
      >[0],
    );

    // Invalidate caches since diet/allergens may have changed
    await queryClient.invalidateQueries({ queryKey: queryKeys.preferences });
    await queryClient.invalidateQueries({ queryKey: ["search"] });
    await queryClient.invalidateQueries({ queryKey: ["category-listing"] });
    await queryClient.invalidateQueries({
      queryKey: queryKeys.categoryOverview,
    });

    setDirty(false);
    track("preferences_updated", {
      diet,
      allergen_count: allergens.length,
    });
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
          { labelKey: "settings.tabNutrition" },
        ]}
      />
      <h1 className="text-xl font-bold text-foreground lg:text-2xl">
        {t("settings.tabNutrition")}
      </h1>

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
    </div>
  );
}
