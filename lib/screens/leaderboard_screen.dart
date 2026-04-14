import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int _selectedTab = 0; // 0: Weekly, 1: All Time, 2: My Achievements

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 200,
            backgroundColor: const Color(0xFF8B5CF6),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Leaderboard & Challenges',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF8B5CF6),
                      const Color(0xFF6366F1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    const Text(
                      '🏆 Rise to the Top',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: DefaultTabController(
                length: 3,
                initialIndex: _selectedTab,
                child: Column(
                  children: [
                    TabBar(
                      labelColor: const Color(0xFF8B5CF6),
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: const Color(0xFF8B5CF6),
                      tabs: const [
                        Tab(
                          child: Text(
                            'Weekly',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Tab(
                          child: Text(
                            'All Time',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Tab(
                          child: Text(
                            'My Achievements',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                      onTap: (index) {
                        setState(() => _selectedTab = index);
                      },
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 600,
                      child: TabBarView(
                        children: [
                          _buildLeaderboardTab('weekly'),
                          _buildLeaderboardTab('allTime'),
                          _buildAchievementsTab(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardTab(String period) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('leaderboard')
          .doc(period)
          .collection('users')
          .orderBy('xp', descending: true)
          .limit(50)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No data yet. Start earning XP!'),
          );
        }

        final users = snapshot.data!.docs;

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            final rank = index + 1;
            final xp = user['xp'] ?? 0;
            final userName = user['name'] ?? 'User';
            final userAvatar = user['avatar'] ?? '👤';

            Color rankColor = Colors.grey;
            String rankMedal = '${rank.toString()}th';
            if (rank == 1) {
              rankColor = const Color(0xFFFFD700);
              rankMedal = '🥇';
            } else if (rank == 2) {
              rankColor = const Color(0xFFC0C0C0);
              rankMedal = '🥈';
            } else if (rank == 3) {
              rankColor = const Color(0xFFCD7F32);
              rankMedal = '🥉';
            }

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: rank <= 3
                      ? rankColor.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: rankColor.withOpacity(0.3),
                    width: rank <= 3 ? 2 : 1,
                  ),
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: rankColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                        child: Text(
                          rankMedal,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '$xp XP',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${(xp / 1000).toStringAsFixed(1)}K',
                        style: const TextStyle(
                          color: Color(0xFF8B5CF6),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
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

  Widget _buildAchievementsTab() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore
          .collection('users')
          .doc(_auth.currentUser?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>?;
        final badges = (userData?['badges'] as List<dynamic>?) ?? [];
        final xp = userData?['totalXp'] ?? 0;
        final streak = userData?['streak'] ?? 0;

        return SingleChildScrollView(
          child: Column(
            children: [
              // Stats Cards
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatCard('📊', 'Total XP', '$xp XP'),
                      _buildStatCard('🔥', 'Streak', '$streak days'),
                      _buildStatCard('🏆', 'Badges', '${badges.length}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Badges Section
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Badges Earned',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(height: 12),
              if (badges.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('No badges yet. Keep going! 💪'),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: badges.length,
                  itemBuilder: (context, index) {
                    final badge = badges[index];
                    return _buildBadgeCard(badge);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String icon, String label, String value) {
    return Column(
      children: [
        Text(
          icon,
          style: const TextStyle(fontSize: 32),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeCard(String badge) {
    final badgeData = {
      'first_meal': {'emoji': '🍽️', 'title': 'First Meal', 'desc': 'Logged first meal'},
      'week_streak': {'emoji': '🔥', 'title': 'Week Streak', 'desc': '7 day streak'},
      'medicine_perfect': {'emoji': '💊', 'title': 'Perfect Week', 'desc': 'No missed meds'},
      'fitness_warrior': {'emoji': '💪', 'title': 'Fitness Warrior', 'desc': '50kg burned'},
      'nutrition_master': {'emoji': '🥗', 'title': 'Nutrition Master', 'desc': '100 meals logged'},
    };

    final data = badgeData[badge] ?? {
      'emoji': '⭐',
      'title': 'Achievement',
      'desc': 'Unknown'
    };

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF8B5CF6).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withOpacity(0.3),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            data['emoji'].toString(),
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(height: 8),
          Text(
            data['title'].toString(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
