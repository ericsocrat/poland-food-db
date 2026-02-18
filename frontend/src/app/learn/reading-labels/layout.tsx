import type { Metadata } from "next";
import type { ReactNode } from "react";

export const metadata: Metadata = {
  title: "Reading Polish Food Labels",
  description:
    "Learn how to read Polish food labels, understand per-100g vs per-serving values, and identify mandatory label elements.",
};

export default function ReadingLabelsLayout({
  children,
}: {
  readonly children: ReactNode;
}) {
  return <>{children}</>;
}
