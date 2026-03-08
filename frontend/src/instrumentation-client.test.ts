import { beforeEach, describe, expect, it, vi } from "vitest";

// ─── Mocks ──────────────────────────────────────────────────────────────────

const mockInit = vi.fn();
const mockCaptureRouterTransitionStart = vi.fn();

vi.mock("@sentry/nextjs", () => ({
  init: (...args: unknown[]) => mockInit(...args),
  captureRouterTransitionStart: mockCaptureRouterTransitionStart,
}));

// ─── Tests ──────────────────────────────────────────────────────────────────

describe("instrumentation-client", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    vi.resetModules();
  });

  it("calls Sentry.init with expected configuration", async () => {
    await import("./instrumentation-client");

    expect(mockInit).toHaveBeenCalledTimes(1);
    const config = mockInit.mock.calls[0][0];
    expect(config).toMatchObject({
      replaysSessionSampleRate: 0,
      replaysOnErrorSampleRate: 0,
    });
    expect(config.beforeSend).toBeTypeOf("function");
    expect(config.ignoreErrors).toBeInstanceOf(Array);
    expect(config.ignoreErrors.length).toBeGreaterThanOrEqual(4);
  });

  it("beforeSend strips email and ip_address from user context", async () => {
    await import("./instrumentation-client");

    const config = mockInit.mock.calls[0][0];
    const event = {
      user: { id: "u1", email: "a@b.com", ip_address: "1.2.3.4" },
    };
    const result = config.beforeSend(event);

    expect(result.user.id).toBe("u1");
    expect(result.user.email).toBeUndefined();
    expect(result.user.ip_address).toBeUndefined();
  });

  it("beforeSend filters health-related breadcrumbs", async () => {
    await import("./instrumentation-client");

    const config = mockInit.mock.calls[0][0];
    const event = {
      breadcrumbs: [
        { message: "navigated to /app" },
        { message: "fetched health_profile data" },
        { message: "clicked button" },
        { message: "loaded allergen list" },
        { message: "checked health_condition" },
      ],
    };
    const result = config.beforeSend(event);

    expect(result.breadcrumbs).toHaveLength(2);
    expect(result.breadcrumbs[0].message).toBe("navigated to /app");
    expect(result.breadcrumbs[1].message).toBe("clicked button");
  });

  it("exports onRouterTransitionStart from Sentry", async () => {
    const mod = await import("./instrumentation-client");

    expect(mod.onRouterTransitionStart).toBe(
      mockCaptureRouterTransitionStart,
    );
  });
});
