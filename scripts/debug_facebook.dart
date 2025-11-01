#!/usr/bin/env dart

import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main(List<String> args) async {
  print('🔍 Facebook Configuration Debug Tool');
  print('=====================================\n');

  // Check .env file
  final envFile = File('.env');
  if (!envFile.existsSync()) {
    print('❌ .env file not found!');
    print('📝 Please run: cp .env.example .env');
    exit(1);
  }

  // Load environment variables
  await dotenv.load(fileName: ".env");

  final facebookId = dotenv.env['FACEBOOK_ID'] ?? '';
  final facebookToken = dotenv.env['FACEBOOK_CLIENT_TOKEN'] ?? '';

  print('📋 Environment Variables:');
  print('  FACEBOOK_ID: ${facebookId.isEmpty ? "❌ Not set" : "✅ Set"}');
  print(
      '  FACEBOOK_CLIENT_TOKEN: ${facebookToken.isEmpty ? "❌ Not set" : "✅ Set"}');

  if (facebookId.contains('your_facebook_app_id_here')) {
    print('⚠️  FACEBOOK_ID still has placeholder value!');
  }

  if (facebookToken.contains('your_facebook_client_token_here')) {
    print('⚠️  FACEBOOK_CLIENT_TOKEN still has placeholder value!');
  }

  print('\n📱 Platform Configuration Check:');

  // Check Android strings.xml
  final androidFile = File('android/app/src/main/res/values/strings.xml');
  if (androidFile.existsSync()) {
    final androidContent = androidFile.readAsStringSync();

    if (androidContent.contains('your_facebook_app_id_here')) {
      print('❌ Android strings.xml still has placeholder values');
      print('💡 Run: ./scripts/setup_env.sh');
    } else {
      print('✅ Android strings.xml looks good');
    }
  }

  // Check iOS Info.plist
  final iosFile = File('ios/Runner/Info.plist');
  if (iosFile.existsSync()) {
    final iosContent = iosFile.readAsStringSync();

    if (iosContent.contains('YOUR_FACEBOOK_APP_ID')) {
      print('❌ iOS Info.plist still has placeholder values');
      print('💡 Run: ./scripts/setup_env.sh');
    } else {
      print('✅ iOS Info.plist looks good');
    }
  }

  print('\n🚀 Next Steps:');
  print(
      '1. Get your Facebook App ID and Client Token from Facebook Developers Console');
  print('2. Edit .env file with real values:');
  print('   FACEBOOK_ID=123456789012345');
  print('   FACEBOOK_CLIENT_TOKEN=abc123def456ghi789');
  print('3. Run: ./scripts/setup_env.sh');
  print('4. Test: flutter run');

  print('\n🔗 Facebook Developer Console:');
  print('https://developers.facebook.com/apps/');
}
