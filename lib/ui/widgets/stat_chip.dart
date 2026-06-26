import 'package:flutter/material.dart';

import '../theme/palette.dart';

/// A small pill showing one solve statistic — an icon plus a short label
/// (time, hints, streak). Shared by the completion screen's stat row and the
/// read-only review panel so both read identically.
class StatChip extends StatelessWidget {
  const StatChip({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = Theme.of(context).extension<GamePalette>()!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.onSurface.withValues(alpha: .05),
        borderRadius: BorderRadius.circular(20),
      ),
      // The chip shrinks gracefully instead of overflowing when huge system
      // text meets a narrow phone (the on-device "26 px" stripe).
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: palette.textSecondary),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
