import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Panel")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snap.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, i) {
              final u = users[i].data() as Map<String, dynamic>;
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(u['name'] ?? 'User'),
                  subtitle: Text(u['email'] ?? ''),
                  trailing: Chip(
                    label: Text(u['role'] ?? 'user'),
                    backgroundColor: u['role'] == 'admin'
                        ? Colors.redAccent
                        : Colors.grey.shade300,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
