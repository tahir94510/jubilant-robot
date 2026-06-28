#!/usr/bin/env python3
"""Procedural sound-effect generator for Quotecrack.

Pure stdlib (wave + math): no licensing, no "stock asset" feel, tiny files.

Sound design v3 — warmer, fuller, "in a room", and now STEREO:
- Each note is an additive bell: several (slightly inharmonic) partials with
  independent decay rates (bright partials die first, like a real struck
  object), a sub-octave for body, and a whisper of detune for chorus width.
- A gentle one-pole low-pass rounds off the harsh top end (the main thing that
  read as "cheap/beepy"), then soft tanh saturation adds warmth.
- A short STEREO ambience (dry signal centred + a handful of decaying early
  reflections panned left/right) gives a sense of space without a washy reverb.
  It is mono-safe: the dry transient stays centred and L+R never cancels, so it
  still sounds clean on a single phone speaker.
- Soft attacks, long natural releases, and raised-cosine edge fades to true
  silence so nothing ever clicks.

Usage: python3 tool/generate_sounds.py
Outputs (committed): assets/audio/{tap,hint,conflict,success,achievement,word}.wav
"""

import math
import random
import struct
import wave
from pathlib import Path

RATE = 44100
OUT = Path(__file__).resolve().parent.parent / "assets/audio"
random.seed(7)  # deterministic output

# A warm, slightly inharmonic partial set: (ratio, amplitude, decay_multiplier).
# Higher partials decay faster (organic), a 0.5 sub adds body, and the small
# 2.01/3.01 detune from exact harmonics gives the shimmer of a real struck bell.
_BELL_PARTIALS = (
    (1.00, 1.00, 1.0),
    (2.01, 0.30, 1.8),
    (3.01, 0.13, 2.5),
    (4.70, 0.06, 3.4),
    (0.50, 0.20, 0.7),
)


def bell(freq, dur, *, volume=0.5, attack=0.012, decay=4.0,
         partials=_BELL_PARTIALS, detune_cents=5.0):
    """One warm bell-like note (mono).

    partials: (ratio, amplitude, decay_multiplier) — higher partials decay
    faster, which is what makes struck/plucked sounds feel organic.
    """
    n = int(RATE * dur)
    det = 2 ** (detune_cents / 1200.0)
    out = [0.0] * n
    for ratio, amp, dmul in partials:
        f1 = freq * ratio
        f2 = f1 * det
        for i in range(n):
            t = i / RATE
            env = min(1.0, t / attack) * math.exp(-decay * dmul * t)
            s = math.sin(2 * math.pi * f1 * t) + 0.6 * math.sin(
                2 * math.pi * f2 * t + 0.7
            )
            out[i] += volume * amp * env * s / 1.6
    return out


def low_pass(samples, cutoff_hz):
    """A gentle one-pole low-pass: rounds off the harsh top that made the old
    sines read as "beepy", leaving a warmer body. Cheap and phase-forgiving."""
    if cutoff_hz <= 0:
        return list(samples)
    dt = 1.0 / RATE
    rc = 1.0 / (2 * math.pi * cutoff_hz)
    a = dt / (rc + dt)
    out = [0.0] * len(samples)
    prev = 0.0
    for i, v in enumerate(samples):
        prev += a * (v - prev)
        out[i] = prev
    return out


def soft_clip(samples, drive=1.15):
    """Gentle tanh saturation — rounds peaks, adds warmth, kills harshness."""
    k = math.tanh(drive)
    return [math.tanh(drive * v) / k for v in samples]


# Early-reflection taps: (delay_seconds, gain, pan) with pan -1 = left, +1 =
# right. Times are short and irregular (a small, bright room, not a hall), and
# each panned reflection bleeds a little to the far channel so the image is wide
# but still folds down cleanly to mono.
_SPACE_TAPS = (
    (0.011, 0.50, -1),
    (0.019, 0.42, +1),
    (0.029, 0.32, +1),
    (0.041, 0.24, -1),
    (0.055, 0.18, -1),
    (0.071, 0.13, +1),
    (0.089, 0.09, +1),
)


def stereo_space(mono, *, wet=0.16, tail=0.11):
    """Place a mono signal in a small stereo room.

    The dry signal sits dead centre (so the attack stays punchy and mono-safe);
    a few decaying early reflections, panned L/R, add air and width. Returns
    (left, right). L+R keeps the dry centred and never phase-cancels.
    """
    n = len(mono)
    extra = int(RATE * tail)
    left = [0.0] * (n + extra)
    right = [0.0] * (n + extra)
    for i, v in enumerate(mono):
        left[i] += v
        right[i] += v
    for delay, gain, pan in _SPACE_TAPS:
        d = int(RATE * delay)
        near = wet * gain
        far = near * 0.4  # cross-bleed keeps it mono-compatible
        gl, gr = (near, far) if pan < 0 else (far, near)
        for i, v in enumerate(mono):
            left[i + d] += gl * v
            right[i + d] += gr * v
    return left, right


def mix(*tracks):
    """Sum layered mono tracks, each at its (offset_seconds, samples)."""
    total = max(int(off * RATE) + len(s) for off, s in tracks)
    buf = [0.0] * total
    for off, s in tracks:
        start = int(off * RATE)
        for i, v in enumerate(s):
            buf[start + i] += v
    return buf


def clean_edges(samples, *, fade_in=0.010, fade_out=0.120):
    """Force a channel to start and end at true silence with a raised-cosine
    ramp. Without this, a tail still audible when the buffer ends produces a
    hard step -> an audible click. Applied to both channels of every sound.

    The 10ms fade-in softens the hard attack transient; the generous 120ms
    fade-out resolves long bell tails to true silence smoothly (longer than the
    old 80ms so even the deepest cues settle gently, never abruptly). The ramps
    are capped at half the buffer, so very short clips (the tap) are unaffected."""
    out = list(samples)
    n = len(out)
    fi = min(int(RATE * fade_in), n // 2)
    fo = min(int(RATE * fade_out), n // 2)
    for i in range(fi):
        out[i] *= 0.5 - 0.5 * math.cos(math.pi * i / fi)
    for i in range(fo):
        out[n - 1 - i] *= 0.5 - 0.5 * math.cos(math.pi * i / fo)
    return out


def pad_silence(samples, *, lead=0.004, tail=0.060):
    """Bracket a channel with absolute digital silence (zeros).

    The trailing runway is the key one: the discrete cues are played with the
    media player's ReleaseMode.stop, so the native MediaPlayer calls stop() the
    instant it reaches end-of-file. If the very last frames still carry signal
    (or even the decoder's own ring-out), that stop() lands on a non-silent
    sample -> a hard step the speaker reproduces as a click/crackle at the END
    of the effect. A short silent tail guarantees stop() always fires while the
    buffer is already at zero, so the clip resolves cleanly every time. A tiny
    lead of silence likewise gives a clean run-in."""
    li = int(RATE * lead)
    ti = int(RATE * tail)
    return [0.0] * li + list(samples) + [0.0] * ti


def render(name, mono, *, target=0.7, wet=0.16, cutoff=7000, space=True):
    """Master one sound and write it as a 16-bit stereo WAV.

    `target` is the per-sound loudness role, so the family stays balanced: the
    solve fanfare is the loudest moment, a keyboard tap the quietest, everything
    else between. (Playback volume is uniform, so the WAV peak *is* the relative
    loudness.)"""
    mono = soft_clip(low_pass(mono, cutoff))
    if space:
        left, right = stereo_space(mono, wet=wet)
    else:
        left, right = list(mono), list(mono)
    # Normalise the JOINT peak to `target` so the stereo image keeps its balance.
    peak = max(
        max((abs(v) for v in left), default=0.0),
        max((abs(v) for v in right), default=0.0),
    ) or 1.0
    scale = target / peak
    # Fade the edges to silence, THEN bracket with absolute-zero padding so the
    # media player's stop-at-EOF always lands on pure silence (no end click).
    left = pad_silence(clean_edges([v * scale for v in left]))
    right = pad_silence(clean_edges([v * scale for v in right]))
    _write_stereo(name, left, right)


def _write_stereo(name, left, right):
    OUT.mkdir(parents=True, exist_ok=True)
    n = min(len(left), len(right))
    peak = max(
        max((abs(v) for v in left), default=0.0),
        max((abs(v) for v in right), default=0.0),
    )
    # Leave headroom so the int16 clamp never hard-clips (clipping = crackle).
    g = (0.95 / peak) if peak > 0.95 else 1.0

    def s16(v):
        return int(max(-1.0, min(1.0, v * g)) * 32767)

    data = b"".join(struct.pack("<hh", s16(left[i]), s16(right[i]))
                    for i in range(n))
    path = OUT / name
    with wave.open(str(path), "w") as f:
        f.setnchannels(2)
        f.setsampwidth(2)
        f.setframerate(RATE)
        f.writeframes(data)
    edge = max(abs(left[0]), abs(left[-1]), abs(right[0]), abs(right[-1]))
    print(f"wrote {path} ({path.stat().st_size} bytes, peak {peak:.3f}, "
          f"edge {edge:.5f})")


# Keyboard tap: woody, barely-there — felt more than heard. A soft pitched
# "thock" (two low partials) with a tiny noise transient for fingertip texture,
# kept DRY and snappy (no ambience tail) so rapid typing never smears.
def tap_sound():
    n = int(RATE * 0.055)
    out = [0.0] * n
    for i in range(n):
        t = i / RATE
        env = min(1.0, t / 0.003) * math.exp(-72 * t)
        # A short, soft noise click for fingertip texture (decays very fast).
        noise = (random.random() * 2 - 1) * 0.16 * math.exp(-300 * t)
        knock = 0.60 * math.sin(2 * math.pi * 540 * t) * env
        body = 0.32 * math.sin(2 * math.pi * 270 * t) * env
        out[i] = 0.5 * (noise + knock + body)
    return out


# Keyboard tap is the quietest member of the family: felt, not heard. Lightly
# low-passed for a rounder "thock" and kept DRY (no ambience tail) so rapid
# typing stays crisp and never smears.
render("tap.wav", tap_sound(), target=0.34, cutoff=5200, space=False)

# Hint reveal: two soft ascending bells (G5 -> C6) in a little air.
render(
    "hint.wav",
    mix(
        (0.00, bell(784.0, 0.34, volume=0.30, decay=6.5)),
        (0.09, bell(1046.5, 0.46, volume=0.32, decay=5.5)),
    ),
    target=0.60,
    wet=0.18,
    cutoff=7500,
)

# Conflict: a muted low wood-block — informative, never punishing.
render(
    "conflict.wav",
    bell(
        208.0, 0.28, volume=0.34, decay=10.0,
        partials=((1.0, 1.0, 1.0), (1.62, 0.30, 2.2), (0.5, 0.22, 0.9)),
        detune_cents=8.0,
    ),
    target=0.52,
    wet=0.12,
    cutoff=3600,
)

# Puzzle solved: an unhurried C-major arpeggio that climbs two octaves and
# resolves with a high sparkle, over a sustained low-C pad — triumphant and
# warm, the single most rewarding moment in the app.
render(
    "success.wav",
    mix(
        (0.00, bell(130.81, 1.8, volume=0.16, decay=1.4,
                    partials=((1.0, 1.0, 1.0), (2.0, 0.2, 1.6)))),   # C3 pad
        (0.00, bell(523.25, 0.9, volume=0.30, decay=3.1)),          # C5
        (0.13, bell(659.25, 0.9, volume=0.30, decay=3.1)),          # E5
        (0.26, bell(783.99, 1.0, volume=0.30, decay=2.8)),          # G5
        (0.42, bell(1046.5, 1.15, volume=0.32, decay=2.3)),         # C6
        (0.55, bell(1568.0, 1.1, volume=0.28, decay=2.3)),          # G6 lift
        (0.66, bell(2093.0, 1.2, volume=0.22, decay=2.1,            # C7 sparkle
                    attack=0.014)),
    ),
    target=0.90,  # the loudest, most rewarding moment in the app
    wet=0.20,
    cutoff=9000,
)

# Achievement: a bright rising sparkle (G5 grace -> E6 -> B6) with a soft low
# body note for weight, so it lands as a proud "ding!" instead of a thin tick.
render(
    "achievement.wav",
    mix(
        (0.00, bell(392.0, 0.5, volume=0.14, decay=4.3)),            # G4 body
        (0.00, bell(784.0, 0.25, volume=0.20, decay=7.5)),           # G5 grace
        (0.05, bell(1318.5, 0.5, volume=0.27, decay=4.6)),           # E6
        (0.17, bell(1975.5, 0.75, volume=0.24, decay=4.0, attack=0.016)),
        (0.30, bell(2637.0, 0.6, volume=0.16, decay=3.7, attack=0.018)),
    ),
    target=0.74,
    wet=0.20,
    cutoff=9000,
)

# Word complete: one soft high bell (E6) — quieter and shorter than the hint's
# two-note rise, so it reads as "progress", not "reward". Long, gentle decay so
# it rings out and settles on its own before the edge fade.
render(
    "word.wav",
    bell(1318.5, 0.55, volume=0.24, decay=4.8),
    target=0.42,
    wet=0.16,
    cutoff=8000,
)
