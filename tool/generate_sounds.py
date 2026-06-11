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


def bell(freq, dur, *, volume=0.5, attack=0.008, decay=4.0,
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


def mix(*tracks):
    total = max(int(off * RATE) + len(s) for off, s in tracks)
    buf = [0.0] * total
    for off, s in tracks:
        start = int(off * RATE)
        for i, v in enumerate(s):
            buf[start + i] += v
    peak = max(1.0, max(abs(v) for v in buf) / 0.82)
    return [v / peak for v in buf]


def write(name, samples):
    OUT.mkdir(parents=True, exist_ok=True)
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
    print(f"wrote {path} ({path.stat().st_size} bytes)")


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


write("tap.wav", mix((0, tap_sound())))

# Hint reveal: two soft ascending bells (G5 -> C6) with air.
write(
    "hint.wav",
    mix(
        (0.00, air(bell(784, 0.30, volume=0.30, decay=7))),
        (0.09, air(bell(1046.5, 0.42, volume=0.32, decay=6))),
    ),
)

# Conflict: a muted low wood-block — informative, never punishing.
write(
    "conflict.wav",
    mix((0, air(bell(208, 0.26, volume=0.34, decay=11,
                     partials=((1.0, 1.0, 1.0), (1.62, 0.3, 2.2),
                               (0.5, 0.22, 0.9)),
                     detune_cents=7), amount=0.04))),
)

# Puzzle solved: unhurried C-major arpeggio with a low C pad underneath —
# the pad sustains while the melody rings, which reads as "warm", not
# "ringtone".
write(
    "success.wav",
    mix(
        (0.00, bell(130.81, 1.5, volume=0.16, decay=1.6,
                    partials=((1.0, 1.0, 1.0), (2.0, 0.2, 1.6)))),  # C3 pad
        (0.00, air(bell(523.25, 0.9, volume=0.30, decay=3.2))),     # C5
        (0.13, air(bell(659.25, 0.9, volume=0.30, decay=3.2))),     # E5
        (0.26, air(bell(783.99, 1.0, volume=0.30, decay=2.9))),     # G5
        (0.42, air(bell(1046.5, 1.25, volume=0.33, decay=2.2))),    # C6
    ),
)

# Achievement: bright two-note sparkle (E6 -> B6) over a quick G5 grace.
write(
    "achievement.wav",
    mix(
        (0.00, air(bell(784, 0.25, volume=0.20, decay=8))),
        (0.05, air(bell(1318.5, 0.5, volume=0.28, decay=5))),
        (0.17, air(bell(1975.5, 0.7, volume=0.30, decay=4))),
    ),
)
