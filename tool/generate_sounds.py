#!/usr/bin/env python3
"""Procedural sound-effect generator for Quotecrack.

Pure stdlib (wave + math): no licensing, no "stock asset" feel, tiny files.
Design language: soft sine tones with a gentle attack, exponential decay,
and a quiet 2nd harmonic for warmth — calm, paper-and-ink aesthetics to
match the game.

Usage: python3 tool/generate_sounds.py
Outputs (committed): assets/audio/{tap,hint,conflict,success,achievement}.wav
"""

import math
import struct
import wave
from pathlib import Path

RATE = 44100
OUT = Path(__file__).resolve().parent.parent / "assets/audio"


def tone(freq, dur, *, volume=0.5, attack=0.004, decay=6.0, harmonic=0.25):
    """One soft note: sine + quiet 2nd harmonic, soft attack, exp decay."""
    n = int(RATE * dur)
    samples = []
    for i in range(n):
        t = i / RATE
        env = min(1.0, t / attack) * math.exp(-decay * t)
        s = math.sin(2 * math.pi * freq * t)
        s += harmonic * math.sin(2 * math.pi * freq * 2 * t)
        samples.append(volume * env * s / (1 + harmonic))
    return samples


def mix(*tracks):
    """Overlay tracks (list of (offset_seconds, samples)) into one buffer."""
    total = max(int(off * RATE) + len(s) for off, s in tracks)
    buf = [0.0] * total
    for off, s in tracks:
        start = int(off * RATE)
        for i, v in enumerate(s):
            buf[start + i] += v
    peak = max(1.0, max(abs(v) for v in buf) / 0.85)
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


# Keyboard tap: barely-there woody tick.
write("tap.wav", mix((0, tone(1250, 0.045, volume=0.32, decay=70, harmonic=0.1))))

# Hint reveal: soft rising pop (G5 -> C6 blip).
write(
    "hint.wav",
    mix(
        (0.00, tone(784, 0.10, volume=0.35, decay=22)),
        (0.06, tone(1047, 0.14, volume=0.38, decay=18)),
    ),
)

# Conflict: muted low knock — informative, never punishing.
write("conflict.wav", mix((0, tone(196, 0.16, volume=0.34, decay=22, harmonic=0.15))))

# Puzzle solved: warm C-major arpeggio with overlapping tails (C5 E5 G5 C6).
write(
    "success.wav",
    mix(
        (0.00, tone(523.25, 0.45, volume=0.40, decay=5.5)),
        (0.11, tone(659.25, 0.45, volume=0.40, decay=5.5)),
        (0.22, tone(783.99, 0.50, volume=0.40, decay=5.0)),
        (0.33, tone(1046.50, 0.65, volume=0.42, decay=4.0)),
    ),
)

# Achievement: two bright sparkle notes (E6, B6) with shimmer.
write(
    "achievement.wav",
    mix(
        (0.00, tone(1318.5, 0.22, volume=0.36, decay=10, harmonic=0.35)),
        (0.12, tone(1975.5, 0.34, volume=0.38, decay=8, harmonic=0.35)),
    ),
)
