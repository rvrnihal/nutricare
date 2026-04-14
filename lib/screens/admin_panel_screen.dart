import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nuticare/core/theme.dart';
import 'package:nuticare/components/glass_card.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  int _currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NutriTheme.background,
      appBar: AppBar(
        backgroundColor: NutriTheme.primary,
        elevation: 0,
        title: const Text('👨‍💼 Admin Panel',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: false,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 📊 Dashboard Stats
          _buildStatsSection(),
          const SizedBox(height: 24),

          // 👥 User Management
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('👥 User Management',
                    style: NutriTheme.textTheme.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 16),
                _buildUserStatsRow(),
                const SizedBox(height: 16),
                _buildActionButton('View All Users', Icons.people, Colors.blue, () {
                  _showUserManagementModal();
                }),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 📚 Content Management
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('📚 Content Management',
                    style: NutriTheme.textTheme.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 16),
                _buildActionButton('Manage Diet Templates', Icons.restaurant_menu, Colors.green, () {
                  _showDietManagementModal();
                }),
                const SizedBox(height: 10),
                _buildActionButton('Manage Medicine Database', Icons.medication, Colors.orange, () {
                  _showMedicineManagementModal();
                }),
                const SizedBox(height: 10),
                _buildActionButton('Manage Exercises', Icons.fitness_center, Colors.purple, () {
                  _showExerciseManagementModal();
                }),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 🚨 Alerts & Reports
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('🚨 Alerts & Reports',
                    style: NutriTheme.textTheme.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 16),
                _buildAlertItem(
                  '⚠️ Flagged Food-Drug Interactions',
                  '8 pending',
                  Colors.red.withValues(alpha: 0.2),
                  () => _showFlaggedAlertsModal(),
                ),
                const SizedBox(height: 10),
                _buildAlertItem(
                  '📊 System Analytics',
                  'View detailed reports',
                  Colors.blue.withValues(alpha: 0.2),
                  () => _showAnalyticsModal(),
                ),
                const SizedBox(height: 10),
                _buildAlertItem(
                  '🔔 User Feedback',
                  '12 new messages',
                  Colors.teal.withValues(alpha: 0.2),
                  () => _showFeedbackModal(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 👨‍💼 Expert Approvals
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('👨‍💼 Expert Approvals',
                    style: NutriTheme.textTheme.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 16),
                _buildActionButton(
                  'Approve Trainers',
                  Icons.person_add,
                  Colors.green,
                  () => _showExpertApprovalModal('trainer'),
                ),
                const SizedBox(height: 10),
                _buildActionButton(
                  'Approve Nutritionists',
                  Icons.local_dining,
                  Colors.green,
                  () => _showExpertApprovalModal('nutritionist'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ⚙️ System Settings
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('⚙️ System Settings',
                    style: NutriTheme.textTheme.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 16),
                _buildActionButton('App Configuration', Icons.settings, Colors.grey, () {
                  _showConfigModal();
                }),
                const SizedBox(height: 10),
                _buildActionButton('Backup & Restore', Icons.backup, Colors.teal, () {
                  _showBackupModal();
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, userSnapshot) {
        final totalUsers = userSnapshot.data?.docs.length ?? 0;

        return Row(
          children: [
            Expanded(
              child: GlassCard(
                child: Column(
                  children: [
                    const Icon(Icons.people, color: Colors.blue, size: 32),
                    const SizedBox(height: 8),
                    Text('$totalUsers', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    Text('Total Users', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                  ],
                  crossAxisAlignment: CrossAxisAlignment.center,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GlassCard(
                child: Column(
                  children: [
                    const Icon(Icons.trending_up, color: Colors.green, size: 32),
                    const SizedBox(height: 8),
                    const Text('4.8★', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    Text('Avg. Rating', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                  ],
                  crossAxisAlignment: CrossAxisAlignment.center,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GlassCard(
                child: Column(
                  children: [
                    const Icon(Icons.health_and_safety, color: Colors.red, size: 32),
                    const SizedBox(height: 8),
                    const Text('98%', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    Text('System Health', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                  ],
                  crossAxisAlignment: CrossAxisAlignment.center,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUserStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatColumn('Active', '1,245', Colors.green),
        _buildStatColumn('Inactive', '234', Colors.orange),
        _buildStatColumn('Suspended', '12', Colors.red),
      ],
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
      ],
    );
  }

  Widget _buildActionButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
            ),
            Icon(Icons.arrow_forward_rounded, color: color.withValues(alpha: 0.5), size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertItem(String title, String subtitle, Color bgColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(color: Colors.grey[300], fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_rounded, color: Colors.white70, size: 18),
          ],
        ),
      ),
    );
  }

  void _showUserManagementModal() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: NutriTheme.surface,
        title: const Text('👥 User Management', style: TextStyle(color: Colors.white)),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              return ListView(
                children: snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final status = data['active'] == true ? '✅ Active' : '⏸ Inactive';
                  return _buildUserRow(
                    data['name'] ?? 'Unknown',
                    data['email'] ?? 'N/A',
                    status,
                  );
                }).toList(),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildUserRow(String name, String email, String status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey[700],
            child: Text(name[0], style: const TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                Text(email, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
              ],
            ),
          ),
          Text(status, style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _showDietManagementModal() {
    _showSimpleModal('📚 Diet Templates Management', 'Manage diet plan templates, recipes, and meal defaults.');
  }

  void _showMedicineManagementModal() {
    _showSimpleModal('💊 Medicine Database', 'Add, edit, or remove medicines from the system database.');
  }

  void _showExerciseManagementModal() {
    _showSimpleModal('🏋️ Exercise Management', 'Manage workout routines and fitness plans.');
  }

  void _showFlaggedAlertsModal() {
    _showSimpleModal('⚠️ Flagged Alerts', 'Review and manage flagged food-drug interactions.');
  }

  void _showAnalyticsModal() {
    _showSimpleModal('📊 System Analytics', 'View detailed usage statistics and system performance.');
  }

  void _showFeedbackModal() {
    _showSimpleModal('💬 User Feedback', 'Review and respond to user feedback and suggestions.');
  }

  void _showExpertApprovalModal(String type) {
    final title = type == 'trainer' ? '🏋️ Trainer Approvals' : '🥗 Nutritionist Approvals';
    _showSimpleModal(title, 'Review and approve pending expert registrations.');
  }

  void _showConfigModal() {
    _showSimpleModal('⚙️ App Configuration', 'Configure app-wide settings and feature toggles.');
  }

  void _showBackupModal() {
    _showSimpleModal('💾 Backup & Restore', 'Create backups and restore from previous versions.');
  }

  void _showSimpleModal(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: NutriTheme.surface,
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Text(content, style: TextStyle(color: Colors.grey[300])),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }
}
