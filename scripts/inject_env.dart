#!/usr/bin/env dart

import 'dart:io';

void main(List<String> args) async {
  final envFile = File('.env');

  if (!envFile.existsSync()) {
    print('❌ .env file not found!');
    print('📝 Please copy .env.example to .env and fill in your values.');
    exit(1);
  }

  final envContent = envFile.readAsStringSync();
  final envVars = <String, String>{};

  // Parse .env file
  for (final line in envContent.split('\n')) {
    final trimmedLine = line.trim();
    if (trimmedLine.isEmpty || trimmedLine.startsWith('#')) continue;

    final parts = trimmedLine.split('=');
    if (parts.length >= 2) {
      final key = parts[0].trim();
      final value = parts.sublist(1).join('=').trim();
      envVars[key] = value;
    }
  }

  // Inject into Android strings.xml
  final androidStringsFile =
      File('android/app/src/main/res/values/strings.xml');
  if (androidStringsFile.existsSync()) {
    var androidContent = androidStringsFile.readAsStringSync();

    androidContent = androidContent.replaceAll('FACEBOOK_ID_PLACEHOLDER',
        envVars['FACEBOOK_ID'] ?? 'YOUR_FACEBOOK_APP_ID');

    androidContent = androidContent.replaceAll(
        'FACEBOOK_CLIENT_TOKEN_PLACEHOLDER',
        envVars['FACEBOOK_CLIENT_TOKEN'] ?? 'YOUR_FACEBOOK_CLIENT_TOKEN');

    androidStringsFile.writeAsStringSync(androidContent);
    print('✅ Updated Android strings.xml');
  }

  // Inject into iOS Info.plist
  final iosInfoFile = File('ios/Runner/Info.plist');
  if (iosInfoFile.existsSync()) {
    var iosContent = iosInfoFile.readAsStringSync();

    iosContent = iosContent.replaceAll('YOUR_FACEBOOK_APP_ID',
        envVars['FACEBOOK_ID'] ?? 'YOUR_FACEBOOK_APP_ID');

    iosContent = iosContent.replaceAll('YOUR_FACEBOOK_CLIENT_TOKEN',
        envVars['FACEBOOK_CLIENT_TOKEN'] ?? 'YOUR_FACEBOOK_CLIENT_TOKEN');

    iosInfoFile.writeAsStringSync(iosContent);
    print('✅ Updated iOS Info.plist');
  }

  print('🎉 Environment variables injected successfully!');
  print('📱 You can now run: flutter run');
}
