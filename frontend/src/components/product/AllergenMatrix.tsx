"use client";

// ─── AllergenMatrix ─────────────────────────────────────────────────────────
// Structured allergen display: grouped by status (contains / traces / free),
// EU FIC Regulation 1169/2011-aligned grid with color-coded badges.

import { useTranslation } from "@/lib/i18n";
import { AlertTriangle, Check, Minus } from "lucide-react";
import type { ProfileAllergens } from "@/lib/types";

/**
 * EU FIC Regulation 1169/2011 mandates declaration of these 14 allergens.
 * Tags may appear with or without "en:" prefix in the data.
 */
const EU_14_ALLERGENS = [
  "gluten",
  "crustaceans",
  "eggs",
  "fish",
  "peanuts",
  "soybeans",
  "milk",
  "nuts",
  "celery",
  "mustard",
  "sesame-seeds",
  "sulphur-dioxide",
  "lupin",
  "molluscs",
] as const;

/** Normalise an allergen tag: strip "en:" prefix, trim, lowercase */
function normaliseTag(tag: string): string {
  return tag.trim().replace(/^en:/, "").toLowerCase();
}

type AllergenStatus = "contains" | "traces" | "free";

interface AllergenRow {
  name: string;
  status: AllergenStatus;
}

function parseAllergens(allergens: ProfileAllergens): AllergenRow[] {
  const containsSet = new Set(
    allergens.contains.split(",").filter(Boolean).map(normaliseTag),
  );
  const tracesSet = new Set(
    allergens.traces.split(",").filter(Boolean).map(normaliseTag),
  );

  // Collect all mentioned allergens + EU14 baseline
  const allNames = new Set<string>([
    ...EU_14_ALLERGENS,
    ...containsSet,
    ...tracesSet,
  ]);

  const rows: AllergenRow[] = [];
  for (const name of allNames) {
    if (containsSet.has(name)) {
      rows.push({ name, status: "contains" });
    } else if (tracesSet.has(name)) {
      rows.push({ name, status: "traces" });
    } else {
      rows.push({ name, status: "free" });
    }
  }

  // Sort: contains first, then traces, then free
  const statusOrder: Record<AllergenStatus, number> = {
    contains: 0,
    traces: 1,
    free: 2,
  };
  rows.sort((a, b) => statusOrder[a.status] - statusOrder[b.status]);

  return rows;
}

const STATUS_CONFIG: Record<
  AllergenStatus,
  { bg: string; border: string; text: string; label: string }
> = {
  contains: {
    bg: "bg-red-50",
    border: "border-red-200",
    text: "text-red-700",
    label: "allergenMatrix.contains",
  },
  traces: {
    bg: "bg-amber-50",
    border: "border-amber-200",
    text: "text-amber-700",
    label: "allergenMatrix.traces",
  },
  free: {
    bg: "bg-green-50",
    border: "border-green-200",
    text: "text-green-700",
    label: "allergenMatrix.free",
  },
};

function StatusIcon({ status }: Readonly<{ status: AllergenStatus }>) {
  switch (status) {
    case "contains":
      return (
        <AlertTriangle size={12} className="text-red-600" aria-hidden="true" />
      );
    case "traces":
      return <Minus size={12} className="text-amber-600" aria-hidden="true" />;
    case "free":
      return <Check size={12} className="text-green-600" aria-hidden="true" />;
  }
}

/** Pretty-print allergen name: "sesame-seeds" → "Sesame Seeds" */
function formatAllergenName(name: string): string {
  return name
    .split("-")
    .map((w) => w.charAt(0).toUpperCase() + w.slice(1))
    .join(" ");
}

interface AllergenMatrixProps {
  readonly allergens: ProfileAllergens;
}

export function AllergenMatrix({ allergens }: AllergenMatrixProps) {
  const { t } = useTranslation();
  const rows = parseAllergens(allergens);
  const hasAny = allergens.contains_count > 0 || allergens.traces_count > 0;

  if (!hasAny) {
    return (
      <p className="flex items-center gap-1 text-sm text-green-600">
        <Check size={14} aria-hidden="true" /> {t("product.noKnownAllergens")}
      </p>
    );
  }

  return (
    <div className="space-y-3">
      {/* Compact grid */}
      <table
        className="w-full border-separate border-spacing-1.5"
        aria-label={t("allergenMatrix.title")}
      >
        <tbody>
          {rows.map((row) => {
            const cfg = STATUS_CONFIG[row.status];
            return (
              <tr key={row.name}>
                <td
                  className={`flex items-center gap-1.5 rounded-lg border px-2.5 py-1.5 ${cfg.bg} ${cfg.border}`}
                >
                  <StatusIcon status={row.status} />
                  <span className={`text-xs font-medium ${cfg.text}`}>
                    {formatAllergenName(row.name)}
                  </span>
                </td>
              </tr>
            );
          })}
        </tbody>
      </table>

      {/* Legend */}
      <div className="flex flex-wrap gap-3 text-[10px] text-foreground-muted">
        <span className="flex items-center gap-1">
          <AlertTriangle
            size={10}
            className="text-red-500"
            aria-hidden="true"
          />{" "}
          {t("allergenMatrix.contains")}
        </span>
        <span className="flex items-center gap-1">
          <Minus size={10} className="text-amber-500" aria-hidden="true" />{" "}
          {t("allergenMatrix.traces")}
        </span>
        <span className="flex items-center gap-1">
          <Check size={10} className="text-green-500" aria-hidden="true" />{" "}
          {t("allergenMatrix.free")}
        </span>
      </div>

      {/* Disclaimer */}
      <p className="text-[10px] leading-relaxed text-foreground-muted">
        {t("allergenMatrix.disclaimer")}
      </p>
    </div>
  );
}
