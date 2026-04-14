import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WeeklyPlanScreen extends StatelessWidget {
  const WeeklyPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Weekly Plan")),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('workout_plans').snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final plans = snap.data!.docs;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: plans.map((p) {
              final data = p.data() as Map<String, dynamic>;
              return Card(
                child: ListTile(
                  title: Text(data['title']),
                  subtitle: Text("Level: ${data['level']}"),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
