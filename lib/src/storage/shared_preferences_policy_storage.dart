import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/policy_acceptance_result.dart';
import 'policy_storage.dart';

class SharedPreferencesPolicyStorage implements PolicyStorage {
  static const _prefix = 'policy_acceptance.';

  String _key(String appId) => '$_prefix$appId';

  @override
  Future<PolicyAcceptanceResult?> read(String appId) async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key(appId));

    if (json == null) return null;

    try {
      final map = jsonDecode(json) as Map<String, dynamic>;

      return PolicyAcceptanceResult(
        termsAccepted: map['termsAccepted'] as bool,
        privacyAccepted: map['privacyAccepted'] as bool,
        acceptedAt: DateTime.parse(map['acceptedAt'] as String),
        termsVersion: map['termsVersion'] as String,
        privacyVersion: map['privacyVersion'] as String,
      );
    } catch (_) {
      // Invalid or outdated records should not count as consent.
      await prefs.remove(_key(appId));
      return null;
    }
  }

  @override
  Future<void> save(
    String appId,
    PolicyAcceptanceResult result,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _key(appId),
      jsonEncode({
        'termsAccepted': result.termsAccepted,
        'privacyAccepted': result.privacyAccepted,
        'acceptedAt': result.acceptedAt.toIso8601String(),
        'termsVersion': result.termsVersion,
        'privacyVersion': result.privacyVersion,
      }),
    );
  }

  @override
  Future<void> clear(String appId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key(appId));
  }
}
