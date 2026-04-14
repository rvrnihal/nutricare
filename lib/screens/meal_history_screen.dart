import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/meal_service.dart';

class MealHistoryScreen extends StatelessWidget {
  const MealHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Meal History")),
      body: StreamBuilder<QuerySnapshot>(
        stream: MealService.mealHistory(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              return ListTile(
                title: Text(doc["food"]),
                subtitle: Text(
                    "Calories: ${doc["nutrition"]["calories"]}"),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
