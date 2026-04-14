import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';

class MedicineAnalyticsScreen extends StatelessWidget {
  const MedicineAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Weekly Medicine Analytics")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('medicines')
            .doc(uid)
            .collection('items')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final taken = snapshot.data!.docs
              .where((d) => d['taken'] == true)
              .length;
          final missed = snapshot.data!.docs.length - taken;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: taken.toDouble(),
                    title: "Taken",
                    color: Colors.green,
                    radius: 70,
                  ),
                  PieChartSectionData(
                    value: missed.toDouble(),
                    title: "Missed",
                    color: Colors.red,
                    radius: 70,
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
