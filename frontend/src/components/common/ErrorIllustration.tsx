// ─── ErrorIllustration ───────────────────────────────────────────────
// Maps 3 error page types to branded SVG illustrations (240×200).
// Each error type has a food-themed illustration that maintains visual
// consistency with the empty-state illustration family.
// ─────────────────────────────────────────────────────────────────────

import Image from "next/image";

// ─── Types ───────────────────────────────────────────────────────────

/**
 * Error page illustration types.
 * Each maps to a dedicated SVG in public/illustrations/errors/.
 */
export type ErrorType = "not-found" | "server-error" | "offline";

export interface ErrorIllustrationProps {
  /** Which error illustration to display */
  readonly type: ErrorType;
  /** Override the default width (240) */
  readonly width?: number;
  /** Override the default height (200) */
  readonly height?: number;
  /** Additional CSS classes on the wrapper */
  readonly className?: string;
  /** Whether to use priority loading (above the fold) */
  readonly priority?: boolean;
}

// ─── Illustration Metadata ───────────────────────────────────────────

interface ErrorMeta {
  /** Alt text for the illustration image */
  alt: string;
  /** Path to the SVG file in public/ */
  src: string;
  /** HTTP status code associated with this error (informational) */
  statusCode: number | null;
}

const ERROR_META: Record<ErrorType, ErrorMeta> = {
  "not-found": {
    alt: "Plate with 404 text, fork and knife — page not found",
    src: "/illustrations/errors/404-not-found.svg",
    statusCode: 404,
  },
  "server-error": {
    alt: "Tipped-over bowl with spilled ingredients — server error",
    src: "/illustrations/errors/500-server-error.svg",
    statusCode: 500,
  },
  offline: {
    alt: "Cloud with X mark — no internet connection",
    src: "/illustrations/errors/offline.svg",
    statusCode: null,
  },
};

// ─── Utilities ───────────────────────────────────────────────────────

/** Returns all available error type strings. */
export function getErrorTypes(): ErrorType[] {
  return Object.keys(ERROR_META) as ErrorType[];
}

/** Returns metadata for a given error type. */
export function getErrorMeta(type: ErrorType): ErrorMeta {
  return ERROR_META[type];
}

// ─── Component ───────────────────────────────────────────────────────

/**
 * Branded SVG illustration for error pages.
 *
 * All illustrations are 240×200 with dark mode support via
 * `prefers-color-scheme` media queries embedded in the SVGs.
 * These share the same visual language as the empty-state
 * illustrations (flat/semi-flat, brand palette, dark mode).
 */
export function ErrorIllustration({
  type,
  width = 240,
  height = 200,
  className,
  priority = false,
}: ErrorIllustrationProps) {
  const meta = ERROR_META[type];

  return (
    <div
      className={className}
      data-testid="error-illustration"
      data-error-type={type}
    >
      <Image
        src={meta.src}
        alt={meta.alt}
        width={width}
        height={height}
        priority={priority}
        data-illustration={type}
      />
    </div>
  );
}
