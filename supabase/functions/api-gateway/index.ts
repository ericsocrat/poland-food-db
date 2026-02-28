// ─── Supabase Edge Function: api-gateway ────────────────────────────────────
// Centralized write-path gateway for rate limiting, input validation, and
// request forwarding. Read operations bypass this gateway entirely.
//
// Phase 1: record-scan rate limiting (100/day/user)
//
// Auth: Requires authenticated user JWT (Authorization: Bearer <jwt>)
// Issue: #478
// ─────────────────────────────────────────────────────────────────────────────

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

// ─── Types ──────────────────────────────────────────────────────────────────

interface GatewayRequest {
  action: string;
  [key: string]: unknown;
}

interface GatewaySuccess {
  ok: true;
  data: unknown;
}

interface GatewayError {
  ok: false;
  error: string;
  message: string;
  retry_after?: number;
}

type GatewayResponse = GatewaySuccess | GatewayError;

// ─── In-Memory Rate Limiter (Sliding Window) ────────────────────────────────

interface RateLimitEntry {
  timestamps: number[];
}

interface RateLimitConfig {
  max_requests: number;
  window_seconds: number;
}

const rateLimitStore = new Map<string, RateLimitEntry>();

// Cleanup stale entries every 5 minutes to prevent memory leaks
const CLEANUP_INTERVAL_MS = 5 * 60 * 1000;
let lastCleanup = Date.now();

function cleanupStaleEntries(windowMs: number): void {
  const now = Date.now();
  if (now - lastCleanup < CLEANUP_INTERVAL_MS) return;
  lastCleanup = now;

  const cutoff = now - windowMs;
  for (const [key, entry] of rateLimitStore) {
    entry.timestamps = entry.timestamps.filter((t) => t > cutoff);
    if (entry.timestamps.length === 0) {
      rateLimitStore.delete(key);
    }
  }
}

function checkRateLimit(
  userId: string,
  action: string,
  config: RateLimitConfig,
): { allowed: boolean; remaining: number; retry_after?: number } {
  const key = `${userId}:${action}`;
  const now = Date.now();
  const windowMs = config.window_seconds * 1000;

  // Periodic cleanup
  cleanupStaleEntries(windowMs);

  const entry = rateLimitStore.get(key) ?? { timestamps: [] };

  // Remove timestamps outside the sliding window
  const cutoff = now - windowMs;
  entry.timestamps = entry.timestamps.filter((t) => t > cutoff);

  if (entry.timestamps.length >= config.max_requests) {
    // Calculate when the oldest request in the window expires
    const oldestInWindow = entry.timestamps[0];
    const retryAfterMs = oldestInWindow + windowMs - now;
    const retryAfterSec = Math.ceil(retryAfterMs / 1000);

    return {
      allowed: false,
      remaining: 0,
      retry_after: retryAfterSec,
    };
  }

  // Allow the request and record the timestamp
  entry.timestamps.push(now);
  rateLimitStore.set(key, entry);

  return {
    allowed: true,
    remaining: config.max_requests - entry.timestamps.length,
  };
}

// ─── Rate Limit Configuration Per Action ────────────────────────────────────

const RATE_LIMITS: Record<string, RateLimitConfig> = {
  "record-scan": { max_requests: 100, window_seconds: 86400 }, // 100/day
};

// ─── Action Handlers ────────────────────────────────────────────────────────

async function handleRecordScan(
  supabase: ReturnType<typeof createClient>,
  body: GatewayRequest,
): Promise<GatewayResponse> {
  const ean = body.ean;

  // Input validation
  if (!ean || typeof ean !== "string") {
    return {
      ok: false,
      error: "invalid_input",
      message: "Missing or invalid 'ean' parameter. Must be a non-empty string.",
    };
  }

  // EAN format validation (8 or 13 digits only)
  const trimmedEan = ean.trim();
  if (!/^\d{8}$|^\d{13}$/.test(trimmedEan)) {
    return {
      ok: false,
      error: "invalid_ean",
      message:
        "EAN must be exactly 8 or 13 digits. Received: " + trimmedEan.length +
        " characters.",
    };
  }

  // Forward to RPC
  const { data, error } = await supabase.rpc("api_record_scan", {
    p_ean: trimmedEan,
  });

  if (error) {
    return {
      ok: false,
      error: "rpc_error",
      message: error.message ?? "Failed to record scan",
    };
  }

  return { ok: true, data };
}

// ─── Action Router ──────────────────────────────────────────────────────────

const ACTION_HANDLERS: Record<
  string,
  (
    supabase: ReturnType<typeof createClient>,
    body: GatewayRequest,
  ) => Promise<GatewayResponse>
> = {
  "record-scan": handleRecordScan,
};

// ─── JWT User ID Extraction ─────────────────────────────────────────────────

function extractUserIdFromJwt(jwt: string): string | null {
  try {
    // JWT format: header.payload.signature
    const parts = jwt.split(".");
    if (parts.length !== 3) return null;

    // Decode payload (base64url)
    const payload = parts[1]
      .replace(/-/g, "+")
      .replace(/_/g, "/");
    const decoded = atob(payload);
    const parsed = JSON.parse(decoded);

    return parsed.sub ?? null;
  } catch {
    return null;
  }
}

// ─── CORS Headers ───────────────────────────────────────────────────────────

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

// ─── Main Handler ───────────────────────────────────────────────────────────

Deno.serve(async (req: Request) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: CORS_HEADERS });
  }

  // Only accept POST
  if (req.method !== "POST") {
    return new Response(
      JSON.stringify({
        ok: false,
        error: "method_not_allowed",
        message: "Only POST requests are accepted",
      } satisfies GatewayError),
      {
        status: 405,
        headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
      },
    );
  }

  // ── Step 1: Extract and validate JWT ──────────────────────────────────
  const authHeader = req.headers.get("Authorization");
  if (!authHeader?.startsWith("Bearer ")) {
    return new Response(
      JSON.stringify({
        ok: false,
        error: "unauthorized",
        message: "Missing or invalid Authorization header",
      } satisfies GatewayError),
      {
        status: 401,
        headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
      },
    );
  }

  const jwt = authHeader.slice(7);
  const userId = extractUserIdFromJwt(jwt);
  if (!userId) {
    return new Response(
      JSON.stringify({
        ok: false,
        error: "unauthorized",
        message: "Invalid or expired JWT token",
      } satisfies GatewayError),
      {
        status: 401,
        headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
      },
    );
  }

  // ── Step 2: Parse request body ────────────────────────────────────────
  let body: GatewayRequest;
  try {
    body = await req.json();
  } catch {
    return new Response(
      JSON.stringify({
        ok: false,
        error: "invalid_request",
        message: "Request body must be valid JSON",
      } satisfies GatewayError),
      {
        status: 400,
        headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
      },
    );
  }

  // ── Step 3: Validate action ───────────────────────────────────────────
  const { action } = body;
  if (!action || typeof action !== "string") {
    return new Response(
      JSON.stringify({
        ok: false,
        error: "invalid_request",
        message:
          "Missing 'action' field in request body. Valid actions: " +
          Object.keys(ACTION_HANDLERS).join(", "),
      } satisfies GatewayError),
      {
        status: 400,
        headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
      },
    );
  }

  const handler = ACTION_HANDLERS[action];
  if (!handler) {
    return new Response(
      JSON.stringify({
        ok: false,
        error: "unknown_action",
        message:
          `Unknown action '${action}'. Valid actions: ` +
          Object.keys(ACTION_HANDLERS).join(", "),
      } satisfies GatewayError),
      {
        status: 400,
        headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
      },
    );
  }

  // ── Step 4: Rate limit check ──────────────────────────────────────────
  const rateConfig = RATE_LIMITS[action];
  if (rateConfig) {
    const result = checkRateLimit(userId, action, rateConfig);
    if (!result.allowed) {
      return new Response(
        JSON.stringify({
          ok: false,
          error: "rate_limit_exceeded",
          message:
            `You have exceeded the limit of ${rateConfig.max_requests} requests per ${Math.floor(rateConfig.window_seconds / 3600)} hours for '${action}'. Try again later.`,
          retry_after: result.retry_after,
        } satisfies GatewayError),
        {
          status: 429,
          headers: {
            ...CORS_HEADERS,
            "Content-Type": "application/json",
            "Retry-After": String(result.retry_after ?? 3600),
          },
        },
      );
    }
  }

  // ── Step 5: Create authenticated Supabase client ──────────────────────
  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY")!;

  const supabase = createClient(supabaseUrl, supabaseAnonKey, {
    global: {
      headers: { Authorization: `Bearer ${jwt}` },
    },
  });

  // ── Step 6: Execute action handler ────────────────────────────────────
  try {
    const response = await handler(supabase, body);
    const status = response.ok ? 200 : 400;

    return new Response(JSON.stringify(response), {
      status,
      headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
    });
  } catch (err) {
    console.error(`Gateway error for action '${action}':`, err);
    return new Response(
      JSON.stringify({
        ok: false,
        error: "internal_error",
        message: "An unexpected error occurred. Please try again later.",
      } satisfies GatewayError),
      {
        status: 500,
        headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
      },
    );
  }
});
