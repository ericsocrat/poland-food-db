"use client";

// ─── Step 2: Region + Language ──────────────────────────────────────────────

import { COUNTRIES, getLanguagesForCountry } from "@/lib/constants";
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
      <h1 className="mb-2 text-2xl font-bold text-gray-900">
        {t("onboarding.regionTitle")}
      </h1>
      <p className="mb-8 text-sm text-gray-500">
        {t("onboarding.regionSubtitle")}
      </p>

      <div className="space-y-3">
        {COUNTRIES.map((country) => (
          <button
            key={country.code}
            onClick={() => handleCountrySelect(country.code)}
            className={`flex w-full items-center gap-4 rounded-xl border-2 p-4 text-left transition-colors ${
              data.country === country.code
                ? "border-brand-500 bg-brand-50"
                : "border-gray-200 bg-white hover:border-gray-300"
            }`}
            data-testid={`country-${country.code}`}
          >
            <span className="text-3xl">{country.flag}</span>
            <div>
              <p className="font-semibold text-gray-900">{country.name}</p>
              <p className="text-sm text-gray-500">{country.native}</p>
            </div>
            {data.country === country.code && (
              <span className="ml-auto text-brand-600">✓</span>
            )}
          </button>
        ))}
      </div>

      {/* Language selector (appears after country selection) */}
      {data.country && availableLanguages.length > 0 && (
        <section className="mt-6">
          <h2 className="mb-3 text-sm font-semibold text-gray-700">
            {t("onboarding.languageLabel")}
          </h2>
          <div className="flex gap-2">
            {availableLanguages.map((lang) => (
              <button
                key={lang.code}
                onClick={() => onChange({ language: lang.code })}
                className={`flex items-center gap-2 rounded-lg border-2 px-4 py-2 text-sm transition-colors ${
                  data.language === lang.code
                    ? "border-brand-500 bg-brand-50 font-medium text-brand-700"
                    : "border-gray-200 text-gray-700 hover:border-gray-300"
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
