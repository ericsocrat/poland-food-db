// ─── Structured JSON Logger ─────────────────────────────────────────────────
// Outputs structured JSON logs to stdout for Vercel log ingestion.
// Supports 5 severity levels, request ID correlation, and environment tagging.
//
// Usage:
//   import { logger } from "@/lib/logger";
//   logger.info("Product fetched", { route: "/api/health", duration: 42 });
//   logger.error("RPC failed", { error: { name: "RPCError", message: "timeout" } });

// ─── Types ──────────────────────────────────────────────────────────────────

export type LogLevel = "debug" | "info" | "warn" | "error" | "fatal";

export interface LogEntry {
  timestamp: string;
  level: LogLevel;
  message: string;
  environment: string;
  version: string;
  requestId?: string;
  route?: string;
  method?: string;
  status?: number;
  duration?: number;
  userId?: string;
  error?: {
    name: string;
    message: string;
    stack?: string;
  };
  meta?: Record<string, unknown>;
}

// ─── Constants ──────────────────────────────────────────────────────────────

const LOG_LEVEL_ORDER: Record<LogLevel, number> = {
  debug: 0,
  info: 1,
  warn: 2,
  error: 3,
  fatal: 4,
} as const;

const VALID_LEVELS = new Set<LogLevel>(["debug", "info", "warn", "error", "fatal"]);

// ─── Helpers ────────────────────────────────────────────────────────────────

function getMinLevel(): LogLevel {
  const env =
    typeof process === "undefined"
      ? undefined
      : (process.env?.LOG_LEVEL as string | undefined);
  return env && VALID_LEVELS.has(env as LogLevel) ? (env as LogLevel) : "info";
}

function getEnvironment(): string {
  if (typeof process === "undefined") return "browser";
  return process.env?.VERCEL_ENV ?? process.env?.NODE_ENV ?? "development";
}

function getVersion(): string {
  if (typeof process === "undefined") return "browser";
  return process.env?.VERCEL_GIT_COMMIT_SHA?.slice(0, 8) ?? "local";
}

// ─── Core ───────────────────────────────────────────────────────────────────

/**
 * Write a structured JSON log entry to stdout/stderr.
 * Entries below the configured `LOG_LEVEL` are silently dropped.
 */
export function log(
  level: LogLevel,
  message: string,
  context?: Partial<Omit<LogEntry, "timestamp" | "level" | "message" | "environment" | "version">>,
): void {
  if (LOG_LEVEL_ORDER[level] < LOG_LEVEL_ORDER[getMinLevel()]) return;

  const entry: LogEntry = {
    timestamp: new Date().toISOString(),
    level,
    message,
    environment: getEnvironment(),
    version: getVersion(),
    ...context,
  };

  // Errors and fatals go to stderr; everything else to stdout
  const output = level === "error" || level === "fatal" ? console.error : console.log;
  output(JSON.stringify(entry));
}

// ─── Public API ─────────────────────────────────────────────────────────────

type LogContext = Partial<Omit<LogEntry, "timestamp" | "level" | "message" | "environment" | "version">>;

export const logger = {
  debug: (msg: string, ctx?: LogContext): void => log("debug", msg, ctx),
  info: (msg: string, ctx?: LogContext): void => log("info", msg, ctx),
  warn: (msg: string, ctx?: LogContext): void => log("warn", msg, ctx),
  error: (msg: string, ctx?: LogContext): void => log("error", msg, ctx),
  fatal: (msg: string, ctx?: LogContext): void => log("fatal", msg, ctx),
} as const;
