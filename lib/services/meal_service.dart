import 'package:cloud_firestore/cloud_firestore.dart';

class MealService {
  static final _db = FirebaseFirestore.instance;

  static Future<void> logMeal(
      String food, Map<String, dynamic> nutrition) async {
    await _db.collection("meals").add({
      "food": food,
      "nutrition": nutrition,
      "timestamp": FieldValue.serverTimestamp(),
    });
  }

  static Stream<QuerySnapshot> mealHistory() {
    return _db
        .collection("meals")
        .orderBy("timestamp", descending: true)
        .snapshots();
  }
}
