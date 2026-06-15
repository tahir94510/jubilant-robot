#!/usr/bin/env python3
"""Deterministic generator for EVERY committed raster: app icon, adaptive
layers, Android mipmaps/drawables, splash + notification icons, web icons,
favicon, the Play Store icon, and the feature graphic. Pure geometry + the
bundled OFL fonts — nothing to license, and the style matches the in-game
cryptogram board.

This tool is the single source of truth for raster assets. Do NOT run
`dart run flutter_launcher_icons`: it would overwrite these supersampled
outputs with its own plain scaling. The pubspec config block stays only as
documentation of the adaptive-icon wiring.

Everything is drawn on a 2048px canvas and downscaled with Lanczos, so
edges stay crisp at every density.

Usage: python3 tool/generate_icons.py  (requires Pillow)

Outputs (committed to the repo):
  assets/icon/icon.png                          1024  full icon, rounded
  assets/icon/icon_foreground.png               1024  adaptive foreground
  assets/icon/icon_monochrome.png               1024  Android 13 themed layer
  android/.../mipmap-*/ic_launcher.png          48-192   legacy launcher
  android/.../drawable-*/ic_launcher_foreground.png 108-432 adaptive
  android/.../drawable-*/ic_launcher_monochrome.png 108-432 themed
  android/.../drawable-*/splash_icon.png        288-1152 launch screen logo
  android/.../drawable-*/ic_stat_quotecrack.png 24-96    notification glyph
  web/icons/Icon-{192,512}.png + maskable       PWA / social preview
  web/favicon.png                               48
  store_assets/play_icon_512.png                512   Play listing (full bleed)
  store_assets/feature_graphic.png              1024x500
  pages/og-image.png                            1200x630 social-share card
"""

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parent.parent
FONT_QUOTE = ROOT / "assets/fonts/Lora-Variable.ttf"
FONT_UI = ROOT / "assets/fonts/Inter-Bold.ttf"
ANDROID_RES = ROOT / "android/app/src/main/res"

# Brand colors (match lib/ui/theme + brand_mark.dart): "Ink & Gold" — a warm
# ink gradient with ivory + champagne-gold accents.
BG_TOP = (26, 24, 20)        # #1A1814
BG_BOTTOM = (46, 42, 34)     # #2E2A22
PAPER = (243, 238, 226)      # #F3EEE2
ACCENT = (224, 184, 90)      # #E0B85A
UNDERLINE = (203, 162, 78)   # #CBA24E

SS = 2048  # supersample size: draw big, downscale Lanczos

MIPMAP_SIZES = {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144,
                "xxxhdpi": 192}
ADAPTIVE_SIZES = {"mdpi": 108, "hdpi": 162, "xhdpi": 216, "xxhdpi": 324,
                  "xxxhdpi": 432}
SPLASH_SIZES = {"mdpi": 288, "hdpi": 432, "xhdpi": 576, "xxhdpi": 864,
                "xxxhdpi": 1152}
STAT_SIZES = {"mdpi": 24, "hdpi": 36, "xhdpi": 48, "xxhdpi": 72,
              "xxxhdpi": 96}


def lora(px, weight=700):
    """Lora at a variable-font weight; bold gives the glyph shelf presence."""
    font = ImageFont.truetype(str(FONT_QUOTE), px)
    try:
        font.set_variation_by_axes([weight])
    except OSError:
        pass  # older FreeType: regular weight still reads fine
    return font


def vertical_gradient(size, top, bottom):
    img = Image.new("RGB", size)
    w, h = size
    draw = ImageDraw.Draw(img)
    for y in range(h):
        t = y / max(h - 1, 1)
        color = tuple(round(top[i] + (bottom[i] - top[i]) * t) for i in range(3))
        draw.line([(0, y), (w, y)], fill=color)
    return img


def rounded_mask(size, radius):
    mask = Image.new("L", size, 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        [0, 0, size[0] - 1, size[1] - 1], radius=radius, fill=255
    )
    return mask


def draw_glyph_centered(draw, text, font, center, fill):
    """Draws text with its ink box centered on `center`."""
    bbox = draw.textbbox((0, 0), text, font=font)
    w, h = bbox[2] - bbox[0], bbox[3] - bbox[1]
    draw.text((center[0] - w / 2 - bbox[0], center[1] - h / 2 - bbox[1]),
              text, font=font, fill=fill)


def paint_artwork(img, *, monochrome=False, scale=1.0, with_question=True):
    """The brand mark: one dominant serif Q, a coral ? at its shoulder, and
    the shared cryptogram underline beneath. Three bold elements that stay
    legible at 48dp — the old two-tile motif read tiny and cluttered on real
    launchers."""
    s = img.size[0]
    draw = ImageDraw.Draw(img)
    a = s * scale
    ox = oy = (s - a) / 2

    white = (255, 255, 255, 255)
    q_color = white if monochrome else PAPER + (255,)
    mark_color = white if monochrome else ACCENT + (255,)
    line_color = white if monochrome else UNDERLINE + (255,)

    # Q lifted and sized down, underline pushed lower, so the serif Q's tail
    # keeps a clear optical gap above the bar (matches brand_mark.dart).
    draw_glyph_centered(draw, "Q", lora(int(a * 0.56), weight=600),
                        (ox + a * 0.44, oy + a * 0.42), q_color)
    if with_question:
        draw_glyph_centered(draw, "?", lora(int(a * 0.235)),
                            (ox + a * 0.76, oy + a * 0.29), mark_color)
    line_h = a * 0.05
    draw.rounded_rectangle(
        [ox + a * 0.20, oy + a * 0.87 - line_h / 2,
         ox + a * 0.80, oy + a * 0.87 + line_h / 2],
        radius=line_h / 2, fill=line_color,
    )
    return img


def artwork(size, *, transparent_bg=False, monochrome=False, scale=1.0,
            with_question=True):
    """Renders the mark supersampled, then downscales to `size`."""
    if transparent_bg:
        big = Image.new("RGBA", (SS, SS), (0, 0, 0, 0))
    else:
        big = vertical_gradient((SS, SS), BG_TOP, BG_BOTTOM).convert("RGBA")
    paint_artwork(big, monochrome=monochrome, scale=scale,
                  with_question=with_question)
    return big.resize((size, size), Image.LANCZOS)


def save(img, rel_path):
    out = ROOT / rel_path
    out.parent.mkdir(parents=True, exist_ok=True)
    img.save(out)
    print(f"wrote {rel_path}")


def make_masters():
    full = artwork(1024)
    rounded = full.copy()
    # Squircle-ish rounding baked in for surfaces that show the raw PNG.
    rounded.putalpha(rounded_mask((1024, 1024), 225))
    save(rounded, "assets/icon/icon.png")
    # Adaptive layers: launchers mask to a ~66% circle; 0.72 of the artwork
    # stays inside the safe zone (the anydpi-v26 XML adds a 16% inset).
    save(artwork(1024, transparent_bg=True, scale=0.72),
         "assets/icon/icon_foreground.png")
    save(artwork(1024, transparent_bg=True, monochrome=True, scale=0.72),
         "assets/icon/icon_monochrome.png")


def make_android_launchers():
    rounded = Image.open(ROOT / "assets/icon/icon.png")
    for density, px in MIPMAP_SIZES.items():
        save(rounded.resize((px, px), Image.LANCZOS),
             f"android/app/src/main/res/mipmap-{density}/ic_launcher.png")
    for density, px in ADAPTIVE_SIZES.items():
        save(artwork(px, transparent_bg=True, scale=0.72),
             f"android/app/src/main/res/drawable-{density}/"
             f"ic_launcher_foreground.png")
        save(artwork(px, transparent_bg=True, monochrome=True, scale=0.72),
             f"android/app/src/main/res/drawable-{density}/"
             f"ic_launcher_monochrome.png")


def make_splash_icons():
    # Android 12+ masks the splash icon to a 2/3-diameter circle; 0.64 fills
    # that circle with a little more presence at launch while still keeping
    # the whole mark comfortably inside on every OEM. The same drawable is
    # the centered logo of the pre-12 launch_background layer-list.
    for density, px in SPLASH_SIZES.items():
        save(artwork(px, transparent_bg=True, scale=0.64),
             f"android/app/src/main/res/drawable-{density}/splash_icon.png")


def make_notification_icons():
    # Status-bar glyphs are alpha-only: white mark, no ?, no background.
    for density, px in STAT_SIZES.items():
        save(artwork(px, transparent_bg=True, monochrome=True, scale=0.92,
                     with_question=False),
             f"android/app/src/main/res/drawable-{density}/"
             f"ic_stat_quotecrack.png")


def make_web_icons():
    full = artwork(1024)
    for px in (192, 512):
        save(full.resize((px, px), Image.LANCZOS).convert("RGB"),
             f"web/icons/Icon-{px}.png")
    # Maskable: artwork inside the 80%-diameter safe circle, full-bleed bg.
    for px in (192, 512):
        save(artwork(px, scale=0.66), f"web/icons/Icon-maskable-{px}.png")
    rounded = Image.open(ROOT / "assets/icon/icon.png")
    save(rounded.resize((48, 48), Image.LANCZOS), "web/favicon.png")


def make_play_icon():
    # Play Store listing icon: 512x512 full-bleed square, no baked corners
    # (Google applies its own mask).
    save(artwork(512).convert("RGB"), "store_assets/play_icon_512.png")


def draw_decoded_tiles(draw, *, canvas_w, y, tile_w, tile_h, gap):
    """The decoded-word motif: QUOTECRACK as solved tiles over their cipher
    row. Shared by the Play feature graphic and the social-share card."""
    word = "QUOTECRACK"
    cipher = "XJWZQVKYBN"  # decorative cipher row
    total = len(word) * tile_w + (len(word) - 1) * gap
    x = (canvas_w - total) / 2
    big = lora(int(tile_h * 0.58))
    small = ImageFont.truetype(str(FONT_UI), int(tile_h * 0.15))
    for i, ch in enumerate(word):
        color = ACCENT + (255,) if ch in "CK" and i >= 5 else PAPER + (255,)
        cx = x + i * (tile_w + gap) + tile_w / 2
        draw_glyph_centered(draw, ch, big, (cx, y + tile_h * 0.26), color)
        ly = y + tile_h * 0.62
        draw.line([(cx - tile_w * 0.42, ly), (cx + tile_w * 0.42, ly)],
                  fill=UNDERLINE + (255,), width=max(6, int(tile_h * 0.045)))
        sb = draw.textbbox((0, 0), cipher[i], font=small)
        draw.text((cx - (sb[2] - sb[0]) / 2 - sb[0], ly + tile_h * 0.07 - sb[1]),
                  cipher[i], font=small, fill=UNDERLINE + (210,))


def make_feature_graphic():
    """Play feature graphic keeps the richer decoded-word motif."""
    size = (1024, 500)
    img = vertical_gradient(size, BG_TOP, BG_BOTTOM).convert("RGBA")
    draw = ImageDraw.Draw(img)

    draw_decoded_tiles(draw, canvas_w=size[0], y=105,
                       tile_w=76, tile_h=150, gap=12)

    tag = "Decode famous quotes. One cipher a day."
    tag_font = ImageFont.truetype(str(FONT_UI), 40)
    bbox = draw.textbbox((0, 0), tag, font=tag_font)
    draw.text(((size[0] - (bbox[2] - bbox[0])) / 2, 330), tag,
              font=tag_font, fill=PAPER + (235,))

    save(img.convert("RGB"), "store_assets/feature_graphic.png")


def make_og_image():
    """1200x630 social-share card (og:image / Twitter large card) for the
    Pages site. Drawn at 2x and Lanczos-downscaled so link previews stay
    crisp on high-DPI screens."""
    w, h = 2400, 1260
    img = vertical_gradient((w, h), BG_TOP, BG_BOTTOM).convert("RGBA")
    draw = ImageDraw.Draw(img)

    draw_decoded_tiles(draw, canvas_w=w, y=290,
                       tile_w=176, tile_h=340, gap=28)

    tag = "Decode famous quotes. One cipher a day."
    tag_font = ImageFont.truetype(str(FONT_UI), 92)
    bbox = draw.textbbox((0, 0), tag, font=tag_font)
    draw.text(((w - (bbox[2] - bbox[0])) / 2, 810), tag,
              font=tag_font, fill=PAPER + (235,))

    sub = "Free · Offline · Daily cryptogram puzzles"
    sub_font = ImageFont.truetype(str(FONT_UI), 56)
    sb = draw.textbbox((0, 0), sub, font=sub_font)
    draw.text(((w - (sb[2] - sb[0])) / 2, 970), sub,
              font=sub_font, fill=UNDERLINE + (235,))

    save(img.resize((1200, 630), Image.LANCZOS).convert("RGB"),
         "pages/og-image.png")


if __name__ == "__main__":
    make_masters()
    make_android_launchers()
    make_splash_icons()
    make_notification_icons()
    make_web_icons()
    make_play_icon()
    make_feature_graphic()
    make_og_image()
