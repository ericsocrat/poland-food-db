import type { Metadata } from "next";
import type { ReactNode } from "react";

export const metadata: Metadata = {
  title: "Allergens in Food",
  description:
    "Learn about the 14 EU mandatory allergens, how to read Polish allergen labels, and the difference between 'contains' and 'may contain traces of'.",
};

export default function AllergensLayout({
  children,
}: {
  readonly children: ReactNode;
}) {
  return <>{children}</>;
}
