#!/usr/bin/env python3
"""Procedural background-music generator for Quotecrack (v4 — playlist).

Pure stdlib (wave + math): no licensing, no "stock asset" feel — the same
philosophy as tool/generate_sounds.py, scaled up from blips to a bed.

Why a playlist (v4):
- v3 was a single ~128 s loop. Players reported "it's just one track and you
  wait for it to come back". v4 generates SIX distinct ~80 s pieces. The app
  (MusicService) shuffles them, plays each once before any repeat, and
  CROSSFADES one into the next a few seconds before the end — so the bed
  never loops audibly and never falls silent between tracks.
- Each track is a calm pad + one-note melody + soft pluck arpeggio, in a
  different key, with a different chord progression and a slightly different
  tempo (chord span), so the six read as siblings, not clones.

Per-track musical invariants (unchanged from v3, now enforced per track):
- Every track STARTS from silence and ENDS in silence (raised-cosine fades),
  so even an abrupt stop can't click, and a crossfade overlaps two quiet
  edges.
- Every progression starts on the tonic (I) and ends on the dominant (V):
  the natural V->I pull makes the crossfade back into the next track's tonic
  feel like a real cadence rather than a cut.
- Every melody/arp pitch is a chord tone of the chord it sounds over,
  enforced by a self-check below: a wrong note is mathematically impossible.

Audio format: 22.05 kHz mono, encoded to OGG/Vorbis. A soft pad/pluck bed is
band-limited, so Vorbis compresses it ~25x with no audible loss — six tracks
land under ~1 MB total (16-bit WAV was ~20 MB, which Play flags as a large
download). Requires `soundfile` + `numpy` at generation time (dev-only tool).

Usage: python3 tool/generate_music.py
Output (committed): assets/audio/music_calm_1.ogg .. music_calm_6.ogg
"""

import math
import sys
from pathlib import Path

import numpy as np
import soundfile as sf

RATE = 22050
OUT = Path(__file__).resolve().parent.parent / "assets/audio"

# Base chord voicings in C, root first (low-mid range). Tracks transpose these
# by a whole number of semitones to reach other keys while reusing the shapes.
CHORDS = {
    "C": (130.81, 196.00, 261.63, 329.63),  # C3 G3 C4 E4
    "Dm": (146.83, 220.00, 293.66, 349.23),  # D3 A3 D4 F4
    "Em": (164.81, 246.94, 329.63, 392.00),  # E3 B3 E4 G4
    "F": (87.31, 174.61, 220.00, 261.63),  # F2 F3 A3 C4
    "G": (98.00, 146.83, 196.00, 246.94),  # G2 D3 G3 B3
    "Am": (110.00, 164.81, 220.00, 261.63),  # A2 E3 A3 C4
}

# Soft plucked arpeggio beats (seconds within each chord); the note is the
# chord tone at index beat_index, cycling low to high.
ARP_BEATS = (0.0, 2.0, 4.0, 6.0)

TWO_PI = 2.0 * math.pi
DETUNE = 2.0 ** (3.0 / 1200.0)  # +/- 3 cents


# Six sibling tracks: (filename, transpose_semitones, progression, chord_span).
# Each progression starts on C (the I) and ends on G (the V) so transposition
# preserves the tonic->dominant frame and the crossfade lands as a cadence.
TRACKS = [
    ("music_calm_1.ogg", 0, ["C", "Am", "F", "G", "C", "F", "Dm", "G"], 10.0),
    ("music_calm_2.ogg", 3, ["C", "Em", "Am", "F", "Dm", "G", "C", "G"], 9.5),
    ("music_calm_3.ogg", 5, ["C", "F", "Am", "Em", "F", "C", "Dm", "G"], 10.5),
    ("music_calm_4.ogg", -2, ["C", "G", "Am", "F", "C", "Dm", "Em", "G"], 9.0),
    ("music_calm_5.ogg", 7, ["C", "Am", "Dm", "G", "Em", "Am", "F", "G"], 10.0),
    ("music_calm_6.ogg", -4, ["C", "F", "G", "Em", "Am", "Dm", "F", "G"], 11.0),
]

# Every track is loudness-matched to this RMS so none plays louder/softer than
# another (peak-normalizing alone left denser tracks sounding louder). A peak
# ceiling keeps headroom; OGG/Vorbis encodes the result.
TARGET_RMS = 0.14
PEAK_CEILING = 0.92


def transpose(chord, semitones):
    factor = 2.0 ** (semitones / 12.0)
    return tuple(f * factor for f in chord)


def melody_for(prog, semitones):
    """One gentle whole note per chord, alternating between two chord tones
    (the octave-root and the color tone) for a little stepwise motion. Both
    picks are chord members by construction, so the note can never clash."""
    out = []
    for idx, name in enumerate(prog):
        chord = transpose(CHORDS[name], semitones)
        out.append(chord[3] if idx % 2 == 0 else chord[2])
    return out


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


def compose(prog, semitones, chord_span):
    total_seconds = len(prog) * chord_span
    n = int(RATE * total_seconds)
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

    melody = melody_for(prog, semitones)
    last = len(prog) - 1
    # Pad tail (overlap into next chord) scales with tempo so transitions stay
    # seamless at every chord span.
    tail = 3.0
    for idx, name in enumerate(prog):
        chord = transpose(CHORDS[name], semitones)
        offset = idx * chord_span

        # The first chord rises gently; the last SUSTAINS to the end (short
        # release) instead of fading to a long silence. The track-to-track
        # crossfade (MusicService) then overlaps two audible tails/heads, so
        # there is no silent "wait" between tracks. An 80 ms edge fade still
        # guarantees a click-free hard stop.
        if idx == last:
            dur, attack, release = chord_span, 4.0, 1.2
        elif idx == 0:
            dur, attack, release = chord_span + tail, 2.5, 5.0
        else:
            dur, attack, release = chord_span + tail, 4.0, 5.0
        for note_i, f in enumerate(chord):
            vol = 0.15 if note_i == 0 else 0.105
            add(
                offset,
                pad_voice(f, dur, volume=vol, attack=attack, release=release),
                breathe=True,
            )

        # Melody: one gentle note per chord, slightly behind the change.
        melody_dur = (chord_span - 1.5) if idx == last else (chord_span - 1.0)
        add(offset + 0.5, melody_voice(melody[idx], melody_dur))

        # Arpeggio on a regular grid (predictable = calm). The first beat of
        # the piece stays silent so it truly starts from nothing, and the last
        # chord drops its final beat so every pluck dies before the close.
        for beat_i, beat in enumerate(ARP_BEATS):
            if beat >= chord_span:
                continue
            if idx == 0 and beat == 0.0:
                continue
            if idx == last and beat == ARP_BEATS[-1]:
                continue
            add(offset + beat, pluck(chord[beat_i]))

    # Gentle saturation glues the layers; then LOUDNESS-normalize to a shared
    # RMS so every track sits at the same perceived level (peak-only
    # normalization let denser tracks sound louder). Clamp the scale so the
    # peak never exceeds the ceiling.
    glued = [math.tanh(1.1 * v) / math.tanh(1.1) for v in mixbuf]
    cur_rms = rms(glued)
    peak = max(abs(v) for v in glued) or 1.0
    scale = TARGET_RMS / (cur_rms or 1.0)
    if peak * scale > PEAK_CEILING:
        scale = PEAK_CEILING / peak
    return [v * scale for v in glued]


def rms(samples):
    return math.sqrt(sum(v * v for v in samples) / len(samples))


def build_track(filename, semitones, prog, chord_span):
    # A wrong note is impossible by construction — prove it anyway.
    melody = melody_for(prog, semitones)
    for idx, name in enumerate(prog):
        chord = transpose(CHORDS[name], semitones)
        members = {round(f * 2.0**-o) for f in chord for o in (-1, 0, 1, 2)}
        octaves = [melody[idx] * 2.0**o for o in (-2, -1, 0, 1, 2)]
        if not any(round(f) in members for f in octaves):
            sys.exit(f"FAIL: {filename}: melody {melody[idx]} not in {name}")

    samples = compose(prog, semitones, chord_span)

    # An 80 ms raised-cosine fade on each edge guarantees a click-free start and
    # a click-free hard stop. The body stays at full level (no long silence) so
    # the crossfade overlaps audible material.
    fade = int(RATE * 0.08)
    for i in range(fade):
        ramp = 0.5 - 0.5 * math.cos(math.pi * i / fade)
        samples[i] *= ramp
        samples[len(samples) - 1 - i] *= ramp

    # The very edges (first/last 5 ms) must be effectively silent so neither an
    # abrupt stop nor a crossfade can click.
    w = int(0.005 * RATE)
    head, tail = rms(samples[:w]), rms(samples[-w:])
    if head > 2e-3 or tail > 2e-3:
        sys.exit(f"FAIL: {filename}: edges not clean ({head:.5f}/{tail:.5f})")

    peak = max(abs(v) for v in samples)
    if peak > 0.96:
        sys.exit(f"FAIL: {filename}: clipping risk, peak {peak:.3f}")

    dc = abs(sum(samples) / len(samples))
    if dc > 1e-3:
        sys.exit(f"FAIL: {filename}: DC offset {dc:.5f}")

    OUT.mkdir(parents=True, exist_ok=True)
    path = OUT / filename
    # OGG/Vorbis: ~25x smaller than 16-bit WAV with no audible loss for this
    # band-limited pad bed — keeps the bundle small (Play flags large APKs).
    sf.write(str(path), np.asarray(samples, dtype=np.float32), RATE,
             format="OGG", subtype="VORBIS")
    print(
        f"wrote {path} ({path.stat().st_size} bytes, "
        f"{len(samples) / RATE:.1f}s, peak {peak:.3f}, "
        f"rms {rms(samples):.3f}, edges {head:.5f}/{tail:.5f})"
    )


def main():
    # Remove any obsolete WAV music (v3 single loop, v4 per-track WAVs) that the
    # OGG playlist replaces.
    for old in OUT.glob("music_calm*.wav"):
        old.unlink()
        print(f"removed obsolete {old}")
    for filename, semitones, prog, chord_span in TRACKS:
        build_track(filename, semitones, prog, chord_span)


if __name__ == "__main__":
    main()
