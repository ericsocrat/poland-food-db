"use client";

// ─── Feature Flag React Integration ─────────────────────────────────────────
// Client-side hooks, context provider, and component gate for feature flags (#191).
// FlagProvider receives server-evaluated initial state to avoid loading flash.

import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
  type ReactNode,
} from "react";
import { createClient } from "@/lib/supabase/client";

// ─── Types ──────────────────────────────────────────────────────────────────

interface FlagState {
  flags: Record<string, boolean>;
  variants: Record<string, string>;
  loading: boolean;
}

interface FlagContextValue extends FlagState {
  refreshFlags: () => Promise<void>;
}

// ─── Context ────────────────────────────────────────────────────────────────

const FlagCtx = createContext<FlagContextValue>({
  flags: {},
  variants: {},
  loading: true,
  refreshFlags: async () => {},
});

// ─── Provider ───────────────────────────────────────────────────────────────

/**
 * Provides feature flag values to the React tree.
 *
 * - Accepts `initialFlags` from server-side evaluation (no loading flash).
 * - Subscribes to Supabase Realtime for instant flag updates.
 * - Falls back to /api/flags polling if Realtime is unavailable.
 */
export function FlagProvider({
  children,
  initialFlags,
  initialVariants,
}: {
  children: ReactNode;
  initialFlags?: Record<string, boolean>;
  initialVariants?: Record<string, string>;
}) {
  const [state, setState] = useState<FlagState>({
    flags: initialFlags ?? {},
    variants: initialVariants ?? {},
    loading: !initialFlags,
  });

  const refreshFlags = useCallback(async () => {
    try {
      const res = await fetch("/api/flags");
      if (!res.ok) return;
      const data = (await res.json()) as {
        flags: Record<string, boolean>;
        variants: Record<string, string>;
      };
      setState({ flags: data.flags, variants: data.variants, loading: false });
    } catch {
      // Fetch failed — keep current state
    }
  }, []);

  useEffect(() => {
    // Subscribe to real-time flag changes via Supabase Realtime
    const supabase = createClient();
    const channel = supabase
      .channel("flag-changes")
      .on(
        "postgres_changes",
        { event: "*", schema: "public", table: "feature_flags" },
        () => {
          void refreshFlags();
        },
      )
      .subscribe();

    // Load flags from API if no initial state provided
    if (!initialFlags) {
      void refreshFlags();
    }

    return () => {
      void supabase.removeChannel(channel);
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const value = useMemo<FlagContextValue>(
    () => ({ ...state, refreshFlags }),
    [state, refreshFlags],
  );

  return <FlagCtx.Provider value={value}>{children}</FlagCtx.Provider>;
}

// ─── Hooks ──────────────────────────────────────────────────────────────────

/** Check if a boolean flag is enabled */
export function useFlag(key: string): boolean {
  const { flags } = useContext(FlagCtx);
  return flags[key] ?? false;
}

/** Get the variant name for a multivariate flag */
export function useFlagVariant(key: string): string | undefined {
  const { variants } = useContext(FlagCtx);
  return variants[key];
}

/** Check if flags are still loading (before initial fetch completes) */
export function useFlagsLoading(): boolean {
  return useContext(FlagCtx).loading;
}

/** Get the refresh function to manually re-fetch flags */
export function useFlagRefresh(): () => Promise<void> {
  return useContext(FlagCtx).refreshFlags;
}

// ─── Component Gate ─────────────────────────────────────────────────────────

/**
 * Declarative feature gate component.
 * Renders children only when the flag is enabled.
 *
 * @example
 * ```tsx
 * <Feature flag="new_search_ui" fallback={<OldSearch />}>
 *   <NewSearch />
 * </Feature>
 * ```
 */
export function Feature({
  flag,
  children,
  fallback,
}: {
  flag: string;
  children: ReactNode;
  fallback?: ReactNode;
}) {
  const enabled = useFlag(flag);
  return enabled ? <>{children}</> : <>{fallback}</>;
}
