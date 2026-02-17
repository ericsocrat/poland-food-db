import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Settings",
  description:
    "Customize your FoodDB experience — language, country, dietary preferences, allergen alerts, and health profile.",
};

export default function SettingsLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  return children;
}
