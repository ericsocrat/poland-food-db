// ─── Global error boundary ────────────────────────────────────────────────
// Catches errors in the root layout itself.
// Must include its own <html> and <body> tags.

"use client";

export default function GlobalError({
  error: _error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  return (
    <html lang="en">
      <body>
        <div
          style={{
            display: "flex",
            minHeight: "100vh",
            flexDirection: "column",
            alignItems: "center",
            justifyContent: "center",
            padding: "1rem",
            fontFamily: "system-ui, sans-serif",
          }}
        >
          <h1
            style={{
              fontSize: "1.5rem",
              fontWeight: 700,
              marginBottom: "0.5rem",
            }}
          >
            Something went wrong
          </h1>
          <p style={{ color: "#6b7280", marginBottom: "1.5rem" }}>
            A critical error occurred. Please try again.
          </p>
          <button
            onClick={reset}
            style={{
              padding: "0.75rem 1.5rem",
              backgroundColor: "#16a34a",
              color: "white",
              border: "none",
              borderRadius: "0.5rem",
              cursor: "pointer",
              fontSize: "1rem",
              fontWeight: 500,
            }}
          >
            Try again
          </button>
        </div>
      </body>
    </html>
  );
}
