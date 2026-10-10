import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/policy_config.dart';
import '../service/policy_acceptance_service.dart';
import '../theme/policy_acceptance_theme.dart';

/// The consent screen. Prefer [PolicyAcceptanceGate] or
/// `ensurePolicyAcceptance` unless you need full control.
class PolicyAcceptancePage extends StatefulWidget {
  const PolicyAcceptancePage({
    super.key,
    required this.config,
    required this.service,
    required this.onAccepted,
    this.theme = const PolicyAcceptanceTheme(),
  });

  final PolicyConfig config;
  final PolicyAcceptanceService service;
  final VoidCallback onAccepted;
  final PolicyAcceptanceTheme theme;

  @override
  State<PolicyAcceptancePage> createState() => _PolicyAcceptancePageState();
}

class _PolicyAcceptancePageState extends State<PolicyAcceptancePage> {
  bool _accepted = false;
  bool _isSaving = false;

  bool get _canContinue => _accepted && !_isSaving;

  Future<void> _openPolicy(String url) async {
    final uri = Uri.tryParse(url);

    if (uri == null ||
        !uri.hasAuthority ||
        !['https', 'http'].contains(uri.scheme)) {
      _showMessage(widget.config.strings.invalidUrl);
      return;
    }

    try {
      final opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!opened && mounted) {
        _showMessage(widget.config.strings.unableToOpen);
      }
    } catch (_) {
      if (mounted) {
        _showMessage(widget.config.strings.unableToOpen);
      }
    }
  }

  Future<void> _acceptPolicies() async {
    if (!_canContinue) return;

    setState(() => _isSaving = true);

    try {
      await widget.service.accept(widget.config);

      if (!mounted) return;

      widget.onAccepted();
    } catch (_) {
      if (mounted) {
        _showMessage(widget.config.strings.unableToSave);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config;
    final theme = widget.theme;
    final strings = config.strings;

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  if (config.bannerImage != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: Image(
                        image: config.bannerImage!,
                        height: config.bannerHeight,
                        fit: BoxFit.cover,
                        semanticLabel: config.appName,
                        errorBuilder: (_, __, ___) =>
                            _ShieldBadge(theme: theme),
                      ),
                    )
                  else
                    _ShieldBadge(theme: theme),
                  const SizedBox(height: 24),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${config.headerTitle} ',
                            style: TextStyle(color: theme.textColor),
                          ),
                          TextSpan(
                            text: config.headerHighlight,
                            style: TextStyle(color: theme.accentColor),
                          ),
                        ],
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      maxLines: 1,
                      softWrap: false,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    strings.introBuilder(config.appName),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: theme.secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _PolicyCard(
                    icon: Icons.description_rounded,
                    title: config.termsAndConditions.title,
                    description: strings.termsDescription,
                    theme: theme,
                    onTap: () => _openPolicy(
                      config.termsAndConditions.url,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _PolicyCard(
                    icon: Icons.shield_rounded,
                    title: config.privacyPolicy.title,
                    description: strings.privacyDescription,
                    theme: theme,
                    onTap: () => _openPolicy(
                      config.privacyPolicy.url,
                    ),
                  ),
                  const SizedBox(height: 26),
                  _ConsentTile(
                    value: _accepted,
                    theme: theme,
                    prefix: strings.consentPrefix,
                    joiner: strings.consentJoiner,
                    firstLink: config.termsAndConditions.title,
                    secondLink: config.privacyPolicy.title,
                    onChanged: (value) {
                      setState(() => _accepted = value);
                    },
                    onFirstTap: () => _openPolicy(
                      config.termsAndConditions.url,
                    ),
                    onSecondTap: () => _openPolicy(
                      config.privacyPolicy.url,
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    height: 58,
                    child: FilledButton(
                      onPressed: _canContinue ? _acceptPolicies : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        disabledBackgroundColor:
                            theme.primaryColor.withValues(alpha: 0.35),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  strings.continueLabel,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Icon(Icons.arrow_forward_rounded),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    strings.footer,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PolicyCard extends StatelessWidget {
  const _PolicyCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.theme,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final PolicyAcceptanceTheme theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.17),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: theme.primaryColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: theme.textColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: TextStyle(
                        color: theme.secondaryTextColor,
                        height: 1.4,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.secondaryTextColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConsentTile extends StatefulWidget {
  const _ConsentTile({
    required this.value,
    required this.theme,
    required this.prefix,
    required this.joiner,
    required this.firstLink,
    required this.secondLink,
    required this.onChanged,
    required this.onFirstTap,
    required this.onSecondTap,
  });

  final bool value;
  final PolicyAcceptanceTheme theme;
  final String prefix;
  final String joiner;
  final String firstLink;
  final String secondLink;
  final ValueChanged<bool> onChanged;
  final VoidCallback onFirstTap;
  final VoidCallback onSecondTap;

  @override
  State<_ConsentTile> createState() => _ConsentTileState();
}

class _ConsentTileState extends State<_ConsentTile> {
  late final TapGestureRecognizer _first;
  late final TapGestureRecognizer _second;

  @override
  void initState() {
    super.initState();
    _first = TapGestureRecognizer()..onTap = () => widget.onFirstTap();
    _second = TapGestureRecognizer()..onTap = () => widget.onSecondTap();
  }

  @override
  void dispose() {
    _first.dispose();
    _second.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final textStyle = TextStyle(
      color: theme.secondaryTextColor,
      fontSize: 13,
      height: 1.5,
    );
    final linkStyle = TextStyle(
      color: theme.primaryColor,
      fontSize: 13,
      decoration: TextDecoration.underline,
      fontWeight: FontWeight.w600,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: widget.value,
          onChanged: (checked) => widget.onChanged(checked ?? false),
          activeColor: theme.primaryColor,
          side: BorderSide(color: theme.secondaryTextColor),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 11),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text.rich(
                maxLines: 1,
                softWrap: false,
                TextSpan(
                  style: textStyle,
                  children: [
                    TextSpan(text: widget.prefix),
                    TextSpan(
                      text: widget.firstLink,
                      style: linkStyle,
                      recognizer: _first,
                    ),
                    TextSpan(text: widget.joiner),
                    TextSpan(
                      text: widget.secondLink,
                      style: linkStyle,
                      recognizer: _second,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ShieldBadge extends StatelessWidget {
  const _ShieldBadge({required this.theme});

  final PolicyAcceptanceTheme theme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 108,
        height: 108,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.primaryColor.withValues(alpha: 0.15),
          border: Border.all(
            color: theme.primaryColor.withValues(alpha: 0.3),
          ),
        ),
        child: Icon(
          Icons.shield_rounded,
          size: 62,
          color: theme.primaryColor,
        ),
      ),
    );
  }
}
