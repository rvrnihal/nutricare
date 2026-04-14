import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';

class HealthChartScreen extends StatelessWidget {
  const HealthChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Steps Progress")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('health_logs')
            .where('uid', isEqualTo: uid)
            .orderBy('date')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final spots = <FlSpot>[];
          for (int i = 0; i < snapshot.data!.docs.length; i++) {
            final steps = snapshot.data!.docs[i]['steps'] ?? 0;
            spots.add(FlSpot(i.toDouble(), steps.toDouble()));
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Colors.blue,
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
