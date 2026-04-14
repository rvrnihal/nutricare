import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nuticare/core/theme.dart';
import 'package:nuticare/screens/home_screen.dart';
import 'package:nuticare/screens/workout_screen.dart';
import 'package:nuticare/screens/nutrition_screen.dart';
import 'package:nuticare/screens/progress_screen.dart';
import 'package:nuticare/screens/enhanced_medicine_screen.dart';
import 'package:nuticare/screens/ai_chatbot_screen.dart';
import 'package:nuticare/screens/leaderboard_screen.dart';
import 'package:nuticare/screens/challenges_screen.dart';
import 'package:nuticare/screens/budget_nutrition_index_screen.dart';
import 'package:nuticare/screens/eco_footprint_screen.dart';
import 'package:nuticare/screens/social_chat_screen.dart';
import 'package:nuticare/screens/profile_settings_screen.dart';
import 'package:nuticare/screens/admin_panel_screen.dart';

class MainLayout extends StatefulWidget {
  final int initialIndex;

  const MainLayout({super.key, this.initialIndex = 0});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late int _currentIndex;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _screens = [
    const HomeScreen(),
    const WorkoutScreen(),
    const NutritionScreen(),
    const ProgressScreen(),
    const EnhancedMedicineScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, _screens.length - 1);
  }

  void _navigateToScreen(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isAdmin = false; // TODO: Check user role from Firestore

    return Scaffold(
      key: _scaffoldKey,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      drawer: _buildDrawer(user, isAdmin),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavItem(0, Icons.home_rounded, "Home"),
                _buildNavItem(1, Icons.fitness_center_rounded, "Workout"),
                _buildNavItem(2, Icons.restaurant_menu_rounded, "Food"),
                _buildNavItem(3, Icons.bar_chart_rounded, "Progress"),
                _buildNavItem(4, Icons.medication_rounded, "Meds"),
                GestureDetector(
                  onTap: () => _scaffoldKey.currentState?.openDrawer(),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.more_horiz_rounded,
                          color: Colors.grey[600],
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "More",
                          style: NutriTheme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                            fontSize: 10,
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

  Widget _buildDrawer(User? user, bool isAdmin) {
    return Drawer(
      child: Container(
        color: NutriTheme.background,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: NutriTheme.primary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                    child: user?.photoURL == null ? const Icon(Icons.person, size: 32) : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.displayName ?? 'User',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Text(
                    user?.email ?? 'user@example.com',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _buildDrawerItem('🤖 AI Chat', Icons.psychology, () {
              Navigator.pop(context);
              _navigateToScreen(const AIChatbotScreen());
            }),
            _buildDrawerItem('💬 Social Chat', Icons.chat, () {
              Navigator.pop(context);
              _navigateToScreen(const SocialChatScreen());
            }),
            _buildDrawerItem('🏆 Leaderboard', Icons.leaderboard, () {
              Navigator.pop(context);
              _navigateToScreen(const LeaderboardScreen());
            }),
            _buildDrawerItem('🎯 Challenges', Icons.sports, () {
              Navigator.pop(context);
              _navigateToScreen(const ChallengesScreen());
            }),
            _buildDrawerItem('💰 Budget Nutrition', Icons.attach_money, () {
              Navigator.pop(context);
              _navigateToScreen(const BudgetNutritionIndexScreen());
            }),
            _buildDrawerItem('🌱 Eco-footprint', Icons.eco, () {
              Navigator.pop(context);
              _navigateToScreen(const EcoFootprintScreen());
            }),
            _buildDrawerItem('⚙️ Settings & Profile', Icons.settings, () {
              Navigator.pop(context);
              _navigateToScreen(const ProfileSettingsScreen());
            }),
            if (isAdmin) ...[
              const Divider(color: Colors.white12),
              _buildDrawerItem('👨‍💼 Admin Panel', Icons.admin_panel_settings, () {
                Navigator.pop(context);
                _navigateToScreen(const AdminPanelScreen());
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: NutriTheme.primary),
      title: Text(
        title,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
      hoverColor: Colors.white.withValues(alpha: 0.1),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? NutriTheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.black : Colors.grey,
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(height: 4),
              Text(
                label,
                style: NutriTheme.textTheme.bodyMedium?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
