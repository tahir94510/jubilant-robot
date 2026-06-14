import 'package:flutter/material.dart';

/// Centers content and caps its width on large screens so menus and cards
/// don't stretch edge-to-edge (and lines don't grow uncomfortably long) on
/// tablets and foldables. On phones (width below [maxWidth]) it's a no-op,
/// so the existing phone layouts are untouched.
class PageBody extends StatelessWidget {
  const PageBody({super.key, required this.child, this.maxWidth = 560});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
