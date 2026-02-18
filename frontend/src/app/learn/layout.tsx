import type { Metadata } from "next";
import type { ReactNode } from "react";

export const metadata: Metadata = {
  title: "Learn",
  description:
    "Educational resources about Nutri-Score, NOVA classification, food additives, allergens, and how we evaluate food products in FoodDB.",
};

export default function LearnRootLayout({
  children,
}: {
  readonly children: ReactNode;
}) {
  return <>{children}</>;
}
