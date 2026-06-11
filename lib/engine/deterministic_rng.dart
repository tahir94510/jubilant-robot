/// Deterministic, platform-stable PRNG and hashing.
///
/// IMPORTANT: never use `Random(seed)` or `String.hashCode` in engine code.
/// Their sequences/values are not guaranteed identical between the Dart VM
/// (Android) and dart2js (web preview), but the daily puzzle must be the
/// same everywhere. Everything here is masked to 32 bits so JavaScript
/// number semantics agree with the VM. Locked by golden-vector tests.
library;

const int _mask32 = 0xFFFFFFFF;

/// xorshift32 PRNG (Marsaglia). Tiny, fast, and good enough for shuffles.
class DeterministicRng {
  DeterministicRng(int seed) : _state = _seed(seed);

  int _state;

  static int _seed(int seed) {
    final s = seed & _mask32;
    // xorshift state must never be zero.
    return s == 0 ? 0x9E3779B9 : s;
  }

  /// Next raw 32-bit value.
  int nextUint32() {
    var x = _state;
    x = (x ^ (x << 13)) & _mask32;
    x = (x ^ (x >> 17)) & _mask32;
    x = (x ^ (x << 5)) & _mask32;
    _state = x;
    return x;
  }

  /// Uniform-ish integer in [0, max). `max` must be >= 1.
  int nextInt(int max) {
    assert(max >= 1);
    return nextUint32() % max;
  }
}

/// fmix32 finalizer from MurmurHash3: turns correlated integers (dates,
/// counters) into well-distributed seeds.
int fmix32(int h) {
  var x = h & _mask32;
  x = (x ^ (x >> 16)) & _mask32;
  x = _mul32(x, 0x85EBCA6B);
  x = (x ^ (x >> 13)) & _mask32;
  x = _mul32(x, 0xC2B2AE35);
  x = (x ^ (x >> 16)) & _mask32;
  return x;
}

/// FNV-1a string hash, 32-bit. Stable across platforms, unlike
/// `String.hashCode`.
int stableStringHash(String input) {
  var hash = 0x811C9DC5;
  for (final unit in input.codeUnits) {
    hash = (hash ^ unit) & _mask32;
    hash = _mul32(hash, 0x01000193);
  }
  return hash;
}

/// 32-bit multiplication without 64-bit intermediate overflow on the web.
/// (In JS, a*b for large 32-bit values exceeds 2^53 and loses low bits, so
/// multiply in 16-bit halves.)
int _mul32(int a, int b) {
  final aHi = (a >> 16) & 0xFFFF;
  final aLo = a & 0xFFFF;
  // (aHi*2^16 + aLo) * b = aHi*b*2^16 + aLo*b ; keep only low 32 bits.
  final high = (_mulLow(aHi, b) << 16) & _mask32;
  return (high + _mulLow(aLo, b)) & _mask32;
}

/// Product of a 16-bit by 32-bit value, low 32 bits. Max intermediate is
/// 2^48, safely inside JS double precision.
int _mulLow(int a16, int b32) => (a16 * b32) & _mask32;
