import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Recipe Detail",
  description: "View recipe ingredients, steps, and nutritional context.",
};

export default function RecipeDetailLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  return children;
}
