import { describe, it, expect, vi, beforeEach } from "vitest";
import { renderHook, waitFor } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import type { ReactNode } from "react";

// ─── Mocks ──────────────────────────────────────────────────────────────────

const mockSetLanguage = vi.fn();
let mockLoaded = false;

vi.mock("@/stores/language-store", () => ({
  useLanguageStore: (
    selector: (state: {
      setLanguage: typeof mockSetLanguage;
      loaded: boolean;
    }) => unknown,
  ) => selector({ setLanguage: mockSetLanguage, loaded: mockLoaded }),
}));

const mockGetUserPreferences = vi.fn();
vi.mock("@/lib/api", () => ({
  getUserPreferences: (...args: unknown[]) => mockGetUserPreferences(...args),
}));

vi.mock("@/lib/supabase/client", () => ({
  createClient: () => ({}),
}));

vi.mock("@/lib/query-keys", () => ({
  queryKeys: { preferences: ["preferences"] },
  staleTimes: { preferences: 60_000 },
}));

vi.mock("@/lib/constants", () => ({
  COUNTRY_DEFAULT_LANGUAGES: { PL: "pl", DE: "de" },
}));

import { LanguageHydrator } from "@/components/i18n/LanguageHydrator";

// ─── Helpers ────────────────────────────────────────────────────────────────

function createWrapper() {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false } },
  });
  return function Wrapper({ children }: { children: ReactNode }) {
    return (
      <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
    );
  };
}

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("LanguageHydrator", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mockLoaded = false;
  });

  it("sets language from user preferences", async () => {
    mockGetUserPreferences.mockResolvedValue({
      ok: true,
      data: { preferred_language: "pl", country: "PL" },
    });

    renderHook(() => LanguageHydrator(), { wrapper: createWrapper() });

    await waitFor(() => {
      expect(mockSetLanguage).toHaveBeenCalledWith("pl");
    });
  });

  it("falls back to country default when preferred_language is unsupported", async () => {
    mockGetUserPreferences.mockResolvedValue({
      ok: true,
      data: { preferred_language: "fr", country: "DE" },
    });

    renderHook(() => LanguageHydrator(), { wrapper: createWrapper() });

    await waitFor(() => {
      expect(mockSetLanguage).toHaveBeenCalledWith("de");
    });
  });

  it("falls back to English when no preferred_language and no country default", async () => {
    mockGetUserPreferences.mockResolvedValue({
      ok: true,
      data: { preferred_language: null, country: "US" },
    });

    renderHook(() => LanguageHydrator(), { wrapper: createWrapper() });

    await waitFor(() => {
      expect(mockSetLanguage).toHaveBeenCalledWith("en");
    });
  });

  it("uses country default when no preferred_language is set", async () => {
    mockGetUserPreferences.mockResolvedValue({
      ok: true,
      data: { preferred_language: null, country: "PL" },
    });

    renderHook(() => LanguageHydrator(), { wrapper: createWrapper() });

    await waitFor(() => {
      expect(mockSetLanguage).toHaveBeenCalledWith("pl");
    });
  });

  it("renders nothing (returns null)", () => {
    mockGetUserPreferences.mockResolvedValue({
      ok: true,
      data: { preferred_language: "en" },
    });

    const { result } = renderHook(() => LanguageHydrator(), {
      wrapper: createWrapper(),
    });

    expect(result.current).toBeNull();
  });

  it("does not re-set language when already loaded and preferred_language is unsupported", async () => {
    mockLoaded = true;
    mockGetUserPreferences.mockResolvedValue({
      ok: true,
      data: { preferred_language: "fr", country: "PL" },
    });

    renderHook(() => LanguageHydrator(), { wrapper: createWrapper() });

    // Wait for potential effects to run
    await waitFor(() => {
      expect(mockGetUserPreferences).toHaveBeenCalled();
    });

    // Should not call setLanguage because loaded=true and lang is unsupported
    expect(mockSetLanguage).not.toHaveBeenCalled();
  });
});
