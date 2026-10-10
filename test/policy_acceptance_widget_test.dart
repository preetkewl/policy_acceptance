import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:policy_acceptance/policy_acceptance.dart';

class _MemoryStorage implements PolicyStorage {
  final records = <String, PolicyAcceptanceResult>{};

  @override
  Future<PolicyAcceptanceResult?> read(String appId) async => records[appId];

  @override
  Future<void> save(String appId, PolicyAcceptanceResult result) async =>
      records[appId] = result;

  @override
  Future<void> clear(String appId) async => records.remove(appId);
}

class _ThrowingStorage extends _MemoryStorage {
  @override
  Future<PolicyAcceptanceResult?> read(String appId) => throw Exception('boom');
}

PolicyConfig _config({String version = '1', ImageProvider? banner}) {
  return PolicyConfig(
    appName: 'Test Game',
    bannerImage: banner,
    termsAndConditions: PolicyDocument(
      title: 'Terms',
      url: 'https://example.com/terms',
      version: version,
    ),
    privacyPolicy: PolicyDocument(
      title: 'Privacy',
      url: 'https://example.com/privacy',
      version: version,
    ),
  );
}

Widget _app(
  PolicyConfig config,
  PolicyStorage storage, {
  VoidCallback? onAccepted,
  VoidCallback? onConsentReady,
}) {
  return MaterialApp(
    home: PolicyAcceptanceGate(
      config: config,
      service: PolicyAcceptanceService(storage: storage),
      onAccepted: onAccepted,
      onConsentReady: onConsentReady,
      child: const Scaffold(body: Text('HOME')),
    ),
  );
}

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  // Tall viewport so the whole consent screen is visible without scrolling.
  Future<void> tall(WidgetTester tester) async {
    tester.view.physicalSize = const Size(900, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  testWidgets('shows consent screen and blocks continue until ticked',
      (tester) async {
    await tall(tester);
    await tester.pumpWidget(_app(_config(), _MemoryStorage()));
    await tester.pumpAndSettle();

    expect(find.text('HOME'), findsNothing);
    expect(find.byType(Checkbox), findsOneWidget);

    final button = find.byType(FilledButton);
    expect(tester.widget<FilledButton>(button).onPressed, isNull);

    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    expect(tester.widget<FilledButton>(button).onPressed, isNotNull);
  });

  testWidgets('accepting stores consent, shows child, fires both callbacks',
      (tester) async {
    await tall(tester);
    final storage = _MemoryStorage();
    var accepted = 0;
    var ready = 0;

    await tester.pumpWidget(_app(
      _config(),
      storage,
      onAccepted: () => accepted++,
      onConsentReady: () => ready++,
    ));
    await tester.pumpAndSettle();

    expect(ready, 0);

    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(find.text('HOME'), findsOneWidget);
    expect(storage.records['Test Game']?.isComplete, isTrue);
    expect(accepted, 1);
    expect(ready, 1);
  });

  testWidgets('stored consent skips screen; onConsentReady only',
      (tester) async {
    await tall(tester);
    final storage = _MemoryStorage();
    final config = _config();
    await PolicyAcceptanceService(storage: storage).accept(config);
    var accepted = 0;
    var ready = 0;

    await tester.pumpWidget(_app(
      config,
      storage,
      onAccepted: () => accepted++,
      onConsentReady: () => ready++,
    ));
    await tester.pumpAndSettle();

    expect(find.text('HOME'), findsOneWidget);
    expect(find.byType(Checkbox), findsNothing);
    expect(accepted, 0);
    expect(ready, 1);
  });

  testWidgets('version bump re-prompts and withholds onConsentReady',
      (tester) async {
    await tall(tester);
    final storage = _MemoryStorage();
    await PolicyAcceptanceService(storage: storage).accept(_config());
    var ready = 0;

    await tester.pumpWidget(
      _app(_config(version: '2'), storage, onConsentReady: () => ready++),
    );
    await tester.pumpAndSettle();

    expect(find.text('HOME'), findsNothing);
    expect(find.byType(Checkbox), findsOneWidget);
    expect(ready, 0);
  });

  testWidgets('storage failure fails closed', (tester) async {
    await tall(tester);
    var ready = 0;
    await tester.pumpWidget(
      _app(_config(), _ThrowingStorage(), onConsentReady: () => ready++),
    );
    await tester.pumpAndSettle();

    expect(find.text('HOME'), findsNothing);
    expect(find.byType(Checkbox), findsOneWidget);
    expect(ready, 0);
  });

  testWidgets('broken banner falls back to the shield icon', (tester) async {
    await tall(tester);
    await tester.pumpWidget(_app(
      _config(banner: MemoryImage(Uint8List.fromList([1, 2, 3]))),
      _MemoryStorage(),
    ));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.shield_rounded), findsWidgets);
  });

  testWidgets('ensurePolicyAcceptance returns true when already accepted',
      (tester) async {
    await tall(tester);
    final storage = _MemoryStorage();
    final config = _config();
    final service = PolicyAcceptanceService(storage: storage);
    await service.accept(config);

    bool? result;
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () async => result = await ensurePolicyAcceptance(
            context,
            config: config,
            service: service,
          ),
          child: const Text('go'),
        ),
      ),
    ));
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();

    expect(result, isTrue);
    expect(find.byType(Checkbox), findsNothing);
  });

  testWidgets('ensurePolicyAcceptance shows screen then returns true',
      (tester) async {
    await tall(tester);
    final config = _config();
    final service = PolicyAcceptanceService(storage: _MemoryStorage());

    bool? result;
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () async => result = await ensurePolicyAcceptance(
            context,
            config: config,
            service: service,
          ),
          child: const Text('go'),
        ),
      ),
    ));
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
    expect(find.byType(Checkbox), findsOneWidget);

    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(result, isTrue);
  });
}
