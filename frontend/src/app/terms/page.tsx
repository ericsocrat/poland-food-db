// ─── Terms of service stub ───────────────────────────────────────────────────

import { Header } from "@/components/layout/Header";
import { Footer } from "@/components/layout/Footer";

export default function TermsPage() {
  return (
    <div className="flex min-h-screen flex-col">
      <Header />

      <main className="flex flex-1 flex-col items-center px-4 py-16">
        <div className="prose max-w-lg">
          <h1>Terms of Service</h1>
          <p className="text-sm text-gray-500">Last updated: February 2026</p>

          <h2>Acceptance</h2>
          <p>
            By using this service, you agree to these terms. If you do not
            agree, please do not use the service.
          </p>

          <h2>Service Description</h2>
          <p>
            We provide food product health scores and comparisons based on
            publicly available nutritional data. Scores are informational and
            should not replace professional dietary advice.
          </p>

          <h2>Data Accuracy</h2>
          <p>
            Product data is sourced from public databases and may not always be
            accurate or up-to-date. We display data confidence indicators to
            help you judge reliability.
          </p>

          <h2>User Accounts</h2>
          <p>
            You are responsible for maintaining the security of your account
            credentials. We may suspend accounts that violate these terms.
          </p>

          <h2>Limitation of Liability</h2>
          <p>
            This service is provided &ldquo;as is&rdquo; without warranties. We
            are not liable for decisions made based on the information provided.
          </p>

          <h2>Contact</h2>
          <p>
            For questions about these terms, email{" "}
            <a href="mailto:legal@example.com">legal@example.com</a>.
          </p>
        </div>
      </main>

      <Footer />
    </div>
  );
}
