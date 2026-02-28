// ─── EmptyStateIllustration ─────────────────────────────────────────
// Maps 8 page-specific empty-state types to branded SVG illustrations
// and wraps the existing EmptyState component. Each type provides the
// correct illustration, alt text, and default variant mapping.
// ─────────────────────────────────────────────────────────────────────

import Image from "next/image";
import { EmptyState } from "./EmptyState";

// ─── Types ───────────────────────────────────────────────────────────

/**
 * Context-specific empty-state illustration types.
 * Each maps to a dedicated SVG in public/illustrations/empty-states/.
 */
export type EmptyStateIllustrationType =
  | "no-results"
  | "no-favorites"
  | "no-scan-history"
  | "no-comparisons"
  | "no-lists"
  | "no-products-category"
  | "no-submissions"
  | "no-saved-searches";

export interface EmptyStateIllustrationProps {
  /** Which illustration to display */
  readonly type: EmptyStateIllustrationType;
  /** i18n key resolved to the title heading */
  readonly titleKey: string;
  /** i18n key resolved to the description paragraph */
  readonly descriptionKey?: string;
  /** i18n interpolation params for titleKey */
  readonly titleParams?: Record<string, string | number>;
  /** i18n interpolation params for descriptionKey */
  readonly descriptionParams?: Record<string, string | number>;
  /** Primary call-to-action */
  readonly action?: {
    labelKey: string;
    href?: string;
    onClick?: () => void;
  };
  /** Optional secondary call-to-action */
  readonly secondaryAction?: {
    labelKey: string;
    href?: string;
    onClick?: () => void;
  };
  /** Additional CSS classes on the root container */
  readonly className?: string;
}

// ─── Illustration Metadata ───────────────────────────────────────────

interface IllustrationMeta {
  /** Alt text for the illustration image */
  alt: string;
  /** Path to the SVG file in public/ */
  src: string;
  /** Which EmptyState variant this maps to */
  variant: "no-data" | "no-results" | "error" | "offline";
}

const ILLUSTRATION_META: Record<EmptyStateIllustrationType, IllustrationMeta> = {
  "no-results": {
    alt: "Magnifying glass over an empty plate — no results found",
    src: "/illustrations/empty-states/no-results.svg",
    variant: "no-results",
  },
  "no-favorites": {
    alt: "Heart-shaped empty plate — no favorites saved",
    src: "/illustrations/empty-states/no-favorites.svg",
    variant: "no-data",
  },
  "no-scan-history": {
    alt: "Barcode scanner pointing at an empty shelf — no scans recorded",
    src: "/illustrations/empty-states/no-scan-history.svg",
    variant: "no-data",
  },
  "no-comparisons": {
    alt: "Two empty plates side by side — no comparisons saved",
    src: "/illustrations/empty-states/no-comparisons.svg",
    variant: "no-data",
  },
  "no-lists": {
    alt: "Empty shopping basket with sparkles — no lists created",
    src: "/illustrations/empty-states/no-lists.svg",
    variant: "no-data",
  },
  "no-products-category": {
    alt: "Empty category shelf — no products match filters",
    src: "/illustrations/empty-states/no-products-category.svg",
    variant: "no-results",
  },
  "no-submissions": {
    alt: "Clipboard with checkmarks — all submissions reviewed",
    src: "/illustrations/empty-states/no-submissions.svg",
    variant: "no-data",
  },
  "no-saved-searches": {
    alt: "Bookmark with magnifying glass — no saved searches",
    src: "/illustrations/empty-states/no-saved-searches.svg",
    variant: "no-data",
  },
};

// ─── Utilities ───────────────────────────────────────────────────────

/** Returns all available illustration type strings. */
export function getIllustrationTypes(): EmptyStateIllustrationType[] {
  return Object.keys(ILLUSTRATION_META) as EmptyStateIllustrationType[];
}

/** Returns metadata for a given illustration type. */
export function getIllustrationMeta(
  type: EmptyStateIllustrationType,
): IllustrationMeta {
  return ILLUSTRATION_META[type];
}

// ─── Component ───────────────────────────────────────────────────────

/**
 * Empty-state with branded SVG illustration. Wraps the base EmptyState
 * component, injecting the type-specific illustration as a custom icon.
 *
 * Used on: search, favorites, scan history, comparisons, lists,
 * category detail, admin submissions, and saved searches pages.
 */
export function EmptyStateIllustration({
  type,
  titleKey,
  descriptionKey,
  titleParams,
  descriptionParams,
  action,
  secondaryAction,
  className,
}: EmptyStateIllustrationProps) {
  const meta = ILLUSTRATION_META[type];

  const illustration = (
    <Image
      src={meta.src}
      alt={meta.alt}
      width={240}
      height={200}
      priority={false}
      data-illustration={type}
    />
  );

  return (
    <EmptyState
      variant={meta.variant}
      icon={illustration}
      titleKey={titleKey}
      descriptionKey={descriptionKey}
      titleParams={titleParams}
      descriptionParams={descriptionParams}
      action={action}
      secondaryAction={secondaryAction}
      className={className}
    />
  );
}
