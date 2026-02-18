import type { Metadata } from "next";
import type { ReactNode } from "react";

export const metadata: Metadata = {
  title: "Our Health Score",
  description:
    "Learn how the 9-factor Unhealthiness Score works, what the bands mean, and why it goes beyond Nutri-Score.",
};

export default function UnhealthinessScoreLayout({
  children,
}: {
  readonly children: ReactNode;
}) {
  return <>{children}</>;
}
