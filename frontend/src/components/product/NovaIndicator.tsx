// ─── NOVA Processing Indicator ──────────────────────────────────────────────
// Vertical spectrum bar visualising the NOVA food processing classification.
// NOVA groups: 1 (unprocessed) → 4 (ultra-processed).
//
// The active group is highlighted with colour, the rest are muted.
// This visual metaphor communicates processing level more intuitively
// than a bare number.

import { useTranslation } from "@/lib/i18n";

const NOVA_GROUPS = [
  { group: "1", color: "bg-green-500", label: "novaGroup1" },
  { group: "2", color: "bg-lime-500", label: "novaGroup2" },
  { group: "3", color: "bg-amber-500", label: "novaGroup3" },
  { group: "4", color: "bg-red-500", label: "novaGroup4" },
] as const;

interface NovaIndicatorProps {
  /** NOVA group as a string: "1" | "2" | "3" | "4" */
  readonly novaGroup: string;
}

export function NovaIndicator({ novaGroup }: NovaIndicatorProps) {
  const { t } = useTranslation();

  return (
    <figure
      className="flex items-center gap-3"
      aria-label={`NOVA Group ${novaGroup}: ${NOVA_GROUPS.find((ng) => ng.group === novaGroup)?.label ?? "novaGroup4"}`}
    >
      {/* Vertical bar segments — all 4 groups always visible with their colours */}
      <div className="flex flex-col gap-0.5">
        {NOVA_GROUPS.map((ng) => {
          const isActive = ng.group === novaGroup;
          return (
            <div
              key={ng.group}
              className={`h-4 w-7 rounded-sm transition-all ${ng.color} ${
                isActive
                  ? "opacity-100 ring-2 ring-foreground/20"
                  : "opacity-25"
              }`}
            />
          );
        })}
      </div>
      {/* Label */}
      <div className="text-sm">
        <p className="font-semibold text-foreground">NOVA {novaGroup}</p>
        <p className="text-xs text-foreground-secondary">
          {t(
            `product.${NOVA_GROUPS.find((ng) => ng.group === novaGroup)?.label ?? "novaGroup4"}`,
          )}
        </p>
      </div>
    </figure>
  );
}
