// ─── Image Policy Enforcement ────────────────────────────────────────────────
// Technical enforcement of the client-only image processing policy.
// Images are NEVER uploaded to any server. All processing is ephemeral.
// See /privacy for the full privacy policy.
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Wrap any image processing operation with automatic cleanup.
 * Ensures image data is released from memory regardless of success or failure.
 *
 * @example
 * const text = await withImageProcessing(blob, async (bitmap) => {
 *   // do OCR or other processing
 *   return extractedText;
 * });
 */
export async function withImageProcessing<T>(
  imageSrc: Blob | File,
  processor: (imageData: ImageBitmap) => Promise<T>,
): Promise<T> {
  let bitmap: ImageBitmap | null = null;

  try {
    bitmap = await createImageBitmap(imageSrc);
    return await processor(bitmap);
  } finally {
    if (bitmap) {
      bitmap.close();
    }
    if (process.env.NODE_ENV === "development") {
      // eslint-disable-next-line no-console
      console.debug("[image-policy] Image data released");
    }
  }
}

/**
 * Release all image data references — object URLs, canvas buffers, and blobs.
 * Call this after any image capture or display operation.
 */
export function releaseImageData(imageData: {
  blob?: Blob | null;
  objectUrl?: string | null;
  canvas?: HTMLCanvasElement | null;
}): void {
  if (imageData.objectUrl) {
    URL.revokeObjectURL(imageData.objectUrl);
  }
  if (imageData.canvas) {
    const ctx = imageData.canvas.getContext("2d");
    ctx?.clearRect(0, 0, imageData.canvas.width, imageData.canvas.height);
    imageData.canvas.width = 0;
    imageData.canvas.height = 0;
  }
  // Blob will be GC'd once all references are nullified by caller
}

/** Known image MIME types */
const IMAGE_MIME_PREFIX = "image/";
const BASE64_IMAGE_PREFIX = "data:image/";

/**
 * Assert that a network request body does not contain image data.
 * Used in tests to verify policy compliance.
 *
 * @throws Error if image data is detected
 */
export function assertNoImageInBody(body: unknown): void {
  // File extends Blob, so check File first for a more specific error message
  if (body instanceof File) {
    if (body.type.startsWith(IMAGE_MIME_PREFIX)) {
      throw new Error(
        "[image-policy] Attempted to send image File over network",
      );
    }
  } else if (body instanceof Blob) {
    if (body.type.startsWith(IMAGE_MIME_PREFIX)) {
      throw new Error(
        "[image-policy] Attempted to send image Blob over network",
      );
    }
  }

  if (typeof body === "string" && body.startsWith(BASE64_IMAGE_PREFIX)) {
    throw new Error(
      "[image-policy] Attempted to send base64 image data over network",
    );
  }

  if (body instanceof FormData) {
    for (const [, value] of body.entries()) {
      if (value instanceof File && value.type.startsWith(IMAGE_MIME_PREFIX)) {
        throw new Error(
          "[image-policy] Attempted to send image file via FormData",
        );
      }
    }
  }
}

/**
 * Content Security Policy directives that prevent accidental image uploads.
 * Applied via next.config.ts headers.
 */
export const IMAGE_POLICY_CSP_DIRECTIVES = {
  /** Restricts fetch/XHR destinations — only Supabase + Tesseract CDN allowed */
  connectSrc:
    "'self' https://*.supabase.co https://cdn.jsdelivr.net https://tessdata.projectnaptha.com",
  /** Tesseract WASM workers can load from CDN */
  workerSrc: "'self' blob: https://cdn.jsdelivr.net",
  /** Prevent form-based uploads to external URLs */
  formAction: "'self'",
  /** Image sources — self, data URIs (for display), and Open Food Facts CDN */
  imgSrc: "'self' data: blob: https://images.openfoodfacts.org",
} as const;
