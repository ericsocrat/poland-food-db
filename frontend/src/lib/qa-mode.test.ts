import { describe, it, expect, vi, afterEach } from "vitest";

// ─── QA Mode utility tests ──────────────────────────────────────────────────
// Issue: #173 — [Quality Gate 2/9] QA Mode Flag for Deterministic UI
// ─────────────────────────────────────────────────────────────────────────────

describe("qa-mode", () => {
  const ORIGINAL_ENV = process.env.NEXT_PUBLIC_QA_MODE;

  afterEach(() => {
    vi.resetModules();
    if (ORIGINAL_ENV === undefined) {
      delete process.env.NEXT_PUBLIC_QA_MODE;
    } else {
      process.env.NEXT_PUBLIC_QA_MODE = ORIGINAL_ENV;
    }
  });

  // ─── IS_QA_MODE ─────────────────────────────────────────────────────────

  describe("IS_QA_MODE", () => {
    it('is true when NEXT_PUBLIC_QA_MODE is "1"', async () => {
      process.env.NEXT_PUBLIC_QA_MODE = "1";
      const { IS_QA_MODE } = await import("@/lib/qa-mode");
      expect(IS_QA_MODE).toBe(true);
    });

    it("is false when NEXT_PUBLIC_QA_MODE is undefined", async () => {
      delete process.env.NEXT_PUBLIC_QA_MODE;
      const { IS_QA_MODE } = await import("@/lib/qa-mode");
      expect(IS_QA_MODE).toBe(false);
    });

    it('is false when NEXT_PUBLIC_QA_MODE is "0"', async () => {
      process.env.NEXT_PUBLIC_QA_MODE = "0";
      const { IS_QA_MODE } = await import("@/lib/qa-mode");
      expect(IS_QA_MODE).toBe(false);
    });

    it('is false when NEXT_PUBLIC_QA_MODE is "true"', async () => {
      process.env.NEXT_PUBLIC_QA_MODE = "true";
      const { IS_QA_MODE } = await import("@/lib/qa-mode");
      expect(IS_QA_MODE).toBe(false);
    });

    it('is false when NEXT_PUBLIC_QA_MODE is "false"', async () => {
      process.env.NEXT_PUBLIC_QA_MODE = "false";
      const { IS_QA_MODE } = await import("@/lib/qa-mode");
      expect(IS_QA_MODE).toBe(false);
    });

    it("is false when NEXT_PUBLIC_QA_MODE is empty string", async () => {
      process.env.NEXT_PUBLIC_QA_MODE = "";
      const { IS_QA_MODE } = await import("@/lib/qa-mode");
      expect(IS_QA_MODE).toBe(false);
    });
  });

  // ─── qaStable ───────────────────────────────────────────────────────────

  describe("qaStable", () => {
    it("returns stable value when QA mode is active", async () => {
      process.env.NEXT_PUBLIC_QA_MODE = "1";
      const { qaStable } = await import("@/lib/qa-mode");
      expect(qaStable("live-random-tip", "stable-tip-0")).toBe("stable-tip-0");
    });

    it("returns live value when QA mode is inactive", async () => {
      delete process.env.NEXT_PUBLIC_QA_MODE;
      const { qaStable } = await import("@/lib/qa-mode");
      expect(qaStable("live-random-tip", "stable-tip-0")).toBe(
        "live-random-tip",
      );
    });

    it("works with numeric values", async () => {
      process.env.NEXT_PUBLIC_QA_MODE = "1";
      const { qaStable } = await import("@/lib/qa-mode");
      expect(qaStable(7, 0)).toBe(0);
    });

    it("works with object values", async () => {
      process.env.NEXT_PUBLIC_QA_MODE = "1";
      const { qaStable } = await import("@/lib/qa-mode");
      const live = { id: 42 };
      const stable = { id: 1 };
      expect(qaStable(live, stable)).toBe(stable);
    });

    it("returns live value when QA mode is '0'", async () => {
      process.env.NEXT_PUBLIC_QA_MODE = "0";
      const { qaStable } = await import("@/lib/qa-mode");
      expect(qaStable("live", "stable")).toBe("live");
    });
  });
});
