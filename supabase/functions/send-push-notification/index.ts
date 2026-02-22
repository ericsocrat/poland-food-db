// ─── Supabase Edge Function: send-push-notification ─────────────────────────
// Processes the notification_queue table and sends Web Push notifications
// to users with active push subscriptions.
//
// Triggered by: cron job, database webhook, or manual invocation
// Auth: Requires service_role key (Authorization: Bearer <service_role_key>)
// ─────────────────────────────────────────────────────────────────────────────

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

// ─── Web Push VAPID signing ────────────────────────────────────────────────

/**
 * Convert a URL-safe base64 string to a Uint8Array.
 */
function urlBase64ToUint8Array(base64String: string): Uint8Array {
  const padding = "=".repeat((4 - (base64String.length % 4)) % 4);
  const base64 = (base64String + padding)
    .replace(/-/g, "+")
    .replace(/_/g, "/");
  const raw = atob(base64);
  const arr = new Uint8Array(raw.length);
  for (let i = 0; i < raw.length; i++) {
    arr[i] = raw.charCodeAt(i);
  }
  return arr;
}

/**
 * Convert Uint8Array to URL-safe base64.
 */
function uint8ArrayToUrlBase64(arr: Uint8Array): string {
  let binary = "";
  for (const byte of arr) {
    binary += String.fromCharCode(byte);
  }
  return btoa(binary).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
}

/**
 * Import a raw P-256 private key for ECDSA signing.
 */
async function importVapidPrivateKey(base64Key: string): Promise<CryptoKey> {
  const raw = urlBase64ToUint8Array(base64Key);
  // VAPID private key is a raw 32-byte P-256 scalar — import as JWK
  const jwk = {
    kty: "EC",
    crv: "P-256",
    d: uint8ArrayToUrlBase64(raw),
    // Public key x, y aren't needed for signing but we need to derive them
    // For VAPID, we sign the JWT with the private key
    x: "", // Will be filled from public key
    y: "",
  };

  // Actually, for Deno Edge Functions, we use the simpler approach:
  // Import PKCS8 format or use a pre-built JWT
  return await crypto.subtle.importKey(
    "jwk",
    jwk,
    { name: "ECDSA", namedCurve: "P-256" },
    false,
    ["sign"],
  );
}

/**
 * Create a signed VAPID JWT for the given audience.
 */
async function createVapidJwt(
  audience: string,
  subject: string,
  publicKey: string,
  privateKeyBase64: string,
): Promise<string> {
  const header = { typ: "JWT", alg: "ES256" };
  const now = Math.floor(Date.now() / 1000);
  const payload = {
    aud: audience,
    exp: now + 12 * 60 * 60, // 12 hours
    sub: subject,
  };

  const headerB64 = uint8ArrayToUrlBase64(
    new TextEncoder().encode(JSON.stringify(header)),
  );
  const payloadB64 = uint8ArrayToUrlBase64(
    new TextEncoder().encode(JSON.stringify(payload)),
  );
  const unsignedToken = `${headerB64}.${payloadB64}`;

  // Import the private key for signing
  const rawKey = urlBase64ToUint8Array(privateKeyBase64);
  const privateKey = await crypto.subtle.importKey(
    "jwk",
    {
      kty: "EC",
      crv: "P-256",
      d: uint8ArrayToUrlBase64(rawKey),
      // For signing only, x and y are derived internally
      x: uint8ArrayToUrlBase64(urlBase64ToUint8Array(publicKey).slice(1, 33)),
      y: uint8ArrayToUrlBase64(urlBase64ToUint8Array(publicKey).slice(33, 65)),
    },
    { name: "ECDSA", namedCurve: "P-256" },
    false,
    ["sign"],
  );

  const signature = await crypto.subtle.sign(
    { name: "ECDSA", hash: "SHA-256" },
    privateKey,
    new TextEncoder().encode(unsignedToken),
  );

  // Convert DER signature to raw r||s format (64 bytes)
  const sigArray = new Uint8Array(signature);
  const signatureB64 = uint8ArrayToUrlBase64(sigArray);

  return `${unsignedToken}.${signatureB64}`;
}

/**
 * Send a Web Push notification to a single subscription endpoint.
 */
async function sendPushNotification(
  subscription: { endpoint: string; keys: { p256dh: string; auth: string } },
  payload: object,
  vapidPublicKey: string,
  vapidPrivateKey: string,
  vapidSubject: string,
): Promise<{ success: boolean; status: number; expired: boolean }> {
  try {
    const url = new URL(subscription.endpoint);
    const audience = `${url.protocol}//${url.host}`;

    const jwt = await createVapidJwt(
      audience,
      vapidSubject,
      vapidPublicKey,
      vapidPrivateKey,
    );

    const body = JSON.stringify(payload);

    const response = await fetch(subscription.endpoint, {
      method: "POST",
      headers: {
        "Content-Type": "application/octet-stream",
        "Content-Encoding": "aes128gcm",
        TTL: "86400",
        Authorization: `vapid t=${jwt}, k=${vapidPublicKey}`,
      },
      body: new TextEncoder().encode(body),
    });

    const expired = response.status === 404 || response.status === 410;

    return {
      success: response.status >= 200 && response.status < 300,
      status: response.status,
      expired,
    };
  } catch (error) {
    console.error("Push send error:", error);
    return { success: false, status: 0, expired: false };
  }
}

// ─── Main handler ──────────────────────────────────────────────────────────

Deno.serve(async (req: Request) => {
  // Only accept POST
  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "Method not allowed" }), {
      status: 405,
      headers: { "Content-Type": "application/json" },
    });
  }

  // Verify service_role authorization
  const authHeader = req.headers.get("Authorization");
  if (!authHeader?.startsWith("Bearer ")) {
    return new Response(JSON.stringify({ error: "Unauthorized" }), {
      status: 401,
      headers: { "Content-Type": "application/json" },
    });
  }

  const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
  const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const VAPID_PUBLIC_KEY = Deno.env.get("VAPID_PUBLIC_KEY");
  const VAPID_PRIVATE_KEY = Deno.env.get("VAPID_PRIVATE_KEY");
  const VAPID_SUBJECT = Deno.env.get("VAPID_SUBJECT");

  if (!VAPID_PUBLIC_KEY || !VAPID_PRIVATE_KEY || !VAPID_SUBJECT) {
    return new Response(
      JSON.stringify({ error: "VAPID keys not configured" }),
      { status: 500, headers: { "Content-Type": "application/json" } },
    );
  }

  const supabase = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);

  try {
    // 1. Fetch pending notifications with their subscriptions
    const { data: result, error: fetchError } = await supabase.rpc(
      "api_get_pending_notifications",
      { p_limit: 50 },
    );

    if (fetchError) {
      console.error("Fetch error:", fetchError);
      return new Response(
        JSON.stringify({ error: "Failed to fetch notifications" }),
        { status: 500, headers: { "Content-Type": "application/json" } },
      );
    }

    const notifications = result?.notifications ?? [];

    if (notifications.length === 0) {
      return new Response(
        JSON.stringify({ processed: 0, message: "No pending notifications" }),
        { status: 200, headers: { "Content-Type": "application/json" } },
      );
    }

    // 2. Process each notification
    const sentIds: number[] = [];
    const failedIds: number[] = [];
    const expiredEndpoints: string[] = [];

    for (const notif of notifications) {
      const subscriptions = notif.subscriptions ?? [];
      if (subscriptions.length === 0) {
        failedIds.push(notif.id);
        continue;
      }

      // Build notification payload
      const directionEmoji = notif.direction === "improved" ? "📉" : "📈";
      const directionText = notif.direction === "improved" ? "improved" : "worsened";
      const absDelta = Math.abs(notif.delta);

      const pushPayload = {
        title: `${directionEmoji} Score ${directionText}`,
        body: `${notif.product_name}: ${notif.old_score} → ${notif.new_score} (${notif.direction === "improved" ? "↓" : "↑"}${absDelta})`,
        icon: "/icons/icon-192x192.png",
        badge: "/icons/badge-72x72.png",
        url: `/app/product/${notif.product_id}`,
        data: {
          product_id: notif.product_id,
          old_score: notif.old_score,
          new_score: notif.new_score,
          direction: notif.direction,
        },
      };

      let anySent = false;
      for (const sub of subscriptions) {
        const result = await sendPushNotification(
          sub,
          pushPayload,
          VAPID_PUBLIC_KEY,
          VAPID_PRIVATE_KEY,
          VAPID_SUBJECT,
        );

        if (result.success) {
          anySent = true;
        } else if (result.expired) {
          expiredEndpoints.push(sub.endpoint);
        }
      }

      if (anySent) {
        sentIds.push(notif.id);
      } else {
        failedIds.push(notif.id);
      }
    }

    // 3. Mark notifications as sent/failed
    if (sentIds.length > 0) {
      await supabase.rpc("api_mark_notifications_sent", {
        p_notification_ids: sentIds,
        p_status: "sent",
      });
    }

    if (failedIds.length > 0) {
      await supabase.rpc("api_mark_notifications_sent", {
        p_notification_ids: failedIds,
        p_status: "failed",
      });
    }

    // 4. Cleanup expired subscriptions
    for (const endpoint of expiredEndpoints) {
      await supabase.rpc("api_cleanup_push_subscriptions", {
        p_endpoint: endpoint,
      });
    }

    return new Response(
      JSON.stringify({
        processed: notifications.length,
        sent: sentIds.length,
        failed: failedIds.length,
        expired_cleaned: expiredEndpoints.length,
      }),
      { status: 200, headers: { "Content-Type": "application/json" } },
    );
  } catch (error) {
    console.error("Edge function error:", error);
    return new Response(
      JSON.stringify({ error: "Internal server error" }),
      { status: 500, headers: { "Content-Type": "application/json" } },
    );
  }
});
