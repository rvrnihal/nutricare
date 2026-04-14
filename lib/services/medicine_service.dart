import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nuticare/models/medicine_model.dart';
import 'package:nuticare/services/medicine_notification_service.dart';

class MedicineService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser!.uid;

  /// Add a new medicine with reminder configuration
  Future<String> addMedicine({
    required String name,
    required String dosage,
    String type = 'tablet',
    required List<String> reminderTimes,
    String frequency = 'daily',
    DateTime? endDate,
    String? notes,
  }) async {
    final medicine = Medicine(
      id: '',
      name: name,
      dosage: dosage,
      type: type,
      reminderTimes: reminderTimes,
      frequency: frequency,
      startDate: DateTime.now(),
      endDate: endDate,
      notes: notes,
      createdAt: DateTime.now(),
    );

    final docRef = await _firestore
        .collection('users')
        .doc(uid)
        .collection('medicines')
        .add(medicine.toMap());

    // Schedule notifications for each reminder time
    for (int i = 0; i < reminderTimes.length; i++) {
      final timeParts = reminderTimes[i].split(':');
      if (timeParts.length == 2) {
        final hour = int.tryParse(timeParts[0]) ?? 0;
        final minute = int.tryParse(timeParts[1]) ?? 0;

        await MedicineNotificationService.scheduleDailyReminder(
          id: docRef.id.hashCode + i, // Unique ID for each reminder
          title: 'Medicine Reminder',
          body: 'Time to take $name ($dosage)',
          hour: hour,
          minute: minute,
        );
      }
    }

    return docRef.id;
  }

  /// Update an existing medicine
  Future<void> updateMedicine(Medicine medicine) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('medicines')
        .doc(medicine.id)
        .update(medicine.toMap());

    // Reschedule notifications
    await _rescheduleNotifications(medicine);
  }

  /// Delete a medicine
  Future<void> deleteMedicine(String medicineId) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('medicines')
        .doc(medicineId)
        .delete();

    // Cancel notifications
    await MedicineNotificationService.cancelMedicineReminders(medicineId);
  }

  /// Mark medicine as taken (creates a log entry)
  Future<void> markTaken(String medicineId, String medicineName) async {
    final log = MedicineLog(
      id: '',
      userId: uid,
      medicineId: medicineId,
      medicineName: medicineName,
      scheduledTime: DateTime.now(),
      takenTime: DateTime.now(),
      skipped: false,
    );

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('medicine_logs')
        .add(log.toMap());
  }

  /// Get all active medicines
  Stream<List<Medicine>> getMedicines() {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('medicines')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Medicine.fromFirestore(doc)).toList());
  }

  /// Get a specific medicine
  Future<Medicine?> getMedicine(String medicineId) async {
    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .collection('medicines')
        .doc(medicineId)
        .get();

    if (doc.exists) {
      return Medicine.fromFirestore(doc);
    }
    return null;
  }

  /// Calculate adherence for a specific medicine over the last N days
  Future<double> calculateAdherence(String medicineId, int days) async {
    final startDate = DateTime.now().subtract(Duration(days: days));
    final startOfPeriod =
        DateTime(startDate.year, startDate.month, startDate.day);

    final logsSnapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('medicine_logs')
        .where('medicineId', isEqualTo: medicineId)
        .where('scheduledTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfPeriod))
        .get();

    if (logsSnapshot.docs.isEmpty) return 0.0;

    final totalScheduled = logsSnapshot.docs.length;
    final totalTaken = logsSnapshot.docs
        .where((doc) => (doc.data()['takenTime'] != null))
        .length;

    return (totalTaken / totalScheduled) * 100;
  }

  /// Reschedule notifications for a medicine
  Future<void> _rescheduleNotifications(Medicine medicine) async {
    // Cancel existing notifications
    await MedicineNotificationService.cancelMedicineReminders(medicine.id);

    // Schedule new notifications
    for (int i = 0; i < medicine.reminderTimes.length; i++) {
      final timeParts = medicine.reminderTimes[i].split(':');
      if (timeParts.length == 2) {
        final hour = int.tryParse(timeParts[0]) ?? 0;
        final minute = int.tryParse(timeParts[1]) ?? 0;

        await MedicineNotificationService.scheduleDailyReminder(
          id: medicine.id.hashCode + i,
          title: 'Medicine Reminder',
          body: 'Time to take ${medicine.name} (${medicine.dosage})',
          hour: hour,
          minute: minute,
        );
      }
    }
  }
}
