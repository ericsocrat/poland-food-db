// ─── CountryChip: inline country indicator with SVG micro-flag ──────────────
// Shows SVG flag + country code (or full name with showLabel).
// Reflects reality from API responses, not local state.

import { COUNTRIES } from "@/lib/constants";

// ─── Types ──────────────────────────────────────────────────────────────────

interface CountryChipProps {
  /** ISO 3166-1 alpha-2 country code. Null → render nothing. */
  country: string | null;
  /** Show full country name instead of 2-letter code. */
  showLabel?: boolean;
  /** Badge size variant. */
  size?: "sm" | "md";
  className?: string;
}

// ─── Inline SVG Flags ───────────────────────────────────────────────────────
// Simplified flag SVGs (<500 bytes each) for crisp rendering at small sizes.

function PolishFlag({ size }: Readonly<{ size: number }>) {
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 16 12"
      aria-hidden="true"
      className="shrink-0 rounded-[2px]"
    >
      <rect width="16" height="6" fill="#fff" />
      <rect y="6" width="16" height="6" fill="#DC143C" />
    </svg>
  );
}

function GermanFlag({ size }: Readonly<{ size: number }>) {
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 16 12"
      aria-hidden="true"
      className="shrink-0 rounded-[2px]"
    >
      <rect width="16" height="4" fill="#000" />
      <rect y="4" width="16" height="4" fill="#DD0000" />
      <rect y="8" width="16" height="4" fill="#FFCC00" />
    </svg>
  );
}

function FallbackFlag({ size }: Readonly<{ size: number }>) {
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 16 12"
      aria-hidden="true"
      className="shrink-0 rounded-[2px]"
    >
      <rect width="16" height="12" fill="#9CA3AF" rx="1" />
      <text
        x="8"
        y="8"
        textAnchor="middle"
        fontSize="6"
        fill="#fff"
        fontWeight="bold"
      >
        ?
      </text>
    </svg>
  );
}

const FLAG_COMPONENTS: Record<string, typeof PolishFlag> = {
  PL: PolishFlag,
  DE: GermanFlag,
};

// ─── Size config ────────────────────────────────────────────────────────────

const SIZE_CONFIG = {
  sm: { flag: 14, text: "text-xs", px: "px-1.5 py-0.5", gap: "gap-1" },
  md: { flag: 16, text: "text-sm", px: "px-2.5 py-1", gap: "gap-1.5" },
} as const;

// ─── Component ──────────────────────────────────────────────────────────────

export function CountryChip({
  country,
  showLabel = false,
  size = "md",
  className = "",
}: Readonly<CountryChipProps>) {
  if (!country) return null;

  const meta = COUNTRIES.find((c) => c.code === country);
  const name = meta?.name ?? country;
  const FlagIcon = FLAG_COMPONENTS[country] ?? FallbackFlag;
  const cfg = SIZE_CONFIG[size];
  const displayText = showLabel ? name : country;

  return (
    <span
      role="img"
      aria-label={`Product from ${name}`}
      className={`inline-flex items-center ${cfg.gap} rounded-full border border-border bg-surface-subtle ${cfg.px} ${cfg.text} font-medium text-foreground-secondary ${className}`}
    >
      <FlagIcon size={cfg.flag} />
      <span>{displayText}</span>
    </span>
  );
}
