import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/meal_planner_service.dart';

class MealPlannerScreen extends StatefulWidget {
  const MealPlannerScreen({super.key});

  @override
  State<MealPlannerScreen> createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends State<MealPlannerScreen> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Meal Planner"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.restaurant),
              label: const Text("Generate Weekly Plan"),
              onPressed: loading ? null : _generate,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('meal_plans')
                    .doc(uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData ||
                      snapshot.data!.data() == null) {
                    return const Text("No meal plan yet");
                  }

                  final data =
                      snapshot.data!.data() as Map<String, dynamic>;

                  return SingleChildScrollView(
                    child: Text(data['plan'] ?? ""),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generate() async {
    setState(() => loading = true);
    try {
      await MealPlannerService.generateWeeklyPlan();
    } catch (_) {}
    setState(() => loading = false);
  }
}
