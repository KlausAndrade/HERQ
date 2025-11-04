import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/database_provider.dart';

class DatabaseTestScreen extends ConsumerStatefulWidget {
  const DatabaseTestScreen({super.key});

  @override
  ConsumerState<DatabaseTestScreen> createState() => _DatabaseTestScreenState();
}

class _DatabaseTestScreenState extends ConsumerState<DatabaseTestScreen> {
  String _testResults = 'Ready to test database...';
  bool _isTesting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Test'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Database Connection Test',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This will test if the database is accessible and if the template_folders table exists.',
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _testResults,
                      style: TextStyle(
                        color: _isTesting ? Colors.orange : Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isTesting ? null : () => _testDatabase(),
              icon: const Icon(Icons.bug_report),
              label: const Text('Test Database'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isTesting ? null : () => _testTemplateFolders(),
              icon: const Icon(Icons.folder),
              label: const Text('Test Template Folders'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isTesting ? null : () => _testExercises(),
              icon: const Icon(Icons.fitness_center),
              label: const Text('Test Exercises'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _testDatabase() async {
    setState(() {
      _isTesting = true;
      _testResults = 'Testing database connection...';
    });

    try {
      final database = ref.read(databaseProvider);
      if (database == null) {
        setState(() {
          _testResults = '❌ Database is null (this is expected on web)';
        });
        return;
      }

      // Test basic database access
      await database.customSelect('SELECT 1').get();
      setState(() {
        _testResults = '✅ Database connection successful!';
      });
    } catch (e) {
      setState(() {
        _testResults = '❌ Database connection failed: $e';
      });
    } finally {
      setState(() {
        _isTesting = false;
      });
    }
  }

  Future<void> _testTemplateFolders() async {
    setState(() {
      _isTesting = true;
      _testResults = 'Testing template folders table...';
    });

    try {
      final database = ref.read(databaseProvider);
      if (database == null) {
        setState(() {
          _testResults = '❌ Database is null (this is expected on web)';
        });
        return;
      }

      // Test template folders table
      final folders = await database.select(database.templateFolders).get();
      setState(() {
        _testResults =
            '✅ Template folders table accessible! Found ${folders.length} folders';
      });
    } catch (e) {
      setState(() {
        _testResults = '❌ Template folders table failed: $e';
      });
    } finally {
      setState(() {
        _isTesting = false;
      });
    }
  }

  Future<void> _testExercises() async {
    setState(() {
      _isTesting = true;
      _testResults = 'Testing exercises table...';
    });

    try {
      final database = ref.read(databaseProvider);
      if (database == null) {
        setState(() {
          _testResults = '❌ Database is null (this is expected on web)';
        });
        return;
      }

      // Test exercises table
      final exercises = await database.select(database.exercises).get();
      setState(() {
        _testResults =
            '✅ Exercises table accessible! Found ${exercises.length} exercises';
      });
    } catch (e) {
      setState(() {
        _testResults = '❌ Exercises table failed: $e';
      });
    } finally {
      setState(() {
        _isTesting = false;
      });
    }
  }
}
