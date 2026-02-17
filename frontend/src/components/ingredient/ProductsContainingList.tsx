"use client";

import Link from "next/link";
import { useTranslation } from "@/lib/i18n";
import { CONCERN_TIER_STYLES } from "@/lib/constants";
import type { IngredientUsage } from "@/lib/types";

interface ProductsContainingListProps {
  readonly products: IngredientUsage["top_products"];
}

/**
 * Card listing the top products that contain this ingredient, ordered
 * by healthiest score. Each row links to that product's profile page.
 */
export function ProductsContainingList({
  products,
}: ProductsContainingListProps) {
  const { t } = useTranslation();

  return (
    <div className="card">
      <h2 className="mb-2 text-sm font-semibold text-gray-700">
        {t("ingredient.topProducts")}
      </h2>
      <ul className="divide-y divide-gray-100">
        {products.map((p) => (
          <li key={p.product_id}>
            <Link
              href={`/app/product/${p.product_id}`}
              className="flex items-center gap-3 py-2 hover:bg-gray-50 -mx-1 px-1 rounded"
            >
              <ScorePill score={p.score} />
              <div className="min-w-0 flex-1">
                <p className="truncate text-sm font-medium text-gray-800">
                  {p.product_name}
                </p>
                <p className="truncate text-xs text-gray-400">
                  {p.brand} · {p.category}
                </p>
              </div>
            </Link>
          </li>
        ))}
      </ul>
    </div>
  );
}

function ScorePill({ score }: Readonly<{ score: number }>) {
  let tier: number;
  if (score <= 25) tier = 0;
  else if (score <= 50) tier = 1;
  else if (score <= 75) tier = 2;
  else tier = 3;
  const style = CONCERN_TIER_STYLES[tier] ?? CONCERN_TIER_STYLES[0];
  return (
    <span
      className={`flex h-8 w-8 flex-shrink-0 items-center justify-center rounded-full text-xs font-bold ${style.bg} ${style.color}`}
    >
      {score}
    </span>
  );
}
