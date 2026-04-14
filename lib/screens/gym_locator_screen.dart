import 'package:flutter/material.dart';
import 'package:nuticare/core/theme.dart';

class GymLocatorScreen extends StatelessWidget {
  const GymLocatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Find Gyms")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.map, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text("Gym Locator", style: NutriTheme.textTheme.displayMedium),
            const SizedBox(height: 8),
            const Text("Map integration requires valid API Key."),
          ],
        ),
      ),
    );
  }
}
