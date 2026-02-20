// ─── Default OpenGraph image for the app ──────────────────────────────────
// Generates a 1200×630 PNG branding card for link previews on pages that
// don't have a page-specific OG image (home, search, categories, etc.).

import { ImageResponse } from "next/og";

export const runtime = "nodejs";
export const alt = "Poland Food DB — Multi-Axis Food Scoring";
export const size = { width: 1200, height: 630 };
export const contentType = "image/png";

export default function OGImage() {
  return new ImageResponse(
    <div
      style={{
        width: "100%",
        height: "100%",
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        justifyContent: "center",
        backgroundColor: "#f9fafb",
        fontFamily: "system-ui, sans-serif",
      }}
    >
      {/* Brand bar */}
      <div
        style={{
          position: "absolute",
          top: 0,
          left: 0,
          right: 0,
          height: 8,
          backgroundColor: "#16a34a",
        }}
      />

      {/* Icon */}
      <div
        style={{
          width: 120,
          height: 120,
          borderRadius: 24,
          backgroundColor: "#16a34a",
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          fontSize: 64,
          marginBottom: 32,
        }}
      >
        🍽️
      </div>

      {/* Title */}
      <div
        style={{
          fontSize: 56,
          fontWeight: 700,
          color: "#111827",
          marginBottom: 16,
        }}
      >
        Poland Food DB
      </div>

      {/* Tagline */}
      <div
        style={{
          fontSize: 24,
          color: "#6b7280",
          maxWidth: 700,
          textAlign: "center",
          lineHeight: 1.4,
        }}
      >
        Multi-axis food quality scoring — find healthier alternatives in Poland
        and Germany
      </div>

      {/* Feature pills */}
      <div
        style={{
          display: "flex",
          gap: 16,
          marginTop: 40,
        }}
      >
        {["Health Scores", "Nutrition Data", "Product Compare"].map((text) => (
          <div
            key={text}
            style={{
              padding: "10px 24px",
              borderRadius: 999,
              backgroundColor: "#dcfce7",
              color: "#166534",
              fontSize: 18,
              fontWeight: 600,
            }}
          >
            {text}
          </div>
        ))}
      </div>
    </div>,
    { ...size },
  );
}
