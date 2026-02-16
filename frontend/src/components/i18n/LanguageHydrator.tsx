"use client";

// ─── LanguageHydrator ───────────────────────────────────────────────────────
// Invisible component that runs in the app layout to hydrate the Zustand
// language store from user preferences. On first load (or when preferences
// change), syncs preferred_language into the store so all i18n hooks
// re-render in the correct language.

import { useEffect } from "react";
import { useQuery } from "@tanstack/react-query";
import { createClient } from "@/lib/supabase/client";
import { getUserPreferences } from "@/lib/api";
import { queryKeys, staleTimes } from "@/lib/query-keys";
import { useLanguageStore, type SupportedLanguage } from "@/stores/language-store";

const SUPPORTED = new Set<SupportedLanguage>(["en", "pl", "de"]);

export function LanguageHydrator() {
  const setLanguage = useLanguageStore((s) => s.setLanguage);
  const loaded = useLanguageStore((s) => s.loaded);
  const supabase = createClient();

  const { data: prefs } = useQuery({
    queryKey: queryKeys.preferences,
    queryFn: async () => {
      const result = await getUserPreferences(supabase);
      if (!result.ok) throw new Error(result.error.message);
      return result.data;
    },
    staleTime: staleTimes.preferences,
  });

  useEffect(() => {
    if (prefs?.preferred_language) {
      const lang = prefs.preferred_language as SupportedLanguage;
      if (SUPPORTED.has(lang)) {
        setLanguage(lang);
      } else if (!loaded) {
        setLanguage("en");
      }
    } else if (prefs && !loaded) {
      setLanguage("en");
    }
  }, [prefs, setLanguage, loaded]);

  return null; // Render-invisible
}
