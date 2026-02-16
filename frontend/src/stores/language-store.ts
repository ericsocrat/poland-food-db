// ─── Zustand store for user language preference ─────────────────────────────
// Hydrated from UserPreferences.preferred_language on auth.
// Components read `language` for rendering; the i18n hook uses it to pick
// the correct message dictionary.

import { create } from "zustand";

export type SupportedLanguage = "en" | "pl" | "de";

interface LanguageState {
  /** Current UI language code. */
  language: SupportedLanguage;
  /** Whether the store has been hydrated from user preferences. */
  loaded: boolean;
  /** Set the language (called when prefs load or user changes language). */
  setLanguage: (lang: SupportedLanguage) => void;
  /** Reset to default (logout). */
  reset: () => void;
}

export const useLanguageStore = create<LanguageState>((set) => ({
  language: "en",
  loaded: false,

  setLanguage: (lang) => set({ language: lang, loaded: true }),

  reset: () => set({ language: "en", loaded: false }),
}));
