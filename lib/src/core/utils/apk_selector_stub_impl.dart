import 'apk_selector.dart';

String getRecommendedApkFileNameWebImpl(Map<String, ApkInfo> variants) =>
    variants['arm64-v8a']!.fileName;

Uri getApkDownloadUrlWebImpl(String fileName, {String? baseOrigin}) =>
    Uri.parse('');
