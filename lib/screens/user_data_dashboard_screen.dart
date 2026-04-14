import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/user_data_storage_service.dart';

class UserDataDashboardScreen extends StatefulWidget {
  const UserDataDashboardScreen({super.key});

  @override
  State<UserDataDashboardScreen> createState() => _UserDataDashboardScreenState();
}

class _UserDataDashboardScreenState extends State<UserDataDashboardScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Health Data'),
        backgroundColor: Colors.green.shade700,
        elevation: 0,
      ),
      body: IndexedStack(
        index: _selectedTab,
        children: [
          _buildConversationsTab(),
          _buildReportsTab(),
          _buildPlansTab(),
          _buildStatisticsTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTab,
        onTap: (index) => setState(() => _selectedTab = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble),
            label: 'Conversations',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Plans',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Stats',
          ),
        ],
      ),
    );
  }

  // ==================== CONVERSATIONS TAB ====================
  Widget _buildConversationsTab() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: UserDataStorageService.getAIConversationHistory(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline, size: 60, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('No conversations yet'),
              ],
            ),
          );
        }

        final conversations = snapshot.data!;
        
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: conversations.length,
          itemBuilder: (context, index) {
            final conv = conversations[index];
            final timestamp = (conv['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
            
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                title: Text(
                  conv['question'] ?? 'Question',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${conv['category']?.toUpperCase() ?? 'General'} • ${_formatDate(timestamp)}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Response:', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(conv['answer'] ?? 'No response'),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ==================== REPORTS TAB ====================
  Widget _buildReportsTab() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: UserDataStorageService.getHealthReports(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.description_outlined, size: 60, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('No health reports uploaded yet'),
              ],
            ),
          );
        }

        final reports = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final report = reports[index];
            final timestamp = (report['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Icon(
                  Icons.image,
                  color: Colors.green.shade700,
                ),
                title: Text(
                  report['reportType']?.toString().replaceAll('_', ' ').toUpperCase() ?? 'Report',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${report['filename'] ?? 'Unknown'}'),
                    Text(
                      _formatDate(timestamp),
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ],
                ),
                trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
                onTap: () => _showReportDetails(report),
              ),
            );
          },
        );
      },
    );
  }

  // ==================== PLANS TAB ====================
  Widget _buildPlansTab() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            tabs: const [
              Tab(text: 'Workout Plans'),
              Tab(text: 'Diet Plans'),
            ],
            labelColor: Colors.green.shade700,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.green.shade700,
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildWorkoutPlansTab(),
                _buildDietPlansTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutPlansTab() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: UserDataStorageService.getWorkoutPlans(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.fitness_center, size: 60, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('No workout plans yet'),
              ],
            ),
          );
        }

        final plans = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: plans.length,
          itemBuilder: (context, index) {
            final plan = plans[index];
            final progress = plan['completionPercentage'] ?? 0;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan['planName'] ?? 'Workout Plan',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text('Goal: ${plan['goal']?.toString().replaceAll('_', ' ').toUpperCase()}'),
                    Text('Duration: ${plan['durationDays']} days'),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress / 100,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation(Colors.green.shade700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$progress% Complete',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDietPlansTab() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: UserDataStorageService.getDietPlans(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.restaurant, size: 60, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('No diet plans yet'),
              ],
            ),
          );
        }

        final plans = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: plans.length,
          itemBuilder: (context, index) {
            final plan = plans[index];
            final adherence = plan['adherencePercentage'] ?? 0;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan['planName'] ?? 'Diet Plan',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text('Type: ${plan['dietType']?.toString().toUpperCase()}'),
                    Text('Daily Calories: ${plan['dailyCalories']} kcal'),
                    Text('Duration: ${plan['durationDays']} days'),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: adherence / 100,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation(Colors.orange.shade700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$adherence% Adherence',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ==================== STATISTICS TAB ====================
  Widget _buildStatisticsTab() {
    return FutureBuilder<Map<String, dynamic>>(
      future: UserDataStorageService.getUserStatistics(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData) {
          return const Center(child: Text('Unable to load statistics'));
        }

        final stats = snapshot.data!;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildStatCard(
                icon: Icons.chat_bubble,
                label: 'Total Conversations',
                value: '${stats['totalConversations'] ?? 0}',
                color: Colors.blue,
              ),
              const SizedBox(height: 12),
              _buildStatCard(
                icon: Icons.description,
                label: 'Health Reports',
                value: '${stats['totalReports'] ?? 0}',
                color: Colors.green,
              ),
              const SizedBox(height: 12),
              _buildStatCard(
                icon: Icons.fitness_center,
                label: 'Active Plans',
                value: '${stats['activePlans'] ?? 0}',
                color: Colors.orange,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _downloadData,
                icon: const Icon(Icons.download),
                label: const Text('Download All Data'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==================== HELPERS ====================

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  Text(
                    value,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showReportDetails(Map<String, dynamic> report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(report['reportType']?.toString().toUpperCase() ?? 'Report'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('File: ${report['filename']}'),
              const SizedBox(height: 12),
              if (report['analysis'] != null) ...[
                const Text('Analysis:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(report['analysis'].toString()),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _downloadData() async {
    try {
      final data = await UserDataStorageService.exportUserData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data exported: ${data.keys.join(", ")}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
