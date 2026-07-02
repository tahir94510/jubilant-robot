#!/usr/bin/env python3
"""Compose localized Play Store marketing screenshots from rendered app screens.

Frames each high-res app-screen render (from test/preview/shots_hires_test.dart)
onto a branded "Ink & Gold" canvas with a localized headline and a floating
device card. Outputs the 2026 Play spec sizes for every language:
  phone      1080x1920   (store_assets/screenshots/phone/<lang>/)
  tablet 7"  1200x1920   (store_assets/screenshots/tablet_7/<lang>/)
  tablet 10" 1920x2560   (store_assets/screenshots/tablet_10/<lang>/)
Output is 24-bit PNG (no alpha), which Play accepts (<=8 MB each).
"""
import os
from PIL import Image, ImageDraw, ImageFont, ImageFilter

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SHOTS = os.path.join(ROOT, "test/preview/shots")
FONT_LORA = os.path.join(ROOT, "assets/fonts/Lora-Variable.ttf")

# Light ("paper") canvas palette + a dark variant for the Premium showcase.
INK = (38, 34, 28)
GOLD = (150, 110, 30)
BG_TOP_L, BG_BOT_L = (247, 244, 236), (234, 225, 206)
BG_TOP_D, BG_BOT_D = (28, 26, 22), (18, 17, 14)
INK_D = (242, 237, 226)
GOLD_D = (217, 178, 90)

# One screen render -> (headline key, dark showcase?). Order = store order.
# All six use the light "paper" canvas: one dark odd-one-out read as a mistake
# next to five light frames, and the set converts better as a single system.
SCREENS = [
    ("s_home", "home", False),
    ("s_puzzle", "puzzle", False),
    ("s_stats", "stats", False),
    ("s_ach", "ach", False),
    ("s_packs", "packs", False),
    ("s_paywall", "premium", False),
]

# Culturally-adapted marketing headlines (not literal translations).
HEADLINES = {
    "en": {
        "home": "A fresh cipher, every single day",
        "puzzle": "Decode it, one letter at a time",
        "stats": "Build streaks. Track every solve.",
        "ach": "Unlock 24 achievements",
        "packs": "Difficulty and themed packs",
        "premium": "Go Premium. Play without limits.",
    },
    "tr": {
        "home": "Her gün taze bir şifre",
        "puzzle": "Harf harf çöz",
        "stats": "Serini büyüt, her çözümü izle",
        "ach": "24 başarımın kilidini aç",
        "packs": "Zorluk ve tema paketleri",
        "premium": "Premium'a geç, sınırsız oyna",
    },
    "es": {
        "home": "Un nuevo cifrado cada día",
        "puzzle": "Descífralo letra a letra",
        "stats": "Crea rachas. Sigue cada solución.",
        "ach": "Desbloquea 24 logros",
        "packs": "Packs por dificultad y temáticos",
        "premium": "Hazte Premium. Juega sin límites.",
    },
    "de": {
        "home": "Jeden Tag ein neues Rätsel",
        "puzzle": "Entschlüssle Buchstabe für Buchstabe",
        "stats": "Serien aufbauen, Fortschritt verfolgen",
        "ach": "24 Erfolge freischalten",
        "packs": "Schwierigkeits- und Themenpakete",
        "premium": "Premium holen. Ohne Limits spielen.",
    },
    "fr": {
        "home": "Un nouveau chiffre chaque jour",
        "puzzle": "Déchiffre lettre par lettre",
        "stats": "Enchaîne les séries, suis tes progrès",
        "ach": "Débloque 24 succès",
        "packs": "Packs par difficulté et thématiques",
        "premium": "Passe Premium. Joue sans limites.",
    },
    "it": {
        "home": "Un nuovo cifrario ogni giorno",
        "puzzle": "Decifra lettera per lettera",
        "stats": "Costruisci serie, monitora i progressi",
        "ach": "Sblocca 24 obiettivi",
        "packs": "Pacchetti per difficoltà e a tema",
        "premium": "Passa a Premium. Gioca senza limiti.",
    },
    "pt": {
        "home": "Uma nova cifra todos os dias",
        "puzzle": "Decifre letra por letra",
        "stats": "Crie sequências, acompanhe tudo",
        "ach": "Desbloqueie 24 conquistas",
        "packs": "Pacotes por dificuldade e temáticos",
        "premium": "Seja Premium. Jogue sem limites.",
    },
}

SIZES = {
    "phone": (1080, 1920),
    "tablet_7": (1200, 1920),
    "tablet_10": (1920, 2560),
}


def lora(px, weight=600):
    f = ImageFont.truetype(FONT_LORA, px)
    try:
        f.set_variation_by_axes([weight])
    except OSError:
        pass
    return f


def gradient(w, h, top, bot):
    img = Image.new("RGB", (w, h))
    d = ImageDraw.Draw(img)
    for y in range(h):
        t = y / max(h - 1, 1)
        d.line([(0, y), (w, y)],
               fill=tuple(round(top[i] + (bot[i] - top[i]) * t) for i in range(3)))
    return img


def wrap(draw, text, font, max_w):
    words, lines, cur = text.split(), [], ""
    for wd in words:
        trial = (cur + " " + wd).strip()
        if draw.textlength(trial, font=font) <= max_w:
            cur = trial
        else:
            if cur:
                lines.append(cur)
            cur = wd
    if cur:
        lines.append(cur)
    return lines


def rounded(img, radius):
    mask = Image.new("L", img.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        [0, 0, img.size[0] - 1, img.size[1] - 1], radius=radius, fill=255)
    out = img.convert("RGBA")
    out.putalpha(mask)
    return out


def compose(screen_png, headline, out_path, size, dark=False):
    W, H = size
    s = W / 1080.0
    ink = INK_D if dark else INK
    gold = GOLD_D if dark else GOLD
    top, bot = (BG_TOP_D, BG_BOT_D) if dark else (BG_TOP_L, BG_BOT_L)
    canvas = gradient(W, H, top, bot).convert("RGBA")
    draw = ImageDraw.Draw(canvas)

    # Headline (Lora), centered, up to 2 lines, with a gold cipher underline.
    hfont = lora(int(58 * s), weight=600)
    lines = wrap(draw, headline, hfont, int(W * 0.86))[:2]
    y = int(120 * s)
    for ln in lines:
        w = draw.textlength(ln, font=hfont)
        draw.text(((W - w) / 2, y), ln, font=hfont, fill=ink)
        y += int(74 * s)
    bar_w, bar_h = int(120 * s), int(7 * s)
    draw.rounded_rectangle(
        [(W - bar_w) / 2, y + int(12 * s), (W + bar_w) / 2, y + int(12 * s) + bar_h],
        radius=bar_h / 2, fill=gold)

    # Floating device card: fit within the space below the headline, capped by
    # a max width, so the same phone-aspect render sits well on every canvas.
    screen = Image.open(screen_png).convert("RGBA")
    ar = screen.size[0] / screen.size[1]
    top_room = y + int(70 * s)
    avail_h = H - top_room - int(70 * s)
    dev_h = avail_h
    dev_w = round(dev_h * ar)
    max_w = int(W * 0.74)
    if dev_w > max_w:
        dev_w = max_w
        dev_h = round(dev_w / ar)
    dev_x = (W - dev_w) // 2
    dev_y = top_room + (avail_h - dev_h) // 2
    screen = rounded(screen.resize((dev_w, dev_h), Image.LANCZOS), int(40 * s))
    shadow = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    ImageDraw.Draw(shadow).rounded_rectangle(
        [dev_x, dev_y + int(16 * s), dev_x + dev_w, dev_y + dev_h + int(16 * s)],
        radius=int(40 * s), fill=(0, 0, 0, 110 if dark else 90))
    canvas.alpha_composite(shadow.filter(ImageFilter.GaussianBlur(int(26 * s))))
    canvas.alpha_composite(screen, (dev_x, dev_y))
    canvas.convert("RGB").save(out_path)


def compose_landscape(screen_png, headline, out_path, size=(1920, 1080)):
    """Chromebook slot: LANDSCAPE 16:9 layout — headline block on the left,
    floating device card on the right. Same "Ink & Gold" system as portrait."""
    W, H = size
    s = H / 1080.0
    canvas = gradient(W, H, BG_TOP_L, BG_BOT_L).convert("RGBA")
    draw = ImageDraw.Draw(canvas)

    # Device card on the right: fill most of the height.
    screen = Image.open(screen_png).convert("RGBA")
    ar = screen.size[0] / screen.size[1]
    dev_h = int(H * 0.86)
    dev_w = round(dev_h * ar)
    dev_x = W - dev_w - int(W * 0.07)
    dev_y = (H - dev_h) // 2
    card = rounded(screen.resize((dev_w, dev_h), Image.LANCZOS), int(36 * s))
    shadow = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    ImageDraw.Draw(shadow).rounded_rectangle(
        [dev_x, dev_y + int(14 * s), dev_x + dev_w, dev_y + dev_h + int(14 * s)],
        radius=int(36 * s), fill=(0, 0, 0, 90))
    canvas.alpha_composite(shadow.filter(ImageFilter.GaussianBlur(int(24 * s))))
    canvas.alpha_composite(card, (dev_x, dev_y))

    # Headline block, vertically centered in the space left of the card.
    text_left = int(W * 0.07)
    text_w = dev_x - text_left - int(W * 0.05)
    hfont = lora(int(72 * s), weight=600)
    lines = wrap(draw, headline, hfont, text_w)[:3]
    line_h = int(90 * s)
    bar_h = int(8 * s)
    block_h = len(lines) * line_h + int(26 * s) + bar_h
    y = (H - block_h) // 2
    for ln in lines:
        draw.text((text_left, y), ln, font=hfont, fill=INK)
        y += line_h
    draw.rounded_rectangle(
        [text_left, y + int(18 * s), text_left + int(150 * s), y + int(18 * s) + bar_h],
        radius=bar_h / 2, fill=GOLD)
    canvas.convert("RGB").save(out_path)


def main():
    total = 0
    for lang, heads in HEADLINES.items():
        for size_name, dims in SIZES.items():
            out_dir = os.path.join(ROOT, "store_assets/screenshots", size_name, lang)
            os.makedirs(out_dir, exist_ok=True)
            for i, (render, hkey, dark) in enumerate(SCREENS, 1):
                # Each language frames its OWN localized app render.
                compose(os.path.join(SHOTS, lang, render + ".png"), heads[hkey],
                        os.path.join(out_dir, f"{i:02d}_{hkey}.png"), dims, dark=dark)
                total += 1
        # Chromebook: landscape 16:9 (Chromebooks are landscape devices; a
        # portrait upload presents poorly there). Optional slot on Play.
        out_dir = os.path.join(ROOT, "store_assets/screenshots", "chromebook", lang)
        os.makedirs(out_dir, exist_ok=True)
        for i, (render, hkey, _dark) in enumerate(SCREENS, 1):
            compose_landscape(os.path.join(SHOTS, lang, render + ".png"),
                              heads[hkey],
                              os.path.join(out_dir, f"{i:02d}_{hkey}.png"))
            total += 1
    print(f"wrote {total} screenshots across {len(HEADLINES)} languages "
          f"({len(SIZES)} portrait sizes + chromebook landscape) x "
          f"{len(SCREENS)} screens")


if __name__ == "__main__":
    main()
