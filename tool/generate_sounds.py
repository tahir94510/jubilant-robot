#!/usr/bin/env python3
"""Procedural sound-effect generator for Quotecrack.

Pure stdlib (wave + math): no licensing, no "stock asset" feel, tiny files.

Sound design v2 — richer, warmer, less "beepy":
- Each note is an additive bell: several inharmonic-ish partials with
  independent decay rates (bright partials die first, like a real struck
  object), a sub-octave for body, and a whisper of detune for chorus width.
- Soft 8ms attacks, long natural releases, gentle saturation, and a touch
  of early-reflection "air" so notes feel like they happen in a room.

Usage: python3 tool/generate_sounds.py
Outputs (committed): assets/audio/{tap,hint,conflict,success,achievement}.wav
"""

import math
import random
import struct
import wave
from pathlib import Path

RATE = 44100
OUT = Path(__file__).resolve().parent.parent / "assets/audio"
random.seed(7)  # deterministic output


def bell(freq, dur, *, volume=0.5, attack=0.011, decay=4.0,
         partials=((1.0, 1.0, 1.0), (2.0, 0.32, 1.9), (2.99, 0.14, 2.6),
                   (0.5, 0.18, 0.8)),
         detune_cents=4.0):
    """One warm bell-like note.

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
    # Gentle tanh saturation rounds the peaks (adds warmth, kills harshness).
    return [math.tanh(1.2 * v) / math.tanh(1.2) for v in out]


def air(samples, *, amount=0.05, delay_ms=23.0):
    """A single soft early reflection — a hint of room, not a reverb."""
    d = int(RATE * delay_ms / 1000)
    out = list(samples) + [0.0] * d
    for i, v in enumerate(samples):
        out[i + d] += amount * v
    return out


def mix(*tracks, target=0.82):
    """Sum tracks, then scale so the result peaks exactly at `target`.

    `target` is the per-sound loudness role, so the family stays balanced:
    the solve fanfare is the loudest moment, a keyboard tap the quietest,
    everything else sits between. (Playback volume is uniform, so the WAV
    peak *is* the relative loudness.)"""
    total = max(int(off * RATE) + len(s) for off, s in tracks)
    buf = [0.0] * total
    for off, s in tracks:
        start = int(off * RATE)
        for i, v in enumerate(s):
            buf[start + i] += v
    peak = max(abs(v) for v in buf) or 1.0
    return [v * (target / peak) for v in buf]


def clean_edges(samples, *, fade_in=0.010, fade_out=0.080):
    """Force every clip to start and end at true silence with a raised-cosine
    ramp. Without this, a bell whose exponential tail is still audible when
    the buffer ends produces a hard step -> an audible click/crackle. This is
    the single most important anti-crackle step, applied to every sound.

    The fade-in is 10ms: long enough to soften the hard attack transient (a
    sharp step from silence to a sample at full amplitude clicks too), short
    enough that the sound still feels immediate/punchy. The fade-out is a
    generous 80ms: bells like word/success still carry ~10% of their amplitude
    when the buffer ends, and a short ramp let that tail get cut off abruptly.
    80ms resolves it to true silence smoothly. Short clips are unaffected —
    [fo] is capped at half the buffer (tap stays ~30ms)."""
    out = list(samples)
    n = len(out)
    fi = min(int(RATE * fade_in), n // 2)
    fo = min(int(RATE * fade_out), n // 2)
    for i in range(fi):
        out[i] *= 0.5 - 0.5 * math.cos(math.pi * i / fi)
    for i in range(fo):
        out[n - 1 - i] *= 0.5 - 0.5 * math.cos(math.pi * i / fo)
    return out


def write(name, samples):
    OUT.mkdir(parents=True, exist_ok=True)
    samples = clean_edges(samples)
    peak = max((abs(v) for v in samples), default=0.0)
    # Leave headroom so the int16 clamp never hard-clips (clipping = crackle).
    if peak > 0.95:
        samples = [v * (0.95 / peak) for v in samples]
    path = OUT / name
    with wave.open(str(path), "w") as f:
        f.setnchannels(1)
        f.setsampwidth(2)
        f.setframerate(RATE)
        f.writeframes(
            b"".join(
                struct.pack("<h", int(max(-1.0, min(1.0, v)) * 32767))
                for v in samples
            )
        )
    edge = max(abs(samples[0]), abs(samples[-1]))
    print(f"wrote {path} ({path.stat().st_size} bytes, peak {peak:.3f}, "
          f"edge {edge:.5f})")


# Keyboard tap: woody, barely-there — felt more than heard.
# Short noise transient + a low damped knock (like a fingertip on wood).
def tap_sound():
    n = int(RATE * 0.06)
    out = [0.0] * n
    for i in range(n):
        t = i / RATE
        env = min(1.0, t / 0.002) * math.exp(-90 * t)
        noise = (random.random() * 2 - 1) * 0.22 * math.exp(-260 * t)
        knock = 0.6 * math.sin(2 * math.pi * 620 * t) * env
        body = 0.25 * math.sin(2 * math.pi * 310 * t) * env
        out[i] = 0.5 * (noise + knock + body)
    return out


# Keyboard tap is the quietest member of the family: felt, not heard.
write("tap.wav", mix((0, tap_sound()), target=0.34))

# Hint reveal: two soft ascending bells (G5 -> C6) with air.
write(
    "hint.wav",
    mix(
        (0.00, air(bell(784, 0.30, volume=0.30, decay=7))),
        (0.09, air(bell(1046.5, 0.42, volume=0.32, decay=6))),
        target=0.60,
    ),
)

# Conflict: a muted low wood-block — informative, never punishing.
write(
    "conflict.wav",
    mix((0, air(bell(208, 0.26, volume=0.34, decay=11,
                     partials=((1.0, 1.0, 1.0), (1.62, 0.3, 2.2),
                               (0.5, 0.22, 0.9)),
                     detune_cents=7), amount=0.04)),
        target=0.52),
)

# Puzzle solved: an unhurried C-major arpeggio that climbs two octaves and
# resolves with a high sparkle, over a sustained low-C pad — triumphant and
# warm, the single most rewarding moment in the app.
write(
    "success.wav",
    mix(
        (0.00, bell(130.81, 1.7, volume=0.16, decay=1.5,
                    partials=((1.0, 1.0, 1.0), (2.0, 0.2, 1.6)))),  # C3 pad
        (0.00, air(bell(523.25, 0.9, volume=0.30, decay=3.2))),     # C5
        (0.13, air(bell(659.25, 0.9, volume=0.30, decay=3.2))),     # E5
        (0.26, air(bell(783.99, 1.0, volume=0.30, decay=2.9))),     # G5
        (0.42, air(bell(1046.5, 1.15, volume=0.32, decay=2.4))),    # C6
        (0.55, air(bell(1568.0, 1.1, volume=0.28, decay=2.4))),     # G6 lift
        (0.66, air(bell(2093.0, 1.2, volume=0.22, decay=2.2,        # C7 sparkle
                        attack=0.014))),
        target=0.90,  # the loudest, most rewarding moment in the app
    ),
)

# Achievement: a bright rising sparkle (G5 grace -> E6 -> B6) with a soft low
# body note for weight, so it lands as a proud "ding!" instead of a thin tick.
write(
    "achievement.wav",
    mix(
        (0.00, air(bell(392.0, 0.5, volume=0.14, decay=4.5))),       # G4 body
        (0.00, air(bell(784, 0.25, volume=0.20, decay=8))),          # G5 grace
        (0.05, air(bell(1318.5, 0.5, volume=0.27, decay=5))),        # E6
        (0.17, air(bell(1975.5, 0.75, volume=0.24, decay=4.3, attack=0.016))),
        (0.30, air(bell(2637.0, 0.6, volume=0.16, decay=4.0, attack=0.018))),
        target=0.74,
    ),
)

# Word complete: one soft high bell (E6) — quieter and shorter than the
# hint's two-note rise, so it reads as "progress", not "reward".
# (Appended last: earlier outputs share the module RNG and must stay
# byte-identical.)
write(
    "word.wav",
    # Longer (0.55s) and gentler decay so the bell rings out and settles to
    # near-silence on its own before the edge fade — the old 0.32s/decay-7
    # version still carried ~10% energy at the cut, which read as "abrupt".
    mix((0.00, air(bell(1318.5, 0.55, volume=0.24, decay=5.0), amount=0.04)),
        target=0.42),
)
