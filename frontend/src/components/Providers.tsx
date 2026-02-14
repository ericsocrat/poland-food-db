"use client";

// ─── TanStack Query + Supabase providers ────────────────────────────────────

import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { useState, type ReactNode } from "react";
import { Toaster } from "sonner";

export function Providers({ children }: Readonly<{ children: ReactNode }>) {
  const [queryClient] = useState(
    () =>
      new QueryClient({
        defaultOptions: {
          queries: {
            // Don't retry on 4xx (auth errors, validation errors)
            retry: (failureCount, error) => {
              const err = error as unknown as Record<string, unknown>;
              if (err && typeof err === "object" && "code" in err) {
                const code = String(err.code);
                if (["401", "403", "PGRST301"].includes(code)) return false;
              }
              return failureCount < 2;
            },
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
        toastOptions={{
          duration: 4000,
        }}
      />
    </QueryClientProvider>
  );
}
