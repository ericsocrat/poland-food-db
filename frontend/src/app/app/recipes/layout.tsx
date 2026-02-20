import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Recipes",
  description:
    "Browse curated healthy recipes. Filter by category, difficulty, and cooking time.",
};

export default function RecipesLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  return children;
}
