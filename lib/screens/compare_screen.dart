import 'package:flutter/material.dart';
import '../services/groq_ai_service.dart';

class CompareScreen extends StatelessWidget {
  final String food1;
  final String food2;

  const CompareScreen({super.key, required this.food1, required this.food2});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Compare Foods")),
      body: FutureBuilder(
        future: GroqAIService.askAI("""
Compare $food1 and $food2 nutritionally.
Return which is healthier and why.
"""),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(snapshot.data.toString()),
          );
        },
      ),
    );
  }
}
