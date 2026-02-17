import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "My Lists",
  description:
    "Manage your custom food lists, favorites, and products to avoid. Organize products for easy comparison and shopping.",
};

export default function ListsLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  return children;
}
