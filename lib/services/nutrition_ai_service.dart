import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NutritionService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser!.uid;

  Future<void> addMeal({
    required String mealName,
    required int calories,
    required int protein,
    required int carbs,
    required int fats,
  }) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('nutrition')
        .add({
      'mealName': mealName,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'timestamp': Timestamp.now(),
    });
  }

  Stream<QuerySnapshot> getMeals() {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('nutrition')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}