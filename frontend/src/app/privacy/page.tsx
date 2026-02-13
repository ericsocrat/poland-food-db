// ─── Privacy policy stub ─────────────────────────────────────────────────────

import { Header } from "@/components/layout/Header";
import { Footer } from "@/components/layout/Footer";

export default function PrivacyPage() {
  return (
    <div className="flex min-h-screen flex-col">
      <Header />

      <main className="flex flex-1 flex-col items-center px-4 py-16">
        <div className="prose max-w-lg">
          <h1>Privacy Policy</h1>
          <p className="text-sm text-gray-500">Last updated: February 2026</p>

          <h2>Data We Collect</h2>
          <p>
            When you create an account, we store your email address and
            preferences (country, diet, allergens). We do not sell or share your
            personal data with third parties.
          </p>

          <h2>How We Use Your Data</h2>
          <p>
            Your preferences are used to personalize product scores and filter
            results to your dietary needs. Usage data is collected anonymously
            to improve the service.
          </p>

          <h2>Data Storage</h2>
          <p>
            Data is stored securely in Supabase (hosted on AWS in the EU
            region). Authentication is handled via Supabase Auth.
          </p>

          <h2>Your Rights</h2>
          <p>
            Under GDPR, you can request access to, correction, or deletion of
            your data at any time by contacting us.
          </p>

          <h2>Contact</h2>
          <p>
            For privacy-related inquiries, email{" "}
            <a href="mailto:privacy@example.com">privacy@example.com</a>.
          </p>
        </div>
      </main>

      <Footer />
    </div>
  );
}
