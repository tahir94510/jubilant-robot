import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/palette.dart';

/// A one-shot, dependency-free confetti celebration in brand colors.
///
/// Three launch sources fire at once — a top-center fountain plus two bottom
/// "cannons" angled up and inward — so the burst fills the frame instead of
/// raining from a single point. Each piece arcs under gravity, flutters with a
/// gentle horizontal sway, spins, twinkles, and fades over the last stretch.
///
/// The animation runs exactly once and never loops (looping overlays would hang
/// every `pumpAndSettle`), and reduced-motion users (`MediaQuery.disableAnimations`)
/// get nothing drawn at all. Motion is a pure function of time, so the painter
/// keeps no per-frame state.
class ConfettiBurst extends StatefulWidget {
  const ConfettiBurst({
    super.key,
    this.particleCount = 120,
    this.duration = const Duration(milliseconds: 2400),
    this.seed = 7,
  });

  final int particleCount;
  final Duration duration;
  final int seed;

  @override
  State<ConfettiBurst> createState() => _ConfettiBurstState();
}

class _ConfettiBurstState extends State<ConfettiBurst>
    with SingleTickerProviderStateMixin {
  // Created eagerly: a lazy `late` controller that is first touched in
  // dispose() would do its TickerMode ancestor lookup mid-unmount.
  late final AnimationController _controller;
  List<_Particle> _particles = const [];
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    if (MediaQuery.of(context).disableAnimations) return;

    final palette = Theme.of(context).extension<GamePalette>()!;
    final scheme = Theme.of(context).colorScheme;
    final colors = [
      palette.success,
      palette.streakFlame,
      palette.revealed,
      scheme.primary,
      scheme.tertiary,
      // A theme- and colorblind-aware accent for hue variety, instead of a
      // hardcoded gold that ignored the theme and clashed after the rebrand.
      palette.confirmed,
    ];
    final rng = math.Random(widget.seed);
    _particles = List.generate(
      widget.particleCount,
      (i) =>
          _Particle.scatter(rng, colors[i % colors.length], _pickOrigin(rng)),
    );
    _controller.forward();
  }

  // Most pieces fountain from the top; the rest split between the two bottom
  // cannons so the burst reads as coming from everywhere at once.
  _Origin _pickOrigin(math.Random rng) {
    final r = rng.nextDouble();
    if (r < 0.56) return _Origin.fountain;
    return r < 0.78 ? _Origin.leftCannon : _Origin.rightCannon;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) {
      return const SizedBox.shrink();
    }
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _ConfettiPainter(
            particles: _particles,
            animation: _controller,
            seconds: widget.duration.inMilliseconds / 1000,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

enum _Origin { fountain, leftCannon, rightCannon }

enum _Shape { square, circle, ribbon }

/// One piece of confetti. Motion is a pure function of time, so the painter
/// keeps no per-frame state.
class _Particle {
  _Particle._({
    required this.color,
    required this.x0,
    required this.y0,
    required this.vx,
    required this.vy,
    required this.drag,
    required this.size,
    required this.spin,
    required this.rotation,
    required this.shape,
    required this.swayAmp,
    required this.swayFreq,
    required this.swayPhase,
    required this.twinkleFreq,
  });

  factory _Particle.scatter(math.Random rng, Color color, _Origin origin) {
    final double x0, y0, vx, vy;
    switch (origin) {
      case _Origin.fountain:
        // A spread fan from just under the top edge, arcing up then raining.
        x0 = 0.5 + (rng.nextDouble() - 0.5) * 0.24;
        y0 = 0.05 + rng.nextDouble() * 0.06;
        vx = (rng.nextDouble() - 0.5) * 2 * 0.9;
        vy = -(0.2 + rng.nextDouble() * 0.85);
      case _Origin.leftCannon:
        // Fired from the bottom-left corner, up and to the right.
        x0 = -0.02 + rng.nextDouble() * 0.05;
        y0 = 0.98 - rng.nextDouble() * 0.05;
        vx = 0.5 + rng.nextDouble() * 0.85;
        vy = -(1.5 + rng.nextDouble() * 0.95);
      case _Origin.rightCannon:
        x0 = 1.02 - rng.nextDouble() * 0.05;
        y0 = 0.98 - rng.nextDouble() * 0.05;
        vx = -(0.5 + rng.nextDouble() * 0.85);
        vy = -(1.5 + rng.nextDouble() * 0.95);
    }
    return _Particle._(
      color: color,
      x0: x0,
      y0: y0,
      vx: vx,
      vy: vy,
      drag: 1.2 + rng.nextDouble() * 1.4,
      size: 5 + rng.nextDouble() * 6,
      spin: (rng.nextDouble() - 0.5) * 14,
      rotation: rng.nextDouble() * math.pi,
      shape: _Shape.values[rng.nextInt(_Shape.values.length)],
      swayAmp: 0.01 + rng.nextDouble() * 0.03,
      swayFreq: 3 + rng.nextDouble() * 4,
      swayPhase: rng.nextDouble() * math.pi * 2,
      twinkleFreq: 6 + rng.nextDouble() * 8,
    );
  }

  final Color color;
  final double x0, y0; // start, as fractions of the canvas
  final double vx, vy; // initial velocity, fractions/second
  final double drag;
  final double size; // logical pixels
  final double spin; // radians/second
  final double rotation;
  final _Shape shape;
  final double swayAmp; // horizontal flutter amplitude (fractions)
  final double swayFreq; // flutter speed (radians/second)
  final double swayPhase;
  final double twinkleFreq;

  static const double _gravity = 1.9; // fractions/second^2

  double x(double t) =>
      x0 +
      vx * (1 - math.exp(-drag * t)) / drag +
      // Flutter ramps in from zero so pieces don't jitter at the launch point.
      swayAmp * math.sin(swayFreq * t + swayPhase) * (1 - math.exp(-0.6 * t));

  double y(double t) =>
      y0 + vy * (1 - math.exp(-drag * t)) / drag + 0.5 * _gravity * t * t;

  // A subtle shimmer layered on the global fade so the field sparkles.
  double twinkle(double t) => 0.8 + 0.2 * math.sin(twinkleFreq * t + swayPhase);
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({
    required this.particles,
    required this.animation,
    required this.seconds,
  }) : super(repaint: animation);

  final List<_Particle> particles;
  final Animation<double> animation;
  final double seconds;

  @override
  void paint(Canvas canvas, Size size) {
    final progress = animation.value;
    final t = progress * seconds;
    // Hold full strength for 70% of the flight, then fade out.
    final opacity = progress < 0.7
        ? 1.0
        : (1 - (progress - 0.7) / 0.3).clamp(0.0, 1.0);
    if (opacity == 0) return;

    final paint = Paint();
    for (final p in particles) {
      final px = p.x(t) * size.width;
      final py = p.y(t) * size.height;
      if (py > size.height + p.size) continue;
      paint.color = p.color.withValues(
        alpha: (opacity * p.twinkle(t)).clamp(0.0, 1.0),
      );
      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(p.rotation + p.spin * t);
      switch (p.shape) {
        case _Shape.ribbon:
          // A tall thin streamer that tumbles as it spins.
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                center: Offset.zero,
                width: p.size * 0.34,
                height: p.size * 1.25,
              ),
              const Radius.circular(1.5),
            ),
            paint,
          );
        case _Shape.square:
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                center: Offset.zero,
                width: p.size,
                height: p.size * 0.55,
              ),
              const Radius.circular(1.5),
            ),
            paint,
          );
        case _Shape.circle:
          canvas.drawCircle(Offset.zero, p.size * 0.34, paint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) =>
      particles != oldDelegate.particles;
}
