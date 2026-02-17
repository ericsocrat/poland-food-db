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
    <div className="flex items-center gap-3">
      {/* Vertical bar segments */}
      <div className="flex flex-col gap-0.5" aria-hidden="true">
        {NOVA_GROUPS.map((ng) => (
          <div
            key={ng.group}
            className={`h-3 w-6 rounded-sm transition-opacity ${
              ng.group === novaGroup ? ng.color : "bg-surface-muted"
            } ${ng.group === novaGroup ? "opacity-100" : "opacity-40"}`}
          />
        ))}
      </div>
      {/* Label */}
      <div className="text-sm">
        <p
          className="font-semibold text-foreground"
          aria-label={`NOVA Group ${novaGroup}`}
        >
          NOVA {novaGroup}
        </p>
        <p className="text-xs text-foreground-secondary">
          {t(
            `product.${NOVA_GROUPS.find((ng) => ng.group === novaGroup)?.label ?? "novaGroup4"}`,
          )}
        </p>
      </div>
    </div>
  );
}
