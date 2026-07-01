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
  assets/icon/icon.png                          2048  full icon, rounded
  assets/icon/icon_foreground.png               2048  adaptive foreground
  assets/icon/icon_monochrome.png               2048  Android 13 themed layer
  android/.../mipmap-*/ic_launcher.png          48-192   legacy launcher
  android/.../drawable-*/ic_launcher_foreground.png 108-432 adaptive
  android/.../drawable-*/ic_launcher_monochrome.png 108-432 themed
  android/.../drawable-*/splash_icon.png        288-1152 launch screen logo
  android/.../drawable-*/ic_stat_quotecrack.png 24-96    notification glyph
  web/icons/Icon-{192,512,1024}.png + maskable  PWA / social preview
  web/favicon.png                               48
  store_assets/play_icon_512.png                512   Play listing (full bleed)
  store_assets/feature_graphic.png              1024x500 (English, canonical)
  store_assets/feature_graphic_<loc>.png        1024x500 per-language (7 locales)
  pages/og-image.png                            1200x630 social-share card
"""

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parent.parent
FONT_QUOTE = ROOT / "assets/fonts/Lora-Variable.ttf"
FONT_UI = ROOT / "assets/fonts/Inter-Bold.ttf"
ANDROID_RES = ROOT / "android/app/src/main/res"

# Brand colors (match lib/ui/theme + brand_mark.dart): "Ink & Gold" on a warm
# PAPER field — a light champagne-cream tile with a dark-ink serif and
# deepened bronze-gold accents. The light field makes the icon stand out in the
# launcher / store grid (a dark icon can vanish on dark wallpapers), and the
# gold is deepened so it keeps strong contrast on the light background instead
# of washing out (a naive dark->light flip kills the gold's legibility).
BG_TOP = (247, 244, 236)     # #F7F4EC  (matches app_surface / light theme)
BG_BOTTOM = (234, 225, 206)  # #EAE1CE  warm subtle gradient
INK = (38, 34, 28)           # #26221C  dark serif glyph + decoded letters
ACCENT = (170, 124, 34)      # #AA7C22  deepened gold for the ? and accents
UNDERLINE = (150, 110, 30)   # #966E1E  deepened gold for the cipher underline

# Dark-mode splash variant (matches AppThemes.dark + brand_mark on a dark
# field): a light "paper" Q with the BRIGHTER dark-theme gold, so the boxless
# transparent badge reads on the dark splash field instead of a dark-ink Q
# vanishing into it. Used ONLY for drawable-night/splash_icon.
INK_DARK = (242, 237, 226)   # #F2EDE2  dark-theme onSurface (light paper ink)
ACCENT_DARK = (217, 178, 90) # #D9B25A  dark-theme gold (revealed)
UNDERLINE_DARK = (217, 178, 90)  # #D9B25A

SS = 4096  # supersample size: draw big, downscale Lanczos. 4096 keeps a >=2x
# supersample even for the 2048px master/web exports, so text edges stay crisp.

# Master / web base resolution. The masters are a true 2K source and every web
# icon is downscaled from this with Lanczos, so nothing is ever upscaled.
MASTER = 2048

MIPMAP_SIZES = {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144,
                "xxxhdpi": 192}
ADAPTIVE_SIZES = {"mdpi": 108, "hdpi": 162, "xhdpi": 216, "xxhdpi": 324,
                  "xxxhdpi": 432}
SPLASH_SIZES = {"mdpi": 288, "hdpi": 432, "xhdpi": 576, "xxhdpi": 864,
                "xxxhdpi": 1152}
STAT_SIZES = {"mdpi": 24, "hdpi": 36, "xhdpi": 48, "xxhdpi": 72,
              "xxxhdpi": 96}

# Adaptive-icon foreground fill. The mark used to render at 0.72 and the
# anydpi-v26 XML then inset it another 16%, so the logo occupied only ~half the
# tile and looked undersized on the launcher. 0.90 here + an 8% XML inset gives
# the mark real presence while its widest element (the underline) still sits
# well inside the 66% circular safe zone on every OEM mask.
LAUNCHER_FG_SCALE = 0.90


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


def paint_artwork(img, *, monochrome=False, scale=1.0, with_question=True,
                  q_col=None, mark_col=None, line_col=None):
    """The brand mark: one dominant serif Q, a coral ? at its shoulder, and
    the shared cryptogram underline beneath. Three bold elements that stay
    legible at 48dp — the old two-tile motif read tiny and cluttered on real
    launchers.

    `q_col`/`mark_col`/`line_col` override the default light-brand colors (used
    by the dark-mode splash badge); `monochrome` still wins for the themed layer.
    """
    s = img.size[0]
    draw = ImageDraw.Draw(img)
    a = s * scale
    ox = oy = (s - a) / 2

    white = (255, 255, 255, 255)
    q_color = white if monochrome else (q_col or INK) + (255,)
    mark_color = white if monochrome else (mark_col or ACCENT) + (255,)
    line_color = white if monochrome else (line_col or UNDERLINE) + (255,)

    # Q lifted and sized down; the underline sits at y 0.80 — a small, even
    # gap below the glyph, close but clear of the serif Q's tail (matches
    # brand_mark.dart).
    draw_glyph_centered(draw, "Q", lora(int(a * 0.56), weight=600),
                        (ox + a * 0.44, oy + a * 0.42), q_color)
    if with_question:
        draw_glyph_centered(draw, "?", lora(int(a * 0.235)),
                            (ox + a * 0.76, oy + a * 0.29), mark_color)
    line_h = a * 0.05
    draw.rounded_rectangle(
        [ox + a * 0.20, oy + a * 0.80 - line_h / 2,
         ox + a * 0.80, oy + a * 0.80 + line_h / 2],
        radius=line_h / 2, fill=line_color,
    )
    return img


def artwork(size, *, transparent_bg=False, solid_bg=False, monochrome=False,
            scale=1.0, with_question=True, q_col=None, mark_col=None,
            line_col=None):
    """Renders the mark supersampled, then downscales to `size`."""
    if transparent_bg:
        big = Image.new("RGBA", (SS, SS), (0, 0, 0, 0))
    elif solid_bg:
        # A FLAT brand-cream fill (no gradient). Used for the splash so the icon
        # tile is one solid color that matches the splash window background
        # exactly — a gradient leaves a visible seam against the flat window.
        big = Image.new("RGBA", (SS, SS), BG_TOP + (255,))
    else:
        big = vertical_gradient((SS, SS), BG_TOP, BG_BOTTOM).convert("RGBA")
    paint_artwork(big, monochrome=monochrome, scale=scale,
                  with_question=with_question, q_col=q_col, mark_col=mark_col,
                  line_col=line_col)
    return big.resize((size, size), Image.LANCZOS)


def save(img, rel_path):
    out = ROOT / rel_path
    out.parent.mkdir(parents=True, exist_ok=True)
    img.save(out)
    print(f"wrote {rel_path}")


def make_masters():
    full = artwork(MASTER)
    rounded = full.copy()
    # Squircle-ish rounding baked in for surfaces that show the raw PNG. The
    # corner radius scales with the master so the squircle looks identical at 2K.
    rounded.putalpha(rounded_mask((MASTER, MASTER), round(MASTER * 0.2197)))
    save(rounded, "assets/icon/icon.png")
    # Adaptive layers: launchers mask to a ~66% circle; LAUNCHER_FG_SCALE keeps
    # the mark inside the safe zone (the anydpi-v26 XML adds a small inset).
    save(artwork(MASTER, transparent_bg=True, scale=LAUNCHER_FG_SCALE),
         "assets/icon/icon_foreground.png")
    save(artwork(MASTER, transparent_bg=True, monochrome=True,
                 scale=LAUNCHER_FG_SCALE),
         "assets/icon/icon_monochrome.png")


def make_android_launchers():
    rounded = Image.open(ROOT / "assets/icon/icon.png")
    for density, px in MIPMAP_SIZES.items():
        save(rounded.resize((px, px), Image.LANCZOS),
             f"android/app/src/main/res/mipmap-{density}/ic_launcher.png")
    for density, px in ADAPTIVE_SIZES.items():
        save(artwork(px, transparent_bg=True, scale=LAUNCHER_FG_SCALE),
             f"android/app/src/main/res/drawable-{density}/"
             f"ic_launcher_foreground.png")
        save(artwork(px, transparent_bg=True, monochrome=True,
                     scale=LAUNCHER_FG_SCALE),
             f"android/app/src/main/res/drawable-{density}/"
             f"ic_launcher_monochrome.png")


def make_splash_icons():
    # BOXLESS, THEME-ADAPTIVE splash badge (transparent bg — NO cream tile). The
    # splash WINDOW background is the field (cream in light mode, dark in night;
    # see @color/splash_background + its values-night override), and this badge
    # sits directly on it:
    #   drawable-*/splash_icon        -> dark-ink Q  (for the cream light field)
    #   drawable-night-*/splash_icon  -> light paper Q (for the dark night field)
    # This removes the old cream "box" that appeared whenever the field was not
    # cream — an OEM/dark handoff that showed a dark field behind a cream tile
    # (the user's screenshot). Android auto-selects the -night variant, so the
    # existing styles/launch_background need no drawable-name change.
    for density, px in SPLASH_SIZES.items():
        save(artwork(px, transparent_bg=True, scale=0.60),
             f"android/app/src/main/res/drawable-{density}/splash_icon.png")
        save(artwork(px, transparent_bg=True, scale=0.60,
                     q_col=INK_DARK, mark_col=ACCENT_DARK,
                     line_col=UNDERLINE_DARK),
             f"android/app/src/main/res/drawable-night-{density}/splash_icon.png")


def notification_glyph(size):
    """The status-bar / notification silhouette, tuned for tiny sizes.

    Android strips color from small icons and paints the alpha mask white
    inside its own (accent-tinted, circular) chrome, so this MUST be a clean,
    bold, frameless silhouette — no tile, no background. Compared with the
    launcher mark it is drawn HEAVIER (Lora 700) and LARGER so the serif Q
    fills the 24dp keyline and stays crisp inside the system circle; the "?"
    is dropped (an illegible speck at this size) and the cipher shelf is made
    chunky (a deliberate brand bar, not a stray hairline). Supersampled then
    Lanczos-downscaled like every other raster here."""
    big = Image.new("RGBA", (SS, SS), (0, 0, 0, 0))
    draw = ImageDraw.Draw(big)
    white = (255, 255, 255, 255)
    # A big, bold serif Q, optically centered a touch high so the shelf below
    # has room; the tail clears the shelf.
    draw_glyph_centered(draw, "Q", lora(int(SS * 0.66), weight=700),
                        (SS * 0.5, SS * 0.44), white)
    # Short, chunky cipher shelf — thick enough to survive at 24dp.
    line_h = SS * 0.085
    draw.rounded_rectangle(
        [SS * 0.30, SS * 0.855 - line_h / 2,
         SS * 0.70, SS * 0.855 + line_h / 2],
        radius=line_h / 2, fill=white)
    return big.resize((size, size), Image.LANCZOS)


def make_notification_icons():
    # Status-bar glyphs are alpha-only: white mark, no ?, no background.
    for density, px in STAT_SIZES.items():
        save(notification_glyph(px),
             f"android/app/src/main/res/drawable-{density}/"
             f"ic_stat_quotecrack.png")


def make_web_icons():
    full = artwork(MASTER)
    # 1024 added for retina PWA install / hi-DPI social previews.
    for px in (192, 512, 1024):
        save(full.resize((px, px), Image.LANCZOS).convert("RGB"),
             f"web/icons/Icon-{px}.png")
    # Maskable: artwork inside the 80%-diameter safe circle, full-bleed bg.
    for px in (192, 512, 1024):
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
        color = ACCENT + (255,) if ch in "CK" and i >= 5 else INK + (255,)
        cx = x + i * (tile_w + gap) + tile_w / 2
        draw_glyph_centered(draw, ch, big, (cx, y + tile_h * 0.26), color)
        ly = y + tile_h * 0.62
        draw.line([(cx - tile_w * 0.42, ly), (cx + tile_w * 0.42, ly)],
                  fill=UNDERLINE + (255,), width=max(6, int(tile_h * 0.045)))
        sb = draw.textbbox((0, 0), cipher[i], font=small)
        draw.text((cx - (sb[2] - sb[0]) / 2 - sb[0], ly + tile_h * 0.07 - sb[1]),
                  cipher[i], font=small, fill=UNDERLINE + (210,))


# Per-language Play feature-graphic tagline. Each Play Console listing language
# can carry its own feature graphic, so we render one per locale; the text is
# the canonical opening line of that language's store description in
# docs/STORE_LISTING.md. Keep these in sync if the store copy changes.
FEATURE_TAGLINES = {
    "en": "Decode famous quotes. One cipher a day.",
    "tr": "Sözü harf harf çöz.",
    "de": "Enthülle das Zitat, Buchstabe für Buchstabe.",
    "es": "Revela la frase, letra a letra.",
    "fr": "Révélez la citation, lettre par lettre.",
    "it": "Svela la frase, lettera per lettera.",
    "pt": "Revele a frase, letra por letra.",
}


def _fit_single_line(draw, text, max_width, start_px, font_path=FONT_UI,
                     min_px=24):
    """Largest font (<= start_px) at which `text` fits on one line within
    max_width, never going below min_px. Long locale taglines auto-shrink
    instead of overflowing the canvas."""
    px = start_px
    while px > min_px:
        font = ImageFont.truetype(str(font_path), px)
        bbox = draw.textbbox((0, 0), text, font=font)
        if bbox[2] - bbox[0] <= max_width:
            break
        px -= 2
    return ImageFont.truetype(str(font_path), px)


def make_feature_graphic(tag, out_path):
    """Play feature graphic keeps the richer decoded-word motif. `tag` is the
    localized tagline; it auto-shrinks to stay within the 1024px width."""
    size = (1024, 500)
    img = vertical_gradient(size, BG_TOP, BG_BOTTOM).convert("RGBA")
    draw = ImageDraw.Draw(img)

    draw_decoded_tiles(draw, canvas_w=size[0], y=105,
                       tile_w=76, tile_h=150, gap=12)

    tag_font = _fit_single_line(draw, tag, max_width=size[0] - 96,
                                start_px=40)
    bbox = draw.textbbox((0, 0), tag, font=tag_font)
    # Vertically center the (possibly smaller) tagline in its band so shorter
    # locales don't sit visibly higher than longer ones.
    ty = 330 + (40 - tag_font.size) / 2
    draw.text(((size[0] - (bbox[2] - bbox[0])) / 2, ty), tag,
              font=tag_font, fill=INK + (235,))

    save(img.convert("RGB"), out_path)


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
              font=tag_font, fill=INK + (235,))

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
    # English keeps the canonical filename; each locale also gets its own.
    make_feature_graphic(FEATURE_TAGLINES["en"],
                         "store_assets/feature_graphic.png")
    for loc, tag in FEATURE_TAGLINES.items():
        make_feature_graphic(tag, f"store_assets/feature_graphic_{loc}.png")
    make_og_image()
