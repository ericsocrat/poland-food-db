import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Search Products",
  description:
    "Search and filter food products by name, brand, category, or barcode. Compare TryVit health scores across thousands of products in our database.",
};

export default function SearchLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  return children;
}
