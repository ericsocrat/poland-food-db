"use client";

import { useTranslation } from "@/lib/i18n";

export function AppName() {
  const { t } = useTranslation();
  return <>{t("layout.appNameWithEmoji")}</>;
}
