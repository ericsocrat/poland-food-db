// ─── Root error boundary ──────────────────────────────────────────────────
// Catches errors in route segments. Renders in-place without losing the layout.

"use client";

import { useEffect } from "react";

export default function Error({
  error,
  reset,
}: Readonly<{
  error: Error & { digest?: string };
  reset: () => void;
}>) {
  useEffect(() => {
    // Log error for debugging (console in dev, could be a service in prod)
    console.error("[ErrorBoundary]", error);
  }, [error]);

  return (
    <div className="flex min-h-screen flex-col items-center justify-center px-4">
      <h1 className="mb-2 text-2xl font-bold text-gray-900">
        Something went wrong
      </h1>
      <p className="mb-6 text-gray-500">
        An unexpected error occurred. Please try again.
      </p>
      <button onClick={reset} className="btn-primary px-6 py-3">
        Try again
      </button>
    </div>
  );
}
