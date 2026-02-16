"use client";

import { useRef, useCallback, useEffect, useState } from "react";
import { createClient } from "@/lib/supabase/client";
import { trackEvent } from "@/lib/api";
import type { AnalyticsEventName, DeviceType } from "@/lib/types";

// ─── Helpers ────────────────────────────────────────────────────────────────

function generateSessionId(): string {
  return `${Date.now()}-${Math.random().toString(36).slice(2, 10)}`;
}

function detectDeviceType(): DeviceType {
  if (typeof window === "undefined") return "desktop";
  const w = window.innerWidth;
  if (w < 768) return "mobile";
  if (w < 1024) return "tablet";
  return "desktop";
}

// ─── Session persistence ────────────────────────────────────────────────────

const SESSION_KEY = "analytics_session_id";

function getOrCreateSessionId(): string {
  if (typeof window === "undefined") return generateSessionId();
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
