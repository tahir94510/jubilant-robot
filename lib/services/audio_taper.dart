import 'dart:math' as math;

/// Maps a 0..1 volume-slider position to a perceptually weighted gain.
///
/// Human loudness perception is roughly logarithmic, so a purely linear slider
/// makes the lower half feel nearly as loud as the top — "50%" sounds almost
/// full. The previous mapping squared the position (position²), which is
/// perceptually even but pushed the gain so low across the bottom third that
/// that part of the slider felt dead — "the percentage doesn't do anything"
/// until it is near the top.
///
/// A gentler 1.5 power keeps a natural taper (loud stays loud, quiet stays
/// quiet, and the on-screen % still tracks perceived loudness reasonably well)
/// while leaving the lower half audibly responsive instead of near-mute. The
/// endpoints stay exact (0 -> 0, 1 -> 1). Shared by [SoundService] and
/// [MusicService] so effects and music stay on the same perceptual scale.
double audioTaper(double position) {
  final p = position.clamp(0.0, 1.0);
  return math.pow(p, 1.5).toDouble();
}
