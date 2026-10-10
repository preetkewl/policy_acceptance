import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:policy_acceptance/policy_acceptance.dart';

void main() {
  group('PolicyDocument', () {
    test('stores document details', () {
      const document = PolicyDocument(
        title: 'Privacy Policy',
        url: 'https://example.com/privacy',
        version: '1.0',
      );

      expect(document.title, 'Privacy Policy');
      expect(document.url, 'https://example.com/privacy');
      expect(document.version, '1.0');
    });
  });

  group('PolicyConfig', () {
    test('stores game configuration', () {
      const config = PolicyConfig(
        appName: 'Color Sort',
        privacyPolicy: PolicyDocument(
          title: 'Privacy Policy',
          url: 'https://example.com/privacy',
          version: '1.0',
        ),
        termsAndConditions: PolicyDocument(
          title: 'Terms & Conditions',
          url: 'https://example.com/terms',
          version: '1.0',
        ),
      );

      expect(config.appName, 'Color Sort');
      expect(config.primaryColor, const Color(0xFF4285F4));
      expect(config.accentColor, const Color(0xFFFFC857));
      expect(config.headerTitle, 'Your Privacy');
      expect(config.headerHighlight, 'Matters');
    });
  });

  group('PolicyAcceptanceResult', () {
    test('reports complete acceptance', () {
      final result = PolicyAcceptanceResult(
        termsAccepted: true,
        privacyAccepted: true,
        acceptedAt: DateTime(2026, 10, 10),
        termsVersion: '1.0',
        privacyVersion: '1.0',
      );

      expect(result.isComplete, isTrue);
    });

    test('reports incomplete acceptance', () {
      final result = PolicyAcceptanceResult(
        termsAccepted: true,
        privacyAccepted: false,
        acceptedAt: DateTime(2026, 10, 10),
        termsVersion: '1.0',
        privacyVersion: '1.0',
      );

      expect(result.isComplete, isFalse);
    });
  });
}
