import 'package:flutter/material.dart';

/// Colors used by the consent screen.
class PolicyAcceptanceTheme {
  const PolicyAcceptanceTheme({
    this.backgroundColor = const Color(0xFF111827),
    this.cardColor = const Color(0xFF1D273D),
    this.primaryColor = const Color(0xFF4285F4),
    this.accentColor = const Color(0xFFFFC857),
    this.textColor = Colors.white,
    this.secondaryTextColor = const Color(0xFFB0B8C8),
  });

  final Color backgroundColor;
  final Color cardColor;
  final Color primaryColor;
  final Color accentColor;
  final Color textColor;
  final Color secondaryTextColor;
}
