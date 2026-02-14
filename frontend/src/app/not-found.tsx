// ─── Global 404 page ──────────────────────────────────────────────────────

import Link from "next/link";

export default function NotFound() {
  return (
    <div className="flex min-h-screen flex-col items-center justify-center px-4">
      <h1 className="mb-2 text-6xl font-bold text-gray-900">404</h1>
      <p className="mb-6 text-lg text-gray-500">
        Page not found. The page you&apos;re looking for doesn&apos;t exist or
        has been moved.
      </p>
      <Link href="/" className="btn-primary px-6 py-3">
        Go home
      </Link>
    </div>
  );
}
