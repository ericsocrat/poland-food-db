"use client";

// ─── LiveRegion — announce dynamic content to screen readers ────────────────
// Renders an invisible aria-live region. When `message` changes, screen
// readers will announce the new text. Use `politeness` to control urgency:
//   - "polite"    → wait for current speech to finish (default)
//   - "assertive" → interrupt current speech immediately

interface LiveRegionProps {
  /** The text to announce. Changes trigger a screen-reader announcement. */
  message: string;
  /** aria-live politeness level (default: "polite"). */
  politeness?: "polite" | "assertive";
}

export function LiveRegion({
  message,
  politeness = "polite",
}: Readonly<LiveRegionProps>) {
  return (
    <output aria-live={politeness} aria-atomic="true" className="sr-only">
      {message}
    </output>
  );
}
