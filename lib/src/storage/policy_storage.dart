import '../models/policy_acceptance_result.dart';

/// Persistence backend for acceptance records. Implement to replace the
/// default `shared_preferences` storage (e.g. in tests).
abstract interface class PolicyStorage {
  Future<PolicyAcceptanceResult?> read(String appId);

  Future<void> save(
    String appId,
    PolicyAcceptanceResult result,
  );

  Future<void> clear(String appId);
}
