import 'package:flutter_test/flutter_test.dart';
import 'package:policy_acceptance/policy_acceptance.dart';

class InMemoryPolicyStorage implements PolicyStorage {
  final Map<String, PolicyAcceptanceResult> records = {};

  @override
  Future<PolicyAcceptanceResult?> read(String appId) async {
    return records[appId];
  }

  @override
  Future<void> save(
    String appId,
    PolicyAcceptanceResult result,
  ) async {
    records[appId] = result;
  }

  @override
  Future<void> clear(String appId) async {
    records.remove(appId);
  }
}

PolicyConfig createConfig({
  String appId = 'color_sort',
  String termsVersion = '1.0',
  String privacyVersion = '1.0',
}) {
  return PolicyConfig(
    appId: appId,
    appName: 'Color Sort',
    termsAndConditions: PolicyDocument(
      title: 'Terms & Conditions',
      url: 'https://example.com/terms',
      version: termsVersion,
    ),
    privacyPolicy: PolicyDocument(
      title: 'Privacy Policy',
      url: 'https://example.com/privacy',
      version: privacyVersion,
    ),
  );
}

void main() {
  late InMemoryPolicyStorage storage;
  late PolicyAcceptanceService service;

  setUp(() {
    storage = InMemoryPolicyStorage();
    service = PolicyAcceptanceService(storage: storage);
  });

  test('requires consent when no record exists', () async {
    expect(await service.isAccepted(createConfig()), isFalse);
  });

  test('accepts current policy versions', () async {
    final config = createConfig();

    await service.accept(config);

    expect(await service.isAccepted(config), isTrue);
  });

  test('requires consent after a policy version changes', () async {
    await service.accept(createConfig());

    final updatedConfig = createConfig(
      privacyVersion: '2.0',
    );

    expect(await service.isAccepted(updatedConfig), isFalse);
  });

  test('keeps consent separate for different games', () async {
    await service.accept(createConfig(appId: 'color_sort'));

    expect(
      await service.isAccepted(createConfig(appId: 'color_sort')),
      isTrue,
    );

    expect(
      await service.isAccepted(createConfig(appId: 'quoridor')),
      isFalse,
    );
  });

  test('clears acceptance', () async {
    final config = createConfig();

    await service.accept(config);
    await service.clearAcceptance(config);

    expect(await service.isAccepted(config), isFalse);
  });
}
