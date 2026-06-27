/// Maps a 0..1 volume-slider position to a perceptually even gain.
///
/// Human loudness perception is roughly logarithmic, so a linear slider makes
/// the lower half feel nearly as loud as the top — "50%" sounds almost full.
/// A square taper (position²) makes the on-screen percentage track how loud the
/// audio actually sounds, while keeping the endpoints exact (0 -> 0, 1 -> 1).
/// Shared by [SoundService] and [MusicService] so effects and music stay on the
/// same perceptual scale.
double audioTaper(double position) {
  final p = position.clamp(0.0, 1.0);
  return p * p;
}
