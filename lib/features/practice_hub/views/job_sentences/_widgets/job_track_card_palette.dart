import 'dart:math' as math;

import 'package:flutter/material.dart';

class JobTrackCardPalette {
  const JobTrackCardPalette({
    required this.background,
    required this.accent,
    required this.iconSurface,
    required this.border,
  });

  final Color background;
  final Color accent;
  final Color iconSurface;
  final Color border;
}

JobTrackCardPalette jobTrackCardPalette(
  String value, {
  required Color fallback,
}) {
  final Color source = _parseCardColor(value, fallback);
  final HSLColor hsl = HSLColor.fromColor(source);
  final bool isLight = source.computeLuminance() >= 0.58;

  final Color background = isLight
      ? source
      : Color.lerp(source, Colors.white, 0.68)!;
  final double accentLightness = isLight
      ? math.min(0.56, math.max(0.34, hsl.lightness - 0.28))
      : math.min(0.56, math.max(0.32, hsl.lightness));
  final Color accent = hsl
      .withSaturation(math.max(0.58, hsl.saturation))
      .withLightness(accentLightness)
      .toColor();

  return JobTrackCardPalette(
    background: background,
    accent: accent,
    iconSurface: Color.lerp(background, Colors.white, 0.34)!,
    border: accent.withValues(alpha: 0.18),
  );
}

Color _parseCardColor(String value, Color fallback) {
  String normalized = value.trim().replaceAll('#', '');
  if (normalized.length == 6) normalized = 'FF$normalized';
  final int? colorValue = int.tryParse(normalized, radix: 16);
  return colorValue == null ? fallback : Color(colorValue);
}
