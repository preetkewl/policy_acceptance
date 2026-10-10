import 'package:flutter/material.dart';

import '../models/policy_config.dart';
import '../service/policy_acceptance_service.dart';
import '../theme/policy_acceptance_theme.dart';
import 'policy_acceptance_page.dart';

/// Shows [child] only once valid consent exists, otherwise the consent screen.
class PolicyAcceptanceGate extends StatefulWidget {
  const PolicyAcceptanceGate({
    super.key,
    required this.config,
    required this.child,
    this.service,
    this.theme = const PolicyAcceptanceTheme(),
    this.loadingBuilder,
    this.onAccepted,
    this.onConsentReady,
  });

  final PolicyConfig config;
  final Widget child;
  final PolicyAcceptanceService? service;
  final PolicyAcceptanceTheme theme;
  final WidgetBuilder? loadingBuilder;

  /// Fires only when the user taps Continue on the consent screen.
  final VoidCallback? onAccepted;

  /// Fires once per gate lifetime as soon as valid consent exists: either
  /// found in storage on launch, or just given. Start ads, analytics and
  /// notifications here.
  final VoidCallback? onConsentReady;

  @override
  State<PolicyAcceptanceGate> createState() => _PolicyAcceptanceGateState();
}

class _PolicyAcceptanceGateState extends State<PolicyAcceptanceGate> {
  late final PolicyAcceptanceService _service;

  bool? _isAccepted;
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? PolicyAcceptanceService();
    _checkAcceptance();
  }

  Future<void> _checkAcceptance() async {
    try {
      final accepted = await _service.isAccepted(widget.config);

      if (!mounted) return;

      setState(() {
        _isAccepted = accepted;
        _checking = false;
      });
      if (accepted) _notifyReady();
    } catch (_) {
      if (!mounted) return;

      // Fail closed: if acceptance cannot be verified,
      // show the consent screen.
      setState(() {
        _isAccepted = false;
        _checking = false;
      });
    }
  }

  void _onAccepted() {
    if (!mounted) return;

    setState(() => _isAccepted = true);
    widget.onAccepted?.call();
    _notifyReady();
  }

  bool _readyNotified = false;

  void _notifyReady() {
    if (_readyNotified) return;
    _readyNotified = true;
    widget.onConsentReady?.call();
  }

  @override
  Widget build(BuildContext context) {
    final Widget content;

    if (_checking) {
      // Blank, theme-colored placeholder so there is no white/spinner flash
      // between the native splash and the consent screen.
      content = KeyedSubtree(
        key: const ValueKey('loading'),
        child: widget.loadingBuilder?.call(context) ??
            Scaffold(backgroundColor: widget.theme.backgroundColor),
      );
    } else if (_isAccepted == true) {
      content = KeyedSubtree(
        key: const ValueKey('child'),
        child: widget.child,
      );
    } else {
      content = PolicyAcceptancePage(
        key: const ValueKey('consent'),
        config: widget.config,
        service: _service,
        theme: widget.theme,
        onAccepted: _onAccepted,
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      child: content,
    );
  }
}
