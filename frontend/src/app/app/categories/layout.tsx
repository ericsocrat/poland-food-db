import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Browse Categories",
  description:
    "Browse food categories and compare average health scores. Find healthier alternatives within each product category.",
};

export default function CategoriesLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  return children;
}
