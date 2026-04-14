import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nuticare/core/theme.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:nuticare/screens/ai_chatbot_screen.dart';
import 'package:nuticare/screens/user_data_dashboard_screen.dart';
import 'package:nuticare/screens/nutrition_screen.dart';
import 'package:nuticare/screens/workout_screen.dart';
import 'package:nuticare/screens/enhanced_medicine_screen.dart';
import 'package:nuticare/screens/health_report_upload_screen.dart';
import 'package:nuticare/screens/meal_planner_screen.dart';
import 'package:nuticare/services/daily_nutrition_service.dart';
// ✨ ADVANCED UI/UX IMPORTS
import 'package:nuticare/core/design/premium_colors.dart';
import 'package:nuticare/core/design/premium_typography.dart';
import 'package:nuticare/core/animations/premium_animations.dart';
import 'package:nuticare/core/animations/page_transitions.dart';
import 'package:nuticare/widgets/premium_glass_card.dart';
import 'package:nuticare/widgets/animated_gradient_button.dart';
import 'package:nuticare/widgets/animated_widget_variants.dart';
import 'package:nuticare/widgets/premium_stats_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color _aiBlue = Color(0xFF0B6E99);

  bool _onboardingChecked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowOnboarding();
    });
  }

  Future<void> _checkAndShowOnboarding() async {
    if (_onboardingChecked) return;
    _onboardingChecked = true;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final doc = await docRef.get();
      final data = doc.data();
      final seen = data?['homeAiOnboardingSeen'] == true;

      if (seen || !mounted) return;

      await _showOnboardingDialog();

      await docRef.set({'homeAiOnboardingSeen': true}, SetOptions(merge: true));
    } catch (_) {
      // Keep UI resilient; onboarding is optional.
    }
  }

  Future<void> _showOnboardingDialog() async {
    await showGeneralDialog(
      context: context,
      barrierLabel: 'AI onboarding',
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 22),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: NutriTheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _aiBlue.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Welcome to AI Personalization',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Use Quick Launch to jump directly into Nutrition, Medicine, Fitness, Health Insights, Meal Planner, and AI Chat.',
                  style: TextStyle(
                    color: Colors.grey.shade300,
                    height: 1.4,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: NutriTheme.primary,
                      foregroundColor: Colors.black,
                    ),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Got it'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutBack);
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: Tween<double>(begin: 0.92, end: 1).animate(curved), child: child),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final String greeting = _getGreeting();

    return Scaffold(
      backgroundColor: NutriTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🟢 Header & Profile
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(greeting,
                            style: NutriTheme.textTheme.bodyLarge
                                ?.copyWith(color: Colors.grey)),
                        StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(user?.uid)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData || !snapshot.data!.exists) {
                              return Text("Friend",
                                  style: NutriTheme.textTheme.displayMedium);
                            }
                            final data =
                                snapshot.data!.data() as Map<String, dynamic>?;
                            final name = data?['name'] ?? 'Friend';
                            return Text(name,
                                style: NutriTheme.textTheme.displayMedium);
                          },
                        ),
                      ],
                    ),
                  ),
                  // Actions Row
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // AI Chat Button
                      GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const AIChatbotScreen())),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: NutriTheme.surface,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: NutriTheme.primary.withValues(alpha: 0.5)),
                          ),
                          child: const Icon(Icons.psychology,
                              color: NutriTheme.primary, size: 20),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Data Dashboard Button
                      GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const UserDataDashboardScreen())),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: NutriTheme.surface,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.green.withValues(alpha: 0.5)),
                          ),
                          child: const Icon(Icons.storage,
                              color: Colors.green, size: 20),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 🟢 Motivational Quote (Placeholder for AI)
              PremiumGlassCard(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.format_quote_rounded,
                        color: NutriTheme.primary, size: 30),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Your body can stand almost anything. It’s your mind that you have to convince.",
                        style: NutriTheme.textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: Colors.white, // White for contrast
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              _buildQuickLaunchRow(context),
              const SizedBox(height: 30),

              // 🟢 Today's Calorie Goal (Main Ring) - Real-time data
              StreamBuilder<Map<String, dynamic>?>(
                stream: DailyNutritionService.watchTodayData(),
                builder: (context, nutritionSnapshot) {
                  // Calculate calories eaten from real-time service
                  int caloriesEaten = 0;
                  if (nutritionSnapshot.hasData && nutritionSnapshot.data != null) {
                    caloriesEaten = (nutritionSnapshot.data!['totalCalories'] as num?)?.toInt() ?? 0;
                  }

                  // Get calories burned from workouts
                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(user?.uid ?? '')
                        .collection('workouts')
                        .where('startTime',
                            isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime(
                                DateTime.now().year,
                                DateTime.now().month,
                                DateTime.now().day)))
                        .snapshots(),
                    builder: (context, workoutSnapshot) {
                      int caloriesBurned = 0;
                      if (workoutSnapshot.hasData) {
                        for (var doc in workoutSnapshot.data!.docs) {
                          final data = doc.data() as Map<String, dynamic>;
                          final burned = data['caloriesBurned'];
                          caloriesBurned += (burned as num?)?.toInt() ?? 0;
                        }
                      }

                      const goalCalories = 2000;
                      final caloriesLeft =
                          goalCalories - caloriesEaten + caloriesBurned;
                      final progress = caloriesEaten / goalCalories;

                      return Center(
                        child: CircularPercentIndicator(
                          radius: 120.0,
                          lineWidth: 18.0,
                          animation: true,
                          percent: progress.clamp(0.0, 1.0),
                          center: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.local_fire_department_rounded,
                                  color: Colors.orange, size: 32),
                              const SizedBox(height: 4),
                              Text("$caloriesLeft",
                                  style: NutriTheme.textTheme.displayLarge
                                      ?.copyWith(
                                          fontSize: 40, color: Colors.white)),
                              Text("kcal left",
                                  style: NutriTheme.textTheme.bodyMedium
                                      ?.copyWith(color: Colors.grey)),
                            ],
                          ),
                          circularStrokeCap: CircularStrokeCap.round,
                          backgroundColor: Colors.grey.withValues(alpha: 0.1),
                          progressColor: NutriTheme.primary,
                          footer: Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildStatItem("Eaten", "$caloriesEaten",
                                    Icons.restaurant, Colors.white),
                                _buildStatItem("Burned", "$caloriesBurned",
                                    Icons.directions_run, Colors.white),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 30),

              // 🟢 AI Assistant Info Card
              PremiumGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: NutriTheme.primary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.smart_toy_outlined,
                              color: NutriTheme.primary, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("AI Assistant",
                                  style: NutriTheme.textTheme.bodyLarge
                                      ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                              const SizedBox(height: 2),
                              Text("Your personal health guide",
                                  style: NutriTheme.textTheme.bodySmall
                                      ?.copyWith(color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(color: Colors.white12),
                    const SizedBox(height: 12),
                    Text(
                      "I can help you with:",
                      style: NutriTheme.textTheme.bodyMedium
                          ?.copyWith(color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    _buildAIFeature(
                        "📊 Nutrition Analysis",
                        "Analyze food & get detailed nutrition breakdown"),
                    const SizedBox(height: 8),
                    _buildAIFeature(
                        "💊 Medicine Info",
                        "Check interactions & get medicine recommendations"),
                    const SizedBox(height: 8),
                    _buildAIFeature(
                        "🏋️ Workout Plans",
                        "Get personalized workout & fitness guidance"),
                    const SizedBox(height: 8),
                    _buildAIFeature(
                        "🥗 Meal Planning",
                        "Create healthy meal plans based on your goals"),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: NutriTheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AIChatbotScreen(),
                          ),
                        ),
                        child: const Text(
                          "Chat with AI",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // 🟢 Quick Stats Row - Real-time streak
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user?.uid ?? '')
                    .collection('streaks')
                    .doc('current')
                    .snapshots(),
                builder: (context, streakSnapshot) {
                  int currentStreak = 0;
                  if (streakSnapshot.hasData && streakSnapshot.data!.exists) {
                    currentStreak = (streakSnapshot.data!.data()
                            as Map<String, dynamic>)['currentStreak'] ??
                        0;
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildQuickStatCard(
                          "Steps", "--", Icons.directions_walk, Colors.blue),
                      _buildQuickStatCard(
                          "Active", "--", Icons.timer, Colors.purple),
                      _buildQuickStatCard("Streak", "🔥 $currentStreak",
                          Icons.emoji_events, Colors.orange),
                    ],
                  );
                },
              ),
              const SizedBox(height: 30),

              // 🟢 Daily Summary Cards
              Text("Daily Summary",
                  style: NutriTheme.textTheme.displayMedium
                      ?.copyWith(fontSize: 20)),
              const SizedBox(height: 15),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user?.uid ?? '')
                    .collection('workouts')
                    .orderBy('startTime', descending: true)
                    .limit(1)
                    .snapshots(),
                builder: (context, workoutSnapshot) {
                  String lastWorkoutText = "No workout yet";
                  if (workoutSnapshot.hasData && workoutSnapshot.data!.docs.isNotEmpty) {
                    final data = workoutSnapshot.data!.docs.first.data() as Map<String, dynamic>;
                    final workoutType = data['workoutType'] ?? 'Workout';
                    final duration = data['duration'] ?? 0;
                    lastWorkoutText = "$workoutType • ${duration}m";
                  }
                  
                  return SizedBox(
                    height: 140,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildSummaryCard(
                            "Last Workout", lastWorkoutText, Icons.fitness_center),
                        _buildSummaryCard(
                            "Hydration", "Track in app", Icons.water_drop),
                        _buildSummaryCard("Sleep", "Track in app", Icons.bed),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 80), // Bottom padding for FAB
            ],
          ),
        ),
      ),
      floatingActionButton: null, // Removed as requested
    );
  }

  String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning,";
    if (hour < 17) return "Good Afternoon,";
    return "Good Evening,";
  }

  Widget _buildQuickLaunchRow(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Launch',
          style: NutriTheme.textTheme.bodyLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 92,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _quickLaunchItem(
                icon: Icons.psychology,
                label: 'AI Chat',
                color: const Color(0xFF2B5E9D),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AIChatbotScreen()),
                ),
              ),
              _quickLaunchItem(
                icon: Icons.restaurant_menu,
                label: 'Nutrition',
                color: const Color(0xFF1D8B63),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NutritionScreen()),
                ),
              ),
              _quickLaunchItem(
                icon: Icons.medication,
                label: 'Medicine',
                color: const Color(0xFF2766C4),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EnhancedMedicineScreen()),
                ),
              ),
              _quickLaunchItem(
                icon: Icons.fitness_center,
                label: 'Fitness',
                color: const Color(0xFFCC7A12),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WorkoutScreen()),
                ),
              ),
              _quickLaunchItem(
                icon: Icons.insights,
                label: 'Health',
                color: const Color(0xFF8A49C2),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HealthReportUploadScreen()),
                ),
              ),
              _quickLaunchItem(
                icon: Icons.calendar_view_week,
                label: 'Meal Plan',
                color: const Color(0xFF0B6E99),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MealPlannerScreen()),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _quickLaunchItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 84,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.45)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 18, color: color)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildQuickStatCard(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: NutriTheme.surface, // Dark Surface
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white)),
            Text(label,
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String subtitle, IconData icon) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NutriTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, size: 28, color: Colors.white),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 4),
              Text(subtitle,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAIFeature(String title, String description) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
          const SizedBox(height: 2),
          Text(description,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
        ],
      ),
    );
  }
}
