// ─── Inline script to prevent FOUC (Flash of Unstyled Content) ──────────────
// Injected into <head> before React hydrates. Reads the user's theme preference
// from localStorage and applies `data-theme` to <html> immediately.
//
// Why inline? The script must run before the first paint. If we waited for
// React hydration, users would see a flash of light mode before dark applied.

export function ThemeScript() {
  const script = `
(function() {
  try {
    var theme = localStorage.getItem('theme') || 'system';
    var resolved = theme;
    if (theme === 'system') {
      resolved = window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
    }
    document.documentElement.setAttribute('data-theme', resolved);
  } catch (e) {}
})();
`;

  return (
    <script
      dangerouslySetInnerHTML={{ __html: script }}
      suppressHydrationWarning
    />
  );
}
