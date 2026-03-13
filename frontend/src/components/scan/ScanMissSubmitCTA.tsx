"use client";

import { ButtonLink } from "@/components/common/Button";
import { useTranslation } from "@/lib/i18n";
import { Clock, FileText } from "lucide-react";

interface ScanMissSubmitCTAProps {
  ean: string;
  hasPendingSubmission?: boolean;
}

/** CTA shown when a scanned barcode is not found in the database. */
export function ScanMissSubmitCTA({
  ean,
  hasPendingSubmission = false,
}: ScanMissSubmitCTAProps) {
  const { t } = useTranslation();

  if (hasPendingSubmission) {
    return (
      <div className="card border-warning-border bg-warning-bg">
        <p className="text-sm text-warning-text">
          <span className="inline-flex items-center gap-1">
            <Clock size={16} aria-hidden="true" />{" "}
            {t("scan.alreadySubmitted")}
          </span>
        </p>
      </div>
    );
  }

  return (
    <div className="space-y-2">
      <ButtonLink
        href={`/app/scan/submit?ean=${ean}`}
        fullWidth
        icon={<FileText size={16} aria-hidden="true" />}
      >
        {t("scan.helpAdd")}
      </ButtonLink>
      <p className="text-center text-xs text-foreground-muted">
        {t("scan.helpAddHint")}
      </p>
    </div>
  );
}
