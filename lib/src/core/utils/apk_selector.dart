import 'dart:js_interop';
import 'package:web/web.dart' as web;

/// Utility class to detect device architecture and select the appropriate APK
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
  /// Returns the default (arm64-v8a) if detection fails
  static String getRecommendedApkFileName() {
    try {
      final userAgent = web.window.navigator.userAgent.toLowerCase();
      
      // Most Android devices use ARM64 (64-bit)
      // This is the most common architecture for devices from 2015+
      if (userAgent.contains('arm64') || userAgent.contains('aarch64')) {
        return _apkVariants['arm64-v8a']!.fileName;
      }
      
      // Check for 32-bit ARM (older devices)
      if (userAgent.contains('arm') && !userAgent.contains('arm64')) {
        return _apkVariants['armeabi-v7a']!.fileName;
      }
      
      // Check for x86_64 (Intel-based Android devices like some tablets)
      if (userAgent.contains('x86_64')) {
        return _apkVariants['x86_64']!.fileName;
      }
      
      // Default to arm64-v8a (most common and compatible with most devices)
      return _apkVariants['arm64-v8a']!.fileName;
    } catch (e) {
      // If detection fails, default to arm64-v8a (most common)
      return _apkVariants['arm64-v8a']!.fileName;
    }
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
    final origin = baseOrigin ?? web.window.location.origin;
    return Uri.parse('$origin/$fileName');
  }

  /// Gets the download URL for the recommended APK
  static Uri getRecommendedApkUrl() {
    return getApkDownloadUrl(getRecommendedApkFileName());
  }
}

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

