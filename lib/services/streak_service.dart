import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StreakService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  /// 🔥 Stream current streak (used in Home screen)
  static Stream<int> streakStream() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return const Stream<int>.empty();
    }

    return _firestore
        .collection("streaks")
        .doc(uid)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return 0;
      return doc['count'] ?? 0;
    });
  }

  /// ✅ INCREMENT STREAK (CALLED AFTER WORKOUT)
  static Future<void> incrementStreak() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final ref = _firestore.collection("streaks").doc(uid);
    final today = DateTime.now().toIso8601String().substring(0, 10);

    final snap = await ref.get();

    if (!snap.exists) {
      // first ever streak
      await ref.set({
        "count": 1,
        "lastDate": today,
      });
      return;
    }

    final data = snap.data()!;
    final lastDate = data['lastDate'];
    int count = data['count'] ?? 0;

    if (lastDate == today) {
      // already counted today → do nothing
      return;
    }

    // check if yesterday
    final yesterday = DateTime.now()
        .subtract(const Duration(days: 1))
        .toIso8601String()
        .substring(0, 10);

    if (lastDate == yesterday) {
      count += 1; // continue streak
    } else {
      count = 1; // reset streak
    }

    await ref.update({
      "count": count,
      "lastDate": today,
    });
  }
}
