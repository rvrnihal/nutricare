import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BudgetNutritionIndexScreen extends StatefulWidget {
  const BudgetNutritionIndexScreen({Key? key}) : super(key: key);

  @override
  State<BudgetNutritionIndexScreen> createState() =>
      _BudgetNutritionIndexScreenState();
}

class _BudgetNutritionIndexScreenState extends State<BudgetNutritionIndexScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _selectedFilter = 'all'; // all, protein, carbs, fiber

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Nutrition Index'),
        backgroundColor: const Color(0xFF10B981),
        elevation: 0,
      ),
      body: CustomScrollView(
        slivers: [
          // Header Card
          SliverToBoxAdapter(
            child: Container(
              color: const Color(0xFF10B981).withOpacity(0.1),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '💰 Get Maximum Nutrition for Your Budget',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Find the most nutritious foods per rupee/dollar',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Budget Input Card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Monthly Budget',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Enter your budget',
                                  prefixText: '₹ ',
                                  border: InputBorder.none,
                                  hintStyle: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                              ),
                              child: const Text(
                                'Calculate',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Filter Chips
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filter by Value',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All', 'all'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Protein/₹', 'protein'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Carbs/₹', 'carbs'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Fiber/₹', 'fiber'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Best Value Foods List
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: const Text(
                'Best Value Foods',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),

          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final foods = [
                  {
                    'name': 'Rice (White)',
                    'price': '₹40/kg',
                    'protein': '6.6g',
                    'carbs': '80g',
                    'fiber': '0.4g',
                    'icon': '🍚',
                    'proteinValue': 165, // per rupee
                    'carbsValue': 2000,
                    'rating': 4.2,
                  },
                  {
                    'name': 'Dal (Lentils)',
                    'price': '₹120/kg',
                    'protein': '25g',
                    'carbs': '60g',
                    'fiber': '15g',
                    'icon': '🫘',
                    'proteinValue': 208,
                    'carbsValue': 500,
                    'rating': 4.8,
                  },
                  {
                    'name': 'Eggs',
                    'price': '₹50/piece',
                    'protein': '6.3g',
                    'carbs': '0.6g',
                    'fiber': '0g',
                    'icon': '🥚',
                    'proteinValue': 126,
                    'carbsValue': 12,
                    'rating': 4.9,
                  },
                  {
                    'name': 'Chicken Breast',
                    'price': '₹400/kg',
                    'protein': '31g',
                    'carbs': '0g',
                    'fiber': '0g',
                    'icon': '🍗',
                    'proteinValue': 77.5,
                    'carbsValue': 0,
                    'rating': 4.7,
                  },
                  {
                    'name': 'Cabbage',
                    'price': '₹20/kg',
                    'protein': '1.3g',
                    'carbs': '5.2g',
                    'fiber': '2.3g',
                    'icon': '🥬',
                    'proteinValue': 65,
                    'carbsValue': 260,
                    'rating': 4.1,
                  },
                  {
                    'name': 'Banana',
                    'price': '₹40/kg',
                    'protein': '1.1g',
                    'carbs': '23g',
                    'fiber': '2.6g',
                    'icon': '🍌',
                    'proteinValue': 27.5,
                    'carbsValue': 575,
                    'rating': 4.3,
                  },
                ];

                if (index >= foods.length) {
                  return const SizedBox.shrink();
                }

                final food = foods[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: _buildFoodCard(food),
                );
              },
              childCount: 6,
            ),
          ),

          // Meal Plan Suggestion
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF10B981).withOpacity(0.15),
                    const Color(0xFF059669).withOpacity(0.05),
                  ],
                ),
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
                        '📊',
                        style: TextStyle(fontSize: 28),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Daily Budget Meal Plan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildMealPlanItem(
                    '🌅 Breakfast (₹40)',
                    'Rice porridge with eggs and vegetables',
                    '350 cal | 12g protein | 45g carbs',
                  ),
                  const SizedBox(height: 12),
                  _buildMealPlanItem(
                    '🥗 Lunch (₹80)',
                    'Dal with rice and steamed cabbage',
                    '480 cal | 18g protein | 72g carbs',
                  ),
                  const SizedBox(height: 12),
                  _buildMealPlanItem(
                    '🍎 Snack (₹20)',
                    'Banana',
                    '89 cal | 1g protein | 23g carbs',
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Daily Total',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '₹140',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Nutrition',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '920 cal | 31g protein',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedFilter = value);
      },
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFF10B981),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey[700],
        fontWeight: FontWeight.bold,
      ),
      side: BorderSide(
        color: isSelected
            ? const Color(0xFF10B981)
            : Colors.grey.shade300,
      ),
    );
  }

  Widget _buildFoodCard(Map<String, dynamic> food) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                food['icon'].toString(),
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food['name'].toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      food['price'].toString(),
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
                  color: const Color(0xFF10B981).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.star,
                      color: Color(0xFF10B981),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      food['rating'].toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF10B981),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNutrientBadge(
                '🥤',
                'Protein',
                food['protein'].toString(),
              ),
              _buildNutrientBadge(
                '🍞',
                'Carbs',
                food['carbs'].toString(),
              ),
              _buildNutrientBadge(
                '🥗',
                'Fiber',
                food['fiber'].toString(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientBadge(String icon, String label, String value) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMealPlanItem(String title, String description, String nutrition) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
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
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            nutrition,
            style: const TextStyle(
              color: Color(0xFF10B981),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
