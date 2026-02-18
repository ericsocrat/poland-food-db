import type { Metadata } from "next";
import type { ReactNode } from "react";

export const metadata: Metadata = {
  title: "Data Confidence",
  description:
    "Understand what verified, estimated, and low confidence levels mean for product data in FoodDB.",
};

export default function ConfidenceLayout({
  children,
}: {
  readonly children: ReactNode;
}) {
  return <>{children}</>;
}
