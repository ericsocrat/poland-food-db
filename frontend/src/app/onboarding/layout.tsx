// ─── Onboarding layout ───────────────────────────────────────────────────────
// Minimal chrome for the onboarding wizard.

export default function OnboardingLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <div className="flex min-h-screen flex-col bg-gray-50">
      <header className="border-b border-gray-200 bg-white">
        <div className="mx-auto flex h-14 max-w-lg items-center justify-center px-4">
          <span className="text-lg font-bold text-brand-700">🥗 FoodDB</span>
        </div>
      </header>
      <main className="mx-auto w-full max-w-lg flex-1 px-4 py-8">
        {children}
      </main>
    </div>
  );
}
