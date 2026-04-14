import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WorkoutService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser!.uid;

  Future<void> addWorkout({
    required String title,
    required int duration,
    required int calories,
  }) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('workouts')
        .add({
      'title': title,
      'duration': duration,
      'caloriesBurned': calories,
      'date': Timestamp.now(),
      'status': 'completed',
    });
  }

  Stream<QuerySnapshot> getWorkouts() {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('workouts')
        .orderBy('date', descending: true)
        .snapshots();
  }
}