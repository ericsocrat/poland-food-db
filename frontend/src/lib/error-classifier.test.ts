import { describe, expect, it } from "vitest";
import { classifyError, type ErrorCategory } from "./error-classifier";

// ─── Helpers ────────────────────────────────────────────────────────────────

function errorWith(message: string, name = "Error"): Error {
  const e = new Error(message);
  e.name = name;
  return e;
}

// ─── Network errors ─────────────────────────────────────────────────────────

describe("classifyError — network", () => {
  const networkMessages = [
    "Failed to fetch",
    "TypeError: NetworkError when attempting to fetch resource",
    "Network request failed",
    "Load failed",
    "net::ERR_CONNECTION_REFUSED",
    "ECONNREFUSED",
    "DNS_PROBE_FINISHED_NXDOMAIN",
    "ERR_INTERNET_DISCONNECTED",
    "ERR_NETWORK_CHANGED",
    "The Internet connection appears to be offline",
    "A network error occurred",
    "Request timed out",
    "Connection timed out",
  ];

  it.each(networkMessages)('classifies "%s" as network', (msg) => {
    expect(classifyError(errorWith(msg))).toBe("network");
  });

  it("detects network from error name", () => {
    expect(classifyError(errorWith("something", "NetworkError"))).toBe(
      "network",
    );
  });
});

// ─── Auth errors ────────────────────────────────────────────────────────────

describe("classifyError — auth", () => {
  const authMessages = [
    "JWT expired",
    "Invalid JWT token",
    "Not authenticated",
    "Unauthorized",
    "403 Forbidden",
    "401 Unauthorized",
    "Auth session missing",
    "Permission denied",
    "Access denied",
    "Invalid login credentials",
    "Session expired",
    "Invalid refresh_token",
    "PGRST301: JWTExpired",
  ];

  it.each(authMessages)('classifies "%s" as auth', (msg) => {
    expect(classifyError(errorWith(msg))).toBe("auth");
  });
});

// ─── Server errors ──────────────────────────────────────────────────────────

describe("classifyError — server", () => {
  const serverMessages = [
    "500 Internal Server Error",
    "502 Bad Gateway",
    "503 Service Unavailable",
    "504 Gateway Timeout",
    "Internal server error",
  ];

  it.each(serverMessages)('classifies "%s" as server', (msg) => {
    expect(classifyError(errorWith(msg))).toBe("server");
  });
});

// ─── Unknown errors ─────────────────────────────────────────────────────────

describe("classifyError — unknown", () => {
  const unknownMessages = [
    "Cannot read properties of undefined",
    "Something broke",
    "Rendering failed",
    "",
  ];

  it.each(unknownMessages)('classifies "%s" as unknown', (msg) => {
    expect(classifyError(errorWith(msg))).toBe("unknown");
  });
});

// ─── Priority: network > auth ───────────────────────────────────────────────

describe("classifyError — priority", () => {
  it("network takes priority over auth when both patterns match", () => {
    // "failed to fetch" is network, "401" is auth — network wins
    const e = errorWith("failed to fetch: 401 Unauthorized");
    expect(classifyError(e)).toBe("network");
  });

  it("auth takes priority over server", () => {
    const e = errorWith("JWT expired (500)");
    expect(classifyError(e)).toBe("auth");
  });

  it("504 Gateway Timeout is server, not network", () => {
    const e = errorWith("504 Gateway Timeout");
    expect(classifyError(e)).toBe("server");
  });
});

// ─── Type safety ────────────────────────────────────────────────────────────

describe("classifyError — type", () => {
  it("returns a valid ErrorCategory", () => {
    const categories: ErrorCategory[] = [
      "network",
      "auth",
      "server",
      "unknown",
    ];
    const result = classifyError(new Error("anything"));
    expect(categories).toContain(result);
  });
});
