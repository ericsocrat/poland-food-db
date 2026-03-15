import { beforeEach, describe, expect, it, vi } from "vitest";

import {
    type ScannerErrorType,
    classifyScannerError,
    getBrowserSummary,
    getErrorMessageKey,
    getFacingMode,
} from "@/lib/scanner-errors";

// ─── classifyScannerError ───────────────────────────────────────────────────

describe("classifyScannerError", () => {
  it("returns 'permission-denied' for NotAllowedError", () => {
    const err = new DOMException("User denied", "NotAllowedError");
    expect(classifyScannerError(err)).toBe("permission-denied");
  });

  it("returns 'permission-denied' for PermissionDeniedError name", () => {
    const err = { name: "PermissionDeniedError", message: "" };
    expect(classifyScannerError(err)).toBe("permission-denied");
  });

  it("returns 'permission-denied' for message containing 'Permission denied'", () => {
    const err = new Error("Permission denied by system policy");
    expect(classifyScannerError(err)).toBe("permission-denied");
  });

  it("returns 'not-readable' for NotReadableError", () => {
    const err = new DOMException("Could not start source", "NotReadableError");
    expect(classifyScannerError(err)).toBe("not-readable");
  });

  it("returns 'not-readable' for TrackStartError", () => {
    const err = { name: "TrackStartError", message: "hardware error" };
    expect(classifyScannerError(err)).toBe("not-readable");
  });

  it("returns 'overconstrained' for OverconstrainedError", () => {
    const err = new DOMException("facingMode", "OverconstrainedError");
    expect(classifyScannerError(err)).toBe("overconstrained");
  });

  it("returns 'library-load' for TypeError with 'import' in message", () => {
    const err = new TypeError("Failed to fetch dynamically imported module");
    expect(classifyScannerError(err)).toBe("library-load");
  });

  it("returns 'unknown' for unrecognized errors", () => {
    const err = new Error("Something weird happened");
    expect(classifyScannerError(err)).toBe("unknown");
  });

  it("returns 'unknown' for null/undefined", () => {
    expect(classifyScannerError(null)).toBe("unknown");
    expect(classifyScannerError(undefined)).toBe("unknown");
  });

  it("returns 'unknown' for a string error", () => {
    expect(classifyScannerError("some error")).toBe("unknown");
  });
});

// ─── getErrorMessageKey ─────────────────────────────────────────────────────

describe("getErrorMessageKey", () => {
  const cases: [ScannerErrorType, string][] = [
    ["permission-denied", "scannerError.permissionDenied"],
    ["no-camera", "scannerError.noCamera"],
    ["not-readable", "scannerError.notReadable"],
    ["overconstrained", "scannerError.overconstrained"],
    ["stream-ended", "scannerError.streamEnded"],
    ["library-load", "scannerError.libraryLoad"],
    ["unknown", "scannerError.unknown"],
  ];

  it.each(cases)(
    "maps '%s' to '%s'",
    (errorType, expectedKey) => {
      expect(getErrorMessageKey(errorType)).toBe(expectedKey);
    },
  );
});

// ─── getBrowserSummary ──────────────────────────────────────────────────────

describe("getBrowserSummary", () => {
  const originalNavigator = globalThis.navigator;

  beforeEach(() => {
    vi.restoreAllMocks();
  });

  it("returns 'Chrome 120' for a Chrome UA", () => {
    Object.defineProperty(globalThis, "navigator", {
      value: {
        userAgent:
          "Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 Chrome/120.0.0.0 Mobile Safari/537.36",
      },
      configurable: true,
    });
    expect(getBrowserSummary()).toBe("Chrome 120");
    Object.defineProperty(globalThis, "navigator", {
      value: originalNavigator,
      configurable: true,
    });
  });

  it("returns 'Safari 17' for a Safari UA", () => {
    Object.defineProperty(globalThis, "navigator", {
      value: {
        userAgent:
          "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0) AppleWebKit/605.1.15 Version/17.0 Safari/605.1.15",
      },
      configurable: true,
    });
    expect(getBrowserSummary()).toBe("Safari 17");
    Object.defineProperty(globalThis, "navigator", {
      value: originalNavigator,
      configurable: true,
    });
  });

  it("returns 'Edge 120' for an Edge UA", () => {
    Object.defineProperty(globalThis, "navigator", {
      value: {
        userAgent:
          "Mozilla/5.0 Chrome/120.0.0.0 Safari/537.36 Edg/120.0.0.0",
      },
      configurable: true,
    });
    expect(getBrowserSummary()).toBe("Edge 120");
    Object.defineProperty(globalThis, "navigator", {
      value: originalNavigator,
      configurable: true,
    });
  });

  it("returns 'Firefox 121' for a Firefox UA", () => {
    Object.defineProperty(globalThis, "navigator", {
      value: {
        userAgent: "Mozilla/5.0 (X11; Linux x86_64; rv:121.0) Gecko/20100101 Firefox/121.0",
      },
      configurable: true,
    });
    expect(getBrowserSummary()).toBe("Firefox 121");
    Object.defineProperty(globalThis, "navigator", {
      value: originalNavigator,
      configurable: true,
    });
  });

  it("returns 'other' for unrecognized UA", () => {
    Object.defineProperty(globalThis, "navigator", {
      value: { userAgent: "CustomBot/1.0" },
      configurable: true,
    });
    expect(getBrowserSummary()).toBe("other");
    Object.defineProperty(globalThis, "navigator", {
      value: originalNavigator,
      configurable: true,
    });
  });
});

// ─── getFacingMode ──────────────────────────────────────────────────────────

describe("getFacingMode", () => {
  it("returns 'environment' for a back camera track", () => {
    const track = { getSettings: () => ({ facingMode: "environment" }) };
    expect(getFacingMode(track as unknown as MediaStreamTrack)).toBe(
      "environment",
    );
  });

  it("returns 'user' for a front camera track", () => {
    const track = { getSettings: () => ({ facingMode: "user" }) };
    expect(getFacingMode(track as unknown as MediaStreamTrack)).toBe("user");
  });

  it("returns 'unknown' when facingMode is not set", () => {
    const track = { getSettings: () => ({}) };
    expect(getFacingMode(track as unknown as MediaStreamTrack)).toBe("unknown");
  });

  it("returns 'unknown' for undefined track", () => {
    expect(getFacingMode(undefined)).toBe("unknown");
  });
});
