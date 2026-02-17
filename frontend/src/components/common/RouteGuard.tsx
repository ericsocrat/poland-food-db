"use client";

// ─── RouteGuard: centralized redirect logic for /app/* pages ────────────────
// Wraps useQuery for preferences and handles session expiry.

import { useEffect } from "react";
import { useRouter } from "next/navigation";
import { useQuery } from "@tanstack/react-query";
import { showToast } from "@/lib/toast";
import { createClient } from "@/lib/supabase/client";
import { getUserPreferences } from "@/lib/api";
import { isAuthError } from "@/lib/rpc";
import { queryKeys, staleTimes } from "@/lib/query-keys";
import type { UserPreferences } from "@/lib/types";
import { LoadingSpinner } from "@/components/common/LoadingSpinner";

interface RouteGuardProps {
  children: React.ReactNode;
}

export function RouteGuard({ children }: Readonly<RouteGuardProps>) {
  const router = useRouter();
  const supabase = createClient();

  const { data, error, isLoading } = useQuery({
    queryKey: queryKeys.preferences,
    queryFn: async () => {
      const result = await getUserPreferences(supabase);
      if (!result.ok) {
        if (isAuthError(result.error)) {
          throw Object.assign(new Error(result.error.message), {
            code: result.error.code,
          });
        }
        throw new Error(result.error.message);
      }
      return result.data;
    },
    staleTime: staleTimes.preferences,
  });

  useEffect(() => {
    if (error) {
      const code =
        error instanceof Error && "code" in error ? String(error.code) : "";
      if (isAuthError({ code, message: error.message })) {
        showToast({ type: "error", messageKey: "auth.sessionExpired" });
        // Preserve current path + querystring so login can redirect back
        const redirectTo =
          globalThis.location.pathname + globalThis.location.search;
        router.push(
          `/auth/login?reason=expired&redirect=${encodeURIComponent(redirectTo)}`,
        );
        return;
      }
      showToast({ type: "error", messageKey: "auth.preferencesFailed" });
    }
  }, [error, router]);

  useEffect(() => {
    if (data && !data.onboarding_complete) {
      router.push("/onboarding/region");
    }
  }, [data, router]);

  if (isLoading) {
    return (
      <div className="flex min-h-[50vh] items-center justify-center">
        <LoadingSpinner />
      </div>
    );
  }

  if (!data?.onboarding_complete) return null;

  return <>{children}</>;
}

/**
 * Hook to get the current user preferences (already cached by RouteGuard).
 */
export function usePreferences(): UserPreferences | undefined {
  const supabase = createClient();

  const { data } = useQuery({
    queryKey: queryKeys.preferences,
    queryFn: async () => {
      const result = await getUserPreferences(supabase);
      if (!result.ok) throw new Error(result.error.message);
      return result.data;
    },
    staleTime: staleTimes.preferences,
  });

  return data;
}
