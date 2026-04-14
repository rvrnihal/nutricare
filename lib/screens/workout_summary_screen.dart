import 'package:flutter/material.dart';
import 'package:nuticare/core/theme.dart';
import 'package:nuticare/models/workout_model.dart';
import 'package:share_plus/share_plus.dart';

class WorkoutSummaryScreen extends StatelessWidget {
  final WorkoutSession session;

  const WorkoutSummaryScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 🟢 Header
              const Text(
                "WORKOUT COMPLETED",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: NutriTheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                session.type.toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                  fontFamily: 'Outfit',
                ),
              ),
              const SizedBox(height: 40),

              // 🟢 Main Stat (Calories)
              _buildMainStat(),

              const SizedBox(height: 40),

              // 🟢 Grid Stats
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    _buildStatCard("DURATION",
                        _formatDuration(session.durationSeconds), Icons.timer),
                    _buildStatCard("AVG HEART RATE", "${session.heartRate} BPM",
                        Icons.favorite),
                    _buildStatCard(
                        "STEPS", "${session.steps}", Icons.directions_walk),
                    _buildStatCard(
                        "INTENSITY", "HIGH", Icons.battery_charging_full),
                  ],
                ),
              ),

              // 🟢 Buttons
              ElevatedButton.icon(
                onPressed: () {
                  SharePlus.instance.share(
                    ShareParams(
                      text:
                          "I just crushed a ${session.type} workout on NutriCare+! 🔥 ${session.caloriesBurned.toInt()} kcal burned.",
                    ),
                  );
                },
                icon: const Icon(Icons.share),
                label: const Text("SHARE SUMMARY"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade900,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: NutriTheme.primary,
                  foregroundColor: Colors.black,
                ),
                child: const Text("DONE"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainStat() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border:
            Border.all(color: NutriTheme.primary.withValues(alpha: 0.5), width: 4),
        gradient: RadialGradient(
          colors: [NutriTheme.primary.withValues(alpha: 0.2), Colors.transparent],
        ),
      ),
      child: Column(
        children: [
          Text(
            session.caloriesBurned.toInt().toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 64,
              fontWeight: FontWeight.bold,
              height: 1,
            ),
          ),
          const Text(
            "CALORIES",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: NutriTheme.primary, size: 20),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final int min = (seconds ~/ 60) % 60;
    final int hr = seconds ~/ 3600;
    if (hr > 0) return "${hr}h ${min}m";
    return "${min}m";
  }
}
