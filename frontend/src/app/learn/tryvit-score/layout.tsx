import type { Metadata } from "next";
import type { ReactNode } from "react";

export const metadata: Metadata = {
  title: "TryVit Score",
  description:
    "Learn how the 9-factor TryVit Score works, what the bands mean, and why it goes beyond Nutri-Score.",
};

export default function TryVitScoreLayout({
  children,
}: {
  readonly children: ReactNode;
}) {
  return <>{children}</>;
}
