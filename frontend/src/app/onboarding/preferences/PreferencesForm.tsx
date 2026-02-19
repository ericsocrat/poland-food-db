"use client";

// ─── Onboarding Step 2: Dietary preferences (optional, skippable) ───────────

import { useState } from "react";
import { useRouter } from "next/navigation";
import { showToast } from "@/lib/toast";
import { createClient } from "@/lib/supabase/client";
import { setUserPreferences } from "@/lib/api";
import { DIET_OPTIONS, ALLERGEN_TAGS } from "@/lib/constants";
import { useAnalytics } from "@/hooks/use-analytics";
import { useTranslation } from "@/lib/i18n";

export function PreferencesForm() {
  const router = useRouter();
  const supabase = createClient();
  const [diet, setDiet] = useState("none");
  const [allergens, setAllergens] = useState<string[]>([]);
  const [strictDiet, setStrictDiet] = useState(false);
  const [strictAllergen, setStrictAllergen] = useState(false);
  const [treatMayContain, setTreatMayContain] = useState(false);
  const [loading, setLoading] = useState(false);
  const { track } = useAnalytics();
  const { t } = useTranslation();

  function toggleAllergen(tag: string) {
    setAllergens((prev) =>
      prev.includes(tag) ? prev.filter((t) => t !== tag) : [...prev, tag],
    );
  }

  async function handleSave() {
    setLoading(true);
    const result = await setUserPreferences(supabase, {
      p_diet_preference: diet,
      p_avoid_allergens: allergens.length > 0 ? allergens : undefined,
      p_strict_diet: strictDiet,
      p_strict_allergen: strictAllergen,
      p_treat_may_contain_as_unsafe: treatMayContain,
    });
    setLoading(false);

    if (!result.ok) {
      showToast({ type: "error", message: result.error.message });
      return;
    }

    showToast({ type: "success", messageKey: "onboarding.preferencesSaved" });
    track("onboarding_completed", {
      diet,
      allergen_count: allergens.length,
      skipped: false,
    });
    router.push("/app/search");
    router.refresh();
  }

  function handleSkip() {
    track("onboarding_completed", { skipped: true });
    router.push("/app/search");
    router.refresh();
  }

  return (
    <div>
      {/* Progress indicator */}
      <div className="mb-8 flex items-center gap-2">
        <div className="h-2 flex-1 rounded-full bg-brand" />
        <div className="h-2 flex-1 rounded-full bg-brand" />
      </div>

      <h1 className="mb-2 text-2xl font-bold text-foreground">
        {t("onboarding.dietaryPreferences")}
      </h1>
      <p className="mb-8 text-sm text-foreground-secondary">
        {t("onboarding.dietarySubtitle")}
      </p>

      {/* Diet type */}
      <section className="mb-6">
        <h2 className="mb-3 text-sm font-semibold text-foreground-secondary">
          {t("onboarding.dietType")}
        </h2>
        <div className="grid grid-cols-3 gap-2">
          {DIET_OPTIONS.map((opt) => (
            <button
              key={opt.value}
              onClick={() => setDiet(opt.value)}
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
      </section>

      {/* Strict diet toggle */}
      {diet !== "none" && (
        <label className="mb-6 flex cursor-pointer items-center gap-3">
          <input
            type="checkbox"
            checked={strictDiet}
            onChange={(e) => setStrictDiet(e.target.checked)}
            className="h-4 w-4 rounded border-strong text-brand focus:ring-brand"
          />
          <span className="text-sm text-foreground-secondary">
            {t("onboarding.strictDiet")}
          </span>
        </label>
      )}

      {/* Allergens */}
      <section className="mb-6">
        <h2 className="mb-3 text-sm font-semibold text-foreground-secondary">
          {t("onboarding.allergensToAvoid")}
        </h2>
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
      </section>

      {/* Allergen strictness toggles */}
      {allergens.length > 0 && (
        <div className="mb-8 space-y-3">
          <label className="flex cursor-pointer items-center gap-3">
            <input
              type="checkbox"
              checked={strictAllergen}
              onChange={(e) => setStrictAllergen(e.target.checked)}
              className="h-4 w-4 rounded border-strong text-brand focus:ring-brand"
            />
            <span className="text-sm text-foreground-secondary">
              {t("onboarding.strictAllergen")}
            </span>
          </label>
          <label className="flex cursor-pointer items-center gap-3">
            <input
              type="checkbox"
              checked={treatMayContain}
              onChange={(e) => setTreatMayContain(e.target.checked)}
              className="h-4 w-4 rounded border-strong text-brand focus:ring-brand"
            />
            <span className="text-sm text-foreground-secondary">
              {t("onboarding.treatMayContain")}
            </span>
          </label>
        </div>
      )}

      <div className="flex gap-3">
        <button onClick={handleSkip} className="btn-secondary flex-1">
          {t("onboarding.skipForNow")}
        </button>
        <button
          onClick={handleSave}
          disabled={loading}
          className="btn-primary flex-1"
        >
          {loading ? t("common.saving") : t("onboarding.saveAndContinue")}
        </button>
      </div>
    </div>
  );
}
