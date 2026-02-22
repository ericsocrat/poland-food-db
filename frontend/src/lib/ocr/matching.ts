/**
 * OCR Text Matching — Clean, tokenise, and match extracted text against products.
 * Issue #55 — Image Search v0
 *
 * Strategies:
 * 1. Clean OCR output (remove noise, fix common Polish OCR errors)
 * 2. Tokenise into significant words
 * 3. Use existing searchProducts API with extracted tokens as query
 */

/* ── Types ────────────────────────────────────────────────────────────────── */

export interface TokenisedText {
  /** Original cleaned text */
  cleaned: string;
  /** Significant tokens suitable for search queries */
  tokens: string[];
  /** Full query string built from tokens */
  query: string;
}

/* ── Constants ────────────────────────────────────────────────────────────── */

/**
 * Polish ingredient-list filler words to exclude from search queries.
 * These appear on virtually every label and add noise to product matching.
 */
const POLISH_STOP_WORDS = new Set([
  "składniki",
  "skład",
  "wartość",
  "wartości",
  "odżywcze",
  "odżywcza",
  "zawiera",
  "może",
  "zawierać",
  "śladowe",
  "ilości",
  "masa",
  "netto",
  "przechowywać",
  "najlepiej",
  "spożyć",
  "przed",
  "wyprodukowano",
  "ingredients",
  "nutrition",
  "facts",
  "contains",
  "may",
  "contain",
  "traces",
  "best",
  "before",
  "net",
  "weight",
  "store",
  "produced",
]);

/** Minimum token length to be considered significant */
const MIN_TOKEN_LENGTH = 3;

/** Max tokens to include in a search query */
const MAX_QUERY_TOKENS = 8;

const POLISH_CHARS = "ąćęłńóśźż";

/* ── Common OCR error corrections for Polish text ─────────────────────────── */

const OCR_CORRECTIONS: ReadonlyArray<[RegExp, string]> = [
  // Common glyph confusions in Polish
  [/[|l](?=ó)/g, "ł"], // |ó → łó  (pipe/l before ó → ł)
  [/[0O](?=ś)/g, "ó"], // 0ś → óś  (zero/O → ó when before ś)
  [/ĺ/g, "ł"], // ĺ → ł  (accented l → barred l)
  [/č/g, "ć"], // Czech č → Polish ć
  [/š/g, "ś"], // Czech š → Polish ś
  [/ž/g, "ź"], // Czech ž → Polish ź
  [/ř/g, "ż"], // Czech ř → sometimes Polish ż
  // Numeric/symbol noise
  [/\b\d+(?:[.,]\d+)?(?:kg|g|ml|l)\b/gi, ""], // "100g", "2.5ml"
  [/\b\d+(?:[.,]\d+)?\s+(?:kg|g|ml|l)\b/gi, ""], // "2.5 ml"
  [/\b\d+%/g, ""], // "45%"
  [/\b\d+\s+%/g, ""], // "45 %"
  [/[<>≤≥]/g, ""], // inequality symbols
  [/\([^()]*\)/g, " "], // parenthetical notes → space
];

/* ── Functions ────────────────────────────────────────────────────────────── */

/**
 * Clean raw OCR output: apply error corrections, normalise whitespace,
 * remove non-text noise.
 */
export function cleanOCRText(raw: string): string {
  let text = raw;

  // Apply correction patterns
  for (const [pattern, replacement] of OCR_CORRECTIONS) {
    text = text.replaceAll(pattern, replacement);
  }

  // Normalise whitespace and trim
  text = text
    .replaceAll(/[\r\n]+/g, " ") // newlines → space
    .replaceAll(/\s{2,}/g, " ") // collapse multiple spaces
    .trim();

  return text;
}

/**
 * Tokenise cleaned text into significant words suitable for product search.
 * Removes stop words, short tokens, and duplicate words.
 */
export function tokenise(cleaned: string): string[] {
  const raw = cleaned
    .toLowerCase()
    .split(/[\s,;:]+/)
    .map((t) => trimTokenEdges(t))
    .filter(
      (t) => t.length >= MIN_TOKEN_LENGTH && !POLISH_STOP_WORDS.has(t),
    );

  // Deduplicate while preserving order
  return [...new Set(raw)];
}

/**
 * Process raw OCR text into a cleaned, tokenised search query.
 */
export function buildSearchQuery(rawText: string): TokenisedText {
  const cleaned = cleanOCRText(rawText);
  const tokens = tokenise(cleaned);
  const query = tokens.slice(0, MAX_QUERY_TOKENS).join(" ");

  return { cleaned, tokens, query };
}

function isTokenChar(char: string): boolean {
  if (!char) return false;
  return (
    (char >= "a" && char <= "z") ||
    POLISH_CHARS.includes(char)
  );
}

function trimTokenEdges(token: string): string {
  let start = 0;
  let end = token.length;

  while (start < end && !isTokenChar(token[start])) {
    start += 1;
  }

  while (end > start && !isTokenChar(token[end - 1])) {
    end -= 1;
  }

  return token.slice(start, end);
}
