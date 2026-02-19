"use client";

// ─── Onboarding Step 1: Region selection (required) ─────────────────────────

import { useState } from "react";
import { useRouter } from "next/navigation";
import { showToast } from "@/lib/toast";
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
      showToast({ type: "error", messageKey: "onboarding.pleaseSelectRegion" });
      return;
    }

    setLoading(true);
    const result = await setUserPreferences(supabase, { p_country: selected });
    setLoading(false);

    if (!result.ok) {
      showToast({ type: "error", message: result.error.message });
      return;
    }

    router.push("/onboarding/preferences");
  }

  return (
    <div>
      {/* Progress indicator */}
      <div className="mb-8 flex items-center gap-2">
        <div className="h-2 flex-1 rounded-full bg-brand-subtle0" />
        <div className="h-2 flex-1 rounded-full bg-surface-muted" />
      </div>

      <h1 className="mb-2 text-2xl font-bold text-foreground">
        {t("onboarding.selectRegion")}
      </h1>
      <p className="mb-8 text-sm text-foreground-secondary">
        {t("onboarding.regionSubtitle")}
      </p>

      <div className="space-y-3">
        {COUNTRIES.map((country) => (
          <button
            key={country.code}
            onClick={() => setSelected(country.code)}
            className={`flex w-full items-center gap-4 rounded-xl border-2 p-4 text-left transition-colors ${
              selected === country.code
                ? "border-brand bg-brand-subtle"
                : "border bg-surface hover:border-strong"
            }`}
          >
            <span className="text-3xl">{country.flag}</span>
            <div>
              <p className="font-semibold text-foreground">{country.name}</p>
              <p className="text-sm text-foreground-secondary">{country.native}</p>
            </div>
            {selected === country.code && (
              <span className="ml-auto text-brand">✓</span>
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
