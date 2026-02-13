// ─── Public home page ─────────────────────────────────────────────────────

import Link from "next/link";
import { Header } from "@/components/layout/Header";
import { Footer } from "@/components/layout/Footer";

export default function HomePage() {
  return (
    <div className="flex min-h-screen flex-col">
      <Header />

      <main className="flex flex-1 flex-col items-center justify-center px-4 py-16">
        <div className="max-w-md text-center">
          <h1 className="mb-4 text-4xl font-bold text-gray-900">
            <span className="text-brand-600">healthier</span> choices,
            <br />
            made simple
          </h1>
          <p className="mb-8 text-lg text-gray-500">
            Search, scan, and compare food products across Poland and Germany.
            Get instant health scores, allergen warnings, and better
            alternatives.
          </p>

          <div className="flex flex-col gap-3 sm:flex-row sm:justify-center">
            <Link href="/auth/signup" className="btn-primary px-8 py-3">
              Get started
            </Link>
            <Link href="/auth/login" className="btn-secondary px-8 py-3">
              Sign in
            </Link>
          </div>
        </div>

        {/* Feature highlights */}
        <div className="mt-16 grid max-w-lg gap-6 sm:grid-cols-3">
          <Feature
            icon="🔍"
            title="Search"
            desc="Find products by name, brand, or category"
          />
          <Feature
            icon="📷"
            title="Scan"
            desc="Scan barcodes for instant product info"
          />
          <Feature
            icon="📊"
            title="Compare"
            desc="See health scores and find better alternatives"
          />
        </div>
      </main>

      <Footer />
    </div>
  );
}

function Feature({
  icon,
  title,
  desc,
}: {
  icon: string;
  title: string;
  desc: string;
}) {
  return (
    <div className="text-center">
      <span className="text-3xl">{icon}</span>
      <h3 className="mt-2 font-semibold text-gray-900">{title}</h3>
      <p className="mt-1 text-sm text-gray-500">{desc}</p>
    </div>
  );
}
