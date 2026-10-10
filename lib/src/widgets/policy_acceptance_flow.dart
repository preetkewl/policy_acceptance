import 'package:flutter/material.dart';

import '../models/policy_config.dart';
import '../service/policy_acceptance_service.dart';
import '../theme/policy_acceptance_theme.dart';
import 'policy_acceptance_page.dart';

/// Ensures consent exists, showing the consent screen as a full-screen route
/// only if needed. Call it from any screen (e.g. after your loading screen).
///
/// Returns true if consent is valid (already stored or just given).
Future<bool> ensurePolicyAcceptance(
  BuildContext context, {
  required PolicyConfig config,
  PolicyAcceptanceService? service,
  PolicyAcceptanceTheme theme = const PolicyAcceptanceTheme(),
}) async {
  final svc = service ?? PolicyAcceptanceService();

  try {
    if (await svc.isAccepted(config)) return true;
  } catch (_) {
    // Fail closed: fall through and ask again.
  }

  if (!context.mounted) return false;

  final accepted = await Navigator.of(context).push<bool>(
    PageRouteBuilder<bool>(
      opaque: true,
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (routeContext, _, __) => PopScope(
        canPop: false,
        child: PolicyAcceptancePage(
          config: config,
          service: svc,
          theme: theme,
          onAccepted: () => Navigator.of(routeContext).pop(true),
        ),
      ),
      transitionsBuilder: (_, animation, __, child) =>
          FadeTransition(opacity: animation, child: child),
    ),
  );

  return accepted ?? false;
}
