"use client";

// ─── Onboarding Step 2: Dietary preferences (optional, skippable) ───────────

import { useState } from "react";
import { useRouter } from "next/navigation";
import { toast } from "sonner";
import { createClient } from "@/lib/supabase/client";
import { setUserPreferences } from "@/lib/api";
import { DIET_OPTIONS, ALLERGEN_TAGS } from "@/lib/constants";

export function PreferencesForm() {
  const router = useRouter();
  const supabase = createClient();
  const [diet, setDiet] = useState("none");
  const [allergens, setAllergens] = useState<string[]>([]);
  const [strictDiet, setStrictDiet] = useState(false);
  const [strictAllergen, setStrictAllergen] = useState(false);
  const [treatMayContain, setTreatMayContain] = useState(false);
  const [loading, setLoading] = useState(false);

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
      toast.error(result.error.message);
      return;
    }

    toast.success("Preferences saved!");
    router.push("/app/search");
    router.refresh();
  }

  function handleSkip() {
    router.push("/app/search");
    router.refresh();
  }

  return (
    <div>
      {/* Progress indicator */}
      <div className="mb-8 flex items-center gap-2">
        <div className="h-2 flex-1 rounded-full bg-brand-500" />
        <div className="h-2 flex-1 rounded-full bg-brand-500" />
      </div>

      <h1 className="mb-2 text-2xl font-bold text-gray-900">
        Dietary preferences
      </h1>
      <p className="mb-8 text-sm text-gray-500">
        Optional — helps filter products to match your diet. You can change
        these later in Settings.
      </p>

      {/* Diet type */}
      <section className="mb-6">
        <h2 className="mb-3 text-sm font-semibold text-gray-700">Diet type</h2>
        <div className="grid grid-cols-3 gap-2">
          {DIET_OPTIONS.map((opt) => (
            <button
              key={opt.value}
              onClick={() => setDiet(opt.value)}
              className={`rounded-lg border-2 px-3 py-2 text-sm transition-colors ${
                diet === opt.value
                  ? "border-brand-500 bg-brand-50 font-medium text-brand-700"
                  : "border-gray-200 text-gray-700 hover:border-gray-300"
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
            className="h-4 w-4 rounded border-gray-300 text-brand-600 focus:ring-brand-500"
          />
          <span className="text-sm text-gray-700">
            Strict mode — exclude &quot;maybe&quot; products too
          </span>
        </label>
      )}

      {/* Allergens */}
      <section className="mb-6">
        <h2 className="mb-3 text-sm font-semibold text-gray-700">
          Allergens to avoid
        </h2>
        <div className="flex flex-wrap gap-2">
          {ALLERGEN_TAGS.map((a) => (
            <button
              key={a.tag}
              onClick={() => toggleAllergen(a.tag)}
              className={`rounded-full border px-3 py-1.5 text-sm transition-colors ${
                allergens.includes(a.tag)
                  ? "border-red-300 bg-red-50 text-red-700"
                  : "border-gray-200 text-gray-600 hover:border-gray-300"
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
              className="h-4 w-4 rounded border-gray-300 text-brand-600 focus:ring-brand-500"
            />
            <span className="text-sm text-gray-700">
              Strict allergen matching
            </span>
          </label>
          <label className="flex cursor-pointer items-center gap-3">
            <input
              type="checkbox"
              checked={treatMayContain}
              onChange={(e) => setTreatMayContain(e.target.checked)}
              className="h-4 w-4 rounded border-gray-300 text-brand-600 focus:ring-brand-500"
            />
            <span className="text-sm text-gray-700">
              Treat &quot;may contain&quot; as unsafe
            </span>
          </label>
        </div>
      )}

      <div className="flex gap-3">
        <button onClick={handleSkip} className="btn-secondary flex-1">
          Skip for now
        </button>
        <button
          onClick={handleSave}
          disabled={loading}
          className="btn-primary flex-1"
        >
          {loading ? "Saving…" : "Save & Continue"}
        </button>
      </div>
    </div>
  );
}
