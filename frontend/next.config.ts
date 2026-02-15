import type { NextConfig } from "next";

const nextConfig: NextConfig = {
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

export default nextConfig;
