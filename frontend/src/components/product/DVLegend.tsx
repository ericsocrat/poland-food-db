import { useTranslation } from "@/lib/i18n";

export function DVLegend() {
  const { t } = useTranslation();

  return (
    <div className="mt-2 flex items-center gap-3 text-xs text-gray-500">
      <span className="flex items-center gap-1">
        <span className="inline-block h-2 w-2 rounded-full bg-green-500" />
        {t("product.dvLow")}
      </span>
      <span className="flex items-center gap-1">
        <span className="inline-block h-2 w-2 rounded-full bg-amber-500" />
        {t("product.dvModerate")}
      </span>
      <span className="flex items-center gap-1">
        <span className="inline-block h-2 w-2 rounded-full bg-red-500" />
        {t("product.dvHigh")}
      </span>
    </div>
  );
}
