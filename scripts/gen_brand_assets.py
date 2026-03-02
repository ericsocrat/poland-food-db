"""
Brand asset generator for TryVit.

Generates:
  1. Missing PWA icon sizes: 72, 96, 128, 144, 152, 384
  2. Apple iOS splash screen PNGs: 6 sizes for full iPhone coverage

Usage:
  python scripts/gen_brand_assets.py

Requirements: Pillow (pip install Pillow)
"""

from __future__ import annotations

import sys
from pathlib import Path

try:
    from PIL import Image, ImageDraw
except ImportError:
    print("ERROR: Pillow not installed. Run: pip install Pillow")
    sys.exit(1)

# ── Brand constants ──────────────────────────────────────────────────────────
VIT_GREEN = (29, 185, 84)       # #1DB954
VIT_DARK  = (10,  46, 26)       # #0A2E1A
VIT_LIGHT = (240, 250, 244)     # #F0FAF4
WHITE     = (255, 255, 255)

REPO_ROOT = Path(__file__).parent.parent
LOGO_DIR  = REPO_ROOT / "docs" / "assets" / "logo"
ICONS_DIR = REPO_ROOT / "frontend" / "public" / "icons"
SPLASH_DIR = REPO_ROOT / "frontend" / "public" / "splash"

ICONS_DIR.mkdir(parents=True, exist_ok=True)
SPLASH_DIR.mkdir(parents=True, exist_ok=True)


# ── Helper: draw V-leaf mark ─────────────────────────────────────────────────

def draw_v_leaf(draw: ImageDraw.ImageDraw, cx: int, cy: int, size: int, color: tuple) -> None:
    """
    Draw the TryVit V-leaf mark centered at (cx, cy) within a bounding box of `size` px.

    The mark is a bold V-shape with rounded leaf-bud endpoints at the top of each arm.
    This is a simplified programmatic render suitable for small sizes; production versions
    use the SVG master file (docs/assets/logo/logomark.svg).
    """
    # The shield-leaf is a simplified geometric V built from lines + circles.
    # Reference: docs/assets/logo/logomark.svg (shield concept adapted for small rasters)

    half = size / 2
    # Three key points of the V:
    top_left  = (cx - half * 0.42, cy - half * 0.52)
    bottom    = (cx,               cy + half * 0.56)
    top_right = (cx + half * 0.42, cy - half * 0.52)

    # Stroke width proportional to size — minimum 2px
    sw = max(2, int(size * 0.095))

    # Draw V strokes
    draw.line([top_left, bottom, top_right], fill=color, width=sw, joint="curve")

    # Leaf bud endpoints (circles at top of each arm)
    bud_r = max(1, int(size * 0.055))
    for point in (top_left, top_right):
        x, y = int(point[0]), int(point[1])
        draw.ellipse(
            [x - bud_r, y - bud_r, x + bud_r, y + bud_r],
            fill=color,
        )


def make_icon_image(size: int, bg_color: tuple, icon_color: tuple) -> Image.Image:
    """Create a square icon PNG at `size` × `size` with the V-leaf mark."""
    img = Image.new("RGBA", (size, size), (*bg_color, 255))
    draw = ImageDraw.Draw(img)
    icon_size = int(size * 0.6)
    draw_v_leaf(draw, size // 2, size // 2, icon_size, icon_color)
    return img


def make_splash_image(width: int, height: int) -> Image.Image:
    """
    Create an Apple splash screen PNG.
    Background: vitGreen (#1DB954)
    Centered icon: white V-leaf at 120px on iPad, scaled proportionally for each iPhone size.
    """
    img = Image.new("RGBA", (width, height), (*VIT_GREEN, 255))

    # Try to composite the existing high-res logomark PNG if available
    logo_source = LOGO_DIR / "logomark-512.png"
    if logo_source.exists():
        try:
            logo = Image.open(logo_source).convert("RGBA")
            # Tint: replace non-transparent pixels with white
            r, g, b, a = logo.split()
            white_logo = Image.merge("RGBA", (
                Image.new("L", logo.size, 255),
                Image.new("L", logo.size, 255),
                Image.new("L", logo.size, 255),
                a,
            ))
            icon_px = 120
            white_logo = white_logo.resize((icon_px, icon_px), Image.LANCZOS)
            paste_x = (width  - icon_px) // 2
            paste_y = (height - icon_px) // 2
            img.paste(white_logo, (paste_x, paste_y), white_logo)
            return img.convert("RGB")
        except Exception as exc:
            print(f"  WARNING: could not composite logo — falling back to drawn mark ({exc})")

    # Fallback: draw the V-leaf in white
    draw = ImageDraw.Draw(img)
    icon_size = 120
    draw_v_leaf(draw, width // 2, height // 2, icon_size, WHITE)

    return img.convert("RGB")


# ── PWA icon generation ───────────────────────────────────────────────────────

MISSING_ICON_SIZES = [72, 96, 128, 144, 152, 384]

def generate_icons() -> None:
    print("\n── PWA icons ─────────────────────────────────────────────")

    # Try to derive from the existing 512 px PNG (best quality)
    source_512 = LOGO_DIR / "logomark-512.png"

    for px in MISSING_ICON_SIZES:
        dest = ICONS_DIR / f"icon-{px}.png"
        if dest.exists():
            print(f"  SKIP  {dest.name}  (already exists)")
            continue

        if source_512.exists():
            try:
                img = Image.open(source_512).convert("RGBA")
                img = img.resize((px, px), Image.LANCZOS)
                # Composite on vitGreen background (matches Android maskable safe zone)
                bg = Image.new("RGBA", (px, px), (*VIT_GREEN, 255))
                bg.paste(img, (0, 0), img)
                bg.convert("RGB").save(dest, "PNG", optimize=True)
                print(f"  MADE  {dest.name}  ({px}×{px}) from 512 source")
                continue
            except Exception as exc:
                print(f"  WARNING: resize failed ({exc}) — falling back to drawn mark")

        # Fallback: draw mark programmatically
        img = make_icon_image(px, VIT_GREEN, WHITE)
        img.convert("RGB").save(dest, "PNG", optimize=True)
        print(f"  MADE  {dest.name}  ({px}×{px}) drawn mark")

    print(f"  Icons written to: {ICONS_DIR}")


# ── Splash screen generation ──────────────────────────────────────────────────

SPLASH_SPECS = [
    # (filename,              width, height, device)
    ("apple-splash-2796-1290.png", 1290, 2796, "iPhone 15 Pro Max, 14 Plus"),
    ("apple-splash-2532-1170.png", 1170, 2532, "iPhone 14 Pro / 13 / 12"),
    ("apple-splash-2436-1125.png", 1125, 2436, "iPhone X / XS / 11 Pro"),
    ("apple-splash-2208-1242.png", 1242, 2208, "iPhone 8 Plus"),
    ("apple-splash-1334-750.png",   750, 1334, "iPhone 8 / SE 2nd-3rd gen"),
    ("apple-splash-1136-640.png",   640, 1136, "iPhone SE 1st gen"),
]

def generate_splash() -> None:
    print("\n── Apple splash screens ──────────────────────────────────")

    for filename, width, height, device in SPLASH_SPECS:
        dest = SPLASH_DIR / filename
        if dest.exists():
            print(f"  SKIP  {filename}  (already exists)")
            continue
        img = make_splash_image(width, height)
        img.save(dest, "PNG", optimize=True)
        kb = round(dest.stat().st_size / 1024, 1)
        print(f"  MADE  {filename}  ({width}×{height})  {kb} KB  — {device}")

    print(f"  Splash PNGs written to: {SPLASH_DIR}")


# ── Main ──────────────────────────────────────────────────────────────────────

def main() -> None:
    print("TryVit brand asset generator")
    print(f"Repo root: {REPO_ROOT}")
    generate_icons()
    generate_splash()
    print("\n✓ Done. Commit frontend/public/icons/ and frontend/public/splash/")


if __name__ == "__main__":
    main()
