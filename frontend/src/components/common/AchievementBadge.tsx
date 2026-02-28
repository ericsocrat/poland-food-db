// ─── AchievementBadge — Gamification achievement badge component ────────────
// 5 achievement types with unlocked (full color) and locked (grayscale) states.
// SVG illustrations stored in public/illustrations/achievements/.
// CSS-driven locked/unlocked display — no duplicate SVG files needed.
//
// Issue #425 — Design 5 achievement badges (unlocked + locked states)

import Image from "next/image";

/* ── Achievement definitions ─────────────────────────────────────────────── */

export type AchievementType =
  | "first-scan"
  | "list-builder"
  | "health-explorer"
  | "comparison-pro"
  | "profile-complete";

interface AchievementMeta {
  readonly label: string;
  readonly description: string;
  readonly src: string;
}

const ACHIEVEMENT_META: Record<AchievementType, AchievementMeta> = {
  "first-scan": {
    label: "First Scan",
    description: "Scanned your first product barcode",
    src: "/illustrations/achievements/first-scan.svg",
  },
  "list-builder": {
    label: "List Builder",
    description: "Created 5 or more product lists",
    src: "/illustrations/achievements/list-builder.svg",
  },
  "health-explorer": {
    label: "Health Explorer",
    description: "Viewed 50 or more product details",
    src: "/illustrations/achievements/health-explorer.svg",
  },
  "comparison-pro": {
    label: "Comparison Pro",
    description: "Saved 10 or more product comparisons",
    src: "/illustrations/achievements/comparison-pro.svg",
  },
  "profile-complete": {
    label: "Profile Complete",
    description: "Fully configured your health profile",
    src: "/illustrations/achievements/profile-complete.svg",
  },
};

/* ── Size scale ──────────────────────────────────────────────────────────── */

const SIZE_MAP = {
  sm: 32,
  md: 48,
  lg: 96,
} as const;

export type AchievementBadgeSize = keyof typeof SIZE_MAP;

/* ── Props ───────────────────────────────────────────────────────────────── */

export interface AchievementBadgeProps {
  /** Achievement type identifier. */
  readonly type: AchievementType;
  /** Whether the achievement is unlocked (full color) or locked (grayscale). */
  readonly unlocked: boolean;
  /** Badge size preset. @default "md" (48px) */
  readonly size?: AchievementBadgeSize;
  /** Show text label below the badge. @default false */
  readonly showLabel?: boolean;
  /** Additional CSS classes on the wrapper. */
  readonly className?: string;
}

/* ── Component ───────────────────────────────────────────────────────────── */

/**
 * Renders an achievement badge with unlocked (full color) or locked (grayscale)
 * visual state. CSS-driven — same SVG file, different filter classes.
 *
 * @example
 * // Unlocked achievement
 * <AchievementBadge type="first-scan" unlocked={true} size="lg" showLabel />
 *
 * // Locked achievement (grayscale + 50% opacity)
 * <AchievementBadge type="first-scan" unlocked={false} />
 */
export function AchievementBadge({
  type,
  unlocked,
  size = "md",
  showLabel = false,
  className = "",
}: AchievementBadgeProps) {
  const meta = ACHIEVEMENT_META[type];
  const px = SIZE_MAP[size];
  const stateLabel = unlocked ? "Unlocked" : "Locked";
  const ariaLabel = `${meta.label} — ${stateLabel}: ${meta.description}`;

  return (
    <div
      className={`inline-flex flex-col items-center gap-1 ${className}`}
      data-achievement={type}
      data-unlocked={unlocked}
    >
      <Image
        src={meta.src}
        alt={ariaLabel}
        width={px}
        height={px}
        className={
          unlocked
            ? "achievement-unlocked"
            : "achievement-locked grayscale opacity-50"
        }
        draggable={false}
      />
      {showLabel && (
        <span
          className={`text-xs font-medium text-center leading-tight ${
            unlocked ? "text-gray-900 dark:text-gray-100" : "text-gray-400 dark:text-gray-500"
          }`}
          style={{ maxWidth: px }}
        >
          {meta.label}
        </span>
      )}
    </div>
  );
}

/* ── Utilities ───────────────────────────────────────────────────────────── */

/** All supported achievement type identifiers. */
export function getAchievementTypes(): AchievementType[] {
  return Object.keys(ACHIEVEMENT_META) as AchievementType[];
}

/** Returns display metadata for an achievement type. */
export function getAchievementMeta(type: AchievementType): AchievementMeta {
  return ACHIEVEMENT_META[type];
}
