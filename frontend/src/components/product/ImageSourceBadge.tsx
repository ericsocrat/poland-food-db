// ─── ImageSourceBadge ────────────────────────────────────────────────────────
// Small badge overlaid on product images to indicate the image source.
// Shows "Open Food Facts" for OFF images.

import { Camera } from "lucide-react";

interface ImageSourceBadgeProps {
  readonly source: "off_api" | "manual";
}

const sourceLabels: Record<string, string> = {
  off_api: "Open Food Facts",
  manual: "Manual",
};

export function ImageSourceBadge({ source }: ImageSourceBadgeProps) {
  const label = sourceLabels[source] ?? source;

  return (
    <span className="absolute bottom-2 right-2 inline-flex items-center gap-1 rounded bg-black/60 px-1.5 py-0.5 text-[10px] font-medium text-white/80">
      <Camera size={12} aria-hidden="true" /> {label}
    </span>
  );
}
