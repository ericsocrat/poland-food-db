import { useTranslation } from "@/lib/i18n";

interface DVReferenceBadgeProps {
  readonly referenceType: "standard" | "personalized" | "none";
  readonly regulation?: string;
}

export function DVReferenceBadge({
  referenceType,
  regulation,
}: DVReferenceBadgeProps) {
  const { t } = useTranslation();

  if (referenceType === "none") return null;

  const isPersonalized = referenceType === "personalized";
  const label = isPersonalized
    ? t("product.dvPersonalized")
    : t("product.dvStandard", { regulation: regulation ?? "EU RI" });

  return (
    <span
      className={`inline-flex items-center gap-1 rounded-full px-2 py-0.5 text-xs font-medium ${
        isPersonalized
          ? "bg-blue-100 text-blue-700"
          : "bg-surface-muted text-foreground-secondary"
      }`}
    >
      {isPersonalized ? "👤" : "📊"} {label}
    </span>
  );
}
