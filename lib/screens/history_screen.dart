import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nuticare/core/theme.dart';
import 'package:intl/intl.dart';
import 'package:nuticare/services/user_history_service.dart';
import 'package:nuticare/models/nutrition_log_model.dart';
import 'package:nuticare/models/medicine_model.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Changed from 2 to 3
      child: Scaffold(
        backgroundColor: NutriTheme.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text("History & Records",
              style:
                  NutriTheme.textTheme.displayMedium?.copyWith(fontSize: 20)),
          centerTitle: true,
          bottom: const TabBar(
            labelColor: NutriTheme.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: NutriTheme.primary,
            tabs: [
              Tab(text: "Workouts"),
              Tab(text: "Nutrition"),
              Tab(text: "Medicines"), // Added tab
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _WorkoutHistoryList(),
            _NutritionHistoryList(),
            _MedicineHistoryList(), // Added tab
          ],
        ),
      ),
    );
  }
}

class _WorkoutHistoryList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Center(child: Text("Please log in"));

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('workouts')
          .orderBy('startTime', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.fitness_center,
                    size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text("No workouts yet", style: NutriTheme.textTheme.bodyMedium),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final date = (data['startTime'] as Timestamp).toDate();

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: NutriTheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.fitness_center, color: Colors.black),
                ),
                title: Text(
                  data['type'] ?? 'Workout',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(DateFormat.yMMMd().add_jm().format(date)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildTag("${data['durationSeconds'] ~/ 60} min",
                            Colors.blue),
                        const SizedBox(width: 8),
                        _buildTag(
                            "${(data['caloriesBurned'] as num).toInt()} kcal",
                            Colors.orange),
                      ],
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

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style:
            TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _NutritionHistoryList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Center(child: Text("Please log in"));

    final historyService = UserHistoryService();

    return StreamBuilder<List<NutritionLog>>(
      stream: historyService.getNutritionLogsForDate(DateTime.now()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.restaurant, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text("No meals logged today",
                    style: NutriTheme.textTheme.bodyMedium),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final log = snapshot.data![index];

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              color: NutriTheme.surface,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: NutriTheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.restaurant, color: Colors.orange),
                ),
                title: Text(log.foodName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                        "${log.mealType.toUpperCase()} • ${DateFormat.jm().format(log.timestamp)}",
                        style: TextStyle(color: Colors.grey.shade400)),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildNutrientTag(
                            "${log.calories} kcal", Colors.orange),
                        _buildNutrientTag(
                            "P: ${log.protein.toInt()}g", Colors.blue),
                        _buildNutrientTag(
                            "C: ${log.carbs.toInt()}g", Colors.green),
                        _buildNutrientTag("F: ${log.fat.toInt()}g", Colors.red),
                      ],
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

  Widget _buildNutrientTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style:
            TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _MedicineHistoryList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Center(child: Text("Please log in"));

    final historyService = UserHistoryService();

    return StreamBuilder<List<MedicineLog>>(
      stream: historyService.getTodaysMedicineLogs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.medication, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text("No medicines logged today",
                    style: NutriTheme.textTheme.bodyMedium),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final log = snapshot.data![index];
            final isTaken = log.isTaken;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              color: NutriTheme.surface,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isTaken
                        ? Colors.green.withValues(alpha: 0.1)
                        : log.skipped
                            ? Colors.red.withValues(alpha: 0.1)
                            : Colors.grey.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isTaken
                        ? Icons.check_circle
                        : log.skipped
                            ? Icons.cancel
                            : Icons.schedule,
                    color: isTaken
                        ? Colors.green
                        : log.skipped
                            ? Colors.red
                            : Colors.grey,
                  ),
                ),
                title: Text(log.medicineName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      isTaken
                          ? "Taken at ${DateFormat.jm().format(log.takenTime!)}"
                          : log.skipped
                              ? "Skipped"
                              : "Scheduled for ${DateFormat.jm().format(log.scheduledTime)}",
                      style: TextStyle(color: Colors.grey.shade400),
                    ),
                  ],
                ),
                trailing: isTaken
                    ? const Icon(Icons.check, color: Colors.green)
                    : log.skipped
                        ? const Icon(Icons.close, color: Colors.red)
                        : const Icon(Icons.radio_button_unchecked,
                            color: Colors.grey),
              ),
            );
          },
        );
      },
    );
  }
}
