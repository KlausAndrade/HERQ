import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/notification_service.dart';
import 'notification_card.dart';
import 'in_app_notification.dart';

/// A floating overlay that listens to `NotificationService.inAppStream`
/// and shows `NotificationCard` widgets stacked at the top of the app.
///
/// Features:
/// - Smooth slide-in animations
/// - Auto-dismiss after 5 seconds
/// - Swipe to dismiss
/// - Stacks multiple notifications with compact spacing
class NotificationOverlay extends ConsumerStatefulWidget {
  const NotificationOverlay({Key? key}) : super(key: key);

  @override
  ConsumerState<NotificationOverlay> createState() =>
      _NotificationOverlayState();
}

class _NotificationOverlayState extends ConsumerState<NotificationOverlay>
    with TickerProviderStateMixin {
  late final StreamSubscription<InAppNotification> _sub;
  final List<InAppNotification> _active = [];
  final Map<String, Timer> _timers = {};

  @override
  void initState() {
    super.initState();
    _sub = NotificationService().inAppStream.listen((n) {
      if (mounted) {
        setState(() {
          _active.insert(0, n);
          // Auto-dismiss after 5s (unless it has actions)
          final hasActions = (n.primaryActionLabel != null &&
                  n.onPrimaryAction != null) ||
              (n.secondaryActionLabel != null && n.onSecondaryAction != null);

          if (!hasActions) {
            _timers[n.id] = Timer(const Duration(seconds: 5), () {
              _dismissNotification(n.id);
            });
          }
        });
      }
    });
  }

  void _dismissNotification(String id) {
    if (mounted) {
      setState(() {
        _active.removeWhere((item) => item.id == id);
        _timers[id]?.cancel();
        _timers.remove(id);
      });
    }
  }

  @override
  void dispose() {
    _sub.cancel();
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_active.isEmpty) return const SizedBox.shrink();

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _active.map((n) {
              return TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                tween: Tween<double>(begin: -100, end: 0),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, value),
                    child: Opacity(
                      opacity: (value + 100) / 100,
                      child: child,
                    ),
                  );
                },
                child: NotificationCard(
                  id: n.id,
                  title: n.title,
                  body: n.body,
                  leading: n.leading,
                  backgroundColor: n.backgroundColor,
                  primaryActionLabel: n.primaryActionLabel,
                  onPrimaryAction: n.onPrimaryAction,
                  secondaryActionLabel: n.secondaryActionLabel,
                  onSecondaryAction: n.onSecondaryAction,
                  onDismiss: () => _dismissNotification(n.id),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
