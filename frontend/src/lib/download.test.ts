import { describe, it, expect, vi, beforeEach, afterEach } from "vitest";
import {
  downloadJson,
  sanitizeFilename,
  getExportCooldownRemaining,
  setExportTimestamp,
} from "./download";

// ─── sanitizeFilename ───────────────────────────────────────────────────────

describe("sanitizeFilename", () => {
  it("keeps safe characters unchanged", () => {
    expect(sanitizeFilename("my-file_v2.json")).toBe("my-file_v2.json");
  });

  it("replaces path-traversal characters", () => {
    expect(sanitizeFilename("../../etc/passwd")).toBe(".._.._etc_passwd");
  });

  it("replaces shell-dangerous characters", () => {
    expect(sanitizeFilename("file;rm -rf /")).toBe("file_rm -rf _");
  });

  it("replaces quotes and backticks", () => {
    expect(sanitizeFilename('file"name`test')).toBe("file_name_test");
  });

  it("truncates at 200 characters", () => {
    const long = "a".repeat(250);
    expect(sanitizeFilename(long)).toHaveLength(200);
  });

  it("handles empty string", () => {
    expect(sanitizeFilename("")).toBe("");
  });

  it("preserves spaces", () => {
    expect(sanitizeFilename("my file name.json")).toBe("my file name.json");
  });
});

// ─── downloadJson ───────────────────────────────────────────────────────────

describe("downloadJson", () => {
  let createObjectURLSpy: ReturnType<typeof vi.fn>;
  let revokeObjectURLSpy: ReturnType<typeof vi.fn>;
  let clickSpy: ReturnType<typeof vi.fn>;

  beforeEach(() => {
    createObjectURLSpy = vi
      .fn()
      .mockReturnValue("blob:http://localhost/mock-url");
    revokeObjectURLSpy = vi.fn();
    clickSpy = vi.fn();

    vi.stubGlobal("URL", {
      createObjectURL: createObjectURLSpy,
      revokeObjectURL: revokeObjectURLSpy,
    });

    vi.spyOn(document.body, "appendChild").mockImplementation(
      (node) => node,
    );

    vi.spyOn(document, "createElement").mockReturnValue({
      href: "",
      download: "",
      style: { display: "" },
      click: clickSpy,
      remove: vi.fn(),
    } as unknown as HTMLAnchorElement);
  });

  afterEach(() => {
    vi.restoreAllMocks();
    vi.unstubAllGlobals();
  });

  it("creates a Blob and triggers download", () => {
    const data = { products: [1, 2, 3] };
    const result = downloadJson(data, "export.json");

    expect(createObjectURLSpy).toHaveBeenCalledOnce();
    expect(clickSpy).toHaveBeenCalledOnce();
    expect(revokeObjectURLSpy).toHaveBeenCalledOnce();
    expect(result.size).toBeGreaterThan(0);
  });

  it("sanitizes the filename", () => {
    const createElement = vi.spyOn(document, "createElement");
    const mockAnchor = {
      href: "",
      download: "",
      style: { display: "" },
      click: vi.fn(),
      remove: vi.fn(),
    } as unknown as HTMLAnchorElement;
    createElement.mockReturnValue(mockAnchor);

    downloadJson({}, "../../bad<name>.json");
    expect(mockAnchor.download).toBe(".._.._bad_name_.json");
  });

  it("returns the size of the serialized JSON", () => {
    const result = downloadJson({ key: "value" }, "test.json");
    const expected = new Blob([JSON.stringify({ key: "value" }, null, 2)]).size;
    expect(result.size).toBe(expected);
  });
});

// ─── Export cooldown ────────────────────────────────────────────────────────

describe("getExportCooldownRemaining", () => {
  beforeEach(() => {
    localStorage.clear();
    vi.useFakeTimers();
  });

  afterEach(() => {
    vi.useRealTimers();
  });

  it("returns 0 when no timestamp is set", () => {
    expect(getExportCooldownRemaining()).toBe(0);
  });

  it("returns remaining ms within cooldown window", () => {
    vi.setSystemTime(new Date("2026-01-01T12:00:00Z"));
    setExportTimestamp();

    // Advance 30 minutes (half of 1-hour cooldown)
    vi.setSystemTime(new Date("2026-01-01T12:30:00Z"));
    const remaining = getExportCooldownRemaining();
    expect(remaining).toBe(30 * 60 * 1000); // 30 minutes in ms
  });

  it("returns 0 after cooldown expires", () => {
    vi.setSystemTime(new Date("2026-01-01T12:00:00Z"));
    setExportTimestamp();

    // Advance 2 hours (past 1-hour cooldown)
    vi.setSystemTime(new Date("2026-01-01T14:00:00Z"));
    expect(getExportCooldownRemaining()).toBe(0);
  });
});

describe("setExportTimestamp", () => {
  beforeEach(() => {
    localStorage.clear();
  });

  it("stores the current time in localStorage", () => {
    vi.useFakeTimers();
    vi.setSystemTime(new Date("2026-02-15T10:00:00Z"));

    setExportTimestamp();

    const stored = localStorage.getItem("gdpr-export-last-at");
    expect(stored).toBe(String(new Date("2026-02-15T10:00:00Z").getTime()));

    vi.useRealTimers();
  });
});
