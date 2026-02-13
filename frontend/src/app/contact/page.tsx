// ─── Contact page stub ──────────────────────────────────────────────────────

import { Header } from "@/components/layout/Header";
import { Footer } from "@/components/layout/Footer";

export default function ContactPage() {
  return (
    <div className="flex min-h-screen flex-col">
      <Header />

      <main className="flex flex-1 flex-col items-center px-4 py-16">
        <div className="max-w-md">
          <h1 className="mb-4 text-2xl font-bold text-gray-900">Contact</h1>
          <p className="mb-6 text-gray-600">
            Have questions, feedback, or want to report a data issue? Reach out
            to us.
          </p>
          <div className="card space-y-3">
            <p className="text-sm text-gray-600">
              <strong>Email:</strong>{" "}
              <a
                href="mailto:hello@example.com"
                className="text-brand-600 underline"
              >
                hello@example.com
              </a>
            </p>
            <p className="text-sm text-gray-500">
              We typically respond within 48 hours.
            </p>
          </div>
        </div>
      </main>

      <Footer />
    </div>
  );
}
