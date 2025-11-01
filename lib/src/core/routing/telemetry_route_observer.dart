import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/telemetry_provider.dart';

class TelemetryRouteObserver extends NavigatorObserver {
  TelemetryRouteObserver(this.ref);
  final Ref ref;

  void _track(Route<dynamic>? route, String action) {
    if (route == null) return;
    final name = route.settings.name ??
        route.settings.arguments?.toString() ??
        'unknown';
    try {
      ref.read(telemetryProvider).trackEvent('screen_view', {
        'route': name,
        'action': action,
      });
    } catch (_) {}
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _track(route, 'push');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _track(previousRoute, 'pop');
  }
}
