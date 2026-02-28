// ─── Supabase Edge Function: api-gateway ────────────────────────────────────
// Centralized write-path gateway for rate limiting, input validation, and
// request forwarding. Read operations bypass this gateway entirely.
//
// Phase 1: record-scan rate limiting (100/day/user)
// Phase 2: submit-product protection (EAN checksum, sanitization, 10/day)
// Phase 4: track-event (10K/day) + save-search (50/day) rate limiting
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
  "submit-product": { max_requests: 10, window_seconds: 86400 }, // 10/day
  "track-event": { max_requests: 10000, window_seconds: 86400 }, // 10K/day
  "save-search": { max_requests: 50, window_seconds: 86400 }, // 50/day
};

// ─── EAN Checksum Validation (GS1 Algorithm) ────────────────────────────────

/**
 * Validate EAN-8 or EAN-13 barcode using GS1 checksum algorithm.
 * Port of the PostgreSQL is_valid_ean() function.
 */
function isValidEan(ean: string): boolean {
  if (!/^\d{8}$|^\d{13}$/.test(ean)) return false;

  let sum = 0;
  for (let i = 0; i < ean.length; i++) {
    const digit = parseInt(ean[i], 10);
    let weight: number;
    if (ean.length === 13) {
      weight = (i + 1) % 2 === 1 ? 1 : 3;
    } else {
      // EAN-8: weights 3, 1, 3, 1, ...
      weight = (i + 1) % 2 === 1 ? 3 : 1;
    }
    sum += digit * weight;
  }

  return sum % 10 === 0;
}

// ─── Input Sanitization ─────────────────────────────────────────────────────

/** Max allowed length for text fields in product submissions. */
const FIELD_LIMITS = {
  product_name: 200,
  brand: 100,
  category: 50,
  photo_url: 500,
  notes: 1000,
} as const;

/** Characters that are never valid in product submission fields. */
const FORBIDDEN_PATTERN = /[<>{}\\]/;

/**
 * Sanitize a text input: trim, reject forbidden characters, enforce length cap.
 * Returns null for empty/null inputs or the sanitized string.
 */
function sanitizeField(
  value: unknown,
  maxLength: number,
): { valid: true; value: string | null } | { valid: false; reason: string } {
  if (value === null || value === undefined || value === "") {
    return { valid: true, value: null };
  }
  if (typeof value !== "string") {
    return { valid: false, reason: "must be a string" };
  }
  const trimmed = value.trim();
  if (trimmed === "") {
    return { valid: true, value: null };
  }
  if (trimmed.length > maxLength) {
    return {
      valid: false,
      reason: `exceeds maximum length of ${maxLength} characters`,
    };
  }
  if (FORBIDDEN_PATTERN.test(trimmed)) {
    return {
      valid: false,
      reason: "contains forbidden characters (< > { } \\)",
    };
  }
  return { valid: true, value: trimmed };
}

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

// ─── Submit Product Handler ─────────────────────────────────────────────────

async function handleSubmitProduct(
  supabase: ReturnType<typeof createClient>,
  body: GatewayRequest,
): Promise<GatewayResponse> {
  // ── EAN validation ────────────────────────────────────────────────────
  const ean = body.ean;
  if (!ean || typeof ean !== "string") {
    return {
      ok: false,
      error: "invalid_input",
      message: "Missing or invalid 'ean' parameter. Must be a non-empty string.",
    };
  }

  const trimmedEan = ean.trim();
  if (!/^\d{8}$|^\d{13}$/.test(trimmedEan)) {
    return {
      ok: false,
      error: "invalid_ean",
      message:
        "EAN must be exactly 8 or 13 digits. Received: " +
        trimmedEan.length +
        " characters.",
    };
  }

  // GS1 checksum validation (before hitting the database)
  if (!isValidEan(trimmedEan)) {
    return {
      ok: false,
      error: "invalid_ean_checksum",
      message:
        "EAN checksum is invalid. Please verify the barcode and try again.",
    };
  }

  // ── Product name validation ───────────────────────────────────────────
  const productName = body.product_name;
  if (!productName || typeof productName !== "string" || productName.trim() === "") {
    return {
      ok: false,
      error: "invalid_input",
      message: "Missing or empty 'product_name' parameter.",
    };
  }

  const nameResult = sanitizeField(productName, FIELD_LIMITS.product_name);
  if (!nameResult.valid) {
    return {
      ok: false,
      error: "invalid_input",
      message: `Product name ${nameResult.reason}.`,
    };
  }

  // ── Optional field sanitization ───────────────────────────────────────
  const brandResult = sanitizeField(body.brand, FIELD_LIMITS.brand);
  if (!brandResult.valid) {
    return {
      ok: false,
      error: "invalid_input",
      message: `Brand ${brandResult.reason}.`,
    };
  }

  const categoryResult = sanitizeField(body.category, FIELD_LIMITS.category);
  if (!categoryResult.valid) {
    return {
      ok: false,
      error: "invalid_input",
      message: `Category ${categoryResult.reason}.`,
    };
  }

  const photoResult = sanitizeField(body.photo_url, FIELD_LIMITS.photo_url);
  if (!photoResult.valid) {
    return {
      ok: false,
      error: "invalid_input",
      message: `Photo URL ${photoResult.reason}.`,
    };
  }

  const notesResult = sanitizeField(body.notes, FIELD_LIMITS.notes);
  if (!notesResult.valid) {
    return {
      ok: false,
      error: "invalid_input",
      message: `Notes ${notesResult.reason}.`,
    };
  }

  // ── Forward to RPC ────────────────────────────────────────────────────
  const { data, error } = await supabase.rpc("api_submit_product", {
    p_ean: trimmedEan,
    p_product_name: nameResult.value,
    p_brand: brandResult.value,
    p_category: categoryResult.value,
    p_photo_url: photoResult.value,
    p_notes: notesResult.value,
  });

  if (error) {
    return {
      ok: false,
      error: "rpc_error",
      message: error.message ?? "Failed to submit product",
    };
  }

  return { ok: true, data };
}

// ─── Track Event Handler ────────────────────────────────────────────────────

const VALID_DEVICE_TYPES = ["mobile", "tablet", "desktop"] as const;

async function handleTrackEvent(
  supabase: ReturnType<typeof createClient>,
  body: GatewayRequest,
): Promise<GatewayResponse> {
  // Validate event_name (required, non-empty string)
  const eventName = body.event_name;
  if (!eventName || typeof eventName !== "string" || eventName.trim() === "") {
    return {
      ok: false,
      error: "invalid_input",
      message: "Missing or empty 'event_name' parameter.",
    };
  }

  // Validate event_name length
  const trimmedName = eventName.trim();
  if (trimmedName.length > 100) {
    return {
      ok: false,
      error: "invalid_input",
      message: "Event name exceeds maximum length of 100 characters.",
    };
  }

  // Validate event_data (optional, must be object if provided)
  const eventData = body.event_data ?? {};
  if (typeof eventData !== "object" || Array.isArray(eventData) || eventData === null) {
    return {
      ok: false,
      error: "invalid_input",
      message: "'event_data' must be a JSON object.",
    };
  }

  // Validate event_data size (prevent oversized payloads)
  const dataStr = JSON.stringify(eventData);
  if (dataStr.length > 10000) {
    return {
      ok: false,
      error: "invalid_input",
      message: "'event_data' exceeds maximum size of 10KB.",
    };
  }

  // Validate device_type (optional, must be valid enum)
  const deviceType = body.device_type;
  if (
    deviceType !== undefined &&
    deviceType !== null &&
    (typeof deviceType !== "string" ||
      !VALID_DEVICE_TYPES.includes(deviceType as typeof VALID_DEVICE_TYPES[number]))
  ) {
    return {
      ok: false,
      error: "invalid_input",
      message:
        "Invalid 'device_type'. Must be one of: mobile, tablet, desktop.",
    };
  }

  // Validate session_id (optional, string, max 100 chars)
  const sessionId = body.session_id;
  if (sessionId !== undefined && sessionId !== null) {
    if (typeof sessionId !== "string" || sessionId.length > 100) {
      return {
        ok: false,
        error: "invalid_input",
        message: "'session_id' must be a string with at most 100 characters.",
      };
    }
  }

  // Forward to RPC
  const { data, error } = await supabase.rpc("api_track_event", {
    p_event_name: trimmedName,
    p_event_data: eventData,
    p_session_id: (sessionId as string) ?? null,
    p_device_type: (deviceType as string) ?? null,
  });

  if (error) {
    return {
      ok: false,
      error: "rpc_error",
      message: error.message ?? "Failed to track event",
    };
  }

  return { ok: true, data };
}

// ─── Save Search Handler ─────────────────────────────────────────────────────

async function handleSaveSearch(
  supabase: ReturnType<typeof createClient>,
  body: GatewayRequest,
): Promise<GatewayResponse> {
  // Validate name (required)
  const name = body.name;
  if (!name || typeof name !== "string" || name.trim() === "") {
    return {
      ok: false,
      error: "invalid_input",
      message: "Missing or empty 'name' parameter.",
    };
  }

  const nameResult = sanitizeField(name, 100);
  if (!nameResult.valid) {
    return {
      ok: false,
      error: "invalid_input",
      message: `Search name ${nameResult.reason}.`,
    };
  }

  // Validate query (optional string, max 200 chars)
  const queryResult = sanitizeField(body.query, 200);
  if (!queryResult.valid) {
    return {
      ok: false,
      error: "invalid_input",
      message: `Search query ${queryResult.reason}.`,
    };
  }

  // Validate filters (optional, must be object if provided)
  const filters = body.filters ?? {};
  if (typeof filters !== "object" || Array.isArray(filters) || filters === null) {
    return {
      ok: false,
      error: "invalid_input",
      message: "'filters' must be a JSON object.",
    };
  }

  // Forward to RPC
  const { data, error } = await supabase.rpc("api_save_search", {
    p_name: nameResult.value,
    p_query: queryResult.value,
    p_filters: filters,
  });

  if (error) {
    return {
      ok: false,
      error: "rpc_error",
      message: error.message ?? "Failed to save search",
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
  "submit-product": handleSubmitProduct,
  "track-event": handleTrackEvent,
  "save-search": handleSaveSearch,
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
