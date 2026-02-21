// ─── Dynamic OpenGraph image for product share cards ──────────────────────────
// Generates a 1200×630 PNG with product name, score ring, hero image, and
// warnings.  Edge-cached for 1 hour.  Uses Next.js  ImageResponse (Satori).

import { ImageResponse } from "next/og";

/* ---------- route configuration ---------- */
export const runtime = "nodejs";
export const alt = "Product health score card";
export const size = { width: 1200, height: 630 };
export const contentType = "image/png";
export const revalidate = 3600; // 1 hour edge cache

/* ---------- helpers ---------- */

/** OG-specific score colour (not Tailwind — raw hex for Satori). */
export function getScoreColor(score: number): string {
  if (score <= 20) return "#22c55e"; // green
  if (score <= 40) return "#eab308"; // yellow
  if (score <= 60) return "#f97316"; // orange
  if (score <= 80) return "#ef4444"; // red
  return "#991b1b"; // dark red
}

/** Human-readable band label for the OG card. */
export function getScoreBandLabel(band: string): string {
  switch (band) {
    case "low":
      return "Low Risk";
    case "moderate":
      return "Moderate Risk";
    case "high":
      return "High Risk";
    case "very_high":
      return "Very High Risk";
    default:
      return "";
  }
}

/** Truncate a string to `max` characters with an ellipsis. */
export function truncate(text: string, max: number): string {
  if (text.length <= max) return text;
  return text.slice(0, max - 1) + "…";
}

/* ---------- font loader ---------- */
// Inter Bold 700 from Google Fonts CDN — fetched once & cached by the edge.
let interBoldPromise: Promise<ArrayBuffer> | null = null;
function getInterBoldFont(): Promise<ArrayBuffer> {
  interBoldPromise ??= fetch(
    "https://fonts.gstatic.com/s/inter/v18/UcCO3FwrK3iLTeHuS_nVMrMxCp50SjIw2boKoduKmMEVuFuYAZ9hiA.ttf",
  ).then((r) => r.arrayBuffer());
  return interBoldPromise;
}

/* ---------- fallback card ---------- */
function FallbackCard() {
  return (
    <div
      style={{
        width: "100%",
        height: "100%",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        backgroundColor: "#f9fafb",
        fontFamily: "Inter",
      }}
    >
      <div
        style={{
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
        }}
      >
        <div style={{ fontSize: 64, marginBottom: 16 }}>🍽️</div>
        <div style={{ fontSize: 32, fontWeight: 700, color: "#111827" }}>
          FoodDB
        </div>
        <div style={{ fontSize: 18, color: "#6b7280", marginTop: 8 }}>
          Product not found
        </div>
      </div>
    </div>
  );
}

/* ---------- main image handler ---------- */
export default async function OGImage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;
  const productId = Number.parseInt(id, 10);

  const fontData = await getInterBoldFont();

  /* ---- fetch product data (anon key — public read) ---- */
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  let profile: any;
  try {
    const res = await fetch(
      `${process.env.NEXT_PUBLIC_SUPABASE_URL}/rest/v1/rpc/api_get_product_profile`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          apikey: process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
          Authorization: `Bearer ${process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!}`,
        },
        body: JSON.stringify({ p_product_id: productId }),
        next: { revalidate: 3600 },
      },
    );
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    profile = await res.json();
  } catch {
    return new ImageResponse(<FallbackCard />, {
      ...size,
      fonts: [
        {
          name: "Inter",
          data: fontData,
          weight: 700,
          style: "normal" as const,
        },
      ],
    });
  }

  /* ---- extract fields ---- */
  const name = truncate(
    profile.product?.product_name_display ??
      profile.product?.product_name ??
      "Unknown",
    60,
  );
  const brand = truncate(profile.product?.brand ?? "", 40);
  const score: number = profile.scores?.unhealthiness_score ?? 0;
  const band: string = profile.scores?.score_band ?? "moderate";
  const scoreColor = getScoreColor(score);
  const bandLabel = getScoreBandLabel(band);

  const heroUrl: string | undefined = profile.images?.primary?.url;
  const categoryIcon: string = profile.product?.category_icon ?? "🍽️";

  const warnings: { type: string; message: string }[] = (
    profile.warnings ?? []
  ).slice(0, 2);

  /* ---- render card ---- */
  return new ImageResponse(
    <div
      style={{
        width: "100%",
        height: "100%",
        display: "flex",
        flexDirection: "column",
        backgroundColor: "#ffffff",
        fontFamily: "Inter",
        padding: 48,
      }}
    >
      {/* ---- main content ---- */}
      <div style={{ display: "flex", flex: 1, gap: 48 }}>
        {/* Left — hero image */}
        <div
          style={{
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            width: 280,
            height: 280,
            borderRadius: 24,
            backgroundColor: "#f3f4f6",
            overflow: "hidden",
            flexShrink: 0,
          }}
        >
          {heroUrl ? (
            // eslint-disable-next-line @next/next/no-img-element
            <img
              src={heroUrl}
              alt=""
              width={260}
              height={260}
              style={{ objectFit: "contain" }}
            />
          ) : (
            <div style={{ fontSize: 96 }}>{categoryIcon}</div>
          )}
        </div>

        {/* Right — product info */}
        <div
          style={{
            display: "flex",
            flexDirection: "column",
            justifyContent: "center",
            flex: 1,
          }}
        >
          <div
            style={{
              fontSize: 36,
              fontWeight: 700,
              color: "#111827",
              lineHeight: 1.2,
              marginBottom: 8,
            }}
          >
            {name}
          </div>

          {brand && (
            <div style={{ fontSize: 22, color: "#6b7280", marginBottom: 24 }}>
              {brand}
            </div>
          )}

          {/* Score ring + band */}
          <div style={{ display: "flex", alignItems: "center", gap: 20 }}>
            <div
              style={{
                width: 100,
                height: 100,
                borderRadius: "50%",
                backgroundColor: scoreColor,
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                color: "#ffffff",
                fontSize: 42,
                fontWeight: 700,
              }}
            >
              {score}
            </div>

            <div style={{ display: "flex", flexDirection: "column" }}>
              <div
                style={{
                  fontSize: 14,
                  color: "#9ca3af",
                  textTransform: "uppercase" as const,
                  letterSpacing: "0.05em",
                }}
              >
                /100
              </div>
              <div style={{ fontSize: 24, fontWeight: 700, color: scoreColor }}>
                {bandLabel}
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* ---- bottom — warnings + branding ---- */}
      <div
        style={{
          display: "flex",
          justifyContent: "space-between",
          alignItems: "flex-end",
          marginTop: 24,
        }}
      >
        {warnings.length > 0 ? (
          <div style={{ display: "flex", gap: 16 }}>
            {warnings.map((w: { type: string; message: string }) => (
              <div
                key={w.type}
                style={{
                  display: "flex",
                  alignItems: "center",
                  gap: 6,
                  fontSize: 16,
                  color: "#dc2626",
                }}
              >
                ⚠ {truncate(w.message, 40)}
              </div>
            ))}
          </div>
        ) : (
          <div />
        )}

        <div
          style={{
            display: "flex",
            alignItems: "center",
            gap: 8,
            fontSize: 18,
            color: "#9ca3af",
          }}
        >
          FoodDB — Know What You Eat
        </div>
      </div>
    </div>,
    {
      ...size,
      fonts: [
        {
          name: "Inter",
          data: fontData,
          weight: 700,
          style: "normal" as const,
        },
      ],
    },
  );
}
