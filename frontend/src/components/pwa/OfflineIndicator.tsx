"use client";

import { useEffect, useState } from "react";
import { useTranslation } from "@/lib/i18n";

export function OfflineIndicator() {
  const { t } = useTranslation();
  const [isOffline, setIsOffline] = useState(false);

  useEffect(() => {
    setIsOffline(!navigator.onLine);

    const handleOffline = () => setIsOffline(true);
    const handleOnline = () => setIsOffline(false);

    window.addEventListener("offline", handleOffline);
    window.addEventListener("online", handleOnline);

    return () => {
      window.removeEventListener("offline", handleOffline);
      window.removeEventListener("online", handleOnline);
    };
  }, []);

  if (!isOffline) return null;

  return (
    <div
      role="status"
      aria-live="polite"
      className="fixed left-0 right-0 top-0 z-50 bg-amber-500 px-4 py-1.5 text-center text-xs font-medium text-white"
    >
      📡 {t("pwa.offline")}
    </div>
  );
}
