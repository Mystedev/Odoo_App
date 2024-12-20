import 'package:flutter/material.dart';

class FloatingActionButtonExtendedTheme extends ThemeExtension<FloatingActionButtonExtendedTheme> {
  final Color? backgroundColor;
  final Color? foregroundColor;

  const FloatingActionButtonExtendedTheme({
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  FloatingActionButtonExtendedTheme copyWith({
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    return FloatingActionButtonExtendedTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      foregroundColor: foregroundColor ?? this.foregroundColor,
    );
  }

  @override
  FloatingActionButtonExtendedTheme lerp(ThemeExtension<FloatingActionButtonExtendedTheme>? other, double t) {
    if (other is! FloatingActionButtonExtendedTheme) return this;
    return FloatingActionButtonExtendedTheme(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      foregroundColor: Color.lerp(foregroundColor, other.foregroundColor, t),
    );
  }
}
