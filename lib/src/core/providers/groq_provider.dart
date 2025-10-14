import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../services/groq_service.dart';

/// Provider for Groq AI service
final groqServiceProvider = Provider<GroqService>((ref) => GroqService());
