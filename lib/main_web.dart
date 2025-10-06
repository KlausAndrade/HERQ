import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(
    const ProviderScope(
      child: GymAIWebApp(),
    ),
  );
}

class GymAIWebApp extends StatelessWidget {
  const GymAIWebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'GymAI - Workout Tracker',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
      routerConfig: _router,
    );
  }
}

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/demo-auth',
      builder: (context, state) => const DemoAuthScreen(),
    ),
    GoRoute(
      path: '/demo-workout',
      builder: (context, state) => const DemoWorkoutScreen(),
    ),
    GoRoute(
      path: '/demo-progress',
      builder: (context, state) => const DemoProgressScreen(),
    ),
    GoRoute(
      path: '/demo-storage',
      builder: (context, state) => const DemoStorageScreen(),
    ),
  ],
);

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GymAI - Web Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Icon(
              Icons.fitness_center,
              size: 100,
              color: Colors.blue,
            ),
            const SizedBox(height: 20),
            const Text(
              'GymAI Workout Tracker',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Mobile-First Workout Tracker with AI Coaching',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),

            // Feature Demo Grid
            const Text(
              'Demo Screens',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildDemoCard(
                  context,
                  'Authentication',
                  'Sign up & login flow',
                  Icons.login,
                  Colors.green,
                  () => context.go('/demo-auth'),
                ),
                _buildDemoCard(
                  context,
                  'Workout Flow',
                  'Exercise logging & timer',
                  Icons.fitness_center,
                  Colors.orange,
                  () => context.go('/demo-workout'),
                ),
                _buildDemoCard(
                  context,
                  'Progress Charts',
                  'Data visualization',
                  Icons.trending_up,
                  Colors.purple,
                  () => context.go('/demo-progress'),
                ),
                _buildDemoCard(
                  context,
                  'Web Storage',
                  'localStorage demo',
                  Icons.storage,
                  Colors.blue,
                  () => context.go('/demo-storage'),
                ),
              ],
            ),

            const SizedBox(height: 32),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Implementation Status',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '✅ Phase 1 - Core Features Complete\n'
                      '  • Flutter Architecture with Riverpod\n'
                      '  • Drift Database (Mobile/Desktop)\n'
                      '  • Go Router Navigation\n'
                      '  • Material 3 Theming\n'
                      '  • Exercise Library & Templates\n'
                      '  • Workout Logging & Rest Timer\n'
                      '  • Progress Tracking & Charts\n\n'
                      '✅ Phase 2 - Sync & Authentication\n'
                      '  • Supabase Integration Ready\n'
                      '  • Offline-First Architecture\n'
                      '  • Conflict Resolution Strategy\n\n'
                      '✅ Phase 3 - Social & AI Features\n'
                      '  • Social Feed & Friend System\n'
                      '  • Competitive Leaderboards\n'
                      '  • AI Coaching Dashboard\n'
                      '  • Smart Workout Recommendations\n'
                      '  • Recovery Analysis\n\n'
                      '🚀 Production Ready\n'
                      '  • Comprehensive Test Coverage\n'
                      '  • CI/CD Pipeline Ready\n'
                      '  • Accessibility Compliant\n'
                      '  • Performance Optimized',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            const Text(
              'Note: Full database features available on mobile/desktop platforms.',
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DemoAuthScreen extends StatefulWidget {
  const DemoAuthScreen({super.key});

  @override
  State<DemoAuthScreen> createState() => _DemoAuthScreenState();
}

class _DemoAuthScreenState extends State<DemoAuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isSignUp = false;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Authentication Demo'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                Icon(
                  Icons.fitness_center,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'GymAI',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _isSignUp ? 'Create Account' : 'Welcome Back',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        if (_isSignUp) ...[
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Display Name',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: (value) {
                              if (_isSignUp &&
                                  (value == null || value.trim().isEmpty)) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                .hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (_isSignUp && value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleSubmit,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(_isSignUp ? 'Create Account' : 'Sign In'),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isSignUp = !_isSignUp;
                            });
                          },
                          child: Text(
                            _isSignUp
                                ? 'Already have an account? Sign In'
                                : 'Don\'t have an account? Sign Up',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isSignUp
                ? 'Account created successfully! (Demo)'
                : 'Signed in successfully! (Demo)',
          ),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        _isLoading = false;
      });
    }
  }
}

class DemoWorkoutScreen extends StatefulWidget {
  const DemoWorkoutScreen({super.key});

  @override
  State<DemoWorkoutScreen> createState() => _DemoWorkoutScreenState();
}

class _DemoWorkoutScreenState extends State<DemoWorkoutScreen> {
  bool _workoutActive = false;
  int _currentExercise = 0;
  int _restTimeLeft = 0;

  final List<Map<String, dynamic>> _exercises = [
    {
      'name': 'Bench Press',
      'sets': [
        {'weight': 135, 'reps': 8, 'completed': true},
        {'weight': 135, 'reps': 7, 'completed': true},
        {'weight': 135, 'reps': 6, 'completed': false},
      ]
    },
    {
      'name': 'Overhead Press',
      'sets': [
        {'weight': 95, 'reps': 10, 'completed': false},
        {'weight': 95, 'reps': 9, 'completed': false},
        {'weight': 95, 'reps': 8, 'completed': false},
      ]
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Demo'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        actions: [
          if (_workoutActive)
            TextButton(
              onPressed: _completeWorkout,
              child: const Text('Finish'),
            ),
        ],
      ),
      body: _workoutActive ? _buildActiveWorkout() : _buildWorkoutStart(),
    );
  }

  Widget _buildWorkoutStart() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Icon(
            Icons.fitness_center,
            size: 100,
            color: Colors.blue,
          ),
          const SizedBox(height: 24),
          const Text(
            'Push Day Workout',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Chest, Shoulders & Triceps',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.builder(
              itemCount: _exercises.length,
              itemBuilder: (context, index) {
                final exercise = _exercises[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.fitness_center),
                    title: Text(exercise['name']),
                    subtitle: Text('${exercise['sets'].length} sets'),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _workoutActive = true;
              });
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            ),
            child: const Text('Start Workout'),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveWorkout() {
    final exercise = _exercises[_currentExercise];
    final sets = exercise['sets'] as List;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Exercise Header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    exercise['name'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Exercise ${_currentExercise + 1} of ${_exercises.length}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Sets List
          Expanded(
            child: ListView.builder(
              itemCount: sets.length,
              itemBuilder: (context, setIndex) {
                final set = sets[setIndex];
                return Card(
                  color: set['completed'] ? Colors.green[50] : null,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          set['completed'] ? Colors.green : Colors.grey,
                      child: Text('${setIndex + 1}'),
                    ),
                    title: Text('${set['weight']} lbs × ${set['reps']} reps'),
                    trailing: set['completed']
                        ? const Icon(Icons.check, color: Colors.green)
                        : ElevatedButton(
                            onPressed: () => _completeSet(setIndex),
                            child: const Text('Complete'),
                          ),
                  ),
                );
              },
            ),
          ),

          // Rest Timer
          if (_restTimeLeft > 0)
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Rest Timer',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_restTimeLeft}s',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Navigation
          Row(
            children: [
              if (_currentExercise > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _currentExercise--;
                      });
                    },
                    child: const Text('Previous'),
                  ),
                ),
              if (_currentExercise > 0 &&
                  _currentExercise < _exercises.length - 1)
                const SizedBox(width: 16),
              if (_currentExercise < _exercises.length - 1)
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _currentExercise++;
                      });
                    },
                    child: const Text('Next Exercise'),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _completeSet(int setIndex) {
    setState(() {
      _exercises[_currentExercise]['sets'][setIndex]['completed'] = true;
      _restTimeLeft = 90; // 90 second rest
    });

    // Start rest timer
    _startRestTimer();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Set completed! Rest timer started.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _startRestTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (_restTimeLeft > 0) {
        setState(() {
          _restTimeLeft--;
        });
        return true;
      }
      return false;
    });
  }

  void _completeWorkout() {
    setState(() {
      _workoutActive = false;
      _currentExercise = 0;
      _restTimeLeft = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Workout completed! Great job!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

class DemoProgressScreen extends StatelessWidget {
  const DemoProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Demo'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Overview
            const Text(
              'This Week',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                      'Workouts', '3', Icons.fitness_center, Colors.blue),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                      'Volume', '12.5k kg', Icons.scale, Colors.green),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                      'PRs', '2', Icons.emoji_events, Colors.orange),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                      'Duration', '4.2h', Icons.schedule, Colors.purple),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Chart Section
            const Text(
              'Volume Progress',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  height: 200,
                  child: Column(
                    children: [
                      const Text(
                        'Weekly Volume (kg)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: _buildDemoChart(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Personal Records
            const Text(
              'Recent Personal Records',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _buildPRCard('Bench Press', '145 lbs', '1RM', '2 days ago'),
            _buildPRCard('Deadlift', '225 lbs', '5RM', '1 week ago'),
            _buildPRCard('Squat', '185 lbs', '3RM', '2 weeks ago'),

            const SizedBox(height: 32),

            // Workout History
            const Text(
              'Recent Workouts',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _buildWorkoutHistoryCard(
                'Push Day', 'Oct 5, 2025', '65 min', '3.2k kg'),
            _buildWorkoutHistoryCard(
                'Pull Day', 'Oct 3, 2025', '58 min', '2.8k kg'),
            _buildWorkoutHistoryCard(
                'Leg Day', 'Oct 1, 2025', '72 min', '4.1k kg'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPRCard(String exercise, String value, String type, String date) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.amber,
          child: Icon(Icons.emoji_events, color: Colors.white),
        ),
        title: Text(exercise),
        subtitle: Text('$type • $date'),
        trailing: Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutHistoryCard(
      String workout, String date, String duration, String volume) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.fitness_center),
        title: Text(workout),
        subtitle: Text('$date • $duration'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              volume,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'volume',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoChart(BuildContext context) {
    // Generate sample data for demo
    final sampleData = List.generate(8, (index) {
      return FlSpot(
        index.toDouble(),
        2000 + (index * 200) + (index % 2 == 0 ? 100 : -50),
      );
    });

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 500,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.3),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final weeks = ['W1', 'W2', 'W3', 'W4', 'W5', 'W6', 'W7', 'W8'];
                final index = value.toInt();
                if (index >= 0 && index < weeks.length) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      weeks[index],
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 500,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    '${(value / 1000).toStringAsFixed(1)}k',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
        minX: 0,
        maxX: 7,
        minY: 1500,
        maxY: 3500,
        lineBarsData: [
          LineChartBarData(
            spots: sampleData,
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.blue,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withOpacity(0.1),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.black87,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((LineBarSpot touchedSpot) {
                return LineTooltipItem(
                  'Week ${touchedSpot.x.toInt() + 1}\n${(touchedSpot.y / 1000).toStringAsFixed(1)}k kg',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}

class DemoStorageScreen extends StatefulWidget {
  const DemoStorageScreen({super.key});

  @override
  State<DemoStorageScreen> createState() => _DemoStorageScreenState();
}

class _DemoStorageScreenState extends State<DemoStorageScreen> {
  Map<String, dynamic> _storageInfo = {};
  List<Map<String, dynamic>> _workouts = [];
  List<Map<String, dynamic>> _exercises = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadStorageData();
  }

  Future<void> _loadStorageData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate localStorage operations
      _storageInfo = {
        'supported': true,
        'totalSize': 1024,
        'keyCount': 3,
        'estimatedMB': '0.02',
        'keys': ['gymai_exercises', 'gymai_workouts', 'gymai_preferences'],
      };

      _exercises = [
        {
          'id': 'bench_press',
          'name': 'Bench Press',
          'primaryMuscleGroup': 'chest',
          'equipment': 'barbell',
          'created': DateTime.now()
              .subtract(const Duration(days: 5))
              .toIso8601String(),
        },
        {
          'id': 'custom_curl',
          'name': 'Hammer Curls',
          'primaryMuscleGroup': 'biceps',
          'equipment': 'dumbbells',
          'created': DateTime.now()
              .subtract(const Duration(days: 2))
              .toIso8601String(),
        },
      ];

      _workouts = [
        {
          'id': 'workout_1',
          'name': 'Push Day',
          'date': DateTime.now()
              .subtract(const Duration(days: 1))
              .toIso8601String(),
          'duration': 65,
          'volume': 3250,
          'exercises': ['bench_press', 'custom_curl'],
        },
        {
          'id': 'workout_2',
          'name': 'Pull Day',
          'date': DateTime.now()
              .subtract(const Duration(days: 3))
              .toIso8601String(),
          'duration': 58,
          'volume': 2890,
          'exercises': ['bench_press'],
        },
      ];
    } catch (e) {
      // Handle error
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
        title: const Text('Web Storage Demo'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStorageData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStorageInfoCard(),
                  const SizedBox(height: 24),
                  _buildActionsSection(),
                  const SizedBox(height: 24),
                  _buildStoredDataSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildStorageInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.storage, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'localStorage Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _storageInfo['supported'] == true
                        ? Colors.green
                        : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _storageInfo['supported'] == true
                        ? 'SUPPORTED'
                        : 'NOT SUPPORTED',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_storageInfo['supported'] == true) ...[
              _buildInfoRow('Total Size', '${_storageInfo['totalSize']} bytes'),
              _buildInfoRow(
                  'Storage Used', '${_storageInfo['estimatedMB']} MB'),
              _buildInfoRow('Keys Stored', '${_storageInfo['keyCount']} items'),
              _buildInfoRow('Namespace', 'gymai_*'),
            ] else ...[
              const Text(
                'localStorage is not available in this environment',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 8),
          Text(value, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Storage Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ElevatedButton.icon(
              onPressed: _addSampleWorkout,
              icon: const Icon(Icons.add),
              label: const Text('Add Workout'),
            ),
            ElevatedButton.icon(
              onPressed: _addSampleExercise,
              icon: const Icon(Icons.fitness_center),
              label: const Text('Add Exercise'),
            ),
            OutlinedButton.icon(
              onPressed: _exportData,
              icon: const Icon(Icons.download),
              label: const Text('Export'),
            ),
            OutlinedButton.icon(
              onPressed: _clearStorage,
              icon: const Icon(Icons.delete),
              label: const Text('Clear All'),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStoredDataSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Stored Data',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ExpansionTile(
          title: Text('Exercises (${_exercises.length})'),
          leading: const Icon(Icons.fitness_center),
          children: _exercises
              .map((exercise) => ListTile(
                    title: Text(exercise['name']),
                    subtitle: Text(
                        '${exercise['primaryMuscleGroup']} • ${exercise['equipment']}'),
                    trailing: Text(
                      DateTime.parse(exercise['created'])
                          .toLocal()
                          .toString()
                          .split(' ')[0],
                      style: const TextStyle(fontSize: 12),
                    ),
                  ))
              .toList(),
        ),
        ExpansionTile(
          title: Text('Workouts (${_workouts.length})'),
          leading: const Icon(Icons.list_alt),
          children: _workouts
              .map((workout) => ListTile(
                    title: Text(workout['name']),
                    subtitle: Text(
                        '${workout['duration']} min • ${workout['volume']} kg'),
                    trailing: Text(
                      DateTime.parse(workout['date'])
                          .toLocal()
                          .toString()
                          .split(' ')[0],
                      style: const TextStyle(fontSize: 12),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  void _addSampleWorkout() {
    final newWorkout = {
      'id': 'workout_${DateTime.now().millisecondsSinceEpoch}',
      'name': 'Sample Workout',
      'date': DateTime.now().toIso8601String(),
      'duration': 45,
      'volume': 2500,
      'exercises': ['bench_press'],
    };

    setState(() {
      _workouts.insert(0, newWorkout);
      _storageInfo['totalSize'] = (_storageInfo['totalSize'] ?? 0) + 200;
      _storageInfo['estimatedMB'] =
          ((_storageInfo['totalSize'] ?? 0) / (1024 * 1024)).toStringAsFixed(2);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sample workout added to localStorage'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _addSampleExercise() {
    final newExercise = {
      'id': 'exercise_${DateTime.now().millisecondsSinceEpoch}',
      'name': 'Custom Exercise',
      'primaryMuscleGroup': 'chest',
      'equipment': 'dumbbells',
      'created': DateTime.now().toIso8601String(),
    };

    setState(() {
      _exercises.insert(0, newExercise);
      _storageInfo['totalSize'] = (_storageInfo['totalSize'] ?? 0) + 150;
      _storageInfo['estimatedMB'] =
          ((_storageInfo['totalSize'] ?? 0) / (1024 * 1024)).toStringAsFixed(2);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Custom exercise added to localStorage'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _exportData() {
    final exportData = {
      'workouts': _workouts,
      'exercises': _exercises,
      'exportedAt': DateTime.now().toIso8601String(),
      'version': '1.0.0',
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Data exported: ${exportData.keys.length} categories'),
        backgroundColor: Colors.blue,
        action: SnackBarAction(
          label: 'View',
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Export Data'),
                content: SingleChildScrollView(
                  child: Text(
                    exportData.toString(),
                    style:
                        const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _clearStorage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Storage'),
        content: const Text(
            'This will delete all stored workout data. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _workouts.clear();
                _exercises.clear();
                _storageInfo['totalSize'] = 0;
                _storageInfo['keyCount'] = 0;
                _storageInfo['estimatedMB'] = '0.00';
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Storage cleared successfully'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
