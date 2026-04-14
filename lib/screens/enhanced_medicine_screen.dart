import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nuticare/core/theme.dart';
import 'package:nuticare/services/groq_ai_service.dart';
import 'package:nuticare/services/medicine_service.dart';
import 'package:nuticare/models/medicine_model.dart';

class EnhancedMedicineScreen extends StatefulWidget {
  const EnhancedMedicineScreen({super.key});

  @override
  State<EnhancedMedicineScreen> createState() => _EnhancedMedicineScreenState();
}

class _EnhancedMedicineScreenState extends State<EnhancedMedicineScreen> {
  final TextEditingController _aiController = TextEditingController();
  final MedicineService _medicineService = MedicineService();
  bool _isAiLoading = false;

  void _showAddMedicineDialog() {
    final nameController = TextEditingController();
    final dosageController = TextEditingController();
    final List<TimeOfDay> reminderTimes = [TimeOfDay.now()];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: NutriTheme.surface,
          title:
              const Text("Add Medicine", style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Medicine Name",
                    labelStyle: TextStyle(color: Colors.grey.shade400),
                    filled: true,
                    fillColor: Colors.grey.shade900,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: dosageController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Dosage (e.g. 500mg)",
                    labelStyle: TextStyle(color: Colors.grey.shade400),
                    filled: true,
                    fillColor: Colors.grey.shade900,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                const Text("Reminder Times",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...reminderTimes.asMap().entries.map((entry) {
                  final index = entry.key;
                  final time = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: time,
                              );
                              if (picked != null) {
                                setState(() {
                                  reminderTimes[index] = picked;
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade900,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.access_time,
                                      color: NutriTheme.primary),
                                  const SizedBox(width: 8),
                                  Text(time.format(context),
                                      style:
                                          const TextStyle(color: Colors.white)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (reminderTimes.length > 1)
                          IconButton(
                            icon: const Icon(Icons.remove_circle,
                                color: Colors.red),
                            onPressed: () {
                              setState(() {
                                reminderTimes.removeAt(index);
                              });
                            },
                          ),
                      ],
                    ),
                  );
                }),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      reminderTimes.add(TimeOfDay.now());
                    });
                  },
                  icon: const Icon(Icons.add, color: NutriTheme.primary),
                  label: const Text("Add Another Time",
                      style: TextStyle(color: NutriTheme.primary)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(backgroundColor: NutriTheme.primary),
              onPressed: () async {
                if (nameController.text.isNotEmpty &&
                    dosageController.text.isNotEmpty) {
                  final timeStrings = reminderTimes
                      .map((t) =>
                          "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}")
                      .toList();

                  await _medicineService.addMedicine(
                    name: nameController.text,
                    dosage: dosageController.text,
                    reminderTimes: timeStrings,
                  );

                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Medicine added with reminders!")),
                    );
                  }
                }
              },
              child: const Text("Add", style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _askAiAboutMedicine(String medicineName) async {
    setState(() => _isAiLoading = true);
    try {
      final response = await GroqAIService.askAI(
          "Provide specific medical information about the medicine '$medicineName'. Include:\n"
          "1. What it's used for (main indications)\n"
          "2. Common dosage range\n"
          "3. Specific side effects for THIS medicine (not generic)\n"
          "4. Important warnings or precautions\n"
          "Keep it concise but specific to $medicineName only.");
      _showAiResponseDialog(medicineName, response);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("AI Error: $e")));
    } finally {
      setState(() => _isAiLoading = false);
    }
  }

  void _showAiResponseDialog(String medicineName, String response) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: NutriTheme.surface,
        title: Text("AI Info: $medicineName",
            style: const TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Text(response, style: const TextStyle(color: Colors.white)),
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

  void _showMedicineOptions(Medicine medicine) {
    showModalBottomSheet(
      context: context,
      backgroundColor: NutriTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: const Text("Mark as Taken",
                  style: TextStyle(color: Colors.white)),
              onTap: () async {
                await _medicineService.markTaken(medicine.id, medicine.name);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("${medicine.name} marked as taken")),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.purple),
              title:
                  const Text("Ask AI", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _askAiAboutMedicine(medicine.name);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title:
                  const Text("Delete", style: TextStyle(color: Colors.white)),
              onTap: () async {
                Navigator.pop(context);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Confirm Delete"),
                    content: Text(
                        "Are you sure you want to delete ${medicine.name}?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text("Delete"),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await _medicineService.deleteMedicine(medicine.id);
                }
              },
            ),
          ],
        ),
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
          // AI Quick Ask Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _aiController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Ask AI about any medicine...",
                      hintStyle: TextStyle(color: Colors.grey.shade600),
                      filled: true,
                      fillColor: NutriTheme.surface,
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

          // Medicine List
          Expanded(
            child: StreamBuilder<List<Medicine>>(
              stream: _medicineService.getMedicines(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
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
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final medicine = snapshot.data![index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: NutriTheme.surface,
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
                        title: Text(medicine.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.white)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${medicine.dosage} • ${medicine.type}",
                                style: TextStyle(color: Colors.grey.shade400)),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 4,
                              children: medicine.reminderTimes
                                  .map((time) => Chip(
                                        label: Text(time,
                                            style: const TextStyle(
                                                fontSize: 10,
                                                color: Colors.white)),
                                        backgroundColor:
                                            NutriTheme.primary.withValues(alpha: 0.3),
                                        padding: EdgeInsets.zero,
                                      ))
                                  .toList(),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon:
                              const Icon(Icons.more_vert, color: Colors.white),
                          onPressed: () => _showMedicineOptions(medicine),
                        ),
                        onTap: () => _showMedicineOptions(medicine),
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
