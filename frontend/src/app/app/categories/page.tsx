"use client";

// ─── Categories overview — grid of category cards ───────────────────────────

import { useQuery } from "@tanstack/react-query";
import Link from "next/link";
import { createClient } from "@/lib/supabase/client";
import { getCategoryOverview } from "@/lib/api";
import { queryKeys, staleTimes } from "@/lib/query-keys";
import { SCORE_BANDS } from "@/lib/constants";
import { LoadingSpinner } from "@/components/common/LoadingSpinner";
import type { CategoryOverviewItem, ScoreBand } from "@/lib/types";

function scoreToBand(score: number): ScoreBand {
  if (score <= 25) return "low";
  if (score <= 50) return "moderate";
  if (score <= 75) return "high";
  return "very_high";
}

export default function CategoriesPage() {
  const supabase = createClient();

  const { data, isLoading, error } = useQuery({
    queryKey: queryKeys.categoryOverview,
    queryFn: async () => {
      const result = await getCategoryOverview(supabase);
      if (!result.ok) throw new Error(result.error.message);
      return result.data;
    },
    staleTime: staleTimes.categoryOverview,
  });

  if (isLoading) {
    return (
      <div className="flex justify-center py-12">
        <LoadingSpinner />
      </div>
    );
  }

  if (error) {
    return (
      <p className="py-12 text-center text-sm text-red-500">
        Failed to load categories. Please try again.
      </p>
    );
  }

  return (
    <div>
      <h1 className="mb-4 text-xl font-bold text-gray-900">Categories</h1>
      <div className="grid grid-cols-2 gap-3 sm:grid-cols-3">
        {data?.map((cat) => (
          <CategoryCard key={cat.category} category={cat} />
        ))}
      </div>
    </div>
  );
}

function CategoryCard({ category }: Readonly<{ category: CategoryOverviewItem }>) {
  const band = scoreToBand(category.avg_score);
  const display = SCORE_BANDS[band];

  return (
    <Link href={`/app/categories/${category.category}`}>
      <div className="card flex flex-col items-center gap-2 p-4 text-center transition-shadow hover:shadow-md">
        <span className="text-3xl">{category.icon_emoji}</span>
        <p className="text-sm font-semibold text-gray-900">
          {category.display_name}
        </p>
        <p className="text-xs text-gray-500">
          {category.product_count} product
          {category.product_count !== 1 && "s"}
        </p>
        <span
          className={`rounded-full px-2 py-0.5 text-xs font-medium ${display.bg} ${display.color}`}
        >
          avg {Math.round(category.avg_score)}
        </span>
      </div>
    </Link>
  );
}
