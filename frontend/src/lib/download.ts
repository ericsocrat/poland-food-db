/**
 * downloadJson — trigger a browser download of a JSON payload.
 *
 * Creates an invisible anchor, assigns an object URL, clicks it,
 * then revokes the URL to free memory.
 */
export function downloadJson(
  data: unknown,
  filename: string,
): { size: number } {
  const json = JSON.stringify(data, null, 2);
  const blob = new Blob([json], { type: "application/json" });
  const url = URL.createObjectURL(blob);

  const a = document.createElement("a");
  a.href = url;
  a.download = sanitizeFilename(filename);
  a.style.display = "none";
  document.body.appendChild(a);
  a.click();

  // Cleanup
  a.remove();
  URL.revokeObjectURL(url);

  return { size: blob.size };
}

/**
 * Sanitise a filename — remove path-traversal chars and shell-dangerous chars.
 * Keeps alphanumeric, hyphens, underscores, dots, spaces.
 */
export function sanitizeFilename(name: string): string {
  return name.replace(/[^a-zA-Z0-9._\- ]/g, "_").slice(0, 200);
}

/* ── Rate limiting (localStorage) ──────────────────────────────────────────── */

const EXPORT_COOLDOWN_KEY = "gdpr-export-last-at";
const EXPORT_COOLDOWN_MS = 60 * 60 * 1000; // 1 hour

/**
 * Returns milliseconds remaining in the cooldown period, or 0 if ready.
 */
export function getExportCooldownRemaining(): number {
  try {
    const raw = localStorage.getItem(EXPORT_COOLDOWN_KEY);
    if (!raw) return 0;
    const elapsed = Date.now() - Number(raw);
    return Math.max(0, EXPORT_COOLDOWN_MS - elapsed);
  } catch {
    return 0;
  }
}

/** Mark the current time as last export. */
export function setExportTimestamp(): void {
  try {
    localStorage.setItem(EXPORT_COOLDOWN_KEY, String(Date.now()));
  } catch {
    /* storage full — ignore */
  }
}
