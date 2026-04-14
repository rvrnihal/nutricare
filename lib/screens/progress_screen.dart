import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:nuticare/core/theme.dart';
import 'package:nuticare/components/glass_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fireController;
  int _currentStreak = 0;
  int _longestStreak = 0;

  @override
  void initState() {
    super.initState();
    _fireController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _loadStreakData();
  }

  @override
  void dispose() {
    _fireController.dispose();
    super.dispose();
  }

  Future<void> _loadStreakData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('streaks')
          .doc('current')
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _currentStreak = data['currentStreak'] ?? 0;
          _longestStreak = data['longestStreak'] ?? 0;
        });
      } else {
        // Initialize streak
        await _updateStreak(0, 0);
      }
    } catch (e) {
      print('Error loading streak: $e');
    }
  }

  Future<void> _updateStreak(int current, int longest) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('streaks')
        .doc('current')
        .set({
      'currentStreak': current,
      'longestStreak': longest,
      'lastUpdated': FieldValue.serverTimestamp(),
    });

    setState(() {
      _currentStreak = current;
      _longestStreak = longest;
    });
  }

  // Simulate logging activity (can be called when user does workout, logs meal, etc.)
  Future<void> _incrementStreak() async {
    final newStreak = _currentStreak + 1;
    final newLongest = newStreak > _longestStreak ? newStreak : _longestStreak;
    await _updateStreak(newStreak, newLongest);

    if (mounted) {
      _showStreakCelebration();
    }
  }

  void _showStreakCelebration() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: NutriTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.celebration, color: Colors.amber, size: 64),
            const SizedBox(height: 16),
            Text(
              '🔥 $_currentStreak Day Streak!',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getMotivationalMessage(_currentStreak),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade400),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Awesome!',
                style: TextStyle(color: NutriTheme.primary)),
          ),
        ],
      ),
    );
  }

  String _getMotivationalMessage(int streak) {
    if (streak >= 30) return "Legend status! 🏆 You're unstoppable!";
    if (streak >= 21) return "Habit formed! 💪 This is your lifestyle now!";
    if (streak >= 14) return "Two weeks strong! 🌟 Keep crushing it!";
    if (streak >= 7) return "One week streak! 🎯 You're on fire!";
    if (streak >= 3) return "Three days in a row! 🚀 Momentum building!";
    return "Great start! 🌱 Keep going!";
  }

  Color _getStreakColor(int streak) {
    if (streak >= 30) return Colors.purple;
    if (streak >= 21) return Colors.amber;
    if (streak >= 14) return Colors.orange;
    if (streak >= 7) return Colors.red;
    return NutriTheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final streakColor = _getStreakColor(_currentStreak);

    return Scaffold(
      backgroundColor: NutriTheme.background,
      appBar: AppBar(
        title: Text("Your Progress", style: NutriTheme.textTheme.displayMedium),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Quick increment button for testing
          IconButton(
            icon: const Icon(Icons.add_circle, color: NutriTheme.primary),
            onPressed: _incrementStreak,
            tooltip: 'Log Activity (Test)',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔥 STREAK CARD (Main Feature)
            AnimatedBuilder(
              animation: _fireController,
              builder: (context, child) {
                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        streakColor.withValues(alpha: 0.2),
                        streakColor.withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                        color: streakColor.withValues(alpha: 0.3), width: 2),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Transform.scale(
                            scale: 1 + (_fireController.value * 0.1),
                            child: Text(
                              '🔥',
                              style: TextStyle(
                                fontSize: 48 + (_fireController.value * 8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$_currentStreak Day Streak!',
                                style: TextStyle(
                                  color: streakColor,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Keep the momentum going!',
                                style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStreakStat(
                              'Current', _currentStreak, streakColor),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.grey.shade800,
                          ),
                          _buildStreakStat(
                            'Best',
                            _longestStreak,
                            Colors.amber,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // 🎯 STREAK MILESTONES
            Text(
              "Streak Milestones",
              style: NutriTheme.textTheme.displayMedium?.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildMilestone(3, '🌱', 'Starter', _currentStreak >= 3),
                  _buildMilestone(7, '🔥', 'On Fire', _currentStreak >= 7),
                  _buildMilestone(14, '💪', 'Committed', _currentStreak >= 14),
                  _buildMilestone(
                      21, '⭐', 'Habit Master', _currentStreak >= 21),
                  _buildMilestone(30, '👑', 'Legend', _currentStreak >= 30),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // 🟢 Level Header
            GlassCard(
              child: Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(
                          value: (_currentStreak % 10) / 10,
                          backgroundColor: Colors.grey,
                          color: NutriTheme.primary,
                          strokeWidth: 6,
                        ),
                      ),
                      Text(
                        "Lvl ${(_currentStreak ~/ 10) + 1}",
                        style: NutriTheme.textTheme.bodyLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Fitness ${_currentStreak >= 21 ? 'Champion' : 'Enthusiast'}",
                          style: NutriTheme.textTheme.displayMedium
                              ?.copyWith(fontSize: 18),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${_currentStreak % 10} / 10 days to Level ${((_currentStreak ~/ 10) + 2)}",
                          style: NutriTheme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // 🟢 Weight Trend Chart
            Text(
              "Weight Trend",
              style: NutriTheme.textTheme.displayMedium?.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 16),
            Container(
              height: 250,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: NutriTheme.surface,
                borderRadius: BorderRadius.circular(24),
              ),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          switch (value.toInt()) {
                            case 0:
                              return const Text('Mon');
                            case 2:
                              return const Text('Wed');
                            case 4:
                              return const Text('Fri');
                            case 6:
                              return const Text('Sun');
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        const FlSpot(0, 75),
                        const FlSpot(1, 74.8),
                        const FlSpot(2, 74.5),
                        const FlSpot(3, 74.2),
                        const FlSpot(4, 73.9),
                        const FlSpot(5, 73.5),
                        const FlSpot(6, 73.2),
                      ],
                      isCurved: true,
                      color: NutriTheme.primary,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: NutriTheme.primary.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // 🟢 Achievements
            Text(
              "Achievements",
              style: NutriTheme.textTheme.displayMedium?.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildBadge("Early Bird", Icons.wb_sunny, Colors.orange,
                    _currentStreak >= 7),
                _buildBadge("Marathoner", Icons.directions_run, Colors.blue,
                    _currentStreak >= 14),
                _buildBadge("Iron Pumper", Icons.fitness_center, Colors.purple,
                    _currentStreak >= 21),
                _buildBadge("Streak Master", Icons.local_fire_department,
                    Colors.red, _currentStreak >= 3),
                _buildBadge(
                    "Hydrated", Icons.water_drop, Colors.blueAccent, false),
                _buildBadge("Goal Crusher", Icons.emoji_events, Colors.yellow,
                    _currentStreak >= 30),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakStat(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            color: color,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildMilestone(int days, String emoji, String title, bool achieved) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: achieved
            ? NutriTheme.primary.withValues(alpha: 0.2)
            : Colors.grey.shade900,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: achieved ? NutriTheme.primary : Colors.grey.shade800,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            emoji,
            style: TextStyle(
              fontSize: 32,
              color: achieved ? Colors.white : Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$days days',
            style: TextStyle(
              color: achieved ? NutriTheme.primary : Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: achieved ? Colors.white : Colors.grey.shade600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, IconData icon, Color color, bool unlocked) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: unlocked ? color.withValues(alpha: 0.1) : Colors.grey.shade900,
            shape: BoxShape.circle,
            border: Border.all(
              color: unlocked ? color : Colors.grey.shade800,
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            color: unlocked ? color : Colors.grey,
            size: 32,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: unlocked ? Colors.white : Colors.grey,
            fontWeight: unlocked ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
