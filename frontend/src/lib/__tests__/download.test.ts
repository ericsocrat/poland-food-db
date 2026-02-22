import { describe, it, expect, vi, beforeEach, afterEach } from "vitest";
import {
  downloadJson,
  sanitizeFilename,
  getExportCooldownRemaining,
  setExportTimestamp,
} from "../download";

/* ── downloadJson ────────────────────────────────────────────────────────── */

describe("downloadJson", () => {
  let appendSpy: ReturnType<typeof vi.spyOn>;
  let revokeURLSpy: ReturnType<typeof vi.spyOn>;

  beforeEach(() => {
    appendSpy = vi.spyOn(document.body, "appendChild").mockImplementation((n) => n);
    vi.spyOn(URL, "createObjectURL").mockReturnValue("blob:test");
    revokeURLSpy = vi.spyOn(URL, "revokeObjectURL").mockImplementation(() => {});
  });

  afterEach(() => {
    vi.restoreAllMocks();
  });

  it("creates an anchor element and triggers click", () => {
    const clickSpy = vi.fn();
    const removeSpy = vi.fn();
    vi.spyOn(document, "createElement").mockReturnValue({
      href: "",
      download: "",
      style: { display: "" },
      click: clickSpy,
      remove: removeSpy,
    } as unknown as HTMLAnchorElement);

    const { size } = downloadJson({ hello: "world" }, "test.json");

    expect(clickSpy).toHaveBeenCalled();
    expect(appendSpy).toHaveBeenCalled();
    expect(removeSpy).toHaveBeenCalled();
    expect(revokeURLSpy).toHaveBeenCalledWith("blob:test");
    expect(size).toBeGreaterThan(0);
  });

  it("returns the blob size in bytes", () => {
    vi.spyOn(document, "createElement").mockReturnValue({
      href: "",
      download: "",
      style: { display: "" },
      click: vi.fn(),
      remove: vi.fn(),
    } as unknown as HTMLAnchorElement);

    const data = { items: Array.from({ length: 100 }, (_, i) => i) };
    const { size } = downloadJson(data, "big.json");
    expect(size).toBeGreaterThan(100);
  });

  it("sets the download attribute to the sanitized filename", () => {
    const mockAnchor = {
      href: "",
      download: "",
      style: { display: "" },
      click: vi.fn(),
      remove: vi.fn(),
    };
    vi.spyOn(document, "createElement").mockReturnValue(
      mockAnchor as unknown as HTMLAnchorElement,
    );

    downloadJson({}, "my<file>.json");
    expect(mockAnchor.download).toBe("my_file_.json");
  });
});

/* ── sanitizeFilename ────────────────────────────────────────────────────── */

describe("sanitizeFilename", () => {
  it("keeps safe characters", () => {
    expect(sanitizeFilename("export-2026.json")).toBe("export-2026.json");
  });

  it("replaces path traversal chars", () => {
    expect(sanitizeFilename("../../etc/passwd")).toBe(".._.._etc_passwd");
  });

  it("replaces angle brackets and other HTML chars", () => {
    expect(sanitizeFilename("<script>alert(1)</script>.json")).toBe(
      "_script_alert_1___script_.json",
    );
  });

  it("truncates to 200 characters", () => {
    const long = "a".repeat(250) + ".json";
    expect(sanitizeFilename(long).length).toBeLessThanOrEqual(200);
  });

  it("allows spaces", () => {
    expect(sanitizeFilename("my export file.json")).toBe(
      "my export file.json",
    );
  });
});

/* ── Rate limiting ───────────────────────────────────────────────────────── */

describe("getExportCooldownRemaining", () => {
  beforeEach(() => {
    localStorage.clear();
  });

  it("returns 0 when no timestamp stored", () => {
    expect(getExportCooldownRemaining()).toBe(0);
  });

  it("returns remaining ms when within cooldown", () => {
    localStorage.setItem(
      "gdpr-export-last-at",
      String(Date.now() - 10 * 60 * 1000), // 10 min ago
    );
    const remaining = getExportCooldownRemaining();
    // Should be about 50 min ± tolerance
    expect(remaining).toBeGreaterThan(49 * 60 * 1000);
    expect(remaining).toBeLessThanOrEqual(50 * 60 * 1000);
  });

  it("returns 0 when cooldown expired", () => {
    localStorage.setItem(
      "gdpr-export-last-at",
      String(Date.now() - 61 * 60 * 1000), // 61 min ago
    );
    expect(getExportCooldownRemaining()).toBe(0);
  });

  it("returns 0 on storage error", () => {
    vi.spyOn(Storage.prototype, "getItem").mockImplementation(() => {
      throw new Error("fail");
    });
    expect(getExportCooldownRemaining()).toBe(0);
    vi.restoreAllMocks();
  });
});

describe("setExportTimestamp", () => {
  beforeEach(() => {
    localStorage.clear();
  });

  it("stores a timestamp", () => {
    setExportTimestamp();
    const stored = localStorage.getItem("gdpr-export-last-at");
    expect(stored).toBeTruthy();
    expect(Number(stored)).toBeCloseTo(Date.now(), -3);
  });

  it("does not throw on storage error", () => {
    vi.spyOn(Storage.prototype, "setItem").mockImplementation(() => {
      throw new Error("quota");
    });
    expect(() => setExportTimestamp()).not.toThrow();
    vi.restoreAllMocks();
  });
});
