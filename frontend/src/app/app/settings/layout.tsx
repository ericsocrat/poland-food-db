import { SettingsNav } from "@/components/settings/SettingsNav";
import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Settings",
  description:
    "Customize your TryVit experience — language, country, dietary preferences, allergen alerts, and health profile.",
};

export default function SettingsLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  return (
    <div className="max-w-2xl space-y-6 lg:space-y-8">
      <SettingsNav />
      {children}
    </div>
  );
}
