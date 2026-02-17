"use client";

// ─── TanStack Query + Supabase providers ────────────────────────────────────

import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { useState, type ReactNode } from "react";
import { Toaster } from "sonner";

/** Don't retry on 4xx auth or PostgREST JWT errors; retry up to 2× otherwise */
export function shouldRetry(failureCount: number, error: Error): boolean {
  if (error && typeof error === "object" && "code" in error) {
    const code = String((error as { code: unknown }).code);
    if (["401", "403", "PGRST301"].includes(code)) return false;
  }
  return failureCount < 2;
}

export function Providers({ children }: Readonly<{ children: ReactNode }>) {
  const [queryClient] = useState(
    () =>
      new QueryClient({
        defaultOptions: {
          queries: {
            // Don't retry on 4xx (auth errors, validation errors)
            retry: shouldRetry,
            refetchOnWindowFocus: false,
          },
        },
      }),
  );

  return (
    <QueryClientProvider client={queryClient}>
      {children}
      <Toaster
        position="top-right"
        richColors
        closeButton
        visibleToasts={3}
        toastOptions={{
          duration: 5000,
        }}
      />
    </QueryClientProvider>
  );
}
