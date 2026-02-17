// ─── CountryChip: shows the backend-resolved country ────────────────────────
// Reflects reality from API responses, not local state.

import { COUNTRIES } from "@/lib/constants";

interface CountryChipProps {
  country: string | null;
  className?: string;
}

export function CountryChip({
  country,
  className = "",
}: Readonly<CountryChipProps>) {
  if (!country) return null;

  const meta = COUNTRIES.find((c) => c.code === country);
  const flag = meta?.flag ?? "🌍";
  const name = meta?.name ?? country;

  return (
    <span
      className={`inline-flex items-center gap-1.5 rounded-full border border bg-surface-subtle px-3 py-1 text-sm font-medium text-foreground-secondary ${className}`}
    >
      <span>{flag}</span>
      <span>{name}</span>
    </span>
  );
}
