import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:groq/groq.dart';

/// Service for interacting with Groq AI API
class GroqService {
  late final Groq? _groq;
  final bool _isMock;
  static const String _defaultModel = 'llama-3.3-70b-versatile';

  /// If no API key is provided in the environment, the service will run in
  /// a deterministic mock mode which returns predictable responses. This
  /// prevents tests that don't configure env vars from failing at
  /// construction time.
  GroqService() : _isMock = _initMockMode() {
    if (_isMock) {
      _groq = null;
      return;
    }

    final apiKey = dotenv.env['GROQ_API_KEY'];
    _groq = Groq(
      apiKey: apiKey!,
      model: _defaultModel,
    );
  }

  static bool _initMockMode() {
    try {
      final apiKey = dotenv.env['GROQ_API_KEY'];
      if (apiKey == null ||
          apiKey.isEmpty ||
          apiKey == 'your_groq_api_key_here') {
        return true;
      }
      return false;
    } catch (_) {
      // If dotenv isn't available or hasn't been loaded, default to mock mode
      return true;
    }
  }

  /// Send a chat message to Groq and get a response
  Future<String> chat({
    required String prompt,
    String? systemPrompt,
  }) async {
    if (_isMock) {
      // Deterministic mock response for tests
      return Future.value(
          'MOCK: ${prompt.substring(0, prompt.length > 80 ? 80 : prompt.length)}');
    }

    try {
      _groq!.startChat();

      if (systemPrompt != null && systemPrompt.isNotEmpty) {
        _groq!.setCustomInstructionsWith(systemPrompt);
      }

      final response = await _groq!.sendMessage(prompt);

      return response.choices.first.message.content;
    } catch (e) {
      if (e is GroqException) {
        throw Exception('Groq API error: ${e.message}');
      }
      throw Exception('Groq error: $e');
    }
  }

  /// Send a structured JSON response request
  Future<String> chatJson({
    required String prompt,
    String? systemPrompt,
  }) async {
    final enhancedSystemPrompt = '''
${systemPrompt ?? 'You are a helpful assistant.'}

IMPORTANT: Respond ONLY with valid JSON. Do not include any markdown formatting, code blocks, or explanatory text. Just pure JSON.
''';

    return chat(
      prompt: prompt,
      systemPrompt: enhancedSystemPrompt,
    );
  }

  /// Clear chat history
  void clearChat() {
    _groq?.clearChat();
  }
}
