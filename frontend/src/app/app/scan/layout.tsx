import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Scan Barcode",
  description:
    "Scan a product barcode with your camera or enter an EAN manually to instantly view health scores and nutrition data.",
};

export default function ScanLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  return children;
}
