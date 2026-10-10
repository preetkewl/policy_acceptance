# policy_acceptance

Shared Flutter package that gates an app behind Terms & Conditions and
Privacy Policy consent. Built for reuse across all our games.

## Features

- Consent screen with two checkboxes and links to both documents
- Acceptance stored locally per app, tied to document versions
- Optional banner image so each game's screen feels on-brand
- All text overridable (localization-ready) via `PolicyStrings`
- Fails closed: if storage can't be read, the consent screen is shown

## Install

Not published. Reference it from git (preferred, shareable across games):

```yaml
dependencies:
  policy_acceptance:
    git:
      url: https://github.com/preetkewl/policy_acceptance.git
      ref: v0.1.0
```

or by path for local development: `policy_acceptance: { path: ../policy_acceptance }`.

## Usage

Keep URLs and versions together as constants so they don't drift:

```dart
abstract final class Policies {
  static const termsUrl = 'https://example.com/terms';
  static const termsVersion = '1.0';
  static const privacyUrl = 'https://example.com/privacy';
  static const privacyVersion = '1.0';
}

final config = PolicyConfig(
  appName: 'My Game',
  bannerImage: const AssetImage('assets/policy_banner.png'), // optional
  termsAndConditions: const PolicyDocument(
    title: 'Terms & Conditions',
    url: Policies.termsUrl,
    version: Policies.termsVersion,
  ),
  privacyPolicy: const PolicyDocument(
    title: 'Privacy Policy',
    url: Policies.privacyUrl,
    version: Policies.privacyVersion,
  ),
);

MaterialApp(
  home: PolicyAcceptanceGate(config: config, child: const HomeScreen()),
);
```

### Banner

Set `bannerImage` (and optionally `bannerHeight`, default 160) on
`PolicyConfig`. Declare the asset in the consuming app's `pubspec.yaml`.
Without it (or if it fails to load) the shield icon is shown.

### Localization

Pass a `PolicyStrings` to `PolicyConfig.strings` to replace any text,
including the intro paragraph (`introBuilder`). Also set `headerTitle` /
`headerHighlight`, and the document `title`s.

## Choosing where the consent screen appears

The gate shows the screen wherever you place it. To show it after your own
loading screen (or any screen), either wrap that next screen in
`PolicyAcceptanceGate`, or call the helper once loading finishes:

```dart
final ok = await ensurePolicyAcceptance(context, config: config);
if (ok) {
  // start ads/notifications, then navigate on
}
```

It shows nothing if consent is already stored, so it is safe to call on every
launch.

## Starting ads, analytics and notifications after consent

Do not initialize ad SDKs, analytics or notifications before `runApp()`.
Start them from `onConsentReady`, which fires once per launch whenever valid
consent exists (previously stored or just given):

```dart
PolicyAcceptanceGate(
  config: config,
  onConsentReady: () {
    Get.find<AdsService>().initialize();
    Get.find<NotificationService>().schedule();
  },
  child: const HomeScreen(),
);
```

Register services (without initializing them) in bootstrap; initialize them
here. `onAccepted` fires only on fresh acceptance, so don't use it for this.

Note: this checkbox gate is not a legal consent mechanism for ads
personalization. In the EEA/UK, run Google's UMP SDK before initializing
AdMob (and the equivalent in US states under CCPA).

## Version bumps

Acceptance is stored with the terms and privacy versions. Changing either
`PolicyDocument.version` makes `isAccepted` return false, so users are shown
the consent screen again on next launch. Bump only when the document changes
materially. Use `PolicyAcceptanceService.clearAcceptance` to reset manually.
