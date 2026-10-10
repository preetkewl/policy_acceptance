/// All user-facing text in the consent screen. Override any field to localize.
class PolicyStrings {
  const PolicyStrings({
    this.invalidUrl = 'Invalid policy URL.',
    this.unableToOpen = 'Unable to open this policy.',
    this.unableToSave = 'Unable to save your acceptance. Please retry.',
    this.termsDescription = 'Review the terms and rules for using this game.',
    this.privacyDescription =
        'Learn how your information is collected and used.',
    this.consentPrefix = 'I agree to the ',
    this.consentJoiner = ' and ',
    this.continueLabel = 'Continue',
    this.footer = 'You can review these policies again at any time.',
    this.introBuilder = defaultIntro,
  });

  final String invalidUrl;
  final String unableToOpen;
  final String unableToSave;
  final String termsDescription;
  final String privacyDescription;

  /// Single checkbox text: prefix + terms title + joiner + privacy title.
  final String consentPrefix;
  final String consentJoiner;
  final String continueLabel;
  final String footer;

  /// Builds the intro paragraph from the app name.
  final String Function(String appName) introBuilder;

  static String defaultIntro(String appName) =>
      'Before you play $appName, please review '
      'our policies and confirm your choices.';
}
