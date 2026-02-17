import type { Metadata, Viewport } from "next";
import { SpeedInsights } from "@vercel/speed-insights/next";
import { Providers } from "@/components/Providers";
import { ThemeScript } from "@/components/ThemeScript";
import "@/styles/globals.css";

export const viewport: Viewport = {
  themeColor: "#16a34a",
  width: "device-width",
  initialScale: 1,
  maximumScale: 1,
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
    icon: [{ url: "/icons/icon-192.svg", type: "image/svg+xml", sizes: "any" }],
    apple: [
      { url: "/icons/icon-192.svg", type: "image/svg+xml", sizes: "192x192" },
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
    card: "summary",
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
    <html lang="en" suppressHydrationWarning>
      <head>
        <ThemeScript />
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
        />
      </head>
      <body>
        <Providers>{children}</Providers>
        <SpeedInsights />
      </body>
    </html>
  );
}
