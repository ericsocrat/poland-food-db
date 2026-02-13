import Link from "next/link";

export function Header() {
  return (
    <header className="border-b border-gray-200 bg-white">
      <div className="mx-auto flex h-16 max-w-5xl items-center justify-between px-4">
        <Link href="/" className="text-xl font-bold text-brand-700">
          🥗 FoodDB
        </Link>
        <nav className="flex items-center gap-4">
          <Link
            href="/contact"
            className="text-sm text-gray-600 hover:text-gray-900"
          >
            Contact
          </Link>
          <Link href="/auth/login" className="btn-primary text-sm">
            Sign In
          </Link>
        </nav>
      </div>
    </header>
  );
}
