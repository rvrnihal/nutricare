import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CoachChatScreen extends StatefulWidget {
  const CoachChatScreen({super.key});

  @override
  State<CoachChatScreen> createState() => _CoachChatScreenState();
}

class _CoachChatScreenState extends State<CoachChatScreen> {
  final controller = TextEditingController();
  final uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Coach Chat")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('coach_chats')
                  .doc(uid)
                  .collection('messages')
                  .orderBy('time')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView(
                  padding: const EdgeInsets.all(12),
                  children: snapshot.data!.docs.map((doc) {
                    final isUser = doc['sender'] == 'user';
                    return Align(
                      alignment:
                          isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isUser
                              ? Colors.deepPurple
                              : const Color.fromARGB(255, 255, 255, 255),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          doc['text'],
                          style: TextStyle(
                            color: isUser ? const Color.fromARGB(255, 253, 253, 253) : Colors.black,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          _inputBar(),
        ],
      ),
    );
  }

  Widget _inputBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration:
                const InputDecoration(hintText: "Type message..."),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.send),
          onPressed: _send,
        ),
      ],
    );
  }

  Future<void> _send() async {
    if (controller.text.trim().isEmpty) return;

    await FirebaseFirestore.instance
        .collection('coach_chats')
        .doc(uid)
        .collection('messages')
        .add({
      'text': controller.text.trim(),
      'sender': 'user',
      'time': FieldValue.serverTimestamp(),
    });

    controller.clear();
  }
}
