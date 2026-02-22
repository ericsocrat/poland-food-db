import { describe, it, expect } from "vitest";

// ─── Sentry PII Scrubbing Tests (#183) ─────────────────────────────────────
// Tests the beforeSend hook logic used across all Sentry configs.
// We extract and test the scrubbing logic directly rather than importing
// the config files (which call Sentry.init as a side effect).

// Replicate the beforeSend logic from sentry.client.config.ts
type SentryEvent = {
  user?: {
    id?: string;
    email?: string;
    ip_address?: string;
  };
  breadcrumbs?: Array<{
    message?: string;
    category?: string;
    timestamp?: number;
  }>;
};

/**
 * PII scrubbing function — mirrors the beforeSend in sentry.*.config.ts
 */
function scrubPII(event: SentryEvent): SentryEvent {
  if (event.user) {
    delete event.user.email;
    delete event.user.ip_address;
  }

  if (event.breadcrumbs) {
    event.breadcrumbs = event.breadcrumbs.filter(
      (b) =>
        !b.message?.includes("health_profile") &&
        !b.message?.includes("allergen") &&
        !b.message?.includes("health_condition"),
    );
  }

  return event;
}

describe("Sentry PII scrubbing (beforeSend)", () => {
  it("removes email from user context", () => {
    const event = scrubPII({
      user: { id: "user-123", email: "test@example.com" },
    });
    expect(event.user?.email).toBeUndefined();
    expect(event.user?.id).toBe("user-123");
  });

  it("removes ip_address from user context", () => {
    const event = scrubPII({
      user: { id: "user-123", ip_address: "192.168.1.1" },
    });
    expect(event.user?.ip_address).toBeUndefined();
  });

  it("preserves user ID", () => {
    const event = scrubPII({
      user: { id: "user-uuid", email: "a@b.com", ip_address: "1.2.3.4" },
    });
    expect(event.user?.id).toBe("user-uuid");
  });

  it("handles event with no user", () => {
    const event = scrubPII({ breadcrumbs: [] });
    expect(event.user).toBeUndefined();
  });

  it("filters breadcrumbs containing health_profile", () => {
    const event = scrubPII({
      breadcrumbs: [
        { message: "Fetching health_profile data", timestamp: 1 },
        { message: "Page loaded", timestamp: 2 },
      ],
    });
    expect(event.breadcrumbs).toHaveLength(1);
    expect(event.breadcrumbs![0].message).toBe("Page loaded");
  });

  it("filters breadcrumbs containing allergen", () => {
    const event = scrubPII({
      breadcrumbs: [
        { message: "RPC: get_allergen_matches", timestamp: 1 },
        { message: "Navigation: /search", timestamp: 2 },
      ],
    });
    expect(event.breadcrumbs).toHaveLength(1);
    expect(event.breadcrumbs![0].message).toBe("Navigation: /search");
  });

  it("filters breadcrumbs containing health_condition", () => {
    const event = scrubPII({
      breadcrumbs: [
        { message: "Updated health_condition preference", timestamp: 1 },
        { message: "Settings saved", timestamp: 2 },
      ],
    });
    expect(event.breadcrumbs).toHaveLength(1);
  });

  it("preserves non-health breadcrumbs", () => {
    const event = scrubPII({
      breadcrumbs: [
        { message: "Button clicked", timestamp: 1 },
        { message: "API call completed", timestamp: 2 },
        { message: "Route changed", timestamp: 3 },
      ],
    });
    expect(event.breadcrumbs).toHaveLength(3);
  });

  it("handles event with no breadcrumbs", () => {
    const event = scrubPII({ user: { id: "123" } });
    expect(event.breadcrumbs).toBeUndefined();
  });

  it("handles empty breadcrumbs array", () => {
    const event = scrubPII({ breadcrumbs: [] });
    expect(event.breadcrumbs).toHaveLength(0);
  });

  it("handles breadcrumbs with undefined message", () => {
    const event = scrubPII({
      breadcrumbs: [
        { category: "console", timestamp: 1 },
        { message: "health_profile update", timestamp: 2 },
      ],
    });
    // Breadcrumb with undefined message should pass (no match)
    expect(event.breadcrumbs).toHaveLength(1);
    expect(event.breadcrumbs![0].category).toBe("console");
  });
});
