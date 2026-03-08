"use client";

import { Button } from "@/components/common/Button";
import { ErrorIllustration } from "@/components/common/ErrorIllustration";
import { useTranslation } from "@/lib/i18n";

export default function OfflinePage() {
  const { t } = useTranslation();
  return (
    <div className="flex min-h-[60vh] flex-col items-center justify-center px-4 text-center">
      <ErrorIllustration type="offline" className="mb-2" />
      <h1 className="mt-4 text-xl font-bold text-foreground">
        {t("offline.title")}
      </h1>
      <p className="mt-2 max-w-sm text-sm text-foreground-secondary">
        {t("offline.offlinePage")}
      </p>
      <Button
        className="mt-6"
        onClick={() => globalThis.location.reload()}
      >
        {t("offline.tryAgain")}
      </Button>
    </div>
  );
}
