"use client";

// ─── Settings page — view/edit preferences, logout ──────────────────────────

import { useState, useEffect } from "react";
import { useRouter } from "next/navigation";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { toast } from "sonner";
import { createClient } from "@/lib/supabase/client";
import { getUserPreferences, setUserPreferences } from "@/lib/api";
import { queryKeys, staleTimes } from "@/lib/query-keys";
import { COUNTRIES, DIET_OPTIONS, ALLERGEN_TAGS } from "@/lib/constants";
import { LoadingSpinner } from "@/components/common/LoadingSpinner";

export default function SettingsPage() {
  const router = useRouter();
  const supabase = createClient();
  const queryClient = useQueryClient();

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
      setCountry(prefs.country ?? "");
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

  async function handleSave() {
    setSaving(true);
    const result = await setUserPreferences(supabase, {
      p_country: country,
      p_diet_preference: diet,
      p_avoid_allergens: allergens.length > 0 ? allergens : undefined,
      p_strict_diet: strictDiet,
      p_strict_allergen: strictAllergen,
      p_treat_may_contain_as_unsafe: treatMayContain,
    });
    setSaving(false);

    if (!result.ok) {
      toast.error(result.error.message);
      return;
    }

    // Invalidate all product-related caches since country/diet may have changed
    await queryClient.invalidateQueries({ queryKey: queryKeys.preferences });
    await queryClient.invalidateQueries({ queryKey: ["search"] });
    await queryClient.invalidateQueries({ queryKey: ["category-listing"] });
    await queryClient.invalidateQueries({
      queryKey: queryKeys.categoryOverview,
    });

    setDirty(false);
    toast.success("Preferences saved!");
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
    <div className="space-y-6">
      <h1 className="text-xl font-bold text-gray-900">Settings</h1>

      {/* Country */}
      <section className="card">
        <h2 className="mb-3 text-sm font-semibold text-gray-700">Country</h2>
        <div className="grid grid-cols-2 gap-2">
          {COUNTRIES.map((c) => (
            <button
              key={c.code}
              onClick={() => {
                setCountry(c.code);
                markDirty();
              }}
              className={`rounded-lg border-2 px-3 py-3 text-center transition-colors ${
                country === c.code
                  ? "border-brand-500 bg-brand-50"
                  : "border-gray-200 hover:border-gray-300"
              }`}
            >
              <span className="text-2xl">{c.flag}</span>
              <p className="mt-1 text-sm font-medium text-gray-900">
                {c.native}
              </p>
            </button>
          ))}
        </div>
      </section>

      {/* Diet */}
      <section className="card">
        <h2 className="mb-3 text-sm font-semibold text-gray-700">
          Diet preference
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
                  ? "border-brand-500 bg-brand-50 font-medium text-brand-700"
                  : "border-gray-200 text-gray-700 hover:border-gray-300"
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
              className="h-4 w-4 rounded border-gray-300 text-brand-600 focus:ring-brand-500"
            />
            <span className="text-sm text-gray-700">
              Strict — exclude &quot;maybe&quot; products
            </span>
          </label>
        )}
      </section>

      {/* Allergens */}
      <section className="card">
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
                onChange={(e) => {
                  setTreatMayContain(e.target.checked);
                  markDirty();
                }}
                className="h-4 w-4 rounded border-gray-300 text-brand-600 focus:ring-brand-500"
              />
              <span className="text-sm text-gray-700">
                Treat &quot;may contain&quot; as unsafe
              </span>
            </label>
          </div>
        )}
      </section>

      {/* Save button */}
      {dirty && (
        <button
          onClick={handleSave}
          disabled={saving}
          className="btn-primary w-full"
        >
          {saving ? "Saving…" : "Save changes"}
        </button>
      )}

      {/* Account section */}
      <section className="card border-red-100">
        <h2 className="mb-3 text-sm font-semibold text-gray-700">Account</h2>
        <p className="mb-3 text-xs text-gray-500">
          {prefs?.user_id && `User ID: ${prefs.user_id.slice(0, 8)}…`}
        </p>
        <button
          onClick={handleLogout}
          className="w-full rounded-lg border border-red-200 px-4 py-2 text-sm font-medium text-red-600 transition-colors hover:bg-red-50"
        >
          Sign out
        </button>
      </section>
    </div>
  );
}
