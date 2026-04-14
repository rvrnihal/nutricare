import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nuticare/core/theme.dart';
import 'package:nuticare/screens/login_screen.dart';
import 'package:nuticare/screens/settings_screen.dart';
import 'package:nuticare/screens/edit_profile_screen.dart';
import 'package:nuticare/screens/health_suggestions_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: NutriTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("My Profile",
            style: NutriTheme.textTheme.displayMedium?.copyWith(fontSize: 20)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // 🟢 Avatar & Name
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey.shade800,
              backgroundImage:
                  user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
              child: user?.photoURL == null
                  ? const Icon(Icons.person, size: 50, color: Colors.grey)
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              user?.displayName ?? "Nutri User",
              style: NutriTheme.textTheme.displayMedium?.copyWith(fontSize: 24),
            ),
            Text(
              user?.email ?? "",
              style: NutriTheme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 30),

            // 🟢 Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem("Weight", "75 kg"),
                _buildStatItem("Height", "180 cm"),
                _buildStatItem("Age", "28"),
              ],
            ),

            const SizedBox(height: 30),

            // 🟢 Options List
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: NutriTheme.surface, // Dark Surface
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5)),
                ],
              ),
              child: Column(
                children: [
                  _buildOptionTile(Icons.person_outline, "Edit Profile",
                      () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const EditProfileScreen()),
                    );
                    // Refresh if profile was updated
                    if (result == true) {
                      // Trigger rebuild by using setState in parent or just rebuild
                    }
                  }),
                  const Divider(height: 1),
                  _buildOptionTile(
                      Icons.health_and_safety, "Health Suggestions", () async {
                    // Fetch user's health report and fitness goal
                    final userData = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user?.uid)
                        .get();
                    
                    final healthReport = userData.data()?['healthReport'] ?? '';
                    final fitnessGoal = userData.data()?['fitnessGoal'] ?? 'maintain health';
                    
                    if (healthReport.isEmpty) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please add your health report in Edit Profile'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                      return;
                    }
                    
                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HealthSuggestionsScreen(
                            healthReport: healthReport,
                            fitnessGoal: fitnessGoal,
                          ),
                        ),
                      );
                    }
                  }),
                  const Divider(height: 1),
                  _buildOptionTile(
                      Icons.notifications_outlined, "Notifications", () {}),
                  const Divider(height: 1),
                  _buildOptionTile(
                      Icons.privacy_tip_outlined, "Privacy Policy", () {}),
                  const Divider(height: 1),
                  _buildOptionTile(Icons.help_outline, "Help & Support", () {}),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 🟢 Logout Button
            TextButton.icon(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text("Log Out",
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: NutriTheme.textTheme.displayMedium?.copyWith(fontSize: 20),
        ),
        Text(
          label,
          style: NutriTheme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildOptionTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title,
          style: NutriTheme.textTheme.bodyLarge?.copyWith(color: Colors.white)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}
