import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminCreateWorkoutScreen extends StatefulWidget {
  const AdminCreateWorkoutScreen({super.key});

  @override
  State<AdminCreateWorkoutScreen> createState() =>
      _AdminCreateWorkoutScreenState();
}

class _AdminCreateWorkoutScreenState
    extends State<AdminCreateWorkoutScreen> {
  final title = TextEditingController();
  String level = "Beginner";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Workout Plan")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: title,
              decoration: const InputDecoration(labelText: "Plan Title"),
            ),
            const SizedBox(height: 12),
            DropdownButton<String>(
              value: level,
              items: ["Beginner", "Intermediate", "Advanced"]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => level = v!),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('workout_plans')
                    .add({
                  'title': title.text,
                  'level': level,
                  'createdAt': FieldValue.serverTimestamp(),
                });
                Navigator.pop(context);
              },
              child: const Text("Create Plan"),
            )
          ],
        ),
      ),
    );
  }
}
