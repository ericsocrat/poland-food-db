import { describe, it, expect, vi, beforeEach } from "vitest";
import {
  withImageProcessing,
  releaseImageData,
  assertNoImageInBody,
  IMAGE_POLICY_CSP_DIRECTIVES,
} from "./enforcement";

// ─── withImageProcessing ─────────────────────────────────────────────────────

describe("withImageProcessing", () => {
  const mockClose = vi.fn();
  const mockBitmap = { close: mockClose } as unknown as ImageBitmap;

  beforeEach(() => {
    vi.restoreAllMocks();
    mockClose.mockClear();
    globalThis.createImageBitmap = vi.fn().mockResolvedValue(mockBitmap);
  });

  it("calls the processor with the created bitmap", async () => {
    const processor = vi.fn().mockResolvedValue("result");
    const blob = new Blob(["test"], { type: "image/png" });

    const result = await withImageProcessing(blob, processor);

    expect(createImageBitmap).toHaveBeenCalledWith(blob);
    expect(processor).toHaveBeenCalledWith(mockBitmap);
    expect(result).toBe("result");
  });

  it("closes bitmap on success", async () => {
    const blob = new Blob(["test"], { type: "image/png" });

    await withImageProcessing(blob, async () => "ok");

    expect(mockClose).toHaveBeenCalledOnce();
  });

  it("closes bitmap on processor error", async () => {
    const blob = new Blob(["test"], { type: "image/png" });

    await expect(
      withImageProcessing(blob, async () => {
        throw new Error("processing failed");
      }),
    ).rejects.toThrow("processing failed");

    expect(mockClose).toHaveBeenCalledOnce();
  });

  it("closes bitmap on createImageBitmap error", async () => {
    globalThis.createImageBitmap = vi.fn().mockRejectedValue(
      new Error("invalid image"),
    );
    const blob = new Blob(["test"], { type: "image/png" });

    await expect(
      withImageProcessing(blob, async () => "ok"),
    ).rejects.toThrow("invalid image");

    // bitmap was never created, so close should not be called
    expect(mockClose).not.toHaveBeenCalled();
  });

  it("logs cleanup in development mode", async () => {
    const originalEnv = process.env.NODE_ENV;
    process.env.NODE_ENV = "development";
    const consoleSpy = vi.spyOn(console, "debug").mockImplementation(() => {});

    const blob = new Blob(["test"], { type: "image/png" });
    await withImageProcessing(blob, async () => "ok");

    expect(consoleSpy).toHaveBeenCalledWith(
      "[image-policy] Image data released",
    );

    process.env.NODE_ENV = originalEnv;
    consoleSpy.mockRestore();
  });
});

// ─── releaseImageData ────────────────────────────────────────────────────────

describe("releaseImageData", () => {
  it("revokes object URL when provided", () => {
    const revokeSpy = vi.spyOn(URL, "revokeObjectURL").mockImplementation(() => {});
    releaseImageData({ objectUrl: "blob:http://localhost/abc123" });
    expect(revokeSpy).toHaveBeenCalledWith("blob:http://localhost/abc123");
    revokeSpy.mockRestore();
  });

  it("clears canvas when provided", () => {
    const clearRect = vi.fn();
    const mockCtx = { clearRect } as unknown as CanvasRenderingContext2D;
    const canvas = {
      getContext: vi.fn().mockReturnValue(mockCtx),
      width: 800,
      height: 600,
    } as unknown as HTMLCanvasElement;

    releaseImageData({ canvas });

    expect(clearRect).toHaveBeenCalledWith(0, 0, 800, 600);
    expect(canvas.width).toBe(0);
    expect(canvas.height).toBe(0);
  });

  it("handles canvas with null context gracefully", () => {
    const canvas = {
      getContext: vi.fn().mockReturnValue(null),
      width: 100,
      height: 100,
    } as unknown as HTMLCanvasElement;

    expect(() => releaseImageData({ canvas })).not.toThrow();
    expect(canvas.width).toBe(0);
  });

  it("handles all null values", () => {
    expect(() =>
      releaseImageData({ blob: null, objectUrl: null, canvas: null }),
    ).not.toThrow();
  });

  it("handles empty object", () => {
    expect(() => releaseImageData({})).not.toThrow();
  });
});

// ─── assertNoImageInBody ─────────────────────────────────────────────────────

describe("assertNoImageInBody", () => {
  it("throws on image Blob", () => {
    const blob = new Blob(["img"], { type: "image/png" });
    expect(() => assertNoImageInBody(blob)).toThrow(
      "[image-policy] Attempted to send image Blob over network",
    );
  });

  it("does not throw on non-image Blob", () => {
    const blob = new Blob(["data"], { type: "application/json" });
    expect(() => assertNoImageInBody(blob)).not.toThrow();
  });

  it("throws on image File", () => {
    const file = new File(["img"], "photo.jpg", { type: "image/jpeg" });
    expect(() => assertNoImageInBody(file)).toThrow(
      "[image-policy] Attempted to send image File over network",
    );
  });

  it("does not throw on non-image File", () => {
    const file = new File(["csv"], "data.csv", { type: "text/csv" });
    expect(() => assertNoImageInBody(file)).not.toThrow();
  });

  it("throws on base64 image string", () => {
    const base64 = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUg==";
    expect(() => assertNoImageInBody(base64)).toThrow(
      "[image-policy] Attempted to send base64 image data over network",
    );
  });

  it("does not throw on regular string", () => {
    expect(() => assertNoImageInBody("hello world")).not.toThrow();
  });

  it("throws on FormData with image File", () => {
    const formData = new FormData();
    formData.append(
      "image",
      new File(["img"], "photo.png", { type: "image/png" }),
    );
    expect(() => assertNoImageInBody(formData)).toThrow(
      "[image-policy] Attempted to send image file via FormData",
    );
  });

  it("does not throw on FormData without images", () => {
    const formData = new FormData();
    formData.append("name", "test product");
    expect(() => assertNoImageInBody(formData)).not.toThrow();
  });

  it("does not throw on null or undefined", () => {
    expect(() => assertNoImageInBody(null)).not.toThrow();
    expect(() => assertNoImageInBody(undefined)).not.toThrow();
  });

  it("does not throw on number or object", () => {
    expect(() => assertNoImageInBody(42)).not.toThrow();
    expect(() => assertNoImageInBody({ key: "value" })).not.toThrow();
  });
});

// ─── IMAGE_POLICY_CSP_DIRECTIVES ─────────────────────────────────────────────

describe("IMAGE_POLICY_CSP_DIRECTIVES", () => {
  it("restricts connect-src to self, Supabase, and Tesseract CDN", () => {
    expect(IMAGE_POLICY_CSP_DIRECTIVES.connectSrc).toContain("'self'");
    expect(IMAGE_POLICY_CSP_DIRECTIVES.connectSrc).toContain(
      "*.supabase.co",
    );
    expect(IMAGE_POLICY_CSP_DIRECTIVES.connectSrc).toContain(
      "cdn.jsdelivr.net",
    );
    // Wildcard * alone is not allowed — *.supabase.co is fine (subdomain match)
    expect(IMAGE_POLICY_CSP_DIRECTIVES.connectSrc).not.toMatch(/\s\*(?:\s|$)/);
  });

  it("allows blob: in worker-src for Tesseract WASM", () => {
    expect(IMAGE_POLICY_CSP_DIRECTIVES.workerSrc).toContain("blob:");
    expect(IMAGE_POLICY_CSP_DIRECTIVES.workerSrc).toContain(
      "cdn.jsdelivr.net",
    );
  });

  it("restricts form-action to self only", () => {
    expect(IMAGE_POLICY_CSP_DIRECTIVES.formAction).toBe("'self'");
  });

  it("allows images from self, data, blob, and Open Food Facts", () => {
    expect(IMAGE_POLICY_CSP_DIRECTIVES.imgSrc).toContain("'self'");
    expect(IMAGE_POLICY_CSP_DIRECTIVES.imgSrc).toContain("data:");
    expect(IMAGE_POLICY_CSP_DIRECTIVES.imgSrc).toContain("blob:");
    expect(IMAGE_POLICY_CSP_DIRECTIVES.imgSrc).toContain(
      "images.openfoodfacts.org",
    );
  });
});
