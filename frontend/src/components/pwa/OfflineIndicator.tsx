"use client";

import { useEffect, useState } from "react";
import { WifiOff } from "lucide-react";
import { useTranslation } from "@/lib/i18n";

export function OfflineIndicator() {
  const { t } = useTranslation();
  const [isOffline, setIsOffline] = useState(false);

  useEffect(() => {
    setIsOffline(!navigator.onLine);

    const handleOffline = () => setIsOffline(true);
    const handleOnline = () => setIsOffline(false);

    globalThis.addEventListener("offline", handleOffline);
    globalThis.addEventListener("online", handleOnline);

    return () => {
      globalThis.removeEventListener("offline", handleOffline);
      globalThis.removeEventListener("online", handleOnline);
    };
  }, []);

  if (!isOffline) return null;

  return (
    <output
      aria-live="polite"
      className="fixed left-0 right-0 top-0 z-50 bg-amber-500 px-4 py-1.5 text-center text-xs font-medium text-white"
    >
      <WifiOff size={14} aria-hidden="true" className="inline" />{" "}
      {t("pwa.offline")}
    </output>
  );
}
