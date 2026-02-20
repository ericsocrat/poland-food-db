import { describe, it, expect } from "vitest";
import { SERVER_IMAGE_POLICY, validateImageForUpload } from "./server-policy";

describe("SERVER_IMAGE_POLICY", () => {
  it("has a 30-day retention limit", () => {
    expect(SERVER_IMAGE_POLICY.maxRetentionDays).toBe(30);
  });

  it("limits file size to 5 MB", () => {
    expect(SERVER_IMAGE_POLICY.maxFileSizeBytes).toBe(5 * 1024 * 1024);
  });

  it("allows only JPEG, PNG, and WebP", () => {
    expect(SERVER_IMAGE_POLICY.allowedMimeTypes).toEqual([
      "image/jpeg",
      "image/png",
      "image/webp",
    ]);
  });

  it("requires EXIF stripping", () => {
    expect(SERVER_IMAGE_POLICY.stripExif).toBe(true);
  });

  it("limits image dimensions to 1920px", () => {
    expect(SERVER_IMAGE_POLICY.maxDimensionPx).toBe(1920);
  });

  it("requires user consent for uploads", () => {
    expect(SERVER_IMAGE_POLICY.requireConsent).toBe(true);
  });

  it("specifies daily cleanup schedule", () => {
    expect(SERVER_IMAGE_POLICY.cleanupSchedule).toBe("daily");
  });
});

describe("validateImageForUpload", () => {
  it("returns empty array for valid JPEG under 5MB", () => {
    const file = new File(["x".repeat(1000)], "photo.jpg", {
      type: "image/jpeg",
    });
    expect(validateImageForUpload(file)).toEqual([]);
  });

  it("returns empty array for valid PNG", () => {
    const file = new File(["x"], "image.png", { type: "image/png" });
    expect(validateImageForUpload(file)).toEqual([]);
  });

  it("returns empty array for valid WebP", () => {
    const file = new File(["x"], "image.webp", { type: "image/webp" });
    expect(validateImageForUpload(file)).toEqual([]);
  });

  it("returns error for files exceeding 5MB", () => {
    // Create a file object that reports a large size
    const largeContent = new ArrayBuffer(6 * 1024 * 1024); // 6 MB
    const file = new File([largeContent], "huge.jpg", {
      type: "image/jpeg",
    });
    const errors = validateImageForUpload(file);
    expect(errors).toContain("File size exceeds 5MB limit");
  });

  it("returns error for disallowed MIME types", () => {
    const file = new File(["x"], "image.gif", { type: "image/gif" });
    const errors = validateImageForUpload(file);
    expect(errors.some((e) => e.includes("image/gif"))).toBe(true);
    expect(errors.some((e) => e.includes("not allowed"))).toBe(true);
  });

  it("returns error for non-image files", () => {
    const file = new File(["x"], "data.pdf", {
      type: "application/pdf",
    });
    const errors = validateImageForUpload(file);
    expect(errors.some((e) => e.includes("application/pdf"))).toBe(true);
  });

  it("can return multiple errors at once", () => {
    const largeContent = new ArrayBuffer(6 * 1024 * 1024);
    const file = new File([largeContent], "huge.bmp", {
      type: "image/bmp",
    });
    const errors = validateImageForUpload(file);
    expect(errors.length).toBe(2);
    expect(errors.some((e) => e.includes("5MB"))).toBe(true);
    expect(errors.some((e) => e.includes("image/bmp"))).toBe(true);
  });
});
