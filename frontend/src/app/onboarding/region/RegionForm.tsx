"use client";

// ─── Onboarding Step 1: Region selection (required) ─────────────────────────

import { useState } from "react";
import { useRouter } from "next/navigation";
import { toast } from "sonner";
import { createClient } from "@/lib/supabase/client";
import { setUserPreferences } from "@/lib/api";
import { COUNTRIES } from "@/lib/constants";
import { useTranslation } from "@/lib/i18n";

export function RegionForm() {
  const router = useRouter();
  const supabase = createClient();
  const [selected, setSelected] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);
  const { t } = useTranslation();

  async function handleContinue() {
    if (!selected) {
      toast.error(t("onboarding.pleaseSelectRegion"));
      return;
    }

    setLoading(true);
    const result = await setUserPreferences(supabase, { p_country: selected });
    setLoading(false);

    if (!result.ok) {
      toast.error(result.error.message);
      return;
    }

    router.push("/onboarding/preferences");
  }

  return (
    <div>
      {/* Progress indicator */}
      <div className="mb-8 flex items-center gap-2">
        <div className="h-2 flex-1 rounded-full bg-brand-500" />
        <div className="h-2 flex-1 rounded-full bg-gray-200" />
      </div>

      <h1 className="mb-2 text-2xl font-bold text-gray-900">
        {t("onboarding.selectRegion")}
      </h1>
      <p className="mb-8 text-sm text-gray-500">
        {t("onboarding.regionSubtitle")}
      </p>

      <div className="space-y-3">
        {COUNTRIES.map((country) => (
          <button
            key={country.code}
            onClick={() => setSelected(country.code)}
            className={`flex w-full items-center gap-4 rounded-xl border-2 p-4 text-left transition-colors ${
              selected === country.code
                ? "border-brand-500 bg-brand-50"
                : "border-gray-200 bg-white hover:border-gray-300"
            }`}
          >
            <span className="text-3xl">{country.flag}</span>
            <div>
              <p className="font-semibold text-gray-900">{country.name}</p>
              <p className="text-sm text-gray-500">{country.native}</p>
            </div>
            {selected === country.code && (
              <span className="ml-auto text-brand-600">✓</span>
            )}
          </button>
        ))}
      </div>

      <button
        onClick={handleContinue}
        disabled={!selected || loading}
        className="btn-primary mt-8 w-full"
      >
        {loading ? t("common.saving") : t("onboarding.continue")}
      </button>
    </div>
  );
}
