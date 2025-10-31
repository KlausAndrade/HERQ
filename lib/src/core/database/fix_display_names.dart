import 'database.dart';

/// Fix display names - remove emails and replace with "Unknown Athlete"
Future<void> fixDisplayNames(AppDatabase db) async {
  print('🔧 Fixing display names in database...');

  // Get all users
  final users = await db.select(db.users).get();
  print('  📊 Found ${users.length} users');

  int fixed = 0;

  for (final user in users) {
    // Skip if user already has a valid display name (not an email)
    if (user.displayName.isNotEmpty &&
        !user.displayName.contains('@') &&
        user.displayName != 'User') {
      print('  ✅ User ${user.id}: "${user.displayName}" - OK');
      continue;
    }

    // Fix: Set to "Unknown Athlete"
    await db
        .update(db.users)
        .replace(user.copyWith(displayName: 'Unknown Athlete'));

    print(
      '  🔧 Fixed user ${user.id}: "${user.displayName}" → "Unknown Athlete"',
    );
    fixed++;
  }

  print('✅ Fixed $fixed display names');
}
