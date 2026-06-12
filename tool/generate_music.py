#!/usr/bin/env python3
"""Procedural background-music generator for Quotecrack.

Pure stdlib (wave + math): no licensing, no "stock asset" feel — the same
philosophy as tool/generate_sounds.py, scaled up from blips to a bed.

The track is a seamless ~52 s ambient loop, "evening study room" mood:
- A slow Cmaj7 -> Am7 -> Fmaj7 -> G6 pad. Each chord holds ~16 s with a 3 s
  attack and 4 s release, overlapping its neighbour so the texture never
  gaps. Voices are dark (sine + quiet 2nd/3rd partials) with two ±3 cent
  detuned copies for width, and a 0.08 Hz amplitude LFO so the bed breathes.
- Sparse pentatonic bell accents (the warm bell from generate_sounds.py,
  much quieter) at irregular, seeded-random offsets — enough movement to
  feel alive, never enough to demand attention.
- A whisper of low-passed noise ("room air") under everything.

Loop seam: the piece is rendered 3 s longer than the loop, then the tail is
equal-power crossfaded into the head. The last G6 release melting into the
Cmaj7 attack is a plain V–I cadence, so the wrap is musical as well as
click-free. The script verifies the seam and exits non-zero if it ever
regresses.

Format: mono 16-bit WAV at 22050 Hz (~2.2 MB) — half the size of 44.1 kHz
with no audible cost for a low-passed ambient bed played at low volume.

Usage: python3 tool/generate_music.py
Output (committed): assets/audio/music_calm.wav
"""

import math
import random
import struct
import sys
import wave
from pathlib import Path

RATE = 22050
LOOP_SECONDS = 52.0
SEAM_SECONDS = 3.0
OUT = Path(__file__).resolve().parent.parent / "assets/audio"
random.seed(11)  # deterministic output

# ----------------------------------------------------------------------
# Building blocks
# ----------------------------------------------------------------------


def pad_voice(freq, dur, *, volume, attack=3.0, release=4.0):
    """One slow pad note: dark additive tone, two detuned copies."""
    n = int(RATE * dur)
    out = [0.0] * n
    det = 2 ** (3.0 / 1200.0)  # +/- 3 cents
    sustain_end = dur - release
    two_pi = 2 * math.pi
    for f in (freq / det, freq * det):
        w1, w2, w3 = two_pi * f, two_pi * 2 * f, two_pi * 3 * f
        for i in range(n):
            t = i / RATE
            if t < attack:
                env = 0.5 - 0.5 * math.cos(math.pi * t / attack)
            elif t > sustain_end:
                env = 0.5 + 0.5 * math.cos(
                    math.pi * (t - sustain_end) / release
                )
            else:
                env = 1.0
            s = (
                math.sin(w1 * t)
                + 0.35 * math.sin(w2 * t + 0.6)
                + 0.12 * math.sin(w3 * t + 1.3)
            )
            out[i] += 0.5 * volume * env * s
    return out


def bell(freq, dur, *, volume, attack=0.008, decay=4.0,
         partials=((1.0, 1.0, 1.0), (2.0, 0.32, 1.9), (2.99, 0.14, 2.6),
                   (0.5, 0.18, 0.8)),
         detune_cents=4.0):
    """The warm bell from generate_sounds.py, reused for sparse accents."""
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
    return [math.tanh(1.2 * v) / math.tanh(1.2) for v in out]


def air(samples, *, amount=0.05, delay_ms=23.0):
    """A single soft early reflection — a hint of room, not a reverb."""
    d = int(RATE * delay_ms / 1000)
    out = list(samples) + [0.0] * d
    for i, v in enumerate(samples):
        out[i + d] += amount * v
    return out


def room_noise(n, *, volume=0.012):
    """Heavily low-passed noise: the 'air' of the study room."""
    out = [0.0] * n
    y = 0.0
    for i in range(n):
        # One-pole low-pass on white noise, slow level drift on top.
        y = 0.992 * y + 0.008 * (random.random() * 2 - 1)
        drift = 1.0 + 0.3 * math.sin(2 * math.pi * 0.05 * i / RATE)
        out[i] = volume * drift * y * 12.0
    return out


# ----------------------------------------------------------------------
# Composition
# ----------------------------------------------------------------------

# Warm low-mid voicings; the closing G6 resolving into the opening Cmaj7
# across the loop seam is a deliberate V-I cadence.
CHORDS = [
    # Cmaj7: C3 G3 B3 E4
    (130.81, 196.00, 246.94, 329.63),
    # Am7: A2 E3 G3 C4
    (110.00, 164.81, 196.00, 261.63),
    # Fmaj7: F2 C3 A3 E4
    (87.31, 130.81, 220.00, 329.63),
    # G6: G2 D3 B3 E4
    (98.00, 146.83, 246.94, 329.63),
]
CHORD_SPACING = 13.0  # one chord every 13 s
CHORD_LENGTH = 16.0  # ...held 16 s, so neighbours overlap by 3 s

# Pentatonic accents over C: never a wrong note against any of the chords.
ACCENT_NOTES = (659.25, 783.99, 880.00, 1046.50, 1174.66)  # E5 G5 A5 C6 D6


def compose(total_seconds):
    n = int(RATE * total_seconds)
    mixbuf = [0.0] * n

    def add(offset_s, samples, gate=None):
        start = int(offset_s * RATE)
        for i, v in enumerate(samples):
            j = start + i
            if j < n:
                mixbuf[j] += v if gate is None else v * gate(j / RATE)

    # Pad bed. The render is one bar longer than the loop; chord 0 is laid
    # again at 52 s so the seam crossfade blends release into attack.
    breath = lambda t: 1.0 + 0.08 * math.sin(2 * math.pi * 0.08 * t)  # noqa: E731
    for idx in range(len(CHORDS) + 1):
        chord = CHORDS[idx % len(CHORDS)]
        offset = idx * CHORD_SPACING
        for note_i, f in enumerate(chord):
            # Roots a touch louder than the colour tones.
            vol = 0.150 if note_i == 0 else 0.105
            add(offset, pad_voice(f, CHORD_LENGTH, volume=vol), gate=breath)

    # Sparse bell accents: irregular but seeded, kept clear of the seam.
    offsets = []
    while len(offsets) < 8:
        t = random.uniform(4.0, 46.0)
        if all(abs(t - o) > 3.0 for o in offsets):
            offsets.append(t)
    for t in sorted(offsets):
        f = random.choice(ACCENT_NOTES)
        v = random.uniform(0.085, 0.125)
        add(t, air(bell(f, 2.4, volume=v, decay=2.4), amount=0.06))

    # Room air, full length.
    add(0.0, room_noise(n))

    # Gentle saturation glues the layers, then normalize with headroom so
    # the bed always sits under the UI sound effects.
    glued = [math.tanh(1.1 * v) / math.tanh(1.1) for v in mixbuf]
    peak = max(abs(v) for v in glued)
    return [v * (0.70 / peak) for v in glued]


def make_loop():
    seam_n = int(SEAM_SECONDS * RATE)
    loop_n = int(LOOP_SECONDS * RATE)
    rendered = compose(LOOP_SECONDS + SEAM_SECONDS)
    out = rendered[:loop_n]
    # Equal-power crossfade: the tail (52..55 s) fades out under the head
    # (0..3 s) fading in. out[0] then continues rendered[loop_n - 1]
    # exactly, so the wrap point is sample-continuous.
    for i in range(seam_n):
        theta = (i / seam_n) * (math.pi / 2)
        out[i] = (
            rendered[i] * math.sin(theta)
            + rendered[loop_n + i] * math.cos(theta)
        )
    return out


# ----------------------------------------------------------------------
# Self-checks + write
# ----------------------------------------------------------------------


def rms(samples):
    return math.sqrt(sum(v * v for v in samples) / len(samples))


def main():
    samples = make_loop()

    expected = int(LOOP_SECONDS * RATE)
    if len(samples) != expected:
        sys.exit(f"FAIL: length {len(samples)} != {expected}")

    # Seam check: the wrap step (last -> first sample) must be no larger
    # than steps that already occur inside the body.
    body_step = max(
        abs(samples[i] - samples[i - 1]) for i in range(1, len(samples))
    )
    wrap_step = abs(samples[0] - samples[-1])
    if wrap_step > 2 * body_step:
        sys.exit(f"FAIL: seam step {wrap_step:.5f} > 2x body {body_step:.5f}")

    # Loudness continuity across the seam (last vs first 100 ms) within 3 dB.
    w = int(0.1 * RATE)
    head_rms, tail_rms = rms(samples[:w]), rms(samples[-w:])
    db = abs(20 * math.log10(head_rms / tail_rms))
    if db > 3.0:
        sys.exit(f"FAIL: seam loudness jump {db:.2f} dB > 3 dB")

    OUT.mkdir(parents=True, exist_ok=True)
    path = OUT / "music_calm.wav"
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
    print(
        f"wrote {path} ({path.stat().st_size} bytes, "
        f"{len(samples) / RATE:.1f}s, seam {wrap_step:.5f}, "
        f"loudness delta {db:.2f} dB)"
    )


if __name__ == "__main__":
    main()
