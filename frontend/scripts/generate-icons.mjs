/**
 * Generate raster PNG icons and favicon.ico from SVG templates.
 *
 * Usage:  node scripts/generate-icons.mjs
 *
 * Requires: sharp (already bundled with Next.js)
 */

import sharp from "sharp";
import { writeFileSync, mkdirSync } from "fs";
import { join, dirname } from "path";
import { fileURLToPath } from "url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const ICONS_DIR = join(__dirname, "..", "public", "icons");
const PUBLIC_DIR = join(__dirname, "..", "public");

const GREEN = "#16a34a";

/** Create an SVG icon buffer at the given pixel size. */
function createIconSvg(size) {
  const rx = Math.round(size * 0.2);
  const fontSize = Math.round(size * 0.40);
  const dy = Math.round(size * 0.03); // optical vertical centering nudge

  return Buffer.from(
    `<svg xmlns="http://www.w3.org/2000/svg" width="${size}" height="${size}" viewBox="0 0 ${size} ${size}">
  <rect width="${size}" height="${size}" rx="${rx}" fill="${GREEN}"/>
  <text x="50%" y="${50 + (dy / size) * 100}%" dominant-baseline="middle" text-anchor="middle"
        font-family="Arial,Helvetica,sans-serif" font-weight="700"
        font-size="${fontSize}" fill="white">FD</text>
</svg>`,
  );
}

/** Write a PNG at `size` px to `outputPath`. */
async function generatePng(size, outputPath) {
  await sharp(createIconSvg(size)).resize(size, size).png().toFile(outputPath);
  console.log(`  ✓ ${outputPath}`);
}

/**
 * Pack one or more PNG buffers into a single ICO file.
 * Uses the PNG-embedded ICO format (supported everywhere since IE 11).
 */
function createIco(images) {
  const HEADER = 6;
  const ENTRY = 16;
  const headerBuf = Buffer.alloc(HEADER);
  headerBuf.writeUInt16LE(0, 0); // reserved
  headerBuf.writeUInt16LE(1, 2); // type = ICO
  headerBuf.writeUInt16LE(images.length, 4);

  let dataOffset = HEADER + ENTRY * images.length;
  const entries = [];

  for (const { size, buffer } of images) {
    const e = Buffer.alloc(ENTRY);
    e.writeUInt8(size < 256 ? size : 0, 0);
    e.writeUInt8(size < 256 ? size : 0, 1);
    e.writeUInt8(0, 2);
    e.writeUInt8(0, 3);
    e.writeUInt16LE(1, 4); // planes
    e.writeUInt16LE(32, 6); // bpp
    e.writeUInt32LE(buffer.length, 8);
    e.writeUInt32LE(dataOffset, 12);
    entries.push(e);
    dataOffset += buffer.length;
  }

  return Buffer.concat([
    headerBuf,
    ...entries,
    ...images.map((i) => i.buffer),
  ]);
}

async function main() {
  mkdirSync(ICONS_DIR, { recursive: true });
  console.log("Generating raster icons…\n");

  // ── PNGs ──────────────────────────────────────────────────────────────────
  for (const size of [16, 32, 192, 512]) {
    await generatePng(size, join(ICONS_DIR, `icon-${size}.png`));
  }

  // Apple touch icon (180 × 180) — required by iOS
  await generatePng(180, join(ICONS_DIR, "apple-touch-icon.png"));

  // ── favicon.ico (16 + 32, PNG-embedded) ───────────────────────────────────
  const ico16 = await sharp(createIconSvg(16)).resize(16, 16).png().toBuffer();
  const ico32 = await sharp(createIconSvg(32)).resize(32, 32).png().toBuffer();
  const icoBuffer = createIco([
    { size: 16, buffer: ico16 },
    { size: 32, buffer: ico32 },
  ]);
  writeFileSync(join(PUBLIC_DIR, "favicon.ico"), icoBuffer);
  console.log(`  ✓ favicon.ico`);

  console.log("\nDone — all icons generated.");
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
