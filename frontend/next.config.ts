import withSerwistInit from "@serwist/next";
import type { NextConfig } from "next";

const withSerwist = withSerwistInit({
  swSrc: "src/app/sw.ts",
  swDest: "public/sw.js",
  disable: process.env.NODE_ENV === "development",
});

const nextConfig: NextConfig = {
  // Enable View Transitions API for smoother page navigations (#61)
  experimental: {
    viewTransitions: true,
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
    ];
  },
};

export default withSerwist(nextConfig);
