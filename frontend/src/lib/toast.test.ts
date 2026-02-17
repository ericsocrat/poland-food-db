import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { toast } from "sonner";
import { showToast, isRateLimited, resetRateLimiter } from "./toast";
import { useLanguageStore } from "@/stores/language-store";

// ─── Mock Sonner ────────────────────────────────────────────────────────────

vi.mock("sonner", () => ({
  toast: {
    success: vi.fn(),
    error: vi.fn(),
    warning: vi.fn(),
    info: vi.fn(),
  },
}));

// ─── Helpers ────────────────────────────────────────────────────────────────

beforeEach(() => {
  vi.clearAllMocks();
  resetRateLimiter();
  useLanguageStore.getState().setLanguage("en");
});

afterEach(() => {
  useLanguageStore.getState().reset();
});

// ─── showToast — basic dispatch ─────────────────────────────────────────────

describe("showToast", () => {
  it("dispatches toast.success for type 'success'", () => {
    showToast({ type: "success", message: "Done!" });
    expect(toast.success).toHaveBeenCalledWith("Done!", expect.objectContaining({ duration: 5000 }));
  });

  it("dispatches toast.error for type 'error'", () => {
    showToast({ type: "error", message: "Oops" });
    expect(toast.error).toHaveBeenCalledWith("Oops", expect.objectContaining({ duration: 8000 }));
  });

  it("dispatches toast.warning for type 'warning'", () => {
    showToast({ type: "warning", message: "Watch out" });
    expect(toast.warning).toHaveBeenCalledWith("Watch out", expect.objectContaining({ duration: 6000 }));
  });

  it("dispatches toast.info for type 'info'", () => {
    showToast({ type: "info", message: "FYI" });
    expect(toast.info).toHaveBeenCalledWith("FYI", expect.objectContaining({ duration: 5000 }));
  });

  it("allows a custom duration override", () => {
    showToast({ type: "success", message: "Quick", duration: 2000 });
    expect(toast.success).toHaveBeenCalledWith("Quick", expect.objectContaining({ duration: 2000 }));
  });

  it("resolves messageKey via i18n", () => {
    showToast({ type: "success", messageKey: "nav.home" });
    expect(toast.success).toHaveBeenCalledWith("Home", expect.any(Object));
  });

  it("resolves messageKey in Polish", () => {
    useLanguageStore.getState().setLanguage("pl");
    showToast({ type: "success", messageKey: "nav.home" });
    expect(toast.success).toHaveBeenCalledWith("Główna", expect.any(Object));
  });

  it("interpolates messageParams", () => {
    showToast({
      type: "info",
      messageKey: "toast.submissionStatus",
      messageParams: { status: "approved" },
    });
    expect(toast.info).toHaveBeenCalledWith("Submission approved", expect.any(Object));
  });

  it("resolves descriptionKey", () => {
    showToast({
      type: "error",
      messageKey: "common.error",
      descriptionKey: "common.errorDescription",
    });
    expect(toast.error).toHaveBeenCalledWith(
      "Something went wrong",
      expect.objectContaining({
        description: "An unexpected error occurred. Please try again.",
      }),
    );
  });

  it("dispatches raw message without i18n", () => {
    showToast({ type: "error", message: "Server returned 500" });
    expect(toast.error).toHaveBeenCalledWith("Server returned 500", expect.any(Object));
  });

  it("passes action through to Sonner options", () => {
    const onClick = vi.fn();
    showToast({
      type: "info",
      message: "Undo?",
      action: { label: "Undo", onClick },
    });
    expect(toast.info).toHaveBeenCalledWith(
      "Undo?",
      expect.objectContaining({
        action: { label: "Undo", onClick },
      }),
    );
  });
});

// ─── Rate limiting — deduplication ──────────────────────────────────────────

describe("rate limiting — deduplication", () => {
  it("suppresses duplicate messageKey within 2s", () => {
    showToast({ type: "success", messageKey: "toast.saved" });
    showToast({ type: "success", messageKey: "toast.saved" });
    expect(toast.success).toHaveBeenCalledTimes(1);
  });

  it("suppresses duplicate raw message within 2s", () => {
    showToast({ type: "error", message: "fail" });
    showToast({ type: "error", message: "fail" });
    expect(toast.error).toHaveBeenCalledTimes(1);
  });

  it("allows different keys within the same window", () => {
    showToast({ type: "success", messageKey: "toast.saved" });
    showToast({ type: "success", messageKey: "toast.deleted" });
    expect(toast.success).toHaveBeenCalledTimes(2);
  });

  it("allows same key after 2s dedupe window", () => {
    vi.useFakeTimers();
    try {
      showToast({ type: "success", messageKey: "toast.saved" });
      vi.advanceTimersByTime(2001);
      resetRateLimiter(); // reset rolling window too for clean test
      showToast({ type: "success", messageKey: "toast.saved" });
      expect(toast.success).toHaveBeenCalledTimes(2);
    } finally {
      vi.useRealTimers();
    }
  });
});

// ─── Rate limiting — rolling window ─────────────────────────────────────────

describe("rate limiting — rolling window", () => {
  it("caps at 3 toasts per 10s window", () => {
    showToast({ type: "success", message: "one" });
    showToast({ type: "success", message: "two" });
    showToast({ type: "success", message: "three" });
    showToast({ type: "success", message: "four" }); // should be suppressed
    expect(toast.success).toHaveBeenCalledTimes(3);
  });

  it("allows more toasts after window expires", () => {
    vi.useFakeTimers();
    try {
      showToast({ type: "info", message: "a" });
      showToast({ type: "info", message: "b" });
      showToast({ type: "info", message: "c" });
      expect(toast.info).toHaveBeenCalledTimes(3);

      // Advance past 10s window
      vi.advanceTimersByTime(10_001);
      showToast({ type: "info", message: "d" });
      expect(toast.info).toHaveBeenCalledTimes(4);
    } finally {
      vi.useRealTimers();
    }
  });
});

// ─── isRateLimited — direct tests ──────────────────────────────────────────

describe("isRateLimited", () => {
  it("returns false for a fresh key", () => {
    expect(isRateLimited("fresh.key")).toBe(false);
  });

  it("returns true after recording a fire for the same key", () => {
    showToast({ type: "info", message: "test" });
    expect(isRateLimited("test")).toBe(true);
  });
});

// ─── resetRateLimiter ───────────────────────────────────────────────────────

describe("resetRateLimiter", () => {
  it("clears all rate-limiting state", () => {
    showToast({ type: "success", message: "x" });
    showToast({ type: "success", message: "y" });
    showToast({ type: "success", message: "z" });
    expect(isRateLimited("new")).toBe(true); // window full

    resetRateLimiter();
    expect(isRateLimited("new")).toBe(false);
  });
});
