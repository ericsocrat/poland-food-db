// ─── N+1 Query Pattern Observer ─────────────────────────────────────────────
// Dev/QA-only utility that detects N+1 query patterns by observing rapid
// repeated RPC calls. Fires a console warning when the same RPC function
// is called N_PLUS_ONE_THRESHOLD or more times within WINDOW_MS.
//
// Integration: called from callRpc() in rpc.ts — zero production overhead.
// Issue: #185 — [Hardening 5/7] Query-Level Performance Guardrails

/** How many identical RPC calls within the window trigger a warning. */
export const N_PLUS_ONE_THRESHOLD = 5;

/** Time window in milliseconds for detecting rapid duplicate calls. */
export const WINDOW_MS = 500;

interface QueryEntry {
  rpc: string;
  timestamp: number;
}

/** Circular buffer of recent RPC calls. */
let queryLog: QueryEntry[] = [];

/** Warnings emitted (for testing). */
let warnings: string[] = [];

/**
 * Check if the observer is active.
 * Only runs in development or when NEXT_PUBLIC_QA_MODE is set.
 */
export function isObserverActive(): boolean {
  return (
    process.env.NODE_ENV === "development" ||
    process.env.NEXT_PUBLIC_QA_MODE === "1" ||
    process.env.NEXT_PUBLIC_QA_MODE === "true"
  );
}

/**
 * Observe an RPC call for N+1 detection.
 * No-op in production unless QA_MODE is enabled.
 *
 * @param rpcName - The name of the RPC function being called.
 * @returns The warning message if an N+1 pattern was detected, null otherwise.
 */
export function observeQuery(rpcName: string): string | null {
  if (!isObserverActive()) return null;

  const now = Date.now();
  queryLog.push({ rpc: rpcName, timestamp: now });

  // Prune entries outside the window
  queryLog = queryLog.filter((q) => now - q.timestamp < WINDOW_MS);

  // Count calls per RPC within the window
  const counts = new Map<string, number>();
  for (const q of queryLog) {
    counts.set(q.rpc, (counts.get(q.rpc) ?? 0) + 1);
  }

  const count = counts.get(rpcName) ?? 0;
  if (count >= N_PLUS_ONE_THRESHOLD) {
    const msg = `[N+1 DETECTED] ${rpcName} called ${count} times in ${WINDOW_MS}ms — probable N+1 query pattern`;
    console.warn(msg);
    warnings.push(msg);
    return msg;
  }

  return null;
}

/**
 * Get all N+1 warnings recorded so far (for testing).
 */
export function getWarnings(): readonly string[] {
  return [...warnings];
}

/**
 * Reset the observer state. Useful in tests.
 */
export function resetObserver(): void {
  queryLog = [];
  warnings = [];
}
