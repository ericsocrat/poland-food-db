import type { Metadata } from "next";
import type { ReactNode } from "react";

export const metadata: Metadata = {
  title: "NOVA Food Classification",
  description:
    "Understand NOVA food processing groups 1–4, from minimally processed to ultra-processed, and their health implications.",
};

export default function NovaGroupsLayout({
  children,
}: {
  readonly children: ReactNode;
}) {
  return <>{children}</>;
}
