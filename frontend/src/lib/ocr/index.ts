export { initOCR, extractText, terminateOCR, isOCRReady } from "./engine";
export { CONFIDENCE, OCR_TIMEOUT_MS } from "./engine";
export type { OCRResult, OCRWord } from "./engine";

export {
  releaseImageData,
  hasPrivacyConsent,
  acceptPrivacyConsent,
  revokePrivacyConsent,
} from "./privacy";

export { cleanOCRText, tokenise, buildSearchQuery } from "./matching";
export type { TokenisedText } from "./matching";
