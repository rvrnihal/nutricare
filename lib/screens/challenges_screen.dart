import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({Key? key}) : super(key: key);

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _selectedFilter = 'active'; // active, completed, upcoming

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Challenges'),
        backgroundColor: const Color(0xFFF59E0B),
        elevation: 0,
      ),
      body: CustomScrollView(
        slivers: [
          // Current Week Card
          SliverToBoxAdapter(
            child: Container(
              color: const Color(0xFFF59E0B).withOpacity(0.1),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🏆 Week 14 Progress',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mar 31 - Apr 6, 2026',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Weekly Stats
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildWeeklyStatItem('💪', 'Challenges', '5/8'),
                        Container(
                          width: 1,
                          height: 50,
                          color: Colors.grey.shade300,
                        ),
                        _buildWeeklyStatItem('🏅', 'XP Earned', '450/500'),
                        Container(
                          width: 1,
                          height: 50,
                          color: Colors.grey.shade300,
                        ),
                        _buildWeeklyStatItem('🔥', 'Streak', '5 days'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Filter Tabs
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _buildFilterTab('Active', 'active'),
                  const SizedBox(width: 8),
                  _buildFilterTab('Completed', 'completed'),
                  const SizedBox(width: 8),
                  _buildFilterTab('Upcoming', 'upcoming'),
                ],
              ),
            ),
          ),

          // Challenge Cards
          if (_selectedFilter == 'active')
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final challenges = [
                    {
                      'title': '🥗 Veggie Warrior',
                      'description': 'Eat 5 servings of vegetables',
                      'progress': 3,
                      'target': 5,
                      'xp': 100,
                      'difficulty': 'Easy',
                      'diffColor': Colors.green,
                    },
                    {
                      'title': '💊 Medicine Perfectionist',
                      'description': 'Take all medicines on time',
                      'progress': 4,
                      'target': 7,
                      'xp': 150,
                      'difficulty': 'Medium',
                      'diffColor': Colors.orange,
                    },
                    {
                      'title': '🏃 Fitness Fanatic',
                      'description': 'Burn 2000 calories this week',
                      'progress': 1800,
                      'target': 2000,
                      'xp': 200,
                      'difficulty': 'Hard',
                      'diffColor': Colors.red,
                    },
                  ];

                  if (index >= challenges.length) {
                    return const SizedBox.shrink();
                  }

                  final challenge = challenges[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: _buildChallengeCard(challenge),
                  );
                },
                childCount: 3,
              ),
            ),

          if (_selectedFilter == 'completed')
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final challenges = [
                    {
                      'title': '🎯 Daily Logger',
                      'description': 'Log meals for 7 consecutive days',
                      'progress': 7,
                      'target': 7,
                      'xp': 100,
                      'completedDate': 'Mar 29',
                    },
                    {
                      'title': '💧 Hydration Hero',
                      'description': 'Drink 8 glasses of water daily',
                      'progress': 7,
                      'target': 7,
                      'xp': 80,
                      'completedDate': 'Mar 25',
                    },
                  ];

                  if (index >= challenges.length) {
                    return const SizedBox.shrink();
                  }

                  final challenge = challenges[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: _buildCompletedChallengeCard(challenge),
                  );
                },
                childCount: 2,
              ),
            ),

          if (_selectedFilter == 'upcoming')
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final challenges = [
                    {
                      'title': '🌟 Social Butterfly',
                      'description': 'Chat with 3 fitness experts',
                      'xp': 120,
                      'startsIn': '2 days',
                    },
                    {
                      'title': '🍎 Clean Eating',
                      'description': 'Zero processed food for a week',
                      'xp': 180,
                      'startsIn': '5 days',
                    },
                  ];

                  if (index >= challenges.length) {
                    return const SizedBox.shrink();
                  }

                  final challenge = challenges[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: _buildUpcomingChallengeCard(challenge),
                  );
                },
                childCount: 2,
              ),
            ),

          // "All-Time" Challenges Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🏆 Lifetime Challenges',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildLifetimeChallenge(
                    '100 Meals Logged',
                    75,
                    100,
                    '75%',
                  ),
                  const SizedBox(height: 8),
                  _buildLifetimeChallenge(
                    '52-Week Streak',
                    25,
                    52,
                    '48%',
                  ),
                  const SizedBox(height: 8),
                  _buildLifetimeChallenge(
                    '1000 XP Points',
                    650,
                    1000,
                    '65%',
                  ),
                ],
              ),
            ),
          ),

          // Reward Shop
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFF59E0B).withOpacity(0.15),
                    const Color(0xFFEB8F14).withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFF59E0B).withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text(
                        '🎁',
                        style: TextStyle(fontSize: 28),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Redeem Your XP',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildRewardItem(
                    '🏅 Bronze Badge',
                    '100 XP',
                    Colors.orange.shade300,
                  ),
                  const SizedBox(height: 8),
                  _buildRewardItem(
                    '⭐ Premium Badge',
                    '300 XP',
                    Colors.amber,
                  ),
                  const SizedBox(height: 8),
                  _buildRewardItem(
                    '💎 Platinum Badge',
                    '500 XP',
                    Colors.deepPurple.shade300,
                  ),
                  const SizedBox(height: 8),
                  _buildRewardItem(
                    '🎖️ Nutritionist Consultation',
                    '750 XP',
                    const Color(0xFF8B5CF6),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String label, String value) {
    final isSelected = _selectedFilter == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedFilter = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFF59E0B)
                : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyStatItem(String icon, String label, String value) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildChallengeCard(Map<String, dynamic> challenge) {
    final progress = (challenge['progress'] as int) / (challenge['target'] as int);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      challenge['title'].toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      challenge['description'].toString(),
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
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: challenge['diffColor'].withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  challenge['difficulty'].toString(),
                  style: TextStyle(
                    color: challenge['diffColor'],
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                const Color(0xFFF59E0B),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${challenge['progress']}/${challenge['target']}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '+${challenge['xp']} XP',
                      style: const TextStyle(
                        color: Color(0xFFF59E0B),
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedChallengeCard(Map<String, dynamic> challenge) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF10B981).withOpacity(0.3),
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('✓', style: TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge['title'].toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Completed on ${challenge['completedDate']}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '+${challenge['xp']} XP',
              style: const TextStyle(
                color: Color(0xFF10B981),
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingChallengeCard(Map<String, dynamic> challenge) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      challenge['title'].toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      challenge['description'].toString(),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Starts in ${challenge['startsIn']}',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '+${challenge['xp']} XP',
              style: const TextStyle(
                color: Color(0xFFF59E0B),
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLifetimeChallenge(String title, int progress, int target, String percentage) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Text(
                percentage,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress / target,
              minHeight: 6,
              backgroundColor: Colors.grey.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                const Color(0xFFF59E0B),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$progress / $target',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardItem(String title, String cost, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.5),
        ),
      ),
      child: Row(
        children: [
          Text(
            title.split(' ')[0],
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title.split(' ').skip(1).join(' '),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              cost,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
