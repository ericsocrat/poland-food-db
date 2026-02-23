// ─── Push notification manager ──────────────────────────────────────────────
// Client-side utilities for Web Push API subscription management.
// All functions are designed to be called from React components.
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Check if the Push API is supported in this browser.
 */
export function isPushSupported(): boolean {
  if (globalThis.window === undefined) return false;
  return (
    "serviceWorker" in navigator &&
    globalThis.PushManager !== undefined &&
    globalThis.Notification !== undefined
  );
}

/**
 * Get the current notification permission state.
 * Returns "default" | "granted" | "denied" or "unsupported".
 */
export function getNotificationPermission(): NotificationPermission | "unsupported" {
  if (globalThis.window === undefined || globalThis.Notification === undefined) {
    return "unsupported";
  }
  return Notification.permission;
}

/**
 * Request notification permission from the user.
 * Returns the permission result: "granted" | "denied" | "default".
 */
export async function requestNotificationPermission(): Promise<NotificationPermission> {
  if (!isPushSupported()) {
    return "denied";
  }
  return await Notification.requestPermission();
}

/**
 * Convert a URL-safe base64 VAPID public key to a Uint8Array
 * for use with PushManager.subscribe().
 */
export function urlBase64ToUint8Array(base64String: string): Uint8Array {
  const padding = "=".repeat((4 - (base64String.length % 4)) % 4);
  const base64 = (base64String + padding)
    .replaceAll("-", "+")
    .replaceAll("_", "/");
  const rawData = atob(base64);
  const outputArray = new Uint8Array(rawData.length);
  for (let i = 0; i < rawData.length; i++) {
    outputArray[i] = rawData.codePointAt(i)!;
  }
  return outputArray;
}

/**
 * Get the active service worker registration.
 * Returns null if no service worker is registered.
 */
async function getServiceWorkerRegistration(): Promise<ServiceWorkerRegistration | null> {
  if (!("serviceWorker" in navigator)) return null;
  try {
    return await navigator.serviceWorker.ready;
  } catch {
    return null;
  }
}

/**
 * Get the current push subscription, if any.
 */
export async function getCurrentPushSubscription(): Promise<PushSubscription | null> {
  const registration = await getServiceWorkerRegistration();
  if (!registration) return null;
  try {
    return await registration.pushManager.getSubscription();
  } catch {
    return null;
  }
}

/**
 * Subscribe to push notifications.
 * Requires notification permission to be "granted".
 * Returns the PushSubscription or null on failure.
 */
export async function subscribeToPush(
  vapidPublicKey: string,
): Promise<PushSubscription | null> {
  const registration = await getServiceWorkerRegistration();
  if (!registration) return null;

  try {
    const subscription = await registration.pushManager.subscribe({
      userVisibleOnly: true,
      applicationServerKey: urlBase64ToUint8Array(vapidPublicKey).buffer as ArrayBuffer,
    });
    return subscription;
  } catch (error) {
    console.error("Push subscription failed:", error);
    return null;
  }
}

/**
 * Unsubscribe from push notifications.
 * Returns true if successfully unsubscribed.
 */
export async function unsubscribeFromPush(): Promise<boolean> {
  const subscription = await getCurrentPushSubscription();
  if (!subscription) return true; // Already unsubscribed

  try {
    return await subscription.unsubscribe();
  } catch (error) {
    console.error("Push unsubscribe failed:", error);
    return false;
  }
}

/**
 * Extract the subscription data needed for the backend.
 */
export function extractSubscriptionData(subscription: PushSubscription): {
  endpoint: string;
  p256dh: string;
  auth: string;
} | null {
  const key_p256dh = subscription.getKey("p256dh");
  const key_auth = subscription.getKey("auth");

  if (!key_p256dh || !key_auth) return null;

  return {
    endpoint: subscription.endpoint,
    p256dh: arrayBufferToBase64(key_p256dh),
    auth: arrayBufferToBase64(key_auth),
  };
}

/**
 * Convert an ArrayBuffer to URL-safe base64 string.
 */
function arrayBufferToBase64(buffer: ArrayBuffer): string {
  const bytes = new Uint8Array(buffer);
  let binary = "";
  for (const byte of bytes) {
    binary += String.fromCodePoint(byte);
  }
  return btoa(binary).replaceAll("+", "-").replaceAll("/", "_").replaceAll("=", "");
}
