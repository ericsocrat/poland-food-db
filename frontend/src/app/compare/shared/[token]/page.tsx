"use client";

// ─── Shared Comparison Page — public, no auth required ──────────────────────
// URL: /compare/shared/[token]
// Displays a shared comparison with the ComparisonGrid component.
// No avoid badges or save features — read-only public view.

import { useParams } from "next/navigation";
import Link from "next/link";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { useSharedComparison } from "@/hooks/use-compare";
import { ComparisonGrid } from "@/components/compare/ComparisonGrid";
import { LoadingSpinner } from "@/components/common/LoadingSpinner";

const queryClient = new QueryClient();

function SharedComparisonContent() {
  const params = useParams();
  const token = params.token as string;
  const { data, isLoading, error } = useSharedComparison(token);

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="border-b border-gray-200 bg-white">
        <div className="mx-auto flex h-14 max-w-5xl items-center justify-between px-4">
          <Link href="/" className="text-lg font-bold text-brand-700">
            🥗 FoodDB
          </Link>
          <span className="rounded-full bg-blue-100 px-3 py-1 text-xs font-medium text-blue-700">
            Shared comparison
          </span>
        </div>
      </header>

      <main className="mx-auto max-w-5xl px-4 py-6 space-y-4">
        {/* Loading */}
        {isLoading && (
          <div className="flex justify-center py-12">
            <LoadingSpinner />
          </div>
        )}

        {/* Error / not found */}
        {error && (
          <div className="card border-red-200 bg-red-50 py-8 text-center">
            <p className="mb-2 text-4xl">🔗</p>
            <p className="mb-1 text-sm text-red-600">
              This comparison link is invalid or has expired.
            </p>
            <Link href="/" className="mt-3 btn-primary inline-block text-sm">
              Go to FoodDB
            </Link>
          </div>
        )}

        {/* Comparison data */}
        {data && data.products.length >= 2 && (
          <>
            <div className="flex items-center justify-between">
              <div>
                <h1 className="text-xl font-bold text-gray-900">
                  ⚖️ {data.title ?? "Product Comparison"}
                </h1>
                <p className="text-sm text-gray-500">
                  {data.product_count} products compared ·{" "}
                  {new Date(data.created_at).toLocaleDateString()}
                </p>
              </div>
            </div>

            <ComparisonGrid
              products={data.products}
              showAvoidBadge={false}
            />
          </>
        )}

        {/* CTA */}
        <div className="card bg-brand-50 text-center">
          <p className="mb-2 text-sm text-gray-700">
            Want to compare your own products?
          </p>
          <Link href="/auth/login" className="btn-primary inline-block text-sm">
            Sign up for free
          </Link>
        </div>
      </main>
    </div>
  );
}

export default function SharedComparisonPage() {
  return (
    <QueryClientProvider client={queryClient}>
      <SharedComparisonContent />
    </QueryClientProvider>
  );
}
