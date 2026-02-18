import type { Metadata } from "next";
import type { ReactNode } from "react";

export const metadata: Metadata = {
  title: "Understanding Nutri-Score",
  description:
    "Learn what the A–E Nutri-Score grades mean, how they're calculated, and their limitations for food evaluation.",
};

export default function NutriScoreLayout({
  children,
}: {
  readonly children: ReactNode;
}) {
  return <>{children}</>;
}
