// ─── Feature Flag Barrel Exports ─────────────────────────────────────────────
// Re-export all public API for the feature flag framework (#191).
//
// Usage:
//   import { useFlag, Feature, FlagProvider } from "@/lib/flags";         // client
//   import { getFlag, evaluateAllFlags } from "@/lib/flags/server";       // server
//   import { evaluateFlag, deterministicHash } from "@/lib/flags/evaluator"; // pure

// Client-side hooks, provider, and component gate
export {
  Feature,
  FlagProvider,
  useFlag,
  useFlagRefresh,
  useFlagsLoading,
  useFlagVariant,
} from "./hooks";

// Shared types
export type {
  FeatureFlag,
  FlagContext,
  FlagResult,
  FlagSource,
  FlagType,
  FlagVariant,
} from "./types";
