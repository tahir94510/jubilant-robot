#!/usr/bin/env python3
"""Deterministic generator for the app icon, adaptive layers, and the Play
feature graphic. Pure geometry + the bundled Lora font — no external
artwork, so there is nothing to license and the visual style matches the
in-game cryptogram board (letter tiles with underlines).

Usage: python3 tool/generate_icons.py
Outputs (committed to the repo):
  assets/icon/icon.png               1024x1024 full icon
  assets/icon/icon_foreground.png    1024x1024 adaptive foreground (safe zone)
  assets/icon/icon_monochrome.png    1024x1024 Android 13 themed icon layer
  store_assets/feature_graphic.png   1024x500  Play Store feature graphic
"""

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parent.parent
FONT_PATH = ROOT / "assets/fonts/Lora-Variable.ttf"
FONT_UI = ROOT / "assets/fonts/Inter-Bold.ttf"

# Brand colors (match lib/ui/theme): deep indigo night + warm paper accents.
BG_TOP = (28, 37, 65)        # #1C2541
BG_BOTTOM = (61, 90, 128)    # #3D5A80
PAPER = (247, 245, 240)      # #F7F5F0
ACCENT = (238, 108, 77)      # #EE6C4D
UNDERLINE = (152, 193, 217)  # #98C1D9


def vertical_gradient(size, top, bottom):
    img = Image.new("RGB", size)
    w, h = size
    for y in range(h):
        t = y / max(h - 1, 1)
        color = tuple(round(top[i] + (bottom[i] - top[i]) * t) for i in range(3))
        ImageDraw.Draw(img).line([(0, y), (w, y)], fill=color)
    return img


def rounded_mask(size, radius):
    mask = Image.new("L", size, 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        [0, 0, size[0] - 1, size[1] - 1], radius=radius, fill=255
    )
    return mask


def draw_tile(draw, x, y, w, h, letter, font, *, letter_color, line_color,
              small=None, small_font=None, small_color=None):
    """One cryptogram tile: big letter, underline, small cipher letter."""
    bbox = draw.textbbox((0, 0), letter, font=font)
    lw, lh = bbox[2] - bbox[0], bbox[3] - bbox[1]
    draw.text((x + (w - lw) / 2 - bbox[0], y + (h * 0.52 - lh) / 2 - bbox[1]),
              letter, font=font, fill=letter_color)
    ly = y + h * 0.62
    draw.line([(x + w * 0.08, ly), (x + w * 0.92, ly)],
              fill=line_color, width=max(6, int(h * 0.045)))
    if small:
        sb = draw.textbbox((0, 0), small, font=small_font)
        sw = sb[2] - sb[0]
        draw.text((x + (w - sw) / 2 - sb[0], ly + h * 0.07 - sb[1]),
                  small, font=small_font, fill=small_color)


def icon_artwork(size, *, transparent_bg=False, monochrome=False, scale=1.0):
    """The 'Q?' tile pair used by every icon variant."""
    s = size[0]
    if transparent_bg:
        img = Image.new("RGBA", size, (0, 0, 0, 0))
    else:
        img = vertical_gradient(size, BG_TOP, BG_BOTTOM).convert("RGBA")
    draw = ImageDraw.Draw(img)

    tile_w = s * 0.34 * scale
    tile_h = s * 0.52 * scale
    gap = s * 0.045 * scale
    total_w = tile_w * 2 + gap
    x0 = (s - total_w) / 2
    y0 = (s - tile_h) / 2

    big = ImageFont.truetype(str(FONT_PATH), int(tile_h * 0.62))
    small = ImageFont.truetype(str(FONT_UI), int(tile_h * 0.16))

    white = (255, 255, 255, 255)
    letter_color = white if monochrome else PAPER + (255,)
    line_color = white if monochrome else UNDERLINE + (255,)
    accent_color = white if monochrome else ACCENT + (255,)
    small_color = white if monochrome else UNDERLINE + (230,)

    draw_tile(draw, x0, y0, tile_w, tile_h, "Q", big,
              letter_color=letter_color, line_color=line_color,
              small="X", small_font=small, small_color=small_color)
    draw_tile(draw, x0 + tile_w + gap, y0, tile_w, tile_h, "?", big,
              letter_color=accent_color, line_color=line_color,
              small="J", small_font=small, small_color=small_color)
    return img


def make_icon():
    img = icon_artwork((1024, 1024))
    # Squircle-ish rounding baked in for stores that show the raw PNG.
    img.putalpha(rounded_mask((1024, 1024), 180))
    out = ROOT / "assets/icon/icon.png"
    out.parent.mkdir(parents=True, exist_ok=True)
    img.save(out)
    print(f"wrote {out}")


def make_adaptive_foreground():
    # Adaptive icons crop to a centered circle ~66% of the canvas: keep all
    # artwork inside that safe zone.
    img = icon_artwork((1024, 1024), transparent_bg=True, scale=0.62)
    out = ROOT / "assets/icon/icon_foreground.png"
    img.save(out)
    print(f"wrote {out}")


def make_monochrome():
    img = icon_artwork((1024, 1024), transparent_bg=True,
                       monochrome=True, scale=0.62)
    out = ROOT / "assets/icon/icon_monochrome.png"
    img.save(out)
    print(f"wrote {out}")


def make_feature_graphic():
    size = (1024, 500)
    img = vertical_gradient(size, BG_TOP, BG_BOTTOM).convert("RGBA")
    draw = ImageDraw.Draw(img)

    # Decoded-word motif: QUOTECRACK as solved tiles.
    word = "QUOTECRACK"
    tile_w, tile_h, gap = 76, 150, 12
    total = len(word) * tile_w + (len(word) - 1) * gap
    x = (size[0] - total) / 2
    y = 105
    big = ImageFont.truetype(str(FONT_PATH), int(tile_h * 0.58))
    small = ImageFont.truetype(str(FONT_UI), int(tile_h * 0.15))
    cipher = "XJWZQVKYBN"  # decorative cipher row
    for i, ch in enumerate(word):
        color = ACCENT + (255,) if ch in "CK" and i >= 5 else PAPER + (255,)
        draw_tile(draw, x + i * (tile_w + gap), y, tile_w, tile_h, ch, big,
                  letter_color=color, line_color=UNDERLINE + (255,),
                  small=cipher[i], small_font=small,
                  small_color=UNDERLINE + (210,))

    tag = "Decode famous quotes. One cipher a day."
    tag_font = ImageFont.truetype(str(FONT_UI), 40)
    bbox = draw.textbbox((0, 0), tag, font=tag_font)
    draw.text(((size[0] - (bbox[2] - bbox[0])) / 2, 330), tag,
              font=tag_font, fill=PAPER + (235,))

    out = ROOT / "store_assets/feature_graphic.png"
    out.parent.mkdir(parents=True, exist_ok=True)
    img.convert("RGB").save(out)
    print(f"wrote {out}")


if __name__ == "__main__":
    make_icon()
    make_adaptive_foreground()
    make_monochrome()
    make_feature_graphic()
