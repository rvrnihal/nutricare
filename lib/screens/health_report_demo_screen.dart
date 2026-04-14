import 'package:flutter/material.dart';
import 'package:nuticare/core/theme.dart';
import 'package:nuticare/screens/health_report_web_upload_screen.dart';

/// Demo/Test page for web health report upload
class HealthReportDemoScreen extends StatelessWidget {
  const HealthReportDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NutriTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("NutriCare Health Report System",
            style: NutriTheme.textTheme.displayMedium?.copyWith(fontSize: 20)),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Welcome message
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: NutriTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(Icons.health_and_safety,
                        size: 64, color: NutriTheme.primary),
                    const SizedBox(height: 16),
                    Text(
                      "Health Report Analysis",
                      style: NutriTheme.textTheme.displayMedium
                          ?.copyWith(fontSize: 24),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Upload or manually enter your health metrics for AI-powered analysis",
                      style: NutriTheme.textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const HealthReportWebUploadScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: NutriTheme.primary,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Start Analysis",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Features list
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: NutriTheme.surface.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Features",
                      style: NutriTheme.textTheme.displayMedium
                          ?.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 16),
                    _featureItem(Icons.image, "Upload Report",
                        "Upload health report images"),
                    _featureItem(Icons.edit, "Manual Entry",
                        "Enter health values directly"),
                    _featureItem(Icons.analytics, "Health Analysis",
                        "18+ condition detection"),
                    _featureItem(Icons.lightbulb, "Recommendations",
                        "Personalized health advice"),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Test Values (for demo)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          "Test Values (Sample)",
                          style: NutriTheme.textTheme.bodyMedium
                              ?.copyWith(color: Colors.blue),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Try these values to test:\nGlucose: 140, Hemoglobin: 13.5, Cholesterol: 250, BP: 140/90",
                      style: TextStyle(color: Colors.blue, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _featureItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: NutriTheme.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: NutriTheme.textTheme.bodyMedium),
                Text(subtitle,
                    style: NutriTheme.textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
