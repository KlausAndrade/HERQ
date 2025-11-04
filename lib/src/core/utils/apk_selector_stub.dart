import 'apk_selector.dart';

/// Stub implementation functions for non-web platforms
String getRecommendedApkFileNameImpl(Map<String, ApkInfo> variants) {
  return variants['arm64-v8a']!.fileName;
}

/// Stub: Returns empty URI for non-web platforms
Uri getApkDownloadUrlImpl(String fileName, {String? baseOrigin}) {
  return Uri.parse('');
}
