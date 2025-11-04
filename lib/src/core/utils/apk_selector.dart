import 'package:flutter/foundation.dart';
// Conditional implementation - must be at top
import 'apk_selector_web_impl.dart' if (dart.library.io) 'apk_selector_stub_impl.dart';

/// Information about an APK variant
class ApkInfo {
  final String fileName;
  final String displayName;
  final String description;
  final String estimatedSize;

  const ApkInfo({
    required this.fileName,
    required this.displayName,
    required this.description,
    required this.estimatedSize,
  });
}

/// Utility class to detect device architecture and select the appropriate APK
/// Platform-agnostic interface
class ApkSelector {
  /// Available APK architectures with their file names and descriptions
  static const Map<String, ApkInfo> _apkVariants = {
    'arm64-v8a': ApkInfo(
      fileName: 'app-arm64-v8a-release.apk',
      displayName: '64-bit ARM',
      description: 'For most modern Android devices (2015+)',
      estimatedSize: '~25 MB',
    ),
    'armeabi-v7a': ApkInfo(
      fileName: 'app-armeabi-v7a-release.apk',
      displayName: '32-bit ARM',
      description: 'For older Android devices',
      estimatedSize: '~22 MB',
    ),
    'x86_64': ApkInfo(
      fileName: 'app-x86_64-release.apk',
      displayName: '64-bit Intel',
      description: 'For Intel-based Android devices',
      estimatedSize: '~27 MB',
    ),
  };

  /// Detects the device architecture and returns the appropriate APK filename
  /// Returns the default (arm64-v8a) if detection fails or on non-web platforms
  static String getRecommendedApkFileName() {
    if (!kIsWeb) {
      return _apkVariants['arm64-v8a']!.fileName;
    }
    // Web-only: use conditional import
    return getRecommendedApkFileNameWebImpl(_apkVariants);
  }

  /// Gets information about the recommended APK
  static ApkInfo getRecommendedApkInfo() {
    final fileName = getRecommendedApkFileName();
    return _apkVariants.values.firstWhere(
      (info) => info.fileName == fileName,
      orElse: () => _apkVariants['arm64-v8a']!,
    );
  }

  /// Gets all available APK variants
  static List<ApkInfo> getAllApkVariants() {
    return _apkVariants.values.toList();
  }

  /// Constructs the full download URL for a given APK filename
  static Uri getApkDownloadUrl(String fileName, {String? baseOrigin}) {
    if (!kIsWeb) {
      return Uri.parse('');
    }
    // Web-only: use conditional import
    return getApkDownloadUrlWebImpl(fileName, baseOrigin: baseOrigin);
  }

  /// Gets the download URL for the recommended APK
  static Uri getRecommendedApkUrl() {
    return getApkDownloadUrl(getRecommendedApkFileName());
  }
}
