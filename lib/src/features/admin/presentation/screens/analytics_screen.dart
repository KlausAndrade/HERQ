import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedTimeRange = '7d';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
            Tab(text: 'Users', icon: Icon(Icons.people)),
            Tab(text: 'Content', icon: Icon(Icons.post_add)),
            Tab(text: 'Performance', icon: Icon(Icons.speed)),
          ],
        ),
        actions: [
          DropdownButton<String>(
            value: _selectedTimeRange,
            items: const [
              DropdownMenuItem(value: '24h', child: Text('24h')),
              DropdownMenuItem(value: '7d', child: Text('7d')),
              DropdownMenuItem(value: '30d', child: Text('30d')),
              DropdownMenuItem(value: '90d', child: Text('90d')),
              DropdownMenuItem(value: '1y', child: Text('1y')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedTimeRange = value!;
              });
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _OverviewTab(timeRange: _selectedTimeRange),
          _UsersTab(timeRange: _selectedTimeRange),
          _ContentTab(timeRange: _selectedTimeRange),
          _PerformanceTab(timeRange: _selectedTimeRange),
        ],
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final String timeRange;

  const _OverviewTab({required this.timeRange});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Key Metrics
          _buildKeyMetrics(context),
          const SizedBox(height: 24),
          
          // Charts Row
          Row(
            children: [
              Expanded(
                child: _buildUserGrowthChart(context),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActivityChart(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Recent Activity
          _buildRecentActivity(context),
        ],
      ),
    );
  }

  Widget _buildKeyMetrics(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            title: 'Total Users',
            value: '1,234',
            change: '+12%',
            icon: Icons.people,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MetricCard(
            title: 'Active Users',
            value: '456',
            change: '+8%',
            icon: Icons.trending_up,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MetricCard(
            title: 'Posts Today',
            value: '89',
            change: '+15%',
            icon: Icons.post_add,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MetricCard(
            title: 'Workouts',
            value: '234',
            change: '+22%',
            icon: Icons.fitness_center,
            color: Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildUserGrowthChart(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Growth',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const titles = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                          return Text(titles[value.toInt() % titles.length]);
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 100),
                        FlSpot(1, 120),
                        FlSpot(2, 110),
                        FlSpot(3, 140),
                        FlSpot(4, 160),
                        FlSpot(5, 150),
                        FlSpot(6, 180),
                      ],
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityChart(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Activity',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: 40,
                      title: 'Workouts',
                      color: Colors.blue,
                      radius: 60,
                    ),
                    PieChartSectionData(
                      value: 30,
                      title: 'Posts',
                      color: Colors.green,
                      radius: 60,
                    ),
                    PieChartSectionData(
                      value: 20,
                      title: 'Comments',
                      color: Colors.orange,
                      radius: 60,
                    ),
                    PieChartSectionData(
                      value: 10,
                      title: 'Likes',
                      color: Colors.purple,
                      radius: 60,
                    ),
                  ],
                  centerSpaceRadius: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _ActivityItem(
              icon: Icons.person_add,
              title: 'New user registered',
              subtitle: 'john.doe@example.com',
              time: '2 minutes ago',
            ),
            _ActivityItem(
              icon: Icons.fitness_center,
              title: 'Workout completed',
              subtitle: 'User completed "Push Day"',
              time: '5 minutes ago',
            ),
            _ActivityItem(
              icon: Icons.post_add,
              title: 'New post created',
              subtitle: 'User shared workout progress',
              time: '8 minutes ago',
            ),
            _ActivityItem(
              icon: Icons.comment,
              title: 'Comment added',
              subtitle: 'User commented on a post',
              time: '12 minutes ago',
            ),
          ],
        ),
      ),
    );
  }
}

class _UsersTab extends StatelessWidget {
  final String timeRange;

  const _UsersTab({required this.timeRange});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Metrics
          _buildUserMetrics(context),
          const SizedBox(height: 24),
          
          // User Growth Chart
          _buildUserGrowthChart(context),
          const SizedBox(height: 24),
          
          // User Demographics
          _buildUserDemographics(context),
        ],
      ),
    );
  }

  Widget _buildUserMetrics(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          // Mobile: 2x2 grid
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      title: 'New Users',
                      value: '45',
                      change: '+12%',
                      icon: Icons.person_add,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MetricCard(
                      title: 'Active Users',
                      value: '456',
                      change: '+8%',
                      icon: Icons.trending_up,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      title: 'Retention',
                      value: '78%',
                      change: '+5%',
                      icon: Icons.repeat,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MetricCard(
                      title: 'Churn Rate',
                      value: '3.2%',
                      change: '-1%',
                      icon: Icons.trending_down,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          );
        } else {
          // Desktop: 4 columns
          return Row(
            children: [
              Expanded(
                child: _MetricCard(
                  title: 'New Users',
                  value: '45',
                  change: '+12%',
                  icon: Icons.person_add,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  title: 'Active Users',
                  value: '456',
                  change: '+8%',
                  icon: Icons.trending_up,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  title: 'Retention',
                  value: '78%',
                  change: '+5%',
                  icon: Icons.repeat,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  title: 'Churn Rate',
                  value: '3.2%',
                  change: '-1%',
                  icon: Icons.trending_down,
                  color: Colors.red,
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildUserGrowthChart(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Growth Over Time',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toInt().toString());
                        },
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const titles = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                          return Text(titles[value.toInt() % titles.length]);
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 100),
                        FlSpot(1, 150),
                        FlSpot(2, 200),
                        FlSpot(3, 180),
                        FlSpot(4, 250),
                        FlSpot(5, 300),
                      ],
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserDemographics(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Demographics',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _DemographicCard(
                    title: 'Age Groups',
                    data: const [
                      {'label': '18-25', 'value': 35, 'color': Colors.blue},
                      {'label': '26-35', 'value': 40, 'color': Colors.green},
                      {'label': '36-45', 'value': 20, 'color': Colors.orange},
                      {'label': '45+', 'value': 5, 'color': Colors.red},
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _DemographicCard(
                    title: 'Gender',
                    data: const [
                      {'label': 'Male', 'value': 60, 'color': Colors.blue},
                      {'label': 'Female', 'value': 35, 'color': Colors.pink},
                      {'label': 'Other', 'value': 5, 'color': Colors.purple},
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ContentTab extends StatelessWidget {
  final String timeRange;

  const _ContentTab({required this.timeRange});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Content Metrics
          _buildContentMetrics(context),
          const SizedBox(height: 24),
          
          // Content Types Chart
          _buildContentTypesChart(context),
          const SizedBox(height: 24),
          
          // Top Content
          _buildTopContent(context),
        ],
      ),
    );
  }

  Widget _buildContentMetrics(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            title: 'Total Posts',
            value: '2,456',
            change: '+15%',
            icon: Icons.post_add,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MetricCard(
            title: 'Comments',
            value: '8,234',
            change: '+22%',
            icon: Icons.comment,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MetricCard(
            title: 'Likes',
            value: '15,678',
            change: '+18%',
            icon: Icons.favorite,
            color: Colors.red,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MetricCard(
            title: 'Shares',
            value: '1,234',
            change: '+25%',
            icon: Icons.share,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildContentTypesChart(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Content Types',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}%');
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const titles = ['Posts', 'Comments', 'Likes', 'Shares'];
                          return Text(titles[value.toInt() % titles.length]);
                        },
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 80, color: Colors.blue)]),
                    BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 60, color: Colors.green)]),
                    BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 90, color: Colors.red)]),
                    BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 40, color: Colors.orange)]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopContent(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Content',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _TopContentItem(
              title: 'Amazing workout today!',
              author: 'John Doe',
              likes: 45,
              comments: 12,
              shares: 8,
            ),
            _TopContentItem(
              title: 'New PR on bench press!',
              author: 'Jane Smith',
              likes: 38,
              comments: 15,
              shares: 5,
            ),
            _TopContentItem(
              title: 'Motivational Monday',
              author: 'Bob Wilson',
              likes: 42,
              comments: 8,
              shares: 12,
            ),
          ],
        ),
      ),
    );
  }
}

class _PerformanceTab extends StatelessWidget {
  final String timeRange;

  const _PerformanceTab({required this.timeRange});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Performance Metrics
          _buildPerformanceMetrics(context),
          const SizedBox(height: 24),
          
          // Performance Charts
          _buildPerformanceCharts(context),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetrics(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            title: 'Response Time',
            value: '120ms',
            change: '-5%',
            icon: Icons.speed,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MetricCard(
            title: 'Uptime',
            value: '99.9%',
            change: '+0.1%',
            icon: Icons.check_circle,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MetricCard(
            title: 'Error Rate',
            value: '0.1%',
            change: '-0.2%',
            icon: Icons.error,
            color: Colors.red,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MetricCard(
            title: 'CPU Usage',
            value: '45%',
            change: '+2%',
            icon: Icons.memory,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceCharts(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Response Time',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: true),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Text('${value.toInt()}ms');
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                const titles = ['00:00', '04:00', '08:00', '12:00', '16:00', '20:00'];
                                return Text(titles[value.toInt() % titles.length]);
                              },
                            ),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: true),
                        lineBarsData: [
                          LineChartBarData(
                            spots: const [
                              FlSpot(0, 100),
                              FlSpot(1, 120),
                              FlSpot(2, 110),
                              FlSpot(3, 130),
                              FlSpot(4, 125),
                              FlSpot(5, 115),
                            ],
                            isCurved: true,
                            color: Colors.blue,
                            barWidth: 3,
                            dotData: FlDotData(show: true),
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
        const SizedBox(width: 16),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'System Health',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _HealthIndicator(
                    title: 'Database',
                    value: 95,
                    color: Colors.green,
                  ),
                  _HealthIndicator(
                    title: 'API',
                    value: 88,
                    color: Colors.orange,
                  ),
                  _HealthIndicator(
                    title: 'Storage',
                    value: 92,
                    color: Colors.green,
                  ),
                  _HealthIndicator(
                    title: 'Cache',
                    value: 85,
                    color: Colors.orange,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String change;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.change,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              change,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: change.startsWith('+') ? Colors.green : Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;

  const _ActivityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _DemographicCard extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> data;

  const _DemographicCard({
    required this.title,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...data.map((item) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                color: item['color'],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(item['label']),
              ),
              Text('${item['value']}%'),
            ],
          ),
        )),
      ],
    );
  }
}

class _TopContentItem extends StatelessWidget {
  final String title;
  final String author;
  final int likes;
  final int comments;
  final int shares;

  const _TopContentItem({
    required this.title,
    required this.author,
    required this.likes,
    required this.comments,
    required this.shares,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'by $author',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Icon(Icons.favorite, size: 16, color: Colors.red),
              const SizedBox(width: 4),
              Text('$likes'),
              const SizedBox(width: 16),
              Icon(Icons.comment, size: 16, color: Colors.blue),
              const SizedBox(width: 4),
              Text('$comments'),
              const SizedBox(width: 16),
              Icon(Icons.share, size: 16, color: Colors.green),
              const SizedBox(width: 4),
              Text('$shares'),
            ],
          ),
        ],
      ),
    );
  }
}

class _HealthIndicator extends StatelessWidget {
  final String title;
  final int value;
  final Color color;

  const _HealthIndicator({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(title),
          ),
          SizedBox(
            width: 100,
            child: LinearProgressIndicator(
              value: value / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(width: 8),
          Text('$value%'),
        ],
      ),
    );
  }
}
