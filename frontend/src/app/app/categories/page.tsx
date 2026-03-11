"use client";

// ─── Categories overview — grid of category cards ───────────────────────────

import { Button } from "@/components/common/Button";
import { CategoryIcon } from "@/components/common/CategoryIcon";
import { CategoryGridSkeleton } from "@/components/common/skeletons";
import { CategoryScoreBar } from "@/components/category/CategoryScoreBar";
import { Breadcrumbs } from "@/components/layout/Breadcrumbs";
import { getCategoryOverview } from "@/lib/api";
import { SCORE_5BAND_DISPLAY, scoreColorFromScore } from "@/lib/constants";
import { useTranslation } from "@/lib/i18n";
import { queryKeys, staleTimes } from "@/lib/query-keys";
import { toTryVitScore } from "@/lib/score-utils";
import { createClient } from "@/lib/supabase/client";
import type { CategoryOverviewItem } from "@/lib/types";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import Link from "next/link";
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
        <p className="mb-3 text-sm text-error">
          {t("categories.loadFailed")}
        </p>
        <Button
          onClick={() =>
            queryClient.invalidateQueries({
              queryKey: queryKeys.categoryOverview,
            })
          }
        >
          {t("common.retry")}
        </Button>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <Breadcrumbs
        items={[
          { labelKey: "nav.home", href: "/app" },
          { labelKey: "nav.categories" },
        ]}
      />
      <h1 className="text-xl font-bold text-foreground lg:text-2xl">
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
  const band = scoreColorFromScore(category.avg_score);
  const display = SCORE_5BAND_DISPLAY[band];
  const tryVitScore = toTryVitScore(Math.round(category.avg_score));

  return (
    <Link href={`/app/categories/${category.slug}`}>
      <div className="card hover-lift-press flex flex-col gap-3 p-4 transition-all duration-fast">
        <div className="flex items-center gap-3">
          <CategoryIcon slug={category.slug} size="xl" />
          <div className="min-w-0 flex-1">
            <p className="truncate text-sm font-semibold text-foreground">
              {category.display_name}
            </p>
            <p className="text-xs text-foreground-secondary">
              {t("common.products", { count: category.product_count })}
            </p>
          </div>
          <div
            className={`flex h-9 w-9 flex-shrink-0 items-center justify-center rounded-lg text-sm font-bold ${display.bg} ${display.color}`}
          >
            {tryVitScore}
          </div>
        </div>
        <CategoryScoreBar
          minScore={category.min_score ?? category.avg_score}
          maxScore={category.max_score ?? category.avg_score}
          avgScore={category.avg_score}
        />
      </div>
    </Link>
  );
}
