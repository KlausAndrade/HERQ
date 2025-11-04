import 'package:web/web.dart' as web;
import 'apk_selector.dart';

String getRecommendedApkFileNameWebImpl(Map<String, ApkInfo> variants) {
  try {
    final userAgent = web.window.navigator.userAgent.toLowerCase();
    
    if (userAgent.contains('arm64') || userAgent.contains('aarch64')) {
      return variants['arm64-v8a']!.fileName;
    }
    
    if (userAgent.contains('arm') && !userAgent.contains('arm64')) {
      return variants['armeabi-v7a']!.fileName;
    }
    
    if (userAgent.contains('x86_64')) {
      return variants['x86_64']!.fileName;
    }
    
    return variants['arm64-v8a']!.fileName;
  } catch (e) {
    return variants['arm64-v8a']!.fileName;
  }
}

Uri getApkDownloadUrlWebImpl(String fileName, {String? baseOrigin}) {
  final origin = baseOrigin ?? web.window.location.origin;
  return Uri.parse('$origin/$fileName');
}
