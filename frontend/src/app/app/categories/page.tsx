"use client";

// ─── Categories overview — grid of category cards ───────────────────────────

import { useQuery, useQueryClient } from "@tanstack/react-query";
import Link from "next/link";
import { createClient } from "@/lib/supabase/client";
import { getCategoryOverview } from "@/lib/api";
import { queryKeys, staleTimes } from "@/lib/query-keys";
import { SCORE_BANDS } from "@/lib/constants";
import { CategoryGridSkeleton } from "@/components/common/skeletons";
import { useTranslation } from "@/lib/i18n";
import type { CategoryOverviewItem, ScoreBand } from "@/lib/types";

function scoreToBand(score: number): ScoreBand {
  if (score <= 25) return "low";
  if (score <= 50) return "moderate";
  if (score <= 75) return "high";
  return "very_high";
}

export default function CategoriesPage() {
  const supabase = createClient();
  const queryClient = useQueryClient();
  const { t } = useTranslation();

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
    return <CategoryGridSkeleton />;
  }

  if (error) {
    return (
      <div className="py-12 text-center">
        <p className="mb-3 text-sm text-red-500">
          {t("categories.loadFailed")}
        </p>
        <button
          type="button"
          className="rounded-lg bg-blue-600 px-4 py-2 text-sm font-medium text-white hover:bg-blue-700"
          onClick={() =>
            queryClient.invalidateQueries({
              queryKey: queryKeys.categoryOverview,
            })
          }
        >
          {t("common.retry")}
        </button>
      </div>
    );
  }

  return (
    <div>
      <h1 className="mb-4 text-xl font-bold text-foreground lg:text-2xl">
        {t("categories.title")}
      </h1>
      <div className="grid grid-cols-2 gap-3 sm:grid-cols-3 lg:grid-cols-3 xl:grid-cols-4 lg:gap-4">
        {data?.map((cat) => (
          <CategoryCard key={cat.category} category={cat} />
        ))}
      </div>
    </div>
  );
}

function CategoryCard({
  category,
}: Readonly<{ category: CategoryOverviewItem }>) {
  const { t } = useTranslation();
  const band = scoreToBand(category.avg_score);
  const display = SCORE_BANDS[band];

  return (
    <Link href={`/app/categories/${category.slug}`}>
      <div className="card hover-lift-press flex flex-col items-center gap-2 p-4 text-center transition-all duration-150">
        <span className="text-3xl">{category.icon_emoji}</span>
        <p className="text-sm font-semibold text-foreground">
          {category.display_name}
        </p>
        <p className="text-xs text-foreground-secondary">
          {t("common.products", { count: category.product_count })}
        </p>
        <span
          className={`rounded-full px-2 py-0.5 text-xs font-medium ${display.bg} ${display.color}`}
        >
          {t("categories.avgScore", { score: Math.round(category.avg_score) })}
        </span>
      </div>
    </Link>
  );
}
