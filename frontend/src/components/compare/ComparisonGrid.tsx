"use client";

// ─── ComparisonGrid — side-by-side product comparison ───────────────────────
// Desktop: table-style grid with columns per product.
// Mobile (<768px): horizontal swipe between product cards.
// Highlights best/worst values per row with green/red coloring.

import { useState, useRef, useCallback, useEffect } from "react";
import { SCORE_BANDS, NUTRI_COLORS } from "@/lib/constants";
import { AvoidBadge } from "@/components/product/AvoidBadge";
import type { CompareProduct, ScoreBand } from "@/lib/types";

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
  getValue: (p: CompareProduct) => number | string | null;
  format?: (v: number | string | null) => string;
  /** 'lower' = lower is better, 'higher' = higher is better, 'none' = no ranking */
  betterDirection: "lower" | "higher" | "none";
  unit?: string;
}

// ─── Row definitions ────────────────────────────────────────────────────────

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
    format: (v) => (v != null ? String(v) : "?"),
    betterDirection: "lower",
  },
  {
    label: "Calories",
    key: "calories",
    getValue: (p) => p.calories,
    format: (v) => (v != null ? `${v} kcal` : "—"),
    betterDirection: "lower",
    unit: "kcal",
  },
  {
    label: "Total Fat",
    key: "total_fat_g",
    getValue: (p) => p.total_fat_g,
    format: (v) => (v != null ? `${v} g` : "—"),
    betterDirection: "lower",
    unit: "g",
  },
  {
    label: "Saturated Fat",
    key: "saturated_fat_g",
    getValue: (p) => p.saturated_fat_g,
    format: (v) => (v != null ? `${v} g` : "—"),
    betterDirection: "lower",
    unit: "g",
  },
  {
    label: "Sugars",
    key: "sugars_g",
    getValue: (p) => p.sugars_g,
    format: (v) => (v != null ? `${v} g` : "—"),
    betterDirection: "lower",
    unit: "g",
  },
  {
    label: "Salt",
    key: "salt_g",
    getValue: (p) => p.salt_g,
    format: (v) => (v != null ? `${v} g` : "—"),
    betterDirection: "lower",
    unit: "g",
  },
  {
    label: "Fibre",
    key: "fibre_g",
    getValue: (p) => p.fibre_g,
    format: (v) => (v != null ? `${v} g` : "—"),
    betterDirection: "higher",
    unit: "g",
  },
  {
    label: "Protein",
    key: "protein_g",
    getValue: (p) => p.protein_g,
    format: (v) => (v != null ? `${v} g` : "—"),
    betterDirection: "higher",
    unit: "g",
  },
  {
    label: "Carbs",
    key: "carbs_g",
    getValue: (p) => p.carbs_g,
    format: (v) => (v != null ? `${v} g` : "—"),
    betterDirection: "lower",
    unit: "g",
  },
  {
    label: "Additives",
    key: "additives_count",
    getValue: (p) => p.additives_count,
    format: (v) => (v != null ? String(v) : "—"),
    betterDirection: "lower",
  },
  {
    label: "Allergens",
    key: "allergen_count",
    getValue: (p) => p.allergen_count,
    format: (v) => (v != null ? String(v) : "0"),
    betterDirection: "lower",
  },
];

// ─── Helpers ────────────────────────────────────────────────────────────────

function getWinnerIndex(products: CompareProduct[]): number {
  let bestIdx = 0;
  let bestScore = products[0].unhealthiness_score;
  for (let i = 1; i < products.length; i++) {
    if (products[i].unhealthiness_score < bestScore) {
      bestScore = products[i].unhealthiness_score;
      bestIdx = i;
    }
  }
  return bestIdx;
}

function getBestWorst(
  values: (number | null)[],
  direction: "lower" | "higher" | "none",
): { bestIdx: number; worstIdx: number } | null {
  if (direction === "none") return null;
  const numericValues = values.map((v) => (typeof v === "number" ? v : null));
  const validIndices = numericValues
    .map((v, i) => (v !== null ? i : -1))
    .filter((i) => i >= 0);

  if (validIndices.length < 2) return null;

  let bestIdx = validIndices[0];
  let worstIdx = validIndices[0];

  for (const i of validIndices) {
    const val = numericValues[i]!;
    const bestVal = numericValues[bestIdx]!;
    const worstVal = numericValues[worstIdx]!;

    if (direction === "lower") {
      if (val < bestVal) bestIdx = i;
      if (val > worstVal) worstIdx = i;
    } else {
      if (val > bestVal) bestIdx = i;
      if (val < worstVal) worstIdx = i;
    }
  }

  // Don't highlight if all values are equal
  if (numericValues[bestIdx] === numericValues[worstIdx]) return null;

  return { bestIdx, worstIdx };
}

function scoreBandFromScore(score: number): ScoreBand {
  if (score <= 25) return "low";
  if (score <= 50) return "moderate";
  if (score <= 75) return "high";
  return "very_high";
}

// ─── Desktop Grid ───────────────────────────────────────────────────────────

function DesktopGrid({
  products,
  showAvoidBadge,
}: Readonly<ComparisonGridProps>) {
  const winnerIdx = getWinnerIndex(products);
  const colCount = products.length;

  return (
    <div className="hidden md:block overflow-x-auto">
      <table className="w-full border-collapse text-sm">
        {/* Header row: product names */}
        <thead>
          <tr className="border-b-2 border-gray-200">
            <th className="sticky left-0 z-10 bg-white px-3 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-400 w-36">
              Metric
            </th>
            {products.map((p, i) => {
              const band =
                SCORE_BANDS[scoreBandFromScore(p.unhealthiness_score)];
              const nutriClass = p.nutri_score
                ? NUTRI_COLORS[p.nutri_score]
                : "bg-gray-200 text-gray-500";

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
                        🏆 Healthiest
                      </span>
                    )}
                    <div
                      className={`mx-auto flex h-12 w-12 items-center justify-center rounded-lg text-lg font-bold ${band.bg} ${band.color}`}
                    >
                      {p.unhealthiness_score}
                    </div>
                    <p className="text-sm font-semibold text-gray-900 line-clamp-2">
                      {p.product_name}
                    </p>
                    <p className="text-xs text-gray-500">{p.brand}</p>
                    <div className="flex items-center justify-center gap-1">
                      <span
                        className={`rounded-full px-1.5 py-0.5 text-xs font-bold ${nutriClass}`}
                      >
                        {p.nutri_score ?? "?"}
                      </span>
                      <span className="rounded-full bg-gray-100 px-1.5 py-0.5 text-xs text-gray-600">
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
              <tr key={row.key} className="border-b border-gray-100">
                <td className="sticky left-0 z-10 bg-white px-3 py-2 text-xs font-medium text-gray-500">
                  {row.label}
                </td>
                {products.map((p, i) => {
                  const rawValue = row.getValue(p);
                  const formatted = row.format
                    ? row.format(rawValue)
                    : rawValue != null
                      ? String(rawValue)
                      : "—";

                  let cellClass = "";
                  if (ranking) {
                    if (i === ranking.bestIdx)
                      cellClass = "bg-green-50 text-green-700 font-semibold";
                    else if (i === ranking.worstIdx)
                      cellClass = "bg-red-50 text-red-600";
                  }

                  return (
                    <td
                      key={p.product_id}
                      className={`px-3 py-2 text-center ${cellClass} ${
                        i === winnerIdx && !cellClass ? "bg-green-50/30" : ""
                      }`}
                    >
                      {formatted}
                    </td>
                  );
                })}
              </tr>
            );
          })}

          {/* Allergen tags row */}
          <tr className="border-b border-gray-100">
            <td className="sticky left-0 z-10 bg-white px-3 py-2 text-xs font-medium text-gray-500">
              Allergen Tags
            </td>
            {products.map((p) => (
              <td
                key={p.product_id}
                className="px-3 py-2 text-center text-xs text-gray-600"
              >
                {p.allergen_tags
                  ? p.allergen_tags
                      .split(", ")
                      .map((t) => t.replace("en:", ""))
                      .join(", ")
                  : "None"}
              </td>
            ))}
          </tr>

          {/* Flags row */}
          <tr className="border-b border-gray-100">
            <td className="sticky left-0 z-10 bg-white px-3 py-2 text-xs font-medium text-gray-500">
              Warnings
            </td>
            {products.map((p) => {
              const flags = [];
              if (p.high_salt) flags.push("🧂 High Salt");
              if (p.high_sugar) flags.push("🍬 High Sugar");
              if (p.high_sat_fat) flags.push("🧈 High Sat Fat");
              if (p.high_additive_load) flags.push("⚗️ Additives");
              return (
                <td
                  key={p.product_id}
                  className="px-3 py-2 text-center text-xs"
                >
                  {flags.length > 0 ? (
                    <div className="flex flex-wrap justify-center gap-1">
                      {flags.map((f) => (
                        <span
                          key={f}
                          className="rounded bg-orange-50 px-1 py-0.5 text-orange-600"
                        >
                          {f}
                        </span>
                      ))}
                    </div>
                  ) : (
                    <span className="text-green-600">✓ None</span>
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
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, [activeIdx, swipeTo]);

  const product = products[activeIdx];
  const band = SCORE_BANDS[scoreBandFromScore(product.unhealthiness_score)];
  const nutriClass = product.nutri_score
    ? NUTRI_COLORS[product.nutri_score]
    : "bg-gray-200 text-gray-500";

  return (
    <div className="md:hidden">
      {/* Sticky header with product names */}
      <div className="sticky top-14 z-30 bg-white border-b border-gray-200 px-4 py-2">
        <div className="flex items-center justify-center gap-2">
          {products.map((p, i) => (
            <button
              key={p.product_id}
              onClick={() => setActiveIdx(i)}
              className={`rounded-full px-3 py-1 text-xs font-medium transition-colors ${
                i === activeIdx
                  ? "bg-brand-600 text-white"
                  : "bg-gray-100 text-gray-600"
              }`}
            >
              {i === winnerIdx && "🏆 "}
              {p.product_name.length > 12
                ? p.product_name.slice(0, 12) + "…"
                : p.product_name}
            </button>
          ))}
        </div>
        {/* Dots indicator */}
        <div className="mt-1 flex justify-center gap-1">
          {products.map((_, i) => (
            <span
              key={i}
              className={`h-1.5 w-1.5 rounded-full transition-colors ${
                i === activeIdx ? "bg-brand-600" : "bg-gray-300"
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
              <p className="font-bold text-gray-900">{product.product_name}</p>
              <p className="text-sm text-gray-500">{product.brand}</p>
              <div className="mt-1 flex items-center gap-1.5">
                <span
                  className={`rounded-full px-1.5 py-0.5 text-xs font-bold ${nutriClass}`}
                >
                  {product.nutri_score ?? "?"}
                </span>
                <span className="rounded-full bg-gray-100 px-1.5 py-0.5 text-xs text-gray-600">
                  NOVA {product.nova_group ?? "?"}
                </span>
                {activeIdx === winnerIdx && (
                  <span className="rounded-full bg-green-100 px-1.5 py-0.5 text-xs font-bold text-green-700">
                    🏆 Best
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
                : rawValue != null
                  ? String(rawValue)
                  : "—";

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
                  <span className="text-sm text-gray-500">{row.label}</span>
                  <span className={`text-sm ${indicator || "text-gray-900"}`}>
                    {formatted}
                    {ranking && activeIdx === ranking.bestIdx && " ✓"}
                    {ranking && activeIdx === ranking.worstIdx && " ✗"}
                  </span>
                </div>
              );
            })}
          </div>

          {/* Allergens */}
          <div className="pt-2 border-t border-gray-100">
            <p className="text-xs font-medium text-gray-400 uppercase mb-1">
              Allergens
            </p>
            <p className="text-sm text-gray-700">
              {product.allergen_tags
                ? product.allergen_tags
                    .split(", ")
                    .map((t) => t.replace("en:", ""))
                    .join(", ")
                : "None declared"}
            </p>
          </div>

          {/* Flags */}
          <div>
            <p className="text-xs font-medium text-gray-400 uppercase mb-1">
              Warnings
            </p>
            <div className="flex flex-wrap gap-1">
              {product.high_salt && (
                <span className="rounded bg-orange-50 px-2 py-0.5 text-xs text-orange-600">
                  🧂 High Salt
                </span>
              )}
              {product.high_sugar && (
                <span className="rounded bg-orange-50 px-2 py-0.5 text-xs text-orange-600">
                  🍬 High Sugar
                </span>
              )}
              {product.high_sat_fat && (
                <span className="rounded bg-orange-50 px-2 py-0.5 text-xs text-orange-600">
                  🧈 High Sat Fat
                </span>
              )}
              {product.high_additive_load && (
                <span className="rounded bg-orange-50 px-2 py-0.5 text-xs text-orange-600">
                  ⚗️ Additives
                </span>
              )}
              {!product.high_salt &&
                !product.high_sugar &&
                !product.high_sat_fat &&
                !product.high_additive_load && (
                  <span className="text-sm text-green-600">✓ No warnings</span>
                )}
            </div>
          </div>
        </div>

        {/* Swipe hint */}
        <p className="mt-3 text-center text-xs text-gray-400">
          ← Swipe to compare · {activeIdx + 1} of {products.length} →
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
  if (products.length < 2) {
    return (
      <div className="py-12 text-center">
        <p className="mb-2 text-4xl">⚖️</p>
        <p className="text-sm text-gray-500">
          Select at least 2 products to compare
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
