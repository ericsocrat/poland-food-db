import withSerwistInit from "@serwist/next";
import type { NextConfig } from "next";
import { IMAGE_POLICY_CSP_DIRECTIVES } from "./src/lib/image-policy/enforcement";

const withSerwist = withSerwistInit({
  swSrc: "src/app/sw.ts",
  swDest: "public/sw.js",
  disable: process.env.NODE_ENV === "development",
});

// ── Content Security Policy (#56) ───────────────────────────────────────────
// Prevents accidental image uploads and restricts network destinations.
// connect-src: Supabase + Tesseract CDN only
// worker-src:  Tesseract WASM workers
// form-action: self only (no external form submissions)
// img-src:     self + data URIs (display) + Open Food Facts CDN
const cspValue = [
  `default-src 'self'`,
  `script-src 'self' 'unsafe-eval' 'unsafe-inline'`,
  `style-src 'self' 'unsafe-inline'`,
  `img-src ${IMAGE_POLICY_CSP_DIRECTIVES.imgSrc}`,
  `connect-src ${IMAGE_POLICY_CSP_DIRECTIVES.connectSrc}`,
  `worker-src ${IMAGE_POLICY_CSP_DIRECTIVES.workerSrc}`,
  `form-action ${IMAGE_POLICY_CSP_DIRECTIVES.formAction}`,
  `frame-ancestors 'none'`,
].join("; ");

const nextConfig: NextConfig = {
  // Enable View Transitions API for smoother page navigations (#61)
  experimental: {
    viewTransition: true,
  },
  // Allow Open Food Facts product images
  images: {
    remotePatterns: [
      {
        protocol: "https",
        hostname: "images.openfoodfacts.org",
        pathname: "/images/products/**",
      },
    ],
  },
  // Security headers
  async headers() {
    return [
      {
        source: "/(.*)",
        headers: [
          { key: "X-Frame-Options", value: "DENY" },
          { key: "X-Content-Type-Options", value: "nosniff" },
          { key: "Referrer-Policy", value: "strict-origin-when-cross-origin" },
          {
            key: "Content-Security-Policy",
            value: cspValue,
          },
        ],
      },
      {
        // Camera permissions for barcode scanner
        source: "/app/scan",
        headers: [
          {
            key: "Permissions-Policy",
            value: "camera=(self)",
          },
        ],
      },
      // ── PWA asset caching ─────────────────────────────────────────────────
      {
        // Service worker must always be revalidated
        source: "/sw.js",
        headers: [
          {
            key: "Cache-Control",
            value: "no-cache, no-store, must-revalidate",
          },
        ],
      },
      {
        // Manifest — revalidate daily
        source: "/manifest.webmanifest",
        headers: [
          {
            key: "Cache-Control",
            value: "public, max-age=86400, stale-while-revalidate=86400",
          },
        ],
      },
      {
        // Icons — long cache (content-addressed by build hash)
        source: "/icons/:path*",
        headers: [
          {
            key: "Cache-Control",
            value: "public, max-age=2592000, immutable",
          },
        ],
      },
      {
        // Favicon
        source: "/favicon.ico",
        headers: [
          {
            key: "Cache-Control",
            value: "public, max-age=2592000, immutable",
          },
        ],
      },
    ];
  },
};

export default withSerwist(nextConfig);
