"use client";

// ─── ComparisonGrid — side-by-side product comparison ───────────────────────
// Desktop: table-style grid with columns per product.
// Mobile (<768px): horizontal swipe between product cards.
// Highlights best/worst values per row with green/red coloring.

import { useState, useRef, useCallback, useEffect } from "react";
import { SCORE_BANDS, NUTRI_COLORS, scoreBandFromScore } from "@/lib/constants";
import { AvoidBadge } from "@/components/product/AvoidBadge";
import { useTranslation } from "@/lib/i18n";
import { Scale, Trophy } from "lucide-react";
import type { CompareProduct, CellValue } from "@/lib/types";
import {
  fmtUnit,
  fmtStr,
  getWinnerIndex,
  getBestWorst,
  getCellHighlightClass,
} from "./comparison-helpers";

// ─── Types ──────────────────────────────────────────────────────────────────

interface ComparisonGridProps {
  products: CompareProduct[];
  /** Whether the viewer is authenticated (shows avoid badge if true) */
  showAvoidBadge?: boolean;
}

/** A single comparison row definition */
interface CompareRow {
  label: string;
  key: string;
  getValue: (p: CompareProduct) => CellValue;
  format?: (v: CellValue) => string;
  /** 'lower' = lower is better, 'higher' = higher is better, 'none' = no ranking */
  betterDirection: "lower" | "higher" | "none";
  unit?: string;
}

// ─── Row definitions ────────────────────────────────────────────────────────

/** Maps row keys to i18n translation keys. */
const ROW_LABEL_KEYS: Record<string, string> = {
  unhealthiness_score: "compare.unhealthinessScore",
  nutri_score: "filters.nutriScore",
  nova_group: "compare.novaGroupLabel",
  calories: "product.caloriesLabel",
  total_fat_g: "product.totalFat",
  saturated_fat_g: "product.saturatedFat",
  sugars_g: "product.sugars",
  salt_g: "product.salt",
  fibre_g: "product.fibre",
  protein_g: "product.protein",
  carbs_g: "product.carbs",
  additives_count: "product.additives",
  allergen_count: "product.allergens",
};

const COMPARE_ROWS: CompareRow[] = [
  {
    label: "Unhealthiness Score",
    key: "unhealthiness_score",
    getValue: (p) => p.unhealthiness_score,
    betterDirection: "lower",
  },
  {
    label: "Nutri-Score",
    key: "nutri_score",
    getValue: (p) => p.nutri_score,
    format: (v) => (v ? String(v) : "?"),
    betterDirection: "none",
  },
  {
    label: "NOVA Group",
    key: "nova_group",
    getValue: (p) => (p.nova_group ? Number(p.nova_group) : null),
    format: (v) => fmtStr(v, "?"),
    betterDirection: "lower",
  },
  {
    label: "Calories",
    key: "calories",
    getValue: (p) => p.calories,
    format: (v) => fmtUnit(v, "kcal"),
    betterDirection: "lower",
    unit: "kcal",
  },
  {
    label: "Total Fat",
    key: "total_fat_g",
    getValue: (p) => p.total_fat_g,
    format: (v) => fmtUnit(v, "g"),
    betterDirection: "lower",
    unit: "g",
  },
  {
    label: "Saturated Fat",
    key: "saturated_fat_g",
    getValue: (p) => p.saturated_fat_g,
    format: (v) => fmtUnit(v, "g"),
    betterDirection: "lower",
    unit: "g",
  },
  {
    label: "Sugars",
    key: "sugars_g",
    getValue: (p) => p.sugars_g,
    format: (v) => fmtUnit(v, "g"),
    betterDirection: "lower",
    unit: "g",
  },
  {
    label: "Salt",
    key: "salt_g",
    getValue: (p) => p.salt_g,
    format: (v) => fmtUnit(v, "g"),
    betterDirection: "lower",
    unit: "g",
  },
  {
    label: "Fibre",
    key: "fibre_g",
    getValue: (p) => p.fibre_g,
    format: (v) => fmtUnit(v, "g"),
    betterDirection: "higher",
    unit: "g",
  },
  {
    label: "Protein",
    key: "protein_g",
    getValue: (p) => p.protein_g,
    format: (v) => fmtUnit(v, "g"),
    betterDirection: "higher",
    unit: "g",
  },
  {
    label: "Carbs",
    key: "carbs_g",
    getValue: (p) => p.carbs_g,
    format: (v) => fmtUnit(v, "g"),
    betterDirection: "lower",
    unit: "g",
  },
  {
    label: "Additives",
    key: "additives_count",
    getValue: (p) => p.additives_count,
    format: (v) => fmtStr(v),
    betterDirection: "lower",
  },
  {
    label: "Allergens",
    key: "allergen_count",
    getValue: (p) => p.allergen_count,
    format: (v) => fmtStr(v, "0"),
    betterDirection: "lower",
  },
];

// ─── Desktop Grid ───────────────────────────────────────────────────────────

function DesktopGrid({
  products,
  showAvoidBadge,
}: Readonly<ComparisonGridProps>) {
  const { t } = useTranslation();
  const winnerIdx = getWinnerIndex(products);
  const colCount = products.length;

  return (
    <div className="hidden md:block overflow-x-auto">
      <table className="w-full border-collapse text-sm">
        {/* Header row: product names */}
        <thead>
          <tr className="border-b-2 border">
            <th className="sticky left-0 z-10 bg-surface px-3 py-3 text-left text-xs font-medium uppercase tracking-wider text-foreground-muted w-36">
              {t("compare.metric")}
            </th>
            {products.map((p, i) => {
              const band =
                SCORE_BANDS[scoreBandFromScore(p.unhealthiness_score)];
              const nutriClass = p.nutri_score
                ? NUTRI_COLORS[p.nutri_score]
                : "bg-surface-muted text-foreground-secondary";

              return (
                <th
                  key={p.product_id}
                  className={`px-3 py-3 text-center ${
                    i === winnerIdx ? "bg-green-50" : ""
                  }`}
                  style={{
                    width: `${(100 - 20) / colCount}%`,
                  }}
                >
                  <div className="space-y-1">
                    {i === winnerIdx && (
                      <span className="inline-block rounded-full bg-green-100 px-2 py-0.5 text-xs font-bold text-green-700">
                        <Trophy
                          size={12}
                          aria-hidden="true"
                          className="inline"
                        />{" "}
                        {t("compare.healthiest")}
                      </span>
                    )}
                    <div
                      className={`mx-auto flex h-12 w-12 items-center justify-center rounded-lg text-lg font-bold ${band.bg} ${band.color}`}
                    >
                      {p.unhealthiness_score}
                    </div>
                    <p className="text-sm font-semibold text-foreground line-clamp-2">
                      {p.product_name}
                    </p>
                    <p className="text-xs text-foreground-secondary">
                      {p.brand}
                    </p>
                    <div className="flex items-center justify-center gap-1">
                      <span
                        className={`rounded-full px-1.5 py-0.5 text-xs font-bold ${nutriClass}`}
                      >
                        {p.nutri_score ?? "?"}
                      </span>
                      <span className="rounded-full bg-surface-muted px-1.5 py-0.5 text-xs text-foreground-secondary">
                        N{p.nova_group ?? "?"}
                      </span>
                      {showAvoidBadge && (
                        <AvoidBadge productId={p.product_id} />
                      )}
                    </div>
                  </div>
                </th>
              );
            })}
          </tr>
        </thead>

        {/* Data rows */}
        <tbody>
          {COMPARE_ROWS.map((row) => {
            const values = products.map((p) => {
              const v = row.getValue(p);
              return typeof v === "number" ? v : null;
            });
            const ranking = getBestWorst(values, row.betterDirection);

            return (
              <tr key={row.key} className="border-b border">
                <td className="sticky left-0 z-10 bg-surface px-3 py-2 text-xs font-medium text-foreground-secondary">
                  {t(ROW_LABEL_KEYS[row.key]) ?? row.label}
                </td>
                {products.map((p, i) => {
                  const rawValue = row.getValue(p);
                  const formatted = row.format
                    ? row.format(rawValue)
                    : fmtStr(rawValue);
                  const cellClass = getCellHighlightClass(
                    i,
                    ranking,
                    winnerIdx,
                  );

                  return (
                    <td
                      key={p.product_id}
                      className={`px-3 py-2 text-center ${cellClass}`}
                    >
                      {formatted}
                    </td>
                  );
                })}
              </tr>
            );
          })}

          {/* Allergen tags row */}
          <tr className="border-b border">
            <td className="sticky left-0 z-10 bg-surface px-3 py-2 text-xs font-medium text-foreground-secondary">
              {t("product.allergens")}
            </td>
            {products.map((p) => (
              <td
                key={p.product_id}
                className="px-3 py-2 text-center text-xs text-foreground-secondary"
              >
                {p.allergen_tags
                  ? p.allergen_tags
                      .split(", ")
                      .map((tag) => tag.replace("en:", ""))
                      .join(", ")
                  : t("compare.none")}
              </td>
            ))}
          </tr>

          {/* Flags row */}
          <tr className="border-b border">
            <td className="sticky left-0 z-10 bg-surface px-3 py-2 text-xs font-medium text-foreground-secondary">
              {t("product.warnings")}
            </td>
            {products.map((p) => {
              const flags: { key: string; label: string }[] = [];
              if (p.high_salt)
                flags.push({
                  key: "salt",
                  label: `🧂 ${t("product.highSalt")}`,
                });
              if (p.high_sugar)
                flags.push({
                  key: "sugar",
                  label: `🍬 ${t("product.highSugar")}`,
                });
              if (p.high_sat_fat)
                flags.push({
                  key: "satfat",
                  label: `🧈 ${t("product.highSatFat")}`,
                });
              if (p.high_additive_load)
                flags.push({
                  key: "additives",
                  label: `⚗️ ${t("product.manyAdditives")}`,
                });
              return (
                <td
                  key={p.product_id}
                  className="px-3 py-2 text-center text-xs"
                >
                  {flags.length > 0 ? (
                    <div className="flex flex-wrap justify-center gap-1">
                      {flags.map((f) => (
                        <span
                          key={f.key}
                          className="rounded bg-orange-50 px-1 py-0.5 text-orange-600"
                        >
                          {f.label}
                        </span>
                      ))}
                    </div>
                  ) : (
                    <span className="text-green-600">
                      {t("compare.noWarnings")}
                    </span>
                  )}
                </td>
              );
            })}
          </tr>
        </tbody>
      </table>
    </div>
  );
}

// ─── Mobile Swipe View ──────────────────────────────────────────────────────

function MobileSwipeView({
  products,
  showAvoidBadge,
}: Readonly<ComparisonGridProps>) {
  const { t } = useTranslation();
  const [activeIdx, setActiveIdx] = useState(0);
  const containerRef = useRef<HTMLDivElement>(null);
  const touchStartX = useRef(0);
  const winnerIdx = getWinnerIndex(products);

  const swipeTo = useCallback(
    (idx: number) => {
      setActiveIdx(Math.max(0, Math.min(idx, products.length - 1)));
    },
    [products.length],
  );

  const handleTouchStart = useCallback((e: React.TouchEvent) => {
    touchStartX.current = e.touches[0].clientX;
  }, []);

  const handleTouchEnd = useCallback(
    (e: React.TouchEvent) => {
      const diff = touchStartX.current - e.changedTouches[0].clientX;
      if (Math.abs(diff) > 50) {
        swipeTo(activeIdx + (diff > 0 ? 1 : -1));
      }
    },
    [activeIdx, swipeTo],
  );

  // Keyboard nav
  useEffect(() => {
    function onKey(e: KeyboardEvent) {
      if (e.key === "ArrowLeft") swipeTo(activeIdx - 1);
      if (e.key === "ArrowRight") swipeTo(activeIdx + 1);
    }
    globalThis.addEventListener("keydown", onKey);
    return () => globalThis.removeEventListener("keydown", onKey);
  }, [activeIdx, swipeTo]);

  const product = products[activeIdx];
  const band = SCORE_BANDS[scoreBandFromScore(product.unhealthiness_score)];
  const nutriClass = product.nutri_score
    ? NUTRI_COLORS[product.nutri_score]
    : "bg-surface-muted text-foreground-secondary";

  return (
    <div className="md:hidden">
      {/* Sticky header with product names */}
      <div className="sticky top-12 md:top-14 z-30 bg-surface border-b border-border px-4 py-2">
        <div className="flex items-center justify-center gap-2">
          {products.map((p, i) => (
            <button
              key={p.product_id}
              onClick={() => setActiveIdx(i)}
              className={`touch-target rounded-full px-3 py-1.5 text-xs font-medium transition-colors ${
                i === activeIdx
                  ? "bg-brand-600 text-white"
                  : "bg-surface-muted text-foreground-secondary"
              }`}
            >
              {i === winnerIdx && (
                <>
                  <Trophy
                    size={12}
                    aria-hidden="true"
                    className="inline"
                  />{" "}
                </>
              )}
              {p.product_name.length > 12
                ? p.product_name.slice(0, 12) + "…"
                : p.product_name}
            </button>
          ))}
        </div>
        {/* Dots indicator */}
        <div className="mt-1 flex justify-center gap-1">
          {products.map((p, i) => (
            <span
              key={`dot-${p.product_id}`}
              className={`h-1.5 w-1.5 rounded-full transition-colors ${
                i === activeIdx ? "bg-brand-600" : "bg-surface-muted"
              }`}
            />
          ))}
        </div>
      </div>

      {/* Swipeable card */}
      <div
        ref={containerRef}
        onTouchStart={handleTouchStart}
        onTouchEnd={handleTouchEnd}
        className="mt-4 px-4"
      >
        <div className="card space-y-4">
          {/* Product header */}
          <div className="flex items-start gap-3">
            <div
              className={`flex h-14 w-14 flex-shrink-0 items-center justify-center rounded-xl text-xl font-bold ${band.bg} ${band.color}`}
            >
              {product.unhealthiness_score}
            </div>
            <div className="min-w-0 flex-1">
              <p className="font-bold text-foreground">
                {product.product_name}
              </p>
              <p className="text-sm text-foreground-secondary">
                {product.brand}
              </p>
              <div className="mt-1 flex items-center gap-1.5">
                <span
                  className={`rounded-full px-1.5 py-0.5 text-xs font-bold ${nutriClass}`}
                >
                  {product.nutri_score ?? "?"}
                </span>
                <span className="rounded-full bg-surface-muted px-1.5 py-0.5 text-xs text-foreground-secondary">
                  {t("product.novaGroup", { group: product.nova_group ?? "?" })}
                </span>
                {activeIdx === winnerIdx && (
                  <span className="rounded-full bg-green-100 px-1.5 py-0.5 text-xs font-bold text-green-700">
                    <Trophy size={12} aria-hidden="true" className="inline" />{" "}
                    {t("compare.best")}
                  </span>
                )}
                {showAvoidBadge && (
                  <AvoidBadge productId={product.product_id} />
                )}
              </div>
            </div>
          </div>

          {/* Nutrition data */}
          <div className="divide-y divide-gray-100">
            {COMPARE_ROWS.filter(
              (r) => r.key !== "nutri_score" && r.key !== "nova_group",
            ).map((row) => {
              const rawValue = row.getValue(product);
              const formatted = row.format
                ? row.format(rawValue)
                : fmtStr(rawValue);

              // Compare with other products
              const allValues = products.map((p) => {
                const v = row.getValue(p);
                return typeof v === "number" ? v : null;
              });
              const ranking = getBestWorst(allValues, row.betterDirection);
              let indicator = "";
              if (ranking) {
                if (activeIdx === ranking.bestIdx)
                  indicator = "text-green-600 font-semibold";
                else if (activeIdx === ranking.worstIdx)
                  indicator = "text-red-600";
              }

              return (
                <div
                  key={row.key}
                  className="flex items-center justify-between py-2"
                >
                  <span className="text-sm text-foreground-secondary">
                    {t(ROW_LABEL_KEYS[row.key]) ?? row.label}
                  </span>
                  <span className={`text-sm ${indicator || "text-foreground"}`}>
                    {formatted}
                    {ranking?.bestIdx === activeIdx && " ✓"}
                    {ranking?.worstIdx === activeIdx && " ✗"}
                  </span>
                </div>
              );
            })}
          </div>

          {/* Allergens */}
          <div className="pt-2 border-t border">
            <p className="text-xs font-medium text-foreground-muted uppercase mb-1">
              {t("product.allergens")}
            </p>
            <p className="text-sm text-foreground-secondary">
              {product.allergen_tags
                ? product.allergen_tags
                    .split(", ")
                    .map((tag) => tag.replace("en:", ""))
                    .join(", ")
                : t("compare.noneDeclared")}
            </p>
          </div>

          {/* Flags */}
          <div>
            <p className="text-xs font-medium text-foreground-muted uppercase mb-1">
              {t("product.warnings")}
            </p>
            <div className="flex flex-wrap gap-1">
              {product.high_salt && (
                <span className="rounded bg-orange-50 px-2 py-0.5 text-xs text-orange-600">
                  🧂 {t("product.highSalt")}
                </span>
              )}
              {product.high_sugar && (
                <span className="rounded bg-orange-50 px-2 py-0.5 text-xs text-orange-600">
                  🍬 {t("product.highSugar")}
                </span>
              )}
              {product.high_sat_fat && (
                <span className="rounded bg-orange-50 px-2 py-0.5 text-xs text-orange-600">
                  🧈 {t("product.highSatFat")}
                </span>
              )}
              {product.high_additive_load && (
                <span className="rounded bg-orange-50 px-2 py-0.5 text-xs text-orange-600">
                  ⚗️ {t("product.manyAdditives")}
                </span>
              )}
              {!product.high_salt &&
                !product.high_sugar &&
                !product.high_sat_fat &&
                !product.high_additive_load && (
                  <span className="text-sm text-green-600">
                    {t("compare.noWarnings")}
                  </span>
                )}
            </div>
          </div>
        </div>

        {/* Swipe hint */}
        <p className="mt-3 text-center text-xs text-foreground-muted">
          {t("compare.swipeHint", {
            current: activeIdx + 1,
            total: products.length,
          })}
        </p>
      </div>
    </div>
  );
}

// ─── Main Export ─────────────────────────────────────────────────────────────

export function ComparisonGrid({
  products,
  showAvoidBadge = false,
}: Readonly<ComparisonGridProps>) {
  const { t } = useTranslation();

  if (products.length < 2) {
    return (
      <div className="py-12 text-center">
        <div className="mb-2 flex justify-center">
          <Scale
            size={40}
            className="text-foreground-muted"
            aria-hidden="true"
          />
        </div>
        <p className="text-sm text-foreground-secondary">
          {t("compare.selectAtLeast2")}
        </p>
      </div>
    );
  }

  return (
    <>
      <DesktopGrid products={products} showAvoidBadge={showAvoidBadge} />
      <MobileSwipeView products={products} showAvoidBadge={showAvoidBadge} />
    </>
  );
}
