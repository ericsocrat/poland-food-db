"use client";

// ─── Step 2: Region + Language ──────────────────────────────────────────────

import { COUNTRIES, getLanguagesForCountry } from "@/lib/constants";
import { Check } from "lucide-react";
import { useTranslation } from "@/lib/i18n";
import type { StepProps } from "../types";

export function RegionStep({ data, onChange, onNext, onBack }: StepProps) {
  const { t } = useTranslation();
  const availableLanguages = data.country
    ? getLanguagesForCountry(data.country)
    : [];

  function handleCountrySelect(code: string) {
    // Auto-pick the first language for the new country
    const langs = getLanguagesForCountry(code);
    const defaultLang = langs[0]?.code ?? "en";
    onChange({ country: code, language: defaultLang });
  }

  return (
    <div>
      <h1 className="mb-2 text-2xl font-bold text-foreground">
        {t("onboarding.regionTitle")}
      </h1>
      <p className="mb-8 text-sm text-foreground-secondary">
        {t("onboarding.regionSubtitle")}
      </p>

      <div className="space-y-3">
        {COUNTRIES.map((country) => (
          <button
            key={country.code}
            onClick={() => handleCountrySelect(country.code)}
            className={`flex w-full items-center gap-4 rounded-xl border-2 p-4 text-left transition-colors ${
              data.country === country.code
                ? "border-brand bg-brand-subtle"
                : "border bg-surface hover:border-strong"
            }`}
            data-testid={`country-${country.code}`}
          >
            <span className="text-3xl">{country.flag}</span>
            <div>
              <p className="font-semibold text-foreground">{country.name}</p>
              <p className="text-sm text-foreground-secondary">{country.native}</p>
            </div>
            {data.country === country.code && (
              <span className="ml-auto text-brand"><Check size={20} /></span>
            )}
          </button>
        ))}
      </div>

      {/* Language selector (appears after country selection) */}
      {data.country && availableLanguages.length > 0 && (
        <section className="mt-6">
          <h2 className="mb-3 text-sm font-semibold text-foreground-secondary">
            {t("onboarding.languageLabel")}
          </h2>
          <div className="flex gap-2">
            {availableLanguages.map((lang) => (
              <button
                key={lang.code}
                onClick={() => onChange({ language: lang.code })}
                className={`flex items-center gap-2 rounded-lg border-2 px-4 py-2 text-sm transition-colors ${
                  data.language === lang.code
                    ? "border-brand bg-brand-subtle font-medium text-brand"
                    : "border text-foreground-secondary hover:border-strong"
                }`}
              >
                <span>{lang.flag}</span>
                <span>{lang.native}</span>
              </button>
            ))}
          </div>
        </section>
      )}

      <div className="mt-8 flex gap-3">
        <button onClick={onBack} className="btn-secondary flex-1">
          {t("onboarding.back")}
        </button>
        <button
          onClick={onNext}
          disabled={!data.country}
          className="btn-primary flex-1"
        >
          {t("onboarding.next")}
        </button>
      </div>
    </div>
  );
}
