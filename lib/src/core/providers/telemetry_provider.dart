import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Import the supabase client provider that's defined alongside auth
import 'auth_provider.dart';

/// Minimal telemetry provider. For now this logs locally and optionally
/// sends lightweight events to Supabase (if configured).
final telemetryProvider = Provider<TelemetryService>((ref) {
  final supabase = ref.read(supabaseClientProvider);
  return TelemetryService(supabase: supabase);
});

class TelemetryService {
  TelemetryService({this.supabase});
  final SupabaseClient? supabase;

  void log(String message) {
    // Local console log
    // ignore: avoid_print
    print('[telemetry] $message');
  }

  Future<void> trackEvent(String name, Map<String, dynamic> props) async {
    // Local log
    // ignore: avoid_print
    print('[telemetry.event] $name: $props');

    // Optional: write to Supabase table `events` if available
    try {
      if (supabase != null) {
        await supabase!.from('events').insert({
          'name': name,
          'properties': props,
          'created_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      // ignore failures - telemetry must not break app
      // ignore: avoid_print
      print('[telemetry.error] Failed to send event: $e');
    }
  }
}
