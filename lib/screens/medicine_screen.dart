import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nuticare/core/theme.dart';
import 'package:nuticare/services/trained_ai_service.dart';

class MedicineScreen extends StatefulWidget {
  const MedicineScreen({super.key});

  @override
  State<MedicineScreen> createState() => _MedicineScreenState();
}

class _MedicineScreenState extends State<MedicineScreen> {
  final TextEditingController _aiController = TextEditingController();
  bool _isAiLoading = false;

  void _showAddMedicineDialog() {
    final nameController = TextEditingController();
    final dosageController = TextEditingController();
    final timeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Medicine"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Medicine Name")),
            TextField(
                controller: dosageController,
                decoration:
                    const InputDecoration(labelText: "Dosage (e.g. 500mg)")),
            TextField(
                controller: timeController,
                decoration:
                    const InputDecoration(labelText: "Time (e.g. 8:00 AM)")),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .collection('medicines')
                      .add({
                    'name': nameController.text,
                    'dosage': dosageController.text,
                    'time': timeController.text,
                    'createdAt': FieldValue.serverTimestamp(),
                  });
                }
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  Future<void> _askAiAboutMedicine(String medicineName) async {
    setState(() => _isAiLoading = true);
    try {
      // Use the new method with Groq fallback
      final medicineInfo =
          await TrainedAIService.getMedicineDetailsWithGroqFallback(medicineName);
      _showMedicineDetailsDialog(medicineInfo);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isAiLoading = false);
    }
  }

  void _showMedicineDetailsDialog(Map<String, dynamic> medicineInfo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: NutriTheme.surface,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.medication, color: Colors.blue, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                medicineInfo['medicineName'] ?? 'Medicine Info',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Medicine Details
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: Text(
                  medicineInfo['details'] ?? 'No information available',
                  style: const TextStyle(
                    color: Colors.white,
                    height: 1.6,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Warning Banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Always consult your doctor before taking any medicine",
                        style: TextStyle(
                          color: Colors.orange.shade400,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close",
                style: TextStyle(color: NutriTheme.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: NutriTheme.background,
      appBar: AppBar(
        title: Text("My Medications",
            style: NutriTheme.textTheme.displayMedium?.copyWith(fontSize: 24)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddMedicineDialog,
        backgroundColor: NutriTheme.primary,
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text("Add Med",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // 🟢 AI Quick Ask Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _aiController,
                    style: const TextStyle(
                        color: Colors.white), // White text for Dark Mode
                    decoration: InputDecoration(
                      hintText: "Ask AI about any medicine...",
                      hintStyle: TextStyle(color: Colors.grey.shade600),
                      filled: true,
                      fillColor: NutriTheme.surface, // Dark Surface
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none),
                      prefixIcon:
                          const Icon(Icons.auto_awesome, color: Colors.purple),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (_isAiLoading)
                  const CircularProgressIndicator()
                else
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.purple),
                    onPressed: () {
                      if (_aiController.text.isNotEmpty) {
                        _askAiAboutMedicine(_aiController.text);
                        _aiController.clear();
                      }
                    },
                  ),
              ],
            ),
          ),

          // 🟢 Medicine List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user?.uid)
                  .collection('medicines')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.medication,
                            size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text("No medicines added",
                            style: NutriTheme.textTheme.bodyMedium),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final data = snapshot.data!.docs[index].data()
                        as Map<String, dynamic>;
                    final name = data['name'] ?? 'Medicine';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: NutriTheme.surface, // Dark Card
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              shape: BoxShape.circle),
                          child: const Icon(Icons.medication_liquid,
                              color: Colors.blue),
                        ),
                        title: Text(name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.white)),
                        subtitle: Text("${data['dosage']} • ${data['time']}",
                            style: TextStyle(color: Colors.grey.shade400)),
                        trailing: IconButton(
                          icon: const Icon(Icons.info_outline,
                              color: Colors.purple),
                          tooltip: "Ask AI",
                          onPressed: () => _askAiAboutMedicine(name),
                        ),
                      ),
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
