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
// ✨ ADVANCED UI/UX IMPORTS - PROFESSIONAL DESIGN SYSTEM
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
      // Keep UI resilient
    }
  }

  Future<void> _showOnboardingDialog() async {
    await showGeneralDialog(
      context: context,
      barrierLabel: 'AI onboarding',
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.45),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: ScaleInAnimation(
            duration: AnimationDurations.standard,
            child: PremiumGlassCard(
              margin: const EdgeInsets.symmetric(horizontal: 22),
              gradient: PremiumColors.blueGradient,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: PremiumColors.primaryGradient,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Welcome to AI Personalization',
                          style: PremiumTypography.titleLarge.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Use Quick Launch to jump directly into Nutrition, Medicine, Fitness, Health Insights, Meal Planner, and AI Chat.',
                    style: PremiumTypography.bodySmall.copyWith(
                      color: Colors.grey.shade300,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerRight,
                    child: AnimatedGradientButton(
                      onPressed: () => Navigator.pop(context),
                      label: 'Got it',
                      gradient: PremiumColors.primaryGradient,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final String greeting = _getGreeting();

    return Scaffold(
      backgroundColor: PremiumColors.darkLuxury,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✨ ANIMATED HEADER WITH PREMIUM COLORS & GRADIENTS
              FadeInAnimation(
                duration: AnimationDurations.standard,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            greeting,
                            style: PremiumTypography.bodyMedium.copyWith(
                              color: PremiumColors.mutedText,
                            ),
                          ),
                          StreamBuilder<DocumentSnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .doc(user?.uid)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData || !snapshot.data!.exists) {
                                return Text("Friend",
                                    style: PremiumTypography.headlineSmall);
                              }
                              final data = snapshot.data!.data()
                                  as Map<String, dynamic>?;
                              final name = data?['name'] ?? 'Friend';
                              return Text(
                                name,
                                style: PremiumTypography.headlineSmall,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    // ✨ PREMIUM ACTION BUTTONS WITH SCALE ANIMATIONS
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ScaleInAnimation(
                          duration: AnimationDurations.standard,
                          child: GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              SlidePageRoute(
                                page: const AIChatbotScreen(),
                                direction: SlideDirection.up,
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: PremiumColors.primaryGradient,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: PremiumColors.primaryNeon
                                        .withOpacity(0.4),
                                    blurRadius: 16,
                                    spreadRadius: 3,
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.psychology,
                                  color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ScaleInAnimation(
                          duration: Duration(
                            milliseconds: AnimationDurations.standard.inMilliseconds + 100,
                          ),
                          child: GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              SlidePageRoute(
                                page: const UserDataDashboardScreen(),
                                direction: SlideDirection.up,
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: PremiumColors.teakGradient,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: PremiumColors.accentTeal
                                        .withOpacity(0.4),
                                    blurRadius: 16,
                                    spreadRadius: 3,
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.storage,
                                  color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ✨ ANIMATED MOTIVATIONAL GLASS CARD WITH GRADIENT
              SlideInAnimation(
                direction: SlideDirection.right,
                duration: AnimationDurations.standard,
                child: PremiumGlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  gradient: PremiumColors.primaryGradient,
                  borderRadius: 20,
                  child: Row(
                    children: [
                      const Icon(Icons.format_quote_rounded,
                          color: Color(0xFF76FF03), size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Your body can stand almost anything. It's your mind that you have to convince.",
                          style: PremiumTypography.bodySmall.copyWith(
                            fontStyle: FontStyle.italic,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // ✨ QUICK LAUNCH WITH STAGGERED ANIMATIONS
              _buildAnimatedQuickLaunchRow(context),
              const SizedBox(height: 30),

              // ✨ TODAY'S CALORIE GOAL WITH ANIMATIONS
              FadeInAnimation(
                duration: AnimationDurations.standard,
                child: StreamBuilder<Map<String, dynamic>?>(
                  stream: DailyNutritionService.watchTodayData(),
                  builder: (context, nutritionSnapshot) {
                    int caloriesEaten = 0;
                    if (nutritionSnapshot.hasData &&
                        nutritionSnapshot.data != null) {
                      caloriesEaten =
                          (nutritionSnapshot.data!['totalCalories'] as num?)
                                  ?.toInt() ??
                              0;
                    }

                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(user?.uid ?? '')
                          .collection('workouts')
                          .where('startTime',
                              isGreaterThanOrEqualTo: Timestamp.fromDate(
                                DateTime(
                                  DateTime.now().year,
                                  DateTime.now().month,
                                  DateTime.now().day,
                                ),
                              ))
                          .snapshots(),
                      builder: (context, workoutSnapshot) {
                        int caloriesBurned = 0;
                        if (workoutSnapshot.hasData) {
                          for (var doc in workoutSnapshot.data!.docs) {
                            final data =
                                doc.data() as Map<String, dynamic>;
                            final burned = data['caloriesBurned'];
                            caloriesBurned +=
                                (burned as num?)?.toInt() ?? 0;
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
                                const Icon(
                                  Icons.local_fire_department_rounded,
                                  color: Color(0xFFFF6B35),
                                  size: 32,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "$caloriesLeft",
                                  style:
                                      PremiumTypography.headlineLarge.copyWith(
                                    fontSize: 40,
                                    color: PremiumColors.primaryNeon,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "kcal left",
                                  style: PremiumTypography.bodySmall.copyWith(
                                    color: PremiumColors.mutedText,
                                  ),
                                ),
                              ],
                            ),
                            circularStrokeCap: CircularStrokeCap.round,
                            backgroundColor:
                                Colors.grey.withOpacity(0.1),
                            progressColor: PremiumColors.primaryNeon,
                            footer: Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildAnimatedStatItem(
                                    "Eaten",
                                    "$caloriesEaten",
                                    Icons.restaurant,
                                    Colors.white,
                                  ),
                                  _buildAnimatedStatItem(
                                    "Burned",
                                    "$caloriesBurned",
                                    Icons.directions_run,
                                    Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),

              // ✨ AI ASSISTANT WITH PREMIUM GLASS CARD & ANIMATIONS
              ScaleInAnimation(
                duration: Duration(
                  milliseconds: AnimationDurations.standard.inMilliseconds + 100,
                ),
                child: PremiumGlassCard(
                  gradient: PremiumColors.blueGradient,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: PremiumColors.primaryGradient,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.smart_toy_outlined,
                                color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "AI Assistant",
                                  style: PremiumTypography.titleLarge.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Your personal health guide",
                                  style: PremiumTypography.bodySmall
                                      .copyWith(color: PremiumColors.mutedText),
                                ),
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
                        style: PremiumTypography.bodyMedium
                            .copyWith(color: PremiumColors.mutedText),
                      ),
                      const SizedBox(height: 8),
                      _buildAIFeature(
                        "📊 Nutrition Analysis",
                        "Analyze food & get detailed nutrition",
                      ),
                      const SizedBox(height: 8),
                      _buildAIFeature(
                        "💊 Medicine Info",
                        "Check interactions & recommendations",
                      ),
                      const SizedBox(height: 8),
                      _buildAIFeature(
                        "🏋️ Workout Plans",
                        "Personalized fitness guidance",
                      ),
                      const SizedBox(height: 8),
                      _buildAIFeature(
                        "🥗 Meal Planning",
                        "Healthy meal plans for your goals",
                      ),
                      const SizedBox(height: 12),
                      AnimatedGradientButton(
                        onPressed: () => Navigator.push(
                          context,
                          SlidePageRoute(
                            page: const AIChatbotScreen(),
                            direction: SlideDirection.up,
                          ),
                        ),
                        label: "Chat with AI",
                        gradient: PremiumColors.primaryGradient,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // ✨ QUICK STATS WITH PREMIUM ANIMATED CARDS
              Text(
                "Daily Stats",
                style: PremiumTypography.headlineMedium
                    .copyWith(color: PremiumColors.primaryNeon),
              ),
              const SizedBox(height: 15),
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user?.uid ?? '')
                    .collection('streaks')
                    .doc('current')
                    .snapshots(),
                builder: (context, streakSnapshot) {
                  int currentStreak = 0;
                  if (streakSnapshot.hasData &&
                      streakSnapshot.data!.exists) {
                    currentStreak = (streakSnapshot.data!.data()
                            as Map<String, dynamic>)['currentStreak'] ??
                        0;
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildAnimatedQuickStatCard(
                        "Steps",
                        "--",
                        Icons.directions_walk,
                        PremiumColors.accentBlue,
                      ),
                      _buildAnimatedQuickStatCard(
                        "Active",
                        "--",
                        Icons.timer,
                        PremiumColors.accentPurple,
                      ),
                      _buildAnimatedQuickStatCard(
                        "Streak",
                        "🔥 $currentStreak",
                        Icons.emoji_events,
                        PremiumColors.accentOrange,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 30),

              // ✨ DAILY SUMMARY CARDS WITH STAGGERED ANIMATIONS
              Text(
                "Daily Summary",
                style: PremiumTypography.headlineMedium
                    .copyWith(color: PremiumColors.primaryNeon),
              ),
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
                  if (workoutSnapshot.hasData &&
                      workoutSnapshot.data!.docs.isNotEmpty) {
                    final data = workoutSnapshot.data!.docs.first.data()
                        as Map<String, dynamic>;
                    final workoutType = data['workoutType'] ?? 'Workout';
                    final duration = data['duration'] ?? 0;
                    lastWorkoutText = "$workoutType • ${duration}m";
                  }

                  return SizedBox(
                    height: 140,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildAnimatedSummaryCard(
                          "Last Workout",
                          lastWorkoutText,
                          Icons.fitness_center,
                          PremiumColors.accentOrange,
                        ),
                        _buildAnimatedSummaryCard(
                          "Hydration",
                          "Track in app",
                          Icons.water_drop,
                          PremiumColors.accentBlue,
                        ),
                        _buildAnimatedSummaryCard(
                          "Sleep",
                          "Track in app",
                          Icons.bed,
                          PremiumColors.accentPurple,
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: null,
    );
  }

  // ✨ HELPER METHODS FOR ADVANCED UI/UX

  String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning,";
    if (hour < 17) return "Good Afternoon,";
    return "Good Evening,";
  }

  // ✨ ANIMATED QUICK LAUNCH WITH STAGGERED ANIMATIONS
  Widget _buildAnimatedQuickLaunchRow(BuildContext context) {
    final items = [
      _QuickLaunchItem(
        icon: Icons.psychology,
        label: 'AI Chat',
        color: PremiumColors.accentBlue,
        page: const AIChatbotScreen(),
      ),
      _QuickLaunchItem(
        icon: Icons.restaurant_menu,
        label: 'Nutrition',
        color: PremiumColors.accentGreen,
        page: const NutritionScreen(),
      ),
      _QuickLaunchItem(
        icon: Icons.medication,
        label: 'Medicine',
        color: PremiumColors.accentBlue,
        page: const EnhancedMedicineScreen(),
      ),
      _QuickLaunchItem(
        icon: Icons.fitness_center,
        label: 'Fitness',
        color: PremiumColors.accentOrange,
        page: const WorkoutScreen(),
      ),
      _QuickLaunchItem(
        icon: Icons.insights,
        label: 'Health',
        color: PremiumColors.accentPurple,
        page: const HealthReportUploadScreen(),
      ),
      _QuickLaunchItem(
        icon: Icons.calendar_view_week,
        label: 'Meal Plan',
        color: PremiumColors.accentBlue,
        page: const MealPlannerScreen(),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Launch',
          style: PremiumTypography.titleLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 92,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              return StaggeredAnimation(
                delay: Duration(milliseconds: 50 * index),
                duration: AnimationDurations.standard,
                child: _buildQuickLaunchButton(
                  context,
                  items[index],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickLaunchButton(
    BuildContext context,
    _QuickLaunchItem item,
  ) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        SlidePageRoute(
          page: item.page,
          direction: SlideDirection.up,
        ),
      ),
      child: Container(
        width: 84,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              item.color.withOpacity(0.3),
              item.color.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: item.color.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: item.color.withOpacity(0.2),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, color: item.color, size: 24),
            const SizedBox(height: 8),
            Text(
              item.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: PremiumTypography.labelSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, size: 18, color: PremiumColors.mutedText),
        const SizedBox(height: 4),
        Text(
          value,
          style: PremiumTypography.labelLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: PremiumTypography.bodySmall.copyWith(
            color: PremiumColors.mutedText,
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedQuickStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: ScaleInAnimation(
        duration: AnimationDurations.standard,
        child: PremiumGlassCard(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          borderRadius: 20,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                value,
                style: PremiumTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                label,
                style: PremiumTypography.bodySmall.copyWith(
                  color: PremiumColors.mutedText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedSummaryCard(
    String title,
    String subtitle,
    IconData icon,
    Color accentColor,
  ) {
    return SlideInAnimation(
      direction: SlideDirection.right,
      duration: AnimationDurations.standard,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              accentColor.withOpacity(0.3),
              accentColor.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: accentColor.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.2),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 28, color: accentColor),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: PremiumTypography.bodySmall
                      .copyWith(color: PremiumColors.mutedText),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: PremiumTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIFeature(String title, String description) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: PremiumTypography.labelLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            description,
            style: PremiumTypography.bodySmall
                .copyWith(color: PremiumColors.mutedText),
          ),
        ],
      ),
    );
  }
}

class _QuickLaunchItem {
  final IconData icon;
  final String label;
  final Color color;
  final Widget page;

  _QuickLaunchItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.page,
  });
}
