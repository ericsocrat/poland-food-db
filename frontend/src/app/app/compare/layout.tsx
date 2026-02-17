import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Compare Products",
  description:
    "Compare food products side-by-side across health scores, nutrition facts, ingredients, and warnings.",
};

export default function CompareLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  return children;
}
