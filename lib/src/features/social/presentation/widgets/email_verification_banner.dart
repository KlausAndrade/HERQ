import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/auth_provider.dart';
import '../../../../core/services/notification_service.dart';

class EmailVerificationBanner extends ConsumerWidget {
  const EmailVerificationBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    // Don't show if no user or email is already confirmed
    if (user == null || user.emailConfirmedAt != null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.email_outlined, color: Colors.orange.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verify your email',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.orange.shade900,
                  ),
                ),
                Text(
                  'Check your inbox for verification link',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange.shade800,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () async {
              try {
                await ref.read(authServiceProvider).resendEmailVerification();
                if (context.mounted) {
                  NotificationService()
                      .showInAppNotification(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: 'Verification sent',
                        body: 'Verification email sent!',
                      )
                      .catchError((_) {});
                }
              } catch (e) {
                if (context.mounted) {
                  NotificationService()
                      .showInAppNotification(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: 'Failed to send',
                        body: '$e',
                      )
                      .catchError((_) {});
                }
              }
            },
            child: const Text('Resend'),
          ),
        ],
      ),
    );
  }
}
