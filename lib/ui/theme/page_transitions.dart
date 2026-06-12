import 'package:flutter/material.dart';

/// A quiet fade-through for pushed routes: the incoming page fades in over
/// a slight scale-up. Understated, quick, and identical on every platform —
/// the navigation equivalent of the board's 120ms eases.
///
/// Note: this replaces Material 3's ZoomPageTransitionsBuilder, which is
/// the builder that renders Android predictive-back previews. Revisit if
/// predictive back is ever enabled in the manifest.
class FadeThroughPageTransitionsBuilder extends PageTransitionsBuilder {
  const FadeThroughPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (MediaQuery.of(context).disableAnimations) return child;
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: const Interval(0.25, 1, curve: Curves.easeOut),
      ),
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.97, end: 1).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        ),
        child: child,
      ),
    );
  }
}
