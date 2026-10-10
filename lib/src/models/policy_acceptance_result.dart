/// The stored record of a user's acceptance.
class PolicyAcceptanceResult {
  const PolicyAcceptanceResult({
    required this.termsAccepted,
    required this.privacyAccepted,
    required this.acceptedAt,
    required this.termsVersion,
    required this.privacyVersion,
  });

  final bool termsAccepted;
  final bool privacyAccepted;
  final DateTime acceptedAt;

  final String termsVersion;
  final String privacyVersion;

  bool get isComplete => termsAccepted && privacyAccepted;
}
