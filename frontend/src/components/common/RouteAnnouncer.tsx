"use client";

/**
 * RouteAnnouncer — announces page navigations to screen readers.
 *
 * Renders a visually-hidden aria-live region that updates whenever
 * the Next.js pathname changes, announcing the new page title to
 * assistive technology users.
 */

import { usePathname } from "next/navigation";
import { useEffect, useRef, useState } from "react";

/** Map pathname segments to human-readable page names. */
function pageTitle(pathname: string): string {
  const segments = pathname.replace(/^\//, "").split("/").filter(Boolean);
  if (segments.length === 0) return "Home";

  // Authenticated app routes: /app/<section>/...
  if (segments[0] === "app") {
    const section = segments[1];
    if (!section) return "Dashboard";

    const titles: Record<string, string> = {
      categories: "Categories",
      product: "Product Detail",
      search: "Search",
      compare: "Comparisons",
      lists: "Lists",
      scan: "Scanner",
      settings: "Settings",
      admin: "Admin",
    };

    return titles[section] ?? section.charAt(0).toUpperCase() + section.slice(1);
  }

  // Public routes
  const publicTitles: Record<string, string> = {
    auth: "Sign In",
    onboarding: "Onboarding",
    contact: "Contact",
    privacy: "Privacy Policy",
    terms: "Terms of Service",
  };

  return publicTitles[segments[0]] ?? "Page";
}

export function RouteAnnouncer() {
  const pathname = usePathname();
  const [announcement, setAnnouncement] = useState("");
  const isFirstRender = useRef(true);

  useEffect(() => {
    // Don't announce the initial page load — the browser already handles that.
    if (isFirstRender.current) {
      isFirstRender.current = false;
      return;
    }

    const title = pageTitle(pathname);
    setAnnouncement(`Navigated to ${title}`);
  }, [pathname]);

  return (
    <div
      role="status"
      aria-live="assertive"
      aria-atomic="true"
      className="sr-only"
    >
      {announcement}
    </div>
  );
}
