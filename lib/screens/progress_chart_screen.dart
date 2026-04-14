import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';

class ProgressChartScreen extends StatelessWidget {
  const ProgressChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Workout Progress")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('user_workouts')
            .doc(uid)
            .collection('history')
            .orderBy('date')
            .snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final spots = snap.data!.docs.asMap().entries.map((e) {
            return FlSpot(
              e.key.toDouble(),
              (e.value['calories'] ?? 0).toDouble(),
            );
          }).toList();

          return Padding(
            padding: const EdgeInsets.all(16),
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Colors.deepPurple,
                    barWidth: 3,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
