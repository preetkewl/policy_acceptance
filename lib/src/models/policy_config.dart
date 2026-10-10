import 'package:flutter/material.dart';

import 'policy_document.dart';
import 'policy_strings.dart';

/// Per-app configuration for the consent screen.
class PolicyConfig {
  const PolicyConfig({
    this.appId,
    required this.appName,
    required this.privacyPolicy,
    required this.termsAndConditions,
    this.primaryColor = const Color(0xFF4285F4),
    this.accentColor = const Color(0xFFFFC857),
    this.headerTitle = 'Your Privacy',
    this.headerHighlight = 'Matters',
    this.bannerImage,
    this.bannerHeight = 160,
    this.strings = const PolicyStrings(),
  });

  final String? appId;

  String get storageId => appId ?? appName;

  final String appName;

  final PolicyDocument privacyPolicy;
  final PolicyDocument termsAndConditions;

  final Color primaryColor;
  final Color accentColor;

  final String headerTitle;
  final String headerHighlight;

  /// Optional banner shown at the top (e.g. `AssetImage('assets/banner.png')`).
  /// Falls back to the shield icon when null.
  final ImageProvider? bannerImage;
  final double bannerHeight;

  final PolicyStrings strings;
}
