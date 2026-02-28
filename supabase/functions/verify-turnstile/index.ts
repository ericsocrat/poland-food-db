// ─── Supabase Edge Function: verify-turnstile ───────────────────────────────
// Server-side Cloudflare Turnstile token verification endpoint.
// Called by the frontend before auth operations (signup, password reset)
// and conditionally before product submissions (low trust / high velocity).
//
// Cloudflare Turnstile test keys (for CI/development):
//   Site key:   1x00000000000000000000AA (always passes)
//   Secret key: 1x0000000000000000000000000000000AA (always passes)
//
// Issue: #470
// ─────────────────────────────────────────────────────────────────────────────

const TURNSTILE_VERIFY_URL =
  "https://challenges.cloudflare.com/turnstile/v0/siteverify";

interface TurnstileVerifyResponse {
  success: boolean;
  "error-codes"?: string[];
  challenge_ts?: string;
  hostname?: string;
  action?: string;
  cdata?: string;
}

interface VerifyRequest {
  token: string;
}

interface VerifySuccess {
  valid: true;
  challenge_ts?: string;
  hostname?: string;
}

interface VerifyFailure {
  valid: false;
  error: string;
  error_codes?: string[];
}

type VerifyResponse = VerifySuccess | VerifyFailure;

// ─── CORS Headers ───────────────────────────────────────────────────────────

const CORS_HEADERS: Record<string, string> = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function jsonResponse(body: VerifyResponse, status: number): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
  });
}

// ─── Main Handler ───────────────────────────────────────────────────────────

Deno.serve(async (req: Request): Promise<Response> => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: CORS_HEADERS });
  }

  // Only accept POST
  if (req.method !== "POST") {
    return jsonResponse(
      { valid: false, error: "Method not allowed. Use POST." },
      405,
    );
  }

  // Parse request body
  let body: VerifyRequest;
  try {
    body = await req.json();
  } catch {
    return jsonResponse(
      { valid: false, error: "Invalid JSON body." },
      400,
    );
  }

  // Validate token presence
  const token = body?.token;
  if (!token || typeof token !== "string" || token.trim().length === 0) {
    return jsonResponse(
      { valid: false, error: "Missing or empty Turnstile token." },
      400,
    );
  }

  // Get secret key from environment
  const secretKey = Deno.env.get("TURNSTILE_SECRET_KEY");
  if (!secretKey) {
    // Graceful degradation: if no secret key configured, allow through
    // This enables local development without Turnstile setup
    console.warn(
      "TURNSTILE_SECRET_KEY not set — allowing request (graceful degradation)",
    );
    return jsonResponse({ valid: true }, 200);
  }

  // Extract client IP for additional verification
  const ip =
    req.headers.get("cf-connecting-ip") ??
    req.headers.get("x-forwarded-for")?.split(",")[0]?.trim() ??
    "";

  // Verify token with Cloudflare
  try {
    const verifyResponse = await fetch(TURNSTILE_VERIFY_URL, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        secret: secretKey,
        response: token,
        remoteip: ip,
      }),
    });

    if (!verifyResponse.ok) {
      console.error(
        `Turnstile API returned ${verifyResponse.status}: ${verifyResponse.statusText}`,
      );
      // Graceful degradation on Turnstile API failure
      return jsonResponse({ valid: true }, 200);
    }

    const data: TurnstileVerifyResponse = await verifyResponse.json();

    if (data.success) {
      return jsonResponse(
        {
          valid: true,
          challenge_ts: data.challenge_ts,
          hostname: data.hostname,
        },
        200,
      );
    }

    return jsonResponse(
      {
        valid: false,
        error: "Turnstile verification failed.",
        error_codes: data["error-codes"],
      },
      403,
    );
  } catch (err) {
    // Graceful degradation: if Turnstile is unreachable, allow through
    console.error("Turnstile verification error:", err);
    return jsonResponse({ valid: true }, 200);
  }
});
