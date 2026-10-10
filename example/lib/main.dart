import 'package:flutter/material.dart';
import 'package:policy_acceptance/policy_acceptance.dart';

/// Keep URLs and versions together so they don't drift.
abstract final class Policies {
  static const termsUrl = 'https://example.com/terms';
  static const termsVersion = '1.0';
  static const privacyUrl = 'https://example.com/privacy';
  static const privacyVersion = '1.0';
}

const config = PolicyConfig(
  appName: 'Example Game',
  termsAndConditions: PolicyDocument(
    title: 'Terms & Conditions',
    url: Policies.termsUrl,
    version: Policies.termsVersion,
  ),
  privacyPolicy: PolicyDocument(
    title: 'Privacy Policy',
    url: Policies.privacyUrl,
    version: Policies.privacyVersion,
  ),
);

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PolicyAcceptanceGate(
        config: config,
        // Start ads, analytics and notifications here, never before.
        onConsentReady: () => debugPrint('Consent ready'),
        child: const Scaffold(body: Center(child: Text('Home'))),
      ),
    );
  }
}
