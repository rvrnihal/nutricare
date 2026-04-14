import 'package:flutter/material.dart';
import 'package:nuticare/core/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nuticare/screens/login_screen.dart';
import 'package:nuticare/screens/profile_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NutriTheme.background,
      appBar: AppBar(
        title: const Text("Settings", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("General",
                style: TextStyle(
                    color: NutriTheme.primary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildSettingTile(Icons.person_outline, "Account Info", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            }),
            _buildSettingTile(
                Icons.notifications_outlined, "Notifications", () {},
                hasSwitch: true),
            _buildSettingTile(Icons.language, "Language", () {},
                subtitle: "English"),
            const SizedBox(height: 30),
            const Text("Support",
                style: TextStyle(
                    color: NutriTheme.primary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildSettingTile(Icons.help_outline, "Help & Center", () {}),
            _buildSettingTile(
                Icons.privacy_tip_outlined, "Privacy Policy", () {}),
            _buildSettingTile(Icons.info_outline, "About NutriCare+", () {}),
            const SizedBox(height: 30),
            Center(
              child: TextButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (c) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
                child: const Text("Log Out",
                    style: TextStyle(color: Colors.red, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 10),
            const Center(
                child: Text("v1.0.0",
                    style: TextStyle(color: Colors.grey, fontSize: 12))),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile(IconData icon, String title, VoidCallback onTap,
      {bool hasSwitch = false, String? subtitle}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: NutriTheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        subtitle: subtitle != null
            ? Text(subtitle, style: const TextStyle(color: Colors.grey))
            : null,
        trailing: hasSwitch
            ? Switch(
                value: true, onChanged: (v) {}, activeThumbColor: NutriTheme.primary)
            : const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: hasSwitch ? null : onTap,
      ),
    );
  }
}
