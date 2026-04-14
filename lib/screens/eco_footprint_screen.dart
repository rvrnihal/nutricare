import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EcoFootprintScreen extends StatefulWidget {
  const EcoFootprintScreen({Key? key}) : super(key: key);

  @override
  State<EcoFootprintScreen> createState() => _EcoFootprintScreenState();
}

class _EcoFootprintScreenState extends State<EcoFootprintScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eco-Footprint Tracker'),
        backgroundColor: const Color(0xFF059669),
        elevation: 0,
      ),
      body: CustomScrollView(
        slivers: [
          // Header Card
          SliverToBoxAdapter(
            child: Container(
              color: const Color(0xFF059669).withOpacity(0.1),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🌍 Your Eco Impact',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Track your environmental footprint through daily nutrition choices',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Score Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF10B981).withOpacity(0.3),
                          const Color(0xFF059669).withOpacity(0.3),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF059669).withOpacity(0.5),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Eco Score',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  '78/100',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF059669),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF10B981).withOpacity(0.2),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 100,
                                    height: 100,
                                    child: CircularProgressIndicator(
                                      value: 0.78,
                                      strokeWidth: 6,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        const Color(0xFF10B981),
                                      ),
                                      backgroundColor:
                                          Colors.grey.withOpacity(0.2),
                                    ),
                                  ),
                                  const Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '🌱',
                                        style: TextStyle(fontSize: 32),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: 0.78,
                            minHeight: 8,
                            backgroundColor: Colors.grey.withOpacity(0.3),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              const Color(0xFF10B981),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Great! You\'re making eco-friendly choices! 🎉',
                          style: TextStyle(
                            color: Color(0xFF059669),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Impact Breakdown
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Impact Breakdown',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildImpactCard(
                    icon: '💧',
                    title: 'Water Usage',
                    value: '2,450 L',
                    subtitle: 'This month',
                    recommendation:
                        'Reduce meat consumption to save water 💡',
                    color: const Color(0xFF0EA5E9),
                  ),
                  const SizedBox(height: 12),
                  _buildImpactCard(
                    icon: '🌳',
                    title: 'Carbon Footprint',
                    value: '12.5 kg CO₂',
                    subtitle: 'CO₂ equivalent',
                    recommendation:
                        'Choose local, seasonal foods 💡',
                    color: const Color(0xFF10B981),
                  ),
                  const SizedBox(height: 12),
                  _buildImpactCard(
                    icon: '📦',
                    title: 'Packaging Waste',
                    value: '2.3 kg',
                    subtitle: 'Plastic & materials',
                    recommendation:
                        'Buy fresh instead of packaged 💡',
                    color: const Color(0xFFEF4444),
                  ),
                ],
              ),
            ),
          ),

          // Food Sustainability
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Food Sustainability Rating',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildFoodSustainabilityItem(
                    icon: '🥦',
                    name: 'Vegetables',
                    score: 95,
                    impact: 'Low Impact',
                    color: Colors.green,
                  ),
                  const SizedBox(height: 10),
                  _buildFoodSustainabilityItem(
                    icon: '🍚',
                    name: 'Grains',
                    score: 85,
                    impact: 'Low Impact',
                    color: Colors.green,
                  ),
                  const SizedBox(height: 10),
                  _buildFoodSustainabilityItem(
                    icon: '🧀',
                    name: 'Dairy',
                    score: 60,
                    impact: 'Medium Impact',
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 10),
                  _buildFoodSustainabilityItem(
                    icon: '🥩',
                    name: 'Red Meat',
                    score: 30,
                    impact: 'High Impact',
                    color: Colors.red,
                  ),
                ],
              ),
            ),
          ),

          // Green Choices This Month
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF10B981).withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text(
                        '✅',
                        style: TextStyle(fontSize: 24),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Your Green Choices',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildGreenChoiceItem(
                    '🥬 52 plant-based meals',
                    'Great contribution!',
                  ),
                  const SizedBox(height: 8),
                  _buildGreenChoiceItem(
                    '🌾 Local vegetables used',
                    '68% of fresh produce',
                  ),
                  const SizedBox(height: 8),
                  _buildGreenChoiceItem(
                    '♻️ Zero-waste packaging',
                    '15 items from bulk stores',
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '🌍 You\'ve saved 8.5 kg CO₂ compared to average 💚',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Tips Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '💡 Eco Tips',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildTipCard(
                    '1. Seasonal Shopping',
                    'Buy seasonal produce reduces transportation impact',
                  ),
                  const SizedBox(height: 8),
                  _buildTipCard(
                    '2. Reduce Meat',
                    'Meat production uses 10x more water than vegetables',
                  ),
                  const SizedBox(height: 8),
                  _buildTipCard(
                    '3. Bulk Buying',
                    'Reduces packaging waste by 60%',
                  ),
                  const SizedBox(height: 8),
                  _buildTipCard(
                    '4. Local Markets',
                    'Supports local farmers & reduces carbon emissions',
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

  Widget _buildImpactCard({
    required String icon,
    required String title,
    required String value,
    required String subtitle,
    required String recommendation,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              recommendation,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodSustainabilityItem({
    required String icon,
    required String name,
    required int score,
    required String impact,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: score / 100,
                    minHeight: 6,
                    backgroundColor: Colors.grey.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$score/100',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                impact,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGreenChoiceItem(String title, String subtitle) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text('✓', style: TextStyle(fontSize: 18)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTipCard(String title, String description) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
