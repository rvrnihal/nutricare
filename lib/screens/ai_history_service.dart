import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AIHistoryService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Save a chat message to user's history
  static Future<void> saveChat(String question, String answer) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      
      if (uid == null) {
        throw Exception('User not authenticated');
      }

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('ai_chats')
          .add({
        'question': question,
        'answer': answer,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to save chat: $e');
    }
  }

  /// Get chat history stream for current user (newest first)
  static Stream<QuerySnapshot<Map<String, dynamic>>> getChatHistory() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    
    if (uid == null) {
      throw Exception('User not authenticated');
    }

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('ai_chats')
        .orderBy('createdAt', descending: true)
        .limit(100) // Limit to last 100 conversations
        .snapshots();
  }

  /// Get specific number of recent chats
  static Future<List<Map<String, dynamic>>> getRecentChats({int limit = 10}) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      
      if (uid == null) {
        throw Exception('User not authenticated');
      }

      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('ai_chats')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();
    } catch (e) {
      throw Exception('Failed to load recent chats: $e');
    }
  }

  /// Delete a specific chat by ID
  static Future<void> deleteChat(String chatId) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      
      if (uid == null) {
        throw Exception('User not authenticated');
      }

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('ai_chats')
          .doc(chatId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete chat: $e');
    }
  }

  /// Clear all chat history for current user
  static Future<void> clearAllHistory() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      
      if (uid == null) {
        throw Exception('User not authenticated');
      }

      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('ai_chats')
          .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to clear history: $e');
    }
  }

  /// Search chat history by keyword
  static Future<List<Map<String, dynamic>>> searchChats(String keyword) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      
      if (uid == null) {
        throw Exception('User not authenticated');
      }

      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('ai_chats')
          .orderBy('createdAt', descending: true)
          .get();

      // Client-side filtering (Firestore doesn't support text search natively)
      return snapshot.docs
          .where((doc) {
            final data = doc.data();
            final question = (data['question'] ?? '').toString().toLowerCase();
            final answer = (data['answer'] ?? '').toString().toLowerCase();
            final searchTerm = keyword.toLowerCase();
            
            return question.contains(searchTerm) || answer.contains(searchTerm);
          })
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();
    } catch (e) {
      throw Exception('Failed to search chats: $e');
    }
  }

  /// Get chat statistics
  static Future<Map<String, dynamic>> getChatStats() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      
      if (uid == null) {
        throw Exception('User not authenticated');
      }

      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('ai_chats')
          .get();

      final totalChats = snapshot.docs.length;
      
      // Get today's chats
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      
      final todayChats = snapshot.docs.where((doc) {
        final data = doc.data();
        final timestamp = data['createdAt'];
        if (timestamp == null) return false;
        
        final date = (timestamp as Timestamp).toDate();
        return date.isAfter(startOfDay);
      }).length;

      return {
        'totalChats': totalChats,
        'todayChats': todayChats,
      };
    } catch (e) {
      throw Exception('Failed to get chat stats: $e');
    }
  }
}