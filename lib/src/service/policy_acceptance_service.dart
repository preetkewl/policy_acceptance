import '../models/policy_acceptance_result.dart';
import '../models/policy_config.dart';
import '../storage/policy_storage.dart';
import '../storage/shared_preferences_policy_storage.dart';

/// Reads, writes and clears consent, comparing stored policy versions.
class PolicyAcceptanceService {
  PolicyAcceptanceService({
    PolicyStorage? storage,
  }) : _storage = storage ?? SharedPreferencesPolicyStorage();

  final PolicyStorage _storage;

  /// Whether complete consent exists for the current policy versions.
  Future<bool> isAccepted(PolicyConfig config) async {
    final result = await _storage.read(config.storageId);

    if (result == null || !result.isComplete) {
      return false;
    }

    return result.termsVersion == config.termsAndConditions.version &&
        result.privacyVersion == config.privacyPolicy.version;
  }

  /// Records acceptance of the current policy versions.
  Future<PolicyAcceptanceResult> accept(
    PolicyConfig config,
  ) async {
    final result = PolicyAcceptanceResult(
      termsAccepted: true,
      privacyAccepted: true,
      acceptedAt: DateTime.now(),
      termsVersion: config.termsAndConditions.version,
      privacyVersion: config.privacyPolicy.version,
    );

    await _storage.save(config.storageId, result);

    return result;
  }

  /// Removes stored consent so the user is asked again.
  Future<void> clearAcceptance(PolicyConfig config) {
    return _storage.clear(config.storageId);
  }
}
