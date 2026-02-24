"use client";

import { useRef, useCallback, useEffect, useState } from "react";
import { createClient } from "@/lib/supabase/client";
import { trackEvent } from "@/lib/api";
import { IS_QA_MODE } from "@/lib/qa-mode";
import type { AnalyticsEventName, DeviceType } from "@/lib/types";

// ─── Helpers ────────────────────────────────────────────────────────────────

function generateSessionId(): string {
  // Use crypto.randomUUID() instead of Math.random() to satisfy
  // SonarCloud rule typescript:S2245 (no weak PRNG).
  const suffix =
    typeof crypto !== "undefined" && typeof crypto.randomUUID === "function"
      ? crypto.randomUUID().slice(0, 8)
      : "fallback0";
  return `${Date.now()}-${suffix}`;
}

function detectDeviceType(): DeviceType {
  if (globalThis.window === undefined) return "desktop";
  const w = globalThis.innerWidth;
  if (w < 768) return "mobile";
  if (w < 1024) return "tablet";
  return "desktop";
}

// ─── Session persistence ────────────────────────────────────────────────────

const SESSION_KEY = "analytics_session_id";

function getOrCreateSessionId(): string {
  if (globalThis.window === undefined) return generateSessionId();
  const existing = sessionStorage.getItem(SESSION_KEY);
  if (existing) return existing;
  const id = generateSessionId();
  sessionStorage.setItem(SESSION_KEY, id);
  return id;
}

// ─── Hook ───────────────────────────────────────────────────────────────────

export function useAnalytics() {
  const supabaseRef = useRef(createClient());
  const sessionIdRef = useRef<string>("");
  const [deviceType, setDeviceType] = useState<DeviceType>("desktop");

  useEffect(() => {
    sessionIdRef.current = getOrCreateSessionId();
    setDeviceType(detectDeviceType());
  }, []);

  const track = useCallback(
    (eventName: AnalyticsEventName, eventData?: Record<string, unknown>) => {
      // Suppress all analytics in QA mode for deterministic audits (#173)
      if (IS_QA_MODE) return;
      // Fire-and-forget — never block UI on analytics
      trackEvent(supabaseRef.current, {
        eventName,
        eventData,
        sessionId: sessionIdRef.current,
        deviceType,
      }).catch(() => {
        // Silently swallow — analytics must never break the app
      });
    },
    [deviceType],
  );

  return { track };
}
