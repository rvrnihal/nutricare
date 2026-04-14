import 'package:flutter/material.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Health Games")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _streakBox(),
            const SizedBox(height: 16),
            _challengeTile("Step Challenge", "5,000 steps today"),
            _challengeTile("Hydration Challenge", "Drink 8 glasses"),
            _challengeTile("Workout Streak", "7 days active"),
          ],
        ),
      ),
    );
  }

  Widget _streakBox() {
    return TextField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: "Current Streak",
        hintText: "🔥 7 Days",
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _challengeTile(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.emoji_events),
      ),
    );
  }
}
