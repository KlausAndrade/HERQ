/// Centralized utility to sanitize display names across the entire app
/// This ensures emails are NEVER shown to users, even if they're in the database
class DisplayNameSanitizer {
  /// Sanitize a display name to ensure it's safe to show
  ///
  /// Rules:
  /// - Never show emails (contains @)
  /// - Replace empty/null with fallback
  /// - Replace generic "User" with fallback
  ///
  /// Returns: Safe display name, or fallback if invalid
  static String sanitize(String? displayName,
      {String fallback = 'Unknown Athlete'}) {
    // Handle null or empty
    if (displayName == null || displayName.isEmpty) {
      return fallback;
    }

    // Remove whitespace
    final cleaned = displayName.trim();

    // Check if it's an email (contains @)
    if (cleaned.contains('@')) {
      print('⚠️ Sanitized email from display name: $cleaned');
      return fallback;
    }

    // Replace generic "User" with fallback
    if (cleaned == 'User') {
      return fallback;
    }

    // Valid display name
    return cleaned;
  }

  /// Get the first letter of a sanitized display name (for avatars)
  static String getInitial(String? displayName, {String fallback = 'U'}) {
    final sanitized = sanitize(displayName);
    return sanitized.isNotEmpty ? sanitized[0].toUpperCase() : fallback;
  }

  /// Check if a string is an email
  static bool isEmail(String? text) {
    if (text == null || text.isEmpty) return false;
    return text.contains('@');
  }

  /// Sanitize a list of display names
  static List<String> sanitizeList(List<String?> displayNames,
      {String fallback = 'Unknown Athlete'}) {
    return displayNames
        .map((name) => sanitize(name, fallback: fallback))
        .toList();
  }
}
