/// A policy (terms or privacy) shown to the user.
///
/// Changing [version] makes previously stored consent invalid.
class PolicyDocument {
  const PolicyDocument({
    required this.title,
    required this.url,
    required this.version,
  });

  /// Display name, also used as the link text.
  final String title;

  /// Public http(s) address opened in the external browser.
  final String url;

  /// Version string compared against the stored acceptance.
  final String version;
}
