#!/usr/bin/env python3
"""Procedural background-music generator for Quotecrack (v2).

Pure stdlib (wave + math): no licensing, no "stock asset" feel — the same
philosophy as tool/generate_sounds.py, scaled up from blips to a bed.

v3 design notes (a longer, two-section bed so it doesn't feel repetitive):
- The track is a ~128 s piece in two restful sections that share one key,
  so they flow without a seam. Section A is the classic
  C - Am - F - G - C - F - Dm - G; section B answers it with
  F - C - Dm - Am - F - G - Am - G before the V (G) pulls back into A's
  opening C. Three predictable layers throughout: warm pads, one gentle
  melody note per chord, and a soft plucked arpeggio on a regular grid.
  Predictability reads as calm; the second section gives the ear
  somewhere new to go so a long session never feels looped.
- The piece STARTS from silence (first chord fades in) and RESOLVES to
  silence (every envelope is closed by ~127.3 s). The loop wrap therefore
  falls inside a natural breath: Android MediaPlayer's looping is not
  gapless, and this composition makes that gap musically invisible —
  no seam crossfade math, no mid-blend start, no wrap click by design.
- 22.05 kHz mono 16-bit: a soft pad/pluck bed has no energy near the old
  22 kHz ceiling, so half the sample rate is inaudible here and keeps the
  file small (~5.6 MB) AND lighter to decode, which removes the buffer
  underrun crackle some low-end phones hit on a big 44.1 kHz asset.
- Every melody/arp pitch is a chord tone of the chord it sounds over,
  enforced by a self-check: a wrong note is mathematically impossible.

Usage: python3 tool/generate_music.py
Output (committed): assets/audio/music_calm.wav
"""

import math
import struct
import sys
import wave
from pathlib import Path

RATE = 22050
TOTAL_SECONDS = 128.0
CHORD_SPAN = 8.0
OUT = Path(__file__).resolve().parent.parent / "assets/audio"

# Low-mid voicings, root first. The closing G pulling back to the opening
# C is a plain V-I cadence across the loop's breath.
CHORDS = {
    "C": (130.81, 196.00, 261.63, 329.63),  # C3 G3 C4 E4
    "Am": (110.00, 164.81, 220.00, 261.63),  # A2 E3 A3 C4
    "F": (87.31, 174.61, 220.00, 261.63),  # F2 F3 A3 C4
    "G": (98.00, 146.83, 196.00, 246.94),  # G2 D3 G3 B3
    "Dm": (146.83, 220.00, 293.66, 349.23),  # D3 A3 D4 F4
}
# Section A, then section B (a gentle answer in the same key). Concatenated,
# they make one ~128 s piece; B's closing G is the V that resolves into A's
# opening C, so the wrap is a real cadence, not a cut.
PROGRESSION_A = ["C", "Am", "F", "G", "C", "F", "Dm", "G"]
PROGRESSION_B = ["F", "C", "Dm", "Am", "F", "G", "Am", "G"]
PROGRESSION = PROGRESSION_A + PROGRESSION_B

# One whole note per chord, stepwise where possible, always a chord tone.
MELODY_A = (329.63, 261.63, 261.63, 246.94, 261.63, 220.00, 349.23, 246.94)
#            E4      C4      C4      B3      C4      A3      F4      B3
MELODY_B = (220.00, 261.63, 293.66, 261.63, 220.00, 246.94, 220.00, 246.94)
#            A3      C4      D4      C4      A3      B3      A3      B3
MELODY = MELODY_A + MELODY_B

# Soft plucked arpeggio beats (seconds within each 8 s chord); the note is
# the chord tone at index beat/2, cycling low to high.
ARP_BEATS = (0.0, 2.0, 4.0, 6.0)

TWO_PI = 2.0 * math.pi
DETUNE = 2.0 ** (3.0 / 1200.0)  # +/- 3 cents


def _tone(freq, n, env):
    """sine + quiet 2nd partial, as a +/-3 cent detuned pair."""
    sin = math.sin
    out = [0.0] * n
    for f in (freq / DETUNE, freq * DETUNE):
        w1 = TWO_PI * f
        w2 = TWO_PI * 2.0 * f
        for i in range(n):
            t = i / RATE
            out[i] += 0.5 * env(t) * (sin(w1 * t) + 0.3 * sin(w2 * t + 0.5))
    return out


def pad_voice(freq, dur, *, volume, attack=4.0, release=5.0):
    """One slow pad note: cosine attack, sustain, cosine release."""
    n = int(RATE * dur)
    sustain_end = dur - release

    def env(t):
        if t < attack:
            return volume * (0.5 - 0.5 * math.cos(math.pi * t / attack))
        if t > sustain_end:
            return volume * (
                0.5 + 0.5 * math.cos(math.pi * (t - sustain_end) / release)
            )
        return volume

    return _tone(freq, n, env)


def melody_voice(freq, dur, *, volume=0.10, attack=1.5, release=2.5):
    return pad_voice(freq, dur, volume=volume, attack=attack, release=release)


def pluck(freq, *, volume=0.12, attack=0.009, decay=2.2, dur=2.0):
    """A soft pluck: fast attack, exponential decay, 50 ms end taper so the
    cut at `dur` can never click."""
    n = int(RATE * dur)

    def env(t):
        taper = min(1.0, (dur - t) / 0.05)
        return volume * min(1.0, t / attack) * math.exp(-decay * t) * taper

    return _tone(freq, n, env)


def compose():
    n = int(RATE * TOTAL_SECONDS)
    mixbuf = [0.0] * n

    def add(offset_s, samples, breathe=False):
        start = int(offset_s * RATE)
        if breathe:
            # A slow amplitude LFO so the pad bed feels alive, not static.
            for i, v in enumerate(samples):
                j = start + i
                if j < n:
                    t = j / RATE
                    mixbuf[j] += v * (1.0 + 0.08 * math.sin(TWO_PI * 0.08 * t))
        else:
            for i, v in enumerate(samples):
                j = start + i
                if j < n:
                    mixbuf[j] += v

    last = len(PROGRESSION) - 1
    for idx, name in enumerate(PROGRESSION):
        chord = CHORDS[name]
        offset = idx * CHORD_SPAN

        # Pads: 3 s tail into the next chord keeps transitions seamless;
        # the first chord rises out of silence, the last one closes fully
        # at ~127.3 s so the loop wraps inside a quiet breath.
        if idx == last:
            dur, attack, release = 7.3, 4.0, 3.3
        elif idx == 0:
            dur, attack, release = 11.0, 2.5, 5.0
        else:
            dur, attack, release = 11.0, 4.0, 5.0
        for note_i, f in enumerate(chord):
            vol = 0.15 if note_i == 0 else 0.105
            add(
                offset,
                pad_voice(f, dur, volume=vol, attack=attack, release=release),
                breathe=True,
            )

        # Melody: one gentle note per chord, slightly behind the change.
        melody_dur = 6.5 if idx == last else 7.0
        add(offset + 0.5, melody_voice(MELODY[idx], melody_dur))

        # Arpeggio on a regular grid (predictable = calm). The very first
        # beat stays silent so the piece truly starts from nothing, and the
        # final chord drops its last beat so every pluck dies before the
        # ~127.3 s close.
        for beat_i, beat in enumerate(ARP_BEATS):
            if idx == 0 and beat == 0.0:
                continue
            if idx == last and beat == 6.0:
                continue
            add(offset + beat, pluck(chord[beat_i]))

    # Gentle saturation glues the layers; normalize LAST so the final peak
    # is exact and always leaves headroom under the UI sound effects.
    glued = [math.tanh(1.1 * v) / math.tanh(1.1) for v in mixbuf]
    peak = max(abs(v) for v in glued)
    return [v * (0.55 / peak) for v in glued]


def rms(samples):
    return math.sqrt(sum(v * v for v in samples) / len(samples))


def main():
    # A wrong note is impossible by construction — prove it anyway.
    for idx, name in enumerate(PROGRESSION):
        members = {round(f * 2.0 ** (-o)) for f in CHORDS[name] for o in (-1, 0, 1, 2)}
        octaves = [MELODY[idx] * 2.0**o for o in (-2, -1, 0, 1, 2)]
        if not any(round(f) in members for f in octaves):
            sys.exit(f"FAIL: melody note {MELODY[idx]} is not in chord {name}")

    samples = compose()

    expected = int(TOTAL_SECONDS * RATE)
    if len(samples) != expected:
        sys.exit(f"FAIL: length {len(samples)} != {expected}")

    # Explicit raised-cosine fades guarantee the loop wraps through true
    # silence: even though the composition already starts/ends quiet, this
    # makes the seam mathematically click-free under MediaPlayer's
    # non-gapless looping.
    fade = int(RATE * 0.08)
    for i in range(fade):
        ramp = 0.5 - 0.5 * math.cos(math.pi * i / fade)
        samples[i] *= ramp
        samples[len(samples) - 1 - i] *= ramp

    w = int(0.05 * RATE)
    head, tail = rms(samples[:w]), rms(samples[-w:])
    if head > 5e-4 or tail > 5e-4:
        sys.exit(f"FAIL: not silence-bracketed (head {head:.5f}, tail {tail:.5f})")

    peak = max(abs(v) for v in samples)
    if peak > 0.56:
        sys.exit(f"FAIL: clipping risk, peak {peak:.3f}")

    dc = abs(sum(samples) / len(samples))
    if dc > 1e-3:
        sys.exit(f"FAIL: DC offset {dc:.5f}")

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
        f"{len(samples) / RATE:.1f}s, peak {peak:.3f}, "
        f"head/tail RMS {head:.5f}/{tail:.5f}, DC {dc:.6f})"
    )


if __name__ == "__main__":
    main()
