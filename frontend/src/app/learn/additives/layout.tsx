import type { Metadata } from "next";
import type { ReactNode } from "react";

export const metadata: Metadata = {
  title: "Understanding Additives",
  description:
    "Learn what E-numbers are, how EFSA evaluates food additive safety, and how to read additive lists on Polish food labels.",
};

export default function AdditivesLayout({
  children,
}: {
  readonly children: ReactNode;
}) {
  return <>{children}</>;
}
