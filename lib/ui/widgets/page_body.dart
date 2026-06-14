import 'package:flutter/material.dart';

/// Centers content and caps its width on large screens so menus and cards
/// don't stretch edge-to-edge (and lines don't grow uncomfortably long) on
/// tablets and foldables. On phones (width below [maxWidth]) it's a no-op,
/// so the existing phone layouts are untouched.
///
/// It also guards the BOTTOM system inset: with Android's edge-to-edge the
/// app draws behind the 3-button nav bar, so a bare scrollable would tuck its
/// last row under those buttons. SafeArea(bottom) keeps content clear of them
/// on every device. (Screens already wrapped in an outer SafeArea, like Home,
/// see the inset already consumed, so this never double-pads.)
class PageBody extends StatelessWidget {
  const PageBody({super.key, required this.child, this.maxWidth = 560});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      ),
    );
  }
}
