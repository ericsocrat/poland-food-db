"use client";

// ─── useReducedMotion — JS-level reduced motion preference ──────────────────
// Returns true when the user prefers reduced motion.
// CSS already respects this via @media (prefers-reduced-motion: reduce) in
// globals.css; this hook enables JS-driven animations (e.g., Framer Motion,
// scroll-into-view, requestAnimationFrame) to also respect the preference.

import { useState, useEffect } from "react";

const QUERY = "(prefers-reduced-motion: reduce)";

/**
 * React hook that tracks the user's `prefers-reduced-motion` media query.
 * Returns `true` when the user prefers reduced motion, `false` otherwise.
 *
 * Safe for SSR — defaults to `false` on the server.
 */
export function useReducedMotion(): boolean {
  const [prefersReduced, setPrefersReduced] = useState(false);

  useEffect(() => {
    const mql = window.matchMedia(QUERY);
    setPrefersReduced(mql.matches);

    function onChange(e: MediaQueryListEvent) {
      setPrefersReduced(e.matches);
    }

    mql.addEventListener("change", onChange);
    return () => mql.removeEventListener("change", onChange);
  }, []);

  return prefersReduced;
}
