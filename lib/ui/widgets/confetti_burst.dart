import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/palette.dart';

/// A one-shot, dependency-free confetti burst in brand colors.
///
/// Pieces fan out from the top center, arc under gravity, and fade over the
/// last stretch. The animation runs exactly once and never loops (looping
/// overlays would hang every `pumpAndSettle`), and reduced-motion users
/// (`MediaQuery.disableAnimations`) get nothing drawn at all.
class ConfettiBurst extends StatefulWidget {
  const ConfettiBurst({
    super.key,
    this.particleCount = 110,
    this.duration = const Duration(milliseconds: 2200),
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
      const Color(0xFFEE6C4D), // brand coral
    ];
    final rng = math.Random(widget.seed);
    _particles = List.generate(
      widget.particleCount,
      (i) => _Particle.scatter(rng, colors[i % colors.length]),
    );
    _controller.forward();
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

/// One piece of confetti. Motion is a pure function of time, so the painter
/// keeps no per-frame state.
class _Particle {
  _Particle.scatter(math.Random rng, this.color)
    : x0 = 0.5 + (rng.nextDouble() - 0.5) * 0.22,
      y0 = 0.06 + rng.nextDouble() * 0.06,
      vx = _spread(rng, 0.85),
      vy = -(0.25 + rng.nextDouble() * 0.85),
      drag = 1.2 + rng.nextDouble() * 1.4,
      size = 5 + rng.nextDouble() * 6,
      spin = (rng.nextDouble() - 0.5) * 14,
      rotation = rng.nextDouble() * math.pi,
      isRect = rng.nextBool();

  static double _spread(math.Random rng, double max) =>
      (rng.nextDouble() - 0.5) * 2 * max;

  final Color color;
  final double x0, y0; // start, as fractions of the canvas
  final double vx, vy; // initial velocity, fractions/second
  final double drag;
  final double size; // logical pixels
  final double spin; // radians/second
  final double rotation;
  final bool isRect;

  static const double _gravity = 1.9; // fractions/second^2

  double x(double t) => x0 + vx * (1 - math.exp(-drag * t)) / drag;

  double y(double t) =>
      y0 + vy * (1 - math.exp(-drag * t)) / drag + 0.5 * _gravity * t * t;
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
      paint.color = p.color.withValues(alpha: opacity);
      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(p.rotation + p.spin * t);
      if (p.isRect) {
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
      } else {
        canvas.drawCircle(Offset.zero, p.size * 0.34, paint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) =>
      particles != oldDelegate.particles;
}
