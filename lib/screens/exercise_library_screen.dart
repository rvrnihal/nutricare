import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExerciseLibraryScreen extends StatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  State<ExerciseLibraryScreen> createState() =>
      _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  String query = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Exercise Library")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: "Search exercises...",
              ),
              onChanged: (v) => setState(() => query = v.toLowerCase()),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('exercises')
                  .snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snap.data!.docs.where((d) {
                  final name =
                      (d['name'] ?? '').toString().toLowerCase();
                  return name.contains(query);
                }).toList();

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final e = docs[i];
                    return ListTile(
                      leading: const Icon(Icons.fitness_center),
                      title: Text(e['name']),
                      subtitle: Text(e['muscle']),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
