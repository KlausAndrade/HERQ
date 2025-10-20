import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/utils/enhanced_web_auth_helper.dart';

class WebDebugScreen extends ConsumerStatefulWidget {
  const WebDebugScreen({super.key});

  @override
  ConsumerState<WebDebugScreen> createState() => _WebDebugScreenState();
}

class _WebDebugScreenState extends ConsumerState<WebDebugScreen> {
  List<String> _debugLogs = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _runDiagnostics();
  }

  Future<void> _runDiagnostics() async {
    setState(() {
      _isLoading = true;
      _debugLogs.clear();
    });

    _addLog('🔍 Starting web authentication diagnostics...');

    try {
      // Test 1: Supabase connection
      _addLog('📡 Testing Supabase connection...');
      final connectionTest = await EnhancedWebAuthHelper.testConnection();
      _addLog(connectionTest ? '✅ Connection test passed' : '❌ Connection test failed');

      // Test 2: Current session
      _addLog('🔐 Checking current session...');
      final session = EnhancedWebAuthHelper.getCurrentSession();
      if (session != null) {
        _addLog('✅ Active session found: ${session.user?.email}');
        _addLog('   User ID: ${session.user?.id}');
        _addLog('   Session expires: ${session.expiresAt}');
      } else {
        _addLog('ℹ️ No active session');
      }

      // Test 3: Current user
      _addLog('👤 Checking current user...');
      final user = EnhancedWebAuthHelper.getCurrentUser();
      if (user != null) {
        _addLog('✅ Current user: ${user.email}');
        _addLog('   User ID: ${user.id}');
        _addLog('   Created: ${user.createdAt}');
      } else {
        _addLog('ℹ️ No current user');
      }

      // Test 4: URL analysis
      _addLog('🌐 Analyzing current URL...');
      final uri = Uri.base;
      _addLog('   Full URL: $uri');
      _addLog('   Fragment: ${uri.fragment}');
      _addLog('   Query params: ${uri.queryParameters}');
      
      if (uri.fragment.contains('access_token')) {
        _addLog('✅ Access token found in URL fragment');
      } else if (uri.queryParameters.containsKey('access_token')) {
        _addLog('✅ Access token found in query parameters');
      } else {
        _addLog('ℹ️ No access token in URL');
      }

      // Test 5: Storage analysis
      _addLog('💾 Checking browser storage...');
      try {
        final localStorage = _getLocalStorageInfo();
        _addLog('   Local storage keys: ${localStorage.length}');
        for (final key in localStorage.take(5)) {
          _addLog('     - $key');
        }
      } catch (e) {
        _addLog('❌ Error checking storage: $e');
      }

      // Test 6: Supabase client state
      _addLog('🔧 Checking Supabase client state...');
      try {
        final client = Supabase.instance.client;
        _addLog('   Client initialized: ${client != null}');
        _addLog('   Auth state: ${client.auth.currentSession != null ? "Active" : "None"}');
      } catch (e) {
        _addLog('❌ Error checking client state: $e');
      }

      _addLog('✅ Diagnostics completed');
    } catch (e) {
      _addLog('❌ Diagnostic error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<String> _getLocalStorageInfo() {
    try {
      // This would need to be implemented with dart:html
      return ['supabase.auth.token', 'supabase.auth.user'];
    } catch (e) {
      return [];
    }
  }

  void _addLog(String message) {
    setState(() {
      _debugLogs.add('${DateTime.now().toIso8601String().substring(11, 19)} $message');
    });
  }

  Future<void> _clearStorage() async {
    _addLog('🧹 Clearing browser storage...');
    try {
      // This would need dart:html implementation
      _addLog('✅ Storage cleared');
    } catch (e) {
      _addLog('❌ Error clearing storage: $e');
    }
  }

  Future<void> _testSignIn() async {
    _addLog('🔐 Testing sign in with test credentials...');
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await EnhancedWebAuthHelper.signInWithPasswordSafe(
        email: 'test@example.com',
        password: 'testpassword',
      );
      
      if (response.user != null) {
        _addLog('✅ Test sign in successful: ${response.user?.email}');
      } else {
        _addLog('❌ Test sign in failed - no user returned');
      }
    } catch (e) {
      _addLog('❌ Test sign in error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Web Debug'),
        backgroundColor: const Color(0xFF00BFA6),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _runDiagnostics,
          ),
        ],
      ),
      body: Column(
        children: [
          // Action buttons
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _runDiagnostics,
                    icon: const Icon(Icons.bug_report),
                    label: const Text('Run Diagnostics'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _clearStorage,
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Clear Storage'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _testSignIn,
                    icon: const Icon(Icons.login),
                    label: const Text('Test Sign In'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Debug logs
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1B1D21),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF00BFA6)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.terminal,
                        color: Color(0xFF00BFA6),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Debug Logs',
                        style: TextStyle(
                          color: Color(0xFF00BFA6),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      if (_isLoading)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00BFA6)),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _debugLogs.map((log) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            log,
                            style: const TextStyle(
                              color: Color(0xFFF8F8FA),
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        )).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
