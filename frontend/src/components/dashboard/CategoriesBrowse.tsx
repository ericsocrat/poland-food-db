"use client";

// ─── CategoriesBrowse — horizontal scrollable category chips ────────────────

import Link from "next/link";
import { useQuery } from "@tanstack/react-query";
import { createClient } from "@/lib/supabase/client";
import { getCategoryOverview } from "@/lib/api";
import { queryKeys, staleTimes } from "@/lib/query-keys";
import { useTranslation } from "@/lib/i18n";
import { Skeleton } from "@/components/common/Skeleton";
import type { CategoryOverviewItem } from "@/lib/types";

function CategoryChip({
  category,
}: Readonly<{ category: CategoryOverviewItem }>) {
  return (
    <Link
      href={`/app/categories/${category.slug}`}
      className="flex shrink-0 flex-col items-center gap-1.5 rounded-xl border bg-surface px-3 py-3 text-center shadow-sm hover-lift-press"
      style={{ minWidth: "5rem" }}
    >
      <span className="text-2xl" aria-hidden="true">
        {category.icon_emoji}
      </span>
      <span className="max-w-[5rem] truncate text-xs font-medium text-foreground">
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
          className="text-sm font-medium text-brand transition-colors hover:text-brand-hover"
        >
          {t("dashboard.viewAll")}
        </Link>
      </div>

      {isLoading && <CategoriesBrowseSkeleton />}
      {!isLoading && data && data.length > 0 && (
        <ul
          className="scrollbar-hide flex list-none gap-3 overflow-x-auto pb-1 lg:grid lg:grid-cols-3 lg:overflow-visible lg:pb-0"
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
