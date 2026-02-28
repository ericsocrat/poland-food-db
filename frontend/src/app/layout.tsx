import type { Metadata, Viewport } from "next";
import { SpeedInsights } from "@vercel/speed-insights/next";
import { Providers } from "@/components/Providers";
import { ThemeScript } from "@/components/ThemeScript";
import { IS_QA_MODE } from "@/lib/qa-mode";
import "@/styles/globals.css";

export const viewport: Viewport = {
  themeColor: "#0d7377",
  width: "device-width",
  initialScale: 1,
  viewportFit: "cover",
};

export const metadata: Metadata = {
  title: {
    default: "Poland Food DB — Multi-Axis Food Scoring",
    template: "%s | FoodDB",
  },
  description:
    "Multi-axis food quality scoring — find healthier alternatives in Poland and Germany.",
  manifest: "/manifest.webmanifest",
  appleWebApp: {
    capable: true,
    statusBarStyle: "black-translucent",
    title: "FoodDB",
  },
  icons: {
    icon: [
      { url: "/favicon.ico", sizes: "48x48" },
      { url: "/favicon.svg", type: "image/svg+xml", sizes: "any" },
      { url: "/favicon-16x16.png", type: "image/png", sizes: "16x16" },
      { url: "/favicon-32x32.png", type: "image/png", sizes: "32x32" },
      { url: "/icons/icon-192.png", type: "image/png", sizes: "192x192" },
      { url: "/icons/icon-512.png", type: "image/png", sizes: "512x512" },
    ],
    apple: [
      {
        url: "/apple-touch-icon.png",
        type: "image/png",
        sizes: "180x180",
      },
    ],
  },
  openGraph: {
    type: "website",
    siteName: "Poland Food DB",
    locale: "en_US",
    title: "Poland Food DB — Multi-Axis Food Scoring",
    description:
      "Compare health scores and nutritional data for food products in Poland and Germany.",
    url: "https://poland-food-db.vercel.app",
  },
  twitter: {
    card: "summary_large_image",
    title: "Poland Food DB",
    description:
      "Compare health scores and nutritional data for food products in Poland and Germany.",
  },
  robots: {
    index: true,
    follow: true,
  },
  metadataBase: new URL(
    process.env.NEXT_PUBLIC_APP_URL ?? "https://poland-food-db.vercel.app",
  ),
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  const jsonLd = {
    "@context": "https://schema.org",
    "@type": "WebApplication",
    name: "Poland Food DB",
    alternateName: "FoodDB",
    url: "https://poland-food-db.vercel.app",
    description:
      "Multi-axis food quality scoring — compare health scores and nutritional data for food products in Poland and Germany.",
    applicationCategory: "HealthApplication",
    operatingSystem: "Any",
    browserRequirements: "Requires a modern web browser",
    offers: {
      "@type": "Offer",
      price: "0",
      priceCurrency: "PLN",
    },
  };

  return (
    <html lang="en" suppressHydrationWarning {...(IS_QA_MODE ? { "data-qa-mode": "true" } : {})}>
      <head>
        <ThemeScript />
        {IS_QA_MODE && (
          <style
            dangerouslySetInnerHTML={{
              __html: "*, *::before, *::after { transition: none !important; animation: none !important; }",
            }}
          />
        )}
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
        />
      </head>
      <body>
        <Providers>{children}</Providers>
        {!IS_QA_MODE && <SpeedInsights />}
      </body>
    </html>
  );
}
