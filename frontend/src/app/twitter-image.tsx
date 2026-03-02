// ─── Twitter / X Card image ─────────────────────────────────────────────────
// Generates a 1200×600 PNG for Twitter summary_large_image cards.
// Consistent with opengraph-image.tsx but letterboxed for Twitter's aspect ratio.

import { ImageResponse } from "next/og";

export const runtime = "nodejs";
export const alt = "TryVit — Scan. Score. Choose better.";
export const size = { width: 1200, height: 600 };
export const contentType = "image/png";
export const revalidate = 86400; // 24 h edge cache

/* ---------- font loader ---------- */
let interBoldPromise: Promise<ArrayBuffer> | null = null;
function getInterBoldFont(): Promise<ArrayBuffer> {
  interBoldPromise ??= fetch(
    "https://fonts.gstatic.com/s/inter/v18/UcCO3FwrK3iLTeHuS_nVMrMxCp50SjIw2boKoduKmMEVuFuYMZhrib2Bg-4.ttf",
  ).then((r) => r.arrayBuffer());
  return interBoldPromise;
}

export default async function TwitterImage() {
  const interBold = await getInterBoldFont();

  return new ImageResponse(
    <div
      style={{
        width: "100%",
        height: "100%",
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        justifyContent: "center",
        backgroundColor: "#0A2E1A", // vitDark
        padding: "60px 80px",
        position: "relative",
      }}
    >
      {/* Subtle green radial glow */}
      <div
        style={{
          position: "absolute",
          top: "-100px",
          right: "-80px",
          width: "480px",
          height: "480px",
          borderRadius: "50%",
          background:
            "radial-gradient(circle, rgba(29,185,84,0.18) 0%, transparent 70%)",
        }}
      />

      {/* Wordmark: Try + Vit */}
      <div
        style={{
          display: "flex",
          alignItems: "baseline",
          marginBottom: "20px",
        }}
      >
        <span
          style={{
            fontFamily: "Inter",
            fontWeight: 800,
            fontSize: "72px",
            color: "#F0FAF4", // vitLight
            letterSpacing: "-0.03em",
            lineHeight: 1,
          }}
        >
          Try
        </span>
        <span
          style={{
            fontFamily: "Inter",
            fontWeight: 800,
            fontSize: "72px",
            color: "#1DB954", // vitGreen
            letterSpacing: "-0.03em",
            lineHeight: 1,
          }}
        >
          Vit
        </span>
      </div>

      {/* Tagline */}
      <div
        style={{
          fontFamily: "Inter",
          fontWeight: 600,
          fontSize: "28px",
          color: "#9DCFB0",
          letterSpacing: "0.02em",
          textAlign: "center",
        }}
      >
        Scan. Score. Choose better.
      </div>

      {/* Score badge row */}
      <div
        style={{
          display: "flex",
          gap: "16px",
          marginTop: "36px",
        }}
      >
        {[
          { score: "12", label: "Healthy" },
          { score: "48", label: "Moderate" },
          { score: "81", label: "Harmful" },
        ].map(({ score, label }) => {
          const bg =
            label === "Healthy"
              ? "#1DB954"
              : label === "Moderate"
                ? "#F59E0B"
                : "#EF4444";
          return (
            <div
              key={label}
              style={{
                display: "flex",
                flexDirection: "column",
                alignItems: "center",
                justifyContent: "center",
                backgroundColor: bg,
                borderRadius: "12px",
                width: "96px",
                height: "72px",
              }}
            >
              <span
                style={{
                  fontFamily: "Inter",
                  fontWeight: 800,
                  fontSize: "28px",
                  color: "#ffffff",
                  lineHeight: 1,
                }}
              >
                {score}
              </span>
              <span
                style={{
                  fontFamily: "Inter",
                  fontWeight: 600,
                  fontSize: "11px",
                  color: "rgba(255,255,255,0.85)",
                  letterSpacing: "0.06em",
                  textTransform: "uppercase",
                }}
              >
                {label}
              </span>
            </div>
          );
        })}
      </div>

      {/* Bottom domain */}
      <div
        style={{
          position: "absolute",
          bottom: "28px",
          right: "48px",
          fontFamily: "Inter",
          fontWeight: 600,
          fontSize: "16px",
          color: "rgba(157, 207, 176, 0.6)",
          letterSpacing: "0.04em",
        }}
      >
        tryvit.vercel.app
      </div>
    </div>,
    {
      ...size,
      fonts: [
        {
          name: "Inter",
          data: interBold,
          style: "normal",
          weight: 800,
        },
      ],
    },
  );
}
