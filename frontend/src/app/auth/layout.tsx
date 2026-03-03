import { Logo } from "@/components/common/Logo";

export default function AuthLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="flex min-h-screen">
      {/* ── Illustration panel (desktop only) ─────────────────────── */}
      <div className="auth-illustration hidden lg:flex lg:w-1/2 flex-col items-center justify-center gap-8 p-12">
        <Logo variant="lockup" size={40} />
        <img
          src="/illustrations/onboarding/step-1-welcome.svg"
          alt=""
          aria-hidden="true"
          width={280}
          height={280}
          className="w-full max-w-xs"
        />
        <p className="max-w-xs text-center text-sm font-medium text-foreground-secondary">
          Search, scan, and compare food products. Get instant health scores and
          find healthier alternatives.
        </p>
      </div>

      {/* ── Form panel ────────────────────────────────────────────── */}
      <div className="flex flex-1 items-center justify-center px-4 py-8">
        {children}
      </div>
    </div>
  );
}
