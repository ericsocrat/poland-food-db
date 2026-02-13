import Link from "next/link";

export function Footer() {
  return (
    <footer className="border-t border-gray-200 bg-gray-50 py-8">
      <div className="mx-auto max-w-5xl px-4 text-center text-sm text-gray-500">
        <div className="mb-3 flex items-center justify-center gap-4">
          <Link href="/privacy" className="hover:text-gray-700">
            Privacy Policy
          </Link>
          <span>·</span>
          <Link href="/terms" className="hover:text-gray-700">
            Terms of Service
          </Link>
          <span>·</span>
          <Link href="/contact" className="hover:text-gray-700">
            Contact
          </Link>
        </div>
        <p>
          © {new Date().getFullYear()} Poland Food DB. Data sourced from Open
          Food Facts.
        </p>
      </div>
    </footer>
  );
}
