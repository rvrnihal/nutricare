import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WeeklyPlanService {
  static final _db = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static Future<void> assignWeeklyPlan() async {
    final uid = _auth.currentUser!.uid;
    final week = DateTime.now().weekday;

    if (week != DateTime.monday) return;

    await _db.collection('weekly_plans').doc(uid).set({
      'week': DateTime.now().toIso8601String(),
      'workouts': [
        "Chest + Triceps",
        "Back + Biceps",
        "Leg Day",
        "Core + Cardio",
        "Shoulders",
      ],
    });
  }

  static Stream<DocumentSnapshot> planStream() {
    final uid = _auth.currentUser!.uid;
    return _db.collection('weekly_plans').doc(uid).snapshots();
  }
}
