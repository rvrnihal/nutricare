import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/logger.dart';
import '../models/medicine_model.dart';

class MedicineFirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> _getUserMedicinesCollection() {
    return _db.collection('users').doc(_userId).collection('medicines');
  }

  /// Get stream of user's medicines
  Stream<List<Medicine>> getMedicines() {
    return _getUserMedicinesCollection().snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Medicine.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  /// Get a single medicine
  Future<Medicine?> getMedicine(String id) async {
    try {
      final doc = await _getUserMedicinesCollection().doc(id).get();
      if (doc.exists) {
        return Medicine.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e, st) {
      AppLogger.error('Error fetching medicine', e, st);
      rethrow;
    }
  }

  /// Add a new medicine
  Future<String> addMedicine(Medicine medicine) async {
    try {
      final docRef = await _getUserMedicinesCollection().add(medicine.toMap());
      AppLogger.info('Added medicine: ${medicine.name}');
      return docRef.id;
    } on FirebaseException catch (e, st) {
      AppLogger.error('Error adding medicine', e, st);
      rethrow;
    }
  }

  /// Update an existing medicine
  Future<void> updateMedicine(String id, Medicine medicine) async {
    try {
      await _getUserMedicinesCollection().doc(id).update(medicine.toMap());
      AppLogger.info('Updated medicine: ${medicine.name}');
    } on FirebaseException catch (e, st) {
      AppLogger.error('Error updating medicine', e, st);
      rethrow;
    }
  }

  /// Delete a medicine
  Future<void> deleteMedicine(String id) async {
    try {
      await _getUserMedicinesCollection().doc(id).delete();
      AppLogger.info('Deleted medicine with ID: $id');
    } on FirebaseException catch (e, st) {
      AppLogger.error('Error deleting medicine', e, st);
      rethrow;
    }
  }

  /// Mark medicine as taken
  Future<void> markAsTaken(String id) async {
    try {
      await _getUserMedicinesCollection().doc(id).update({
        'takenToday': true,
        'lastTaken': Timestamp.now(),
      });
      AppLogger.debug('Marked medicine as taken: $id');
    } on FirebaseException catch (e, st) {
      AppLogger.error('Error marking medicine as taken', e, st);
      rethrow;
    }
  }

  /// Reset medicine taken status for new day
  Future<void> resetDailyStatus(String id) async {
    try {
      await _getUserMedicinesCollection().doc(id).update({
        'takenToday': false,
      });
      AppLogger.debug('Reset medicine daily status: $id');
    } on FirebaseException catch (e, st) {
      AppLogger.error('Error resetting medicine status', e, st);
      rethrow;
    }
  }
}
