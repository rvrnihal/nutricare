import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/medicine_model.dart';
import '../services/medicine_firestore_service.dart';
import '../core/logger.dart';

class MedicineProvider extends ChangeNotifier {
  final MedicineFirestoreService _service = MedicineFirestoreService();
  
  List<Medicine> _medicines = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Medicine> get medicines => _medicines;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Stream getters
  Stream<List<Medicine>> get medicinesStream => _service.getMedicines();

  // Initialize with user medicines
  Future<void> initializeMedicines() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Load initial medicines
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('medicines')
          .get();

      _medicines = snapshot.docs
          .map((doc) => Medicine.fromMap(doc.data(), doc.id))
          .toList();

      AppLogger.info('Loaded ${_medicines.length} medicines');
    } catch (e, st) {
      _error = e.toString();
      AppLogger.error('Failed to initialize medicines', e, st);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add medicine
  Future<void> addMedicine({
    required String name,
    required String dosage,
    required List<String> reminderTimes,
    String? notes,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final medicine = Medicine(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        dosage: dosage,
        reminderTimes: reminderTimes,
        startDate: DateTime.now(),
        notes: notes,
        createdAt: DateTime.now(),
      );

      await _service.addMedicine(medicine);
      _medicines.add(medicine);

      AppLogger.info('Added medicine: $name');
    } catch (e, st) {
      _error = e.toString();
      AppLogger.error('Failed to add medicine', e, st);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update medicine
  Future<void> updateMedicine(Medicine medicine) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await _service.updateMedicine(medicine.id, medicine);
      
      final index = _medicines.indexWhere((m) => m.id == medicine.id);
      if (index >= 0) {
        _medicines[index] = medicine;
      }

      AppLogger.info('Updated medicine: ${medicine.name}');
    } catch (e, st) {
      _error = e.toString();
      AppLogger.error('Failed to update medicine', e, st);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete medicine
  Future<void> deleteMedicine(String id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _service.deleteMedicine(id);
      _medicines.removeWhere((m) => m.id == id);

      AppLogger.info('Deleted medicine with id: $id');
    } catch (e, st) {
      _error = e.toString();
      AppLogger.error('Failed to delete medicine', e, st);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mark as taken
  Future<void> markAsTaken(String medicineId, String medicineName) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('medicine_logs')
          .add({
        'medicineId': medicineId,
        'medicineName': medicineName,
        'takenAt': FieldValue.serverTimestamp(),
      });

      AppLogger.info('Marked $medicineName as taken');
    } catch (e, st) {
      _error = e.toString();
      AppLogger.error('Failed to mark medicine as taken', e, st);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get medicine by ID
  Medicine? getMedicineById(String id) {
    try {
      return _medicines.firstWhere((m) => m.id == id);
    } catch (e) {
      return null;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
