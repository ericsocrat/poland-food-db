"use client";

// ─── Bottom navigation for the app shell ────────────────────────────────────

import Link from "next/link";
import { usePathname } from "next/navigation";

const NAV_ITEMS = [
  { href: "/app/search", label: "Search", icon: "🔍" },
  { href: "/app/categories", label: "Categories", icon: "📂" },
  { href: "/app/scan", label: "Scan", icon: "📷" },
  { href: "/app/settings", label: "Settings", icon: "⚙️" },
];

export function Navigation() {
  const pathname = usePathname();

  return (
    <nav
      className="sticky bottom-0 z-40 border-t border-gray-200 bg-white"
      aria-label="Main navigation"
    >
      <div className="mx-auto flex max-w-5xl">
        {NAV_ITEMS.map((item) => {
          const isActive = pathname.startsWith(item.href);
          return (
            <Link
              key={item.href}
              href={item.href}
              aria-label={item.label}
              aria-current={isActive ? "page" : undefined}
              className={`flex flex-1 flex-col items-center gap-0.5 py-2 text-xs transition-colors ${
                isActive
                  ? "text-brand-700 font-semibold"
                  : "text-gray-500 hover:text-gray-700"
              }`}
            >
              <span className="text-xl">{item.icon}</span>
              <span>{item.label}</span>
            </Link>
          );
        })}
      </div>
    </nav>
  );
}
