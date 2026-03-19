"use client";

// ─── CategoriesBrowse — horizontal scrollable category chips ────────────────

import { CategoryIcon } from "@/components/common/CategoryIcon";
import { Skeleton } from "@/components/common/Skeleton";
import { getCategoryOverview } from "@/lib/api";
import { useTranslation } from "@/lib/i18n";
import { queryKeys, staleTimes } from "@/lib/query-keys";
import { createClient } from "@/lib/supabase/client";
import type { CategoryOverviewItem } from "@/lib/types";
import { useQuery } from "@tanstack/react-query";
import { ArrowRight } from "lucide-react";
import Link from "next/link";

function CategoryChip({
  category,
}: Readonly<{ category: CategoryOverviewItem }>) {
  return (
    <Link
      href={`/app/categories/${category.slug}`}
      className="flex shrink-0 flex-col items-center gap-1.5 rounded-xl border bg-surface px-3 py-3 text-center shadow-sm hover-lift-press"
      style={{ minWidth: "5rem" }}
    >
      <CategoryIcon slug={category.slug} size="xl" />
      <span className="max-w-20 truncate text-xs font-medium text-foreground">
        {category.display_name}
      </span>
    </Link>
  );
}

function CategoriesBrowseSkeleton() {
  return (
    <div className="flex gap-3 overflow-hidden">
      {Array.from({ length: 6 }, (_, i) => (
        <div
          key={i}
          className="flex shrink-0 flex-col items-center gap-1.5 rounded-xl border bg-surface px-3 py-3"
          style={{ minWidth: "5rem" }}
        >
          <Skeleton variant="rect" width={32} height={32} />
          <Skeleton variant="text" width="3.5rem" height={12} />
        </div>
      ))}
    </div>
  );
}

export function CategoriesBrowse() {
  const supabase = createClient();
  const { t } = useTranslation();

  const { data, isLoading } = useQuery({
    queryKey: queryKeys.categoryOverview,
    queryFn: async () => {
      const result = await getCategoryOverview(supabase);
      if (!result.ok) throw new Error(result.error.message);
      return result.data;
    },
    staleTime: staleTimes.categoryOverview,
  });

  return (
    <section>
      <div className="mb-2 flex items-center justify-between lg:mb-3">
        <h2 className="text-lg font-semibold text-foreground lg:text-xl">
          {t("dashboard.categoriesTitle")}
        </h2>
        <Link
          href="/app/categories"
          className="inline-flex items-center gap-1 text-sm font-medium text-brand transition-colors hover:text-brand-hover"
        >
          {t("dashboard.viewAll")}
          <ArrowRight className="h-3 w-3" aria-hidden="true" />
        </Link>
      </div>

      {isLoading && <CategoriesBrowseSkeleton />}
      {!isLoading && data && data.length > 0 && (
        <ul
          className="scroll-fade-x scrollbar-hide -mx-4 flex list-none gap-3 overflow-x-auto px-4 pb-1 lg:scroll-fade-none lg:mx-0 lg:grid lg:grid-cols-3 lg:overflow-visible lg:px-0 lg:pb-0"
          aria-label={t("dashboard.categoriesTitle")}
        >
          {data.map((cat) => (
            <li key={cat.category}>
              <CategoryChip category={cat} />
            </li>
          ))}
        </ul>
      )}
    </section>
  );
}
