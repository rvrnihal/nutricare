import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProgressService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser!.uid;

  Future<void> addProgress(double weight, double bodyFat) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('progress')
        .add({
      'weight': weight,
      'bodyFat': bodyFat,
      'date': Timestamp.now(),
    });
  }
}