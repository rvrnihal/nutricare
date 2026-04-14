import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';

class WorkoutProgressScreen extends StatelessWidget {
  const WorkoutProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Workout Progress")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('workout_logs')
            .where('uid', isEqualTo: uid)
            .orderBy('date')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          final spots = <FlSpot>[];

          for (int i = 0; i < docs.length; i++) {
            final calories = (docs[i]['calories'] ?? 0).toDouble();
            spots.add(FlSpot(i.toDouble(), calories));
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(show: true),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Colors.deepPurple,
                    barWidth: 4,
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
