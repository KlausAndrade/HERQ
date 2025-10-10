import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/notification_service.dart';
import 'notification_card.dart';
import 'in_app_notification.dart';

/// A floating overlay that listens to `NotificationService.inAppStream`
/// and shows `NotificationCard` widgets stacked at the top of the app.
class NotificationOverlay extends ConsumerStatefulWidget {
  const NotificationOverlay({Key? key}) : super(key: key);

  @override
  ConsumerState<NotificationOverlay> createState() => _NotificationOverlayState();
}

class _NotificationOverlayState extends ConsumerState<NotificationOverlay> {
  late final StreamSubscription<InAppNotification> _sub;
  final List<InAppNotification> _active = [];

  @override
  void initState() {
    super.initState();
    _sub = NotificationService().inAppStream.listen((n) {
      setState(() {
        _active.insert(0, n);
        // auto-dismiss after 6s
        Future.delayed(const Duration(seconds: 6), () {
          setState(() {
            _active.removeWhere((item) => item.id == n.id);
          });
        });
      });
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_active.isEmpty) return const SizedBox.shrink();

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _active
              .map((n) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: NotificationCard(
                      id: n.id,
                      title: n.title,
                      body: n.body,
                      leading: n.leading,
                      primaryActionLabel: n.primaryActionLabel,
                      onPrimaryAction: n.onPrimaryAction,
                      secondaryActionLabel: n.secondaryActionLabel,
                      onSecondaryAction: n.onSecondaryAction,
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
