import 'package:cloud_firestore/cloud_firestore.dart';

class TrainerChatService {
  static final _db = FirebaseFirestore.instance;

  static Stream<QuerySnapshot> getMessages(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots();
  }

  static Future<void> sendMessage(
    String chatId,
    String text,
    String senderId,
  ) async {
    await _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'text': text,
      'senderId': senderId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
