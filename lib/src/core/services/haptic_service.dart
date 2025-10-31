import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

/// Centralized haptic feedback service for consistent tactile responses
class HapticService {
  /// Light impact - for subtle feedback like button taps
  static Future<void> lightImpact() async {
    await HapticFeedback.lightImpact();
  }

  /// Medium impact - for standard interactions like toggles
  static Future<void> mediumImpact() async {
    await HapticFeedback.mediumImpact();
  }

  /// Heavy impact - for significant actions like deletions
  static Future<void> heavyImpact() async {
    await HapticFeedback.heavyImpact();
  }

  /// Selection click - for navigation and selections
  static Future<void> selectionClick() async {
    await HapticFeedback.selectionClick();
  }

  /// Success vibration - for completed actions
  static Future<void> success() async {
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      await Vibration.vibrate(
        pattern: [0, 50, 50, 50], // Quick double tap
        intensities: [0, 128, 0, 255],
      );
    } else {
      await HapticFeedback.mediumImpact();
    }
  }

  /// Error vibration - for errors and failures
  static Future<void> error() async {
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      await Vibration.vibrate(
        pattern: [0, 100, 50, 100], // Long-short-long
        intensities: [0, 255, 0, 255],
      );
    } else {
      await HapticFeedback.heavyImpact();
    }
  }

  /// Warning vibration - for warnings and cautions
  static Future<void> warning() async {
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      await Vibration.vibrate(
        pattern: [0, 50, 100, 50, 100, 50], // Triple short
        intensities: [0, 200, 0, 200, 0, 200],
      );
    } else {
      await HapticFeedback.mediumImpact();
    }
  }

  /// Custom vibration pattern
  static Future<void> custom({
    required List<int> pattern,
    List<int>? intensities,
  }) async {
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      if (intensities != null) {
        await Vibration.vibrate(pattern: pattern, intensities: intensities);
      } else {
        await Vibration.vibrate(pattern: pattern);
      }
    } else {
      await HapticFeedback.mediumImpact();
    }
  }
}
