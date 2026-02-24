// ─── Feature Flag Types ─────────────────────────────────────────────────────
// Shared TypeScript types for the feature flag framework (#191).
// Used by evaluator, hooks, server, and API route.

/** Flag type determines evaluation behavior */
export type FlagType = "boolean" | "percentage" | "variant";

/** A single variant option with weighted distribution */
export interface FlagVariant {
  name: string;
  weight: number;
}

/** Feature flag row from the `feature_flags` table */
export interface FeatureFlag {
  id: number;
  key: string;
  name: string;
  description: string | null;
  flag_type: FlagType;
  enabled: boolean;
  percentage: number;
  countries: string[];
  roles: string[];
  environments: string[];
  variants: FlagVariant[];
  created_at: string;
  updated_at: string;
  expires_at: string | null;
  created_by: string | null;
  tags: string[];
  jira_ref: string | null;
}

/** Context for evaluating a flag against targeting rules */
export interface FlagContext {
  userId?: string;
  sessionId?: string;
  country: string;
  role?: string;
  environment: string;
}

/** Result source indicates how the flag value was determined */
export type FlagSource = "override" | "rule" | "default" | "expired" | "kill";

/** Evaluation result returned by the evaluator */
export interface FlagResult {
  enabled: boolean;
  variant?: string;
  source: FlagSource;
}
