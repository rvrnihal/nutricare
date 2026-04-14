import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AIHistoryService {
  static Future<void> saveChat(
      String question, String answer) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('ai_chats')
        .add({
      'question': question,
      'answer': answer,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<List<Map<String, dynamic>>> getRecentChats({int limit = 50}) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return [];

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('ai_chats')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      debugPrint('Error loading recent chats: $e');
      return [];
    }
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getChatHistory() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('ai_chats')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
