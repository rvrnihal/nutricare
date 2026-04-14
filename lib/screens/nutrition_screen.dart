import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:nuticare/core/theme.dart';
import 'package:nuticare/components/glass_card.dart';
import 'package:nuticare/services/groq_ai_service.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nuticare/services/interaction_service.dart';
import 'package:nuticare/services/user_history_service.dart';
import 'package:nuticare/services/daily_nutrition_service.dart';
import 'package:nuticare/services/user_data_persistence_service.dart';
import 'package:nuticare/models/nutrition_log_model.dart';
import 'package:nuticare/models/interaction_model.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  bool _isLoading = false;
  late TextEditingController _allergyController;
  int _calorieGoal = 2000;
  String _fitnessGoal = 'maintain';

  late TextEditingController mealNameController;
  late TextEditingController caloriesController;
  late TextEditingController proteinController;
  late TextEditingController carbsController;
  late TextEditingController fatController;

  @override
  void initState() {
    super.initState();
    _allergyController = TextEditingController();
    mealNameController = TextEditingController();
    caloriesController = TextEditingController();
    proteinController = TextEditingController();
    carbsController = TextEditingController();
    fatController = TextEditingController();
  }

  @override
  void dispose() {
    _allergyController.dispose();
    mealNameController.dispose();
    caloriesController.dispose();
    proteinController.dispose();
    carbsController.dispose();
    fatController.dispose();
    super.dispose();
  }

  Future<void> _scanFood() async {
    // Determine source (Camera/Gallery) - Simple MVP: Show dialog
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: NutriTheme.surface, // Dark Surface for visibility
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("AI Food Scanner",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.blue),
              title: const Text("Take Photo"),
              onTap: () {
                Navigator.pop(context);
                _processImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.purple),
              title: const Text("Upload from Gallery"),
              onTap: () {
                Navigator.pop(context);
                _processImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processImage(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source);

    if (image != null) {
      setState(() => _isLoading = true);
      try {
        final bytes = await image.readAsBytes();
        final base64Image = base64Encode(bytes);

        // Try AI image analysis first
        try {
          final foodName = await GroqAIService.analyzeImageFood(base64Image);

          if (mounted) {
            _showFoodAnalysisDialog(foodName);
          }
        } catch (aiError) {
          // If AI fails, offer manual input
          if (mounted) {
            setState(() => _isLoading = false);
            _showManualFoodInput();
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error processing image: ${e.toString()}"),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: "Enter Manually",
                textColor: Colors.white,
                onPressed: _showManualFoodInput,
              ),
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _showManualFoodInput() {
    final foodController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: NutriTheme.surface,
        title: const Text("Enter Food Name",
            style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: foodController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade900,
            hintText: "e.g. Chicken Biryani",
            hintStyle: TextStyle(color: Colors.grey.shade600),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: NutriTheme.primary),
            onPressed: () {
              if (foodController.text.isNotEmpty) {
                Navigator.pop(context);
                _showFoodAnalysisDialog(foodController.text);
              }
            },
            child: const Text("Analyze", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _showFoodAnalysisDialog(String foodName) async {
    // Second step: Get nutrition stats
    setState(() => _isLoading = true);
    try {
      final stats = await GroqAIService.analyzeFood(foodName);
      if (mounted) {
        setState(() => _isLoading = false);

        // Check for food-medicine interactions before showing dialog
        await _checkInteractionsAndShow(foodName, stats);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _checkInteractionsAndShow(
      String foodName, Map<String, dynamic> stats) async {
    // Import needed at top of file
    final interactionService = InteractionService();
    final user = FirebaseAuth.instance.currentUser;

    InteractionCheckResult? interactionResult;
    if (user != null) {
      interactionResult = await interactionService.checkFoodInteractions(
        userId: user.uid,
        foodName: foodName,
      );
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: NutriTheme.surface,
        title: Text("Identified: $foodName",
            style: const TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Interaction warning banner
              if (interactionResult != null &&
                  interactionResult.hasInteraction) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: interactionResult.hasCriticalInteraction
                        ? Colors.red.withValues(alpha: 0.2)
                        : Colors.orange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: interactionResult.hasCriticalInteraction
                          ? Colors.red
                          : Colors.orange,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.warning,
                            color: interactionResult.hasCriticalInteraction
                                ? Colors.red
                                : Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "⚠️ Medicine Interaction Warning",
                              style: TextStyle(
                                color: interactionResult.hasCriticalInteraction
                                    ? Colors.red
                                    : Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...interactionResult.interactions.map(
                        (interaction) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            "• ${interaction.medicineName}: ${interaction.description}",
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          if (interactionResult != null) {
                            _showInteractionDetails(interactionResult);
                          }
                        },
                        child: const Text("View Details",
                            style: TextStyle(color: NutriTheme.primary)),
                      ),
                    ],
                  ),
                ),
              ],

              // Nutrition info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNutritionRow("Calories",
                        "${stats['calories']?.toInt() ?? 0} kcal", Colors.orange),
                    const SizedBox(height: 8),
                    _buildNutritionRow(
                        "Protein",
                        "${stats['protein']?.toInt() ?? 0}g",
                        Colors.blue),
                    const SizedBox(height: 8),
                    _buildNutritionRow(
                        "Carbs", "${stats['carbs']?.toInt() ?? 0}g", Colors.green),
                    const SizedBox(height: 8),
                    _buildNutritionRow(
                        "Fat", "${stats['fat']?.toInt() ?? 0}g", Colors.red),
                    const SizedBox(height: 8),
                    _buildNutritionRow(
                        "Fiber", "${stats['fiber']?.toInt() ?? 0}g", Colors.purple),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: NutriTheme.primary),
            onPressed: () async {
              // Prevent duplicate submissions
              Navigator.pop(context); // Close dialog first

              // Save to Firestore
              final user = FirebaseAuth.instance.currentUser;
              if (user == null) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("❌ Please login to log meals."),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                return;
              }

              try {
                final calories = (stats['calories'] as num?)?.toInt() ?? 0;
                final protein = (stats['protein'] as num?)?.toDouble() ?? 0.0;
                final carbs = (stats['carbs'] as num?)?.toDouble() ?? 0.0;
                final fat = (stats['fat'] as num?)?.toDouble() ?? 0.0;

                // IMPORTANT: update daily nutrition first because the calories bar
                // and today's meal list both read from daily_nutrition_logs.
                final addedToDailyLog = await DailyNutritionService.addMealToday(
                  foodName,
                  calories.toDouble(),
                  protein: protein,
                  carbs: carbs,
                  fat: fat,
                );

                if (!addedToDailyLog) {
                  final reason = DailyNutritionService.lastError ??
                      'Please check your internet connection.';
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("❌ Failed to log meal: $reason"),
                        backgroundColor: Colors.red,
                        action: SnackBarAction(
                          label: "Retry",
                          textColor: Colors.white,
                          onPressed: () {
                            _showFoodAnalysisDialog(foodName);
                          },
                        ),
                      ),
                    );
                  }
                  return;
                }

                // Best-effort history save (must not block visible nutrition UI update)
                try {
                  final historyService = UserHistoryService();
                  final nutritionLog = NutritionLog(
                    id: '',
                    userId: user.uid,
                    foodName: foodName,
                    calories: calories,
                    protein: protein,
                    carbs: carbs,
                    fat: fat,
                    mealType: _determineMealType(),
                    timestamp: DateTime.now(),
                  );
                  await historyService.saveNutritionLog(nutritionLog);
                } catch (_) {}

                // Best-effort local persistence save
                try {
                  await UserDataPersistenceService.saveFoodLog({
                    'id': DateTime.now().millisecondsSinceEpoch,
                    'foodName': foodName,
                    'calories': calories,
                    'protein': protein,
                    'carbs': carbs,
                    'fat': fat,
                    'mealType': _determineMealType(),
                    'timestamp': DateTime.now(),
                  });
                } catch (_) {}

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("✅ Meal Logged Successfully!"),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: $e")),
                  );
                }
              }
            },
            child:
                const Text("Log Meal", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _showInteractionDetails(InteractionCheckResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: NutriTheme.surface,
        title: const Text("Interaction Details",
            style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: result.interactions.map((interaction) {
              return Card(
                color: Colors.grey.shade900,
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: interaction.isCritical
                                  ? Colors.red
                                  : Colors.orange,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              interaction.severityLabel.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${interaction.medicineName} + ${interaction.foodName}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        interaction.description,
                        style: TextStyle(color: Colors.grey.shade400),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Recommendation:",
                        style: const TextStyle(
                          color: NutriTheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        interaction.recommendation,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close",
                style: TextStyle(color: NutriTheme.primary)),
          ),
        ],
      ),
    );
  }

  void _showManualMealInput(String mealType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: NutriTheme.surface,
        title: Text('Add $mealType',
            style: const TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Meal Name',
                  labelStyle: const TextStyle(color: Colors.grey),
                  hintText: 'e.g., Rice & Curry',
                  hintStyle: const TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: NutriTheme.primary),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (val) {
                  mealNameController.text = val;
                },
              ),
              const SizedBox(height: 12),
              TextField(
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Calories',
                  labelStyle: const TextStyle(color: Colors.grey),
                  hintText: '0',
                  hintStyle: const TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: NutriTheme.primary),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (val) {
                  caloriesController.text = val;
                },
              ),
              const SizedBox(height: 12),
              TextField(
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Protein (g)',
                  labelStyle: const TextStyle(color: Colors.grey),
                  hintText: '0',
                  hintStyle: const TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (val) {
                  proteinController.text = val;
                },
              ),
              const SizedBox(height: 12),
              TextField(
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Carbs (g)',
                  labelStyle: const TextStyle(color: Colors.grey),
                  hintText: '0',
                  hintStyle: const TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (val) {
                  carbsController.text = val;
                },
              ),
              const SizedBox(height: 12),
              TextField(
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Fat (g)',
                  labelStyle: const TextStyle(color: Colors.grey),
                  hintText: '0',
                  hintStyle: const TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (val) {
                  fatController.text = val;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: NutriTheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              final mealName = mealNameController.text.trim();
              final calories = int.tryParse(caloriesController.text) ?? 0;
              final protein = double.tryParse(proteinController.text) ?? 0.0;
              final carbs = double.tryParse(carbsController.text) ?? 0.0;
              final fat = double.tryParse(fatController.text) ?? 0.0;

              if (mealName.isEmpty || calories == 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('❌ Please enter meal name and calories'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Navigator.pop(context);

              // Save to database
              try {
                // Save to daily nutrition service
                final addedToDailyLog = await DailyNutritionService.addMealToday(
                  mealName,
                  calories.toDouble(),
                  protein: protein,
                  carbs: carbs,
                  fat: fat,
                );

                if (mounted) {
                  if (addedToDailyLog) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Meal logged successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    // Clear controllers
                    mealNameController.clear();
                    caloriesController.clear();
                    proteinController.clear();
                    carbsController.clear();
                    fatController.clear();
                  } else {
                    final reason = DailyNutritionService.lastError ?? 'Try again.';
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('❌ Failed to log meal: $reason'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('❌ Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Log Meal', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  String _determineMealType() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'breakfast';
    if (hour < 15) return 'lunch';
    if (hour < 19) return 'dinner';
    return 'snack';
  }

  void _showManualFoodEntry() {
    final foodController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: NutriTheme.surface,
        title: const Text("Add Food Manually",
            style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Enter the name of the food you ate:",
              style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: foodController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "e.g. Chicken breast, Rice bowl, Apple",
                hintStyle: TextStyle(color: Colors.grey.shade600),
                filled: true,
                fillColor: Colors.grey.shade900,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon:
                    const Icon(Icons.fastfood, color: NutriTheme.primary),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  Navigator.pop(context);
                  _showFoodAnalysisDialog(value);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: NutriTheme.primary),
            onPressed: () {
              if (foodController.text.isNotEmpty) {
                Navigator.pop(context);
                _showFoodAnalysisDialog(foodController.text);
              }
            },
            child: const Text("Analyze", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _showMealDesigner() {
    final conditionsController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: NutriTheme.surface,
        title: const Text("AI Meal Designer",
            style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                "Enter health conditions or preferences (e.g. Vegan, Diabetes, High Protein):",
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 10),
            TextField(
              controller: conditionsController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade900,
                hintText: "Type here...",
                hintStyle: TextStyle(color: Colors.grey.shade600),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            // Additional parameters
            TextField(
              controller: _allergyController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Allergies (optional)",
                labelStyle: TextStyle(color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.grey.shade900,
                hintText: "e.g., peanuts, dairy, shellfish",
                hintStyle: TextStyle(color: Colors.grey.shade600),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Daily Calories",
                          style: TextStyle(color: Colors.grey.shade300)),
                      Slider(
                        value: _calorieGoal.toDouble(),
                        min: 1200,
                        max: 3500,
                        divisions: 23,
                        label: '${_calorieGoal.toInt()} cal',
                        onChanged: (value) =>
                            setState(() => _calorieGoal = value.toInt()),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _fitnessGoal,
                    decoration: InputDecoration(
                      labelText: "Fitness Goal",
                      labelStyle: TextStyle(color: Colors.grey.shade400),
                      filled: true,
                      fillColor: Colors.grey.shade900,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    dropdownColor: Colors.grey.shade800,
                    items: const [
                      DropdownMenuItem(
                          value: 'maintain', child: Text("Maintain Weight")),
                      DropdownMenuItem(
                          value: 'lose', child: Text("Lose Weight")),
                      DropdownMenuItem(
                          value: 'gain', child: Text("Gain Muscle")),
                      DropdownMenuItem(value: 'bulk', child: Text("Bulking")),
                      DropdownMenuItem(value: 'cut', child: Text("Cutting")),
                    ],
                    onChanged: (value) =>
                        setState(() => _fitnessGoal = value ?? 'maintain'),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: NutriTheme.primary),
            onPressed: () async {
              Navigator.pop(context);
              if (conditionsController.text.isNotEmpty) {
                _generateMealPlan(
                  conditionsController.text,
                  allergies: _allergyController.text,
                  calorieGoal: _calorieGoal,
                  fitnessGoal: _fitnessGoal,
                );
              }
            },
            child: const Text("Generate Plan",
                style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Future<void> _generateMealPlan(String conditions,
      {String allergies = '',
      int calorieGoal = 2000,
      String fitnessGoal = 'maintain'}) async {
    setState(() => _isLoading = true);
    try {
      final plan = await GroqAIService.createMealPlan({
        'goal': conditions,
        'diet': 'balanced',
        'calories': calorieGoal,
      });
      if (mounted) {
        setState(() => _isLoading = false);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: NutriTheme.surface,
            title: Row(
              children: [
                const Icon(Icons.restaurant_menu,
                    color: NutriTheme.primary, size: 28),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text("Your Personalized Meal Plan",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Show user parameters
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("📊 Your Profile",
                            style: TextStyle(
                                color: Colors.grey.shade400, fontSize: 12)),
                        const SizedBox(height: 8),
                        Text("Daily Goal: $calorieGoal calories",
                            style: const TextStyle(color: Colors.white)),
                        Text("Fitness Goal: $fitnessGoal",
                            style: const TextStyle(color: Colors.white)),
                        if (conditions.isNotEmpty)
                          Text("Conditions: $conditions",
                              style: const TextStyle(color: Colors.white),
                              overflow: TextOverflow.ellipsis),
                        if (allergies.isNotEmpty)
                          Text("Allergies: $allergies",
                              style: const TextStyle(color: Colors.white),
                              overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Meal plan content
                  SelectableText(
                    plan,
                    style: TextStyle(
                        color: Colors.grey.shade200, fontSize: 13.5, height: 1.6),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close",
                    style: TextStyle(color: NutriTheme.primary)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: NutriTheme.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: NutriTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🟢 Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Nutrition", style: NutriTheme.textTheme.displayMedium),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _showManualFoodEntry, // Manual food entry
                        icon: const Icon(Icons.edit_note_rounded,
                            size: 28, color: Colors.white),
                        tooltip: "Add Food Manually",
                      ),
                      IconButton(
                        onPressed: _showMealDesigner, // AI Meal Designer
                        icon: const Icon(Icons.restaurant_menu,
                            size: 28, color: NutriTheme.primary),
                        tooltip: "AI Meal Designer",
                      ),
                      IconButton(
                        onPressed: _scanFood,
                        icon: const Icon(Icons.document_scanner_rounded,
                            size: 28, color: Colors.white),
                        tooltip: "Scan Food",
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 🟢 Macro Progress - Dynamic based on meals
              StreamBuilder<Map<String, dynamic>>(
                stream: DailyNutritionService.watchTodayData(),
                builder: (context, snapshot) {
                  final dailyData = snapshot.data ?? {};

                  // Get values from daily nutrition service
                  final totalCalories = (dailyData['totalCalories'] ?? 0).toInt();
                  final totalProtein = (dailyData['protein'] ?? 0).toDouble();
                  final totalCarbs = (dailyData['carbs'] ?? 0).toDouble();
                  final totalFat = (dailyData['fat'] ?? 0).toDouble();

                  // Daily goals (can be customized via user settings)
                  const goalCalories = 2000;
                  const goalProtein = 150.0; // grams
                  const goalCarbs = 250.0; // grams
                  const goalFat = 65.0; // grams

                  return _buildMacroBars(
                    totalCalories,
                    goalCalories,
                    totalProtein,
                    goalProtein,
                    totalCarbs,
                    goalCarbs,
                    totalFat,
                    goalFat,
                  );
                },
              ),
              const SizedBox(height: 30),

              // 🟢 Meal Log
              Text("Today's Meals",
                  style: NutriTheme.textTheme.displayMedium
                      ?.copyWith(fontSize: 20)),
              const SizedBox(height: 15),

              // Real-time meal stream
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: DailyNutritionService.watchTodayMeals(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(
                            color: NutriTheme.primary),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Error loading meals',
                          style: TextStyle(color: Colors.red)),
                    );
                  }

                  final meals = snapshot.data ?? [];

                  if (meals.isEmpty) {
                    return Column(
                      children: [
                        GestureDetector(
                          onTap: () => _showManualMealInput('Breakfast'),
                          child: _buildMealSection("Breakfast", "Add Meal", 0,
                              isPlaceholder: true),
                        ),
                        GestureDetector(
                          onTap: () => _showManualMealInput('Lunch'),
                          child: _buildMealSection("Lunch", "Add Meal", 0,
                              isPlaceholder: true),
                        ),
                        GestureDetector(
                          onTap: () => _showManualMealInput('Dinner'),
                          child: _buildMealSection("Dinner", "Add Meal", 0,
                              isPlaceholder: true),
                        ),
                        GestureDetector(
                          onTap: () => _showManualMealInput('Snacks'),
                          child: _buildMealSection("Snacks", "Add Snack", 0,
                              isPlaceholder: true),
                        ),
                      ],
                    );
                  }

                  // Display all meals ordered by time
                  return Column(
                    children: meals.map((meal) {
                      return _buildMealSection(
                        "Meal",
                        meal['mealName'] ?? 'Unknown',
                        (meal['calories'] as num?)?.toInt() ?? 0,
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _scanFood,
        backgroundColor: NutriTheme.primary, // Neon Green
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildMacroBars(
    int totalCalories,
    int goalCalories,
    double totalProtein,
    double goalProtein,
    double totalCarbs,
    double goalCarbs,
    double totalFat,
    double goalFat,
  ) {
    // Calculate percentages safely
    final calorieProgress =
        goalCalories > 0 ? totalCalories / goalCalories : 0.0;
    final proteinProgress = goalProtein > 0 ? totalProtein / goalProtein : 0.0;
    final carbsProgress = goalCarbs > 0 ? totalCarbs / goalCarbs : 0.0;
    final fatProgress = goalFat > 0 ? totalFat / goalFat : 0.0;

    return GlassCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Calories",
                  style: NutriTheme.textTheme.bodyLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              Text("$totalCalories / $goalCalories",
                  style: NutriTheme.textTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: 10),
          LinearPercentIndicator(
            lineHeight: 12.0,
            percent: calorieProgress.clamp(0.0, 1.0),
            backgroundColor: Colors.grey.shade200,
            progressColor: NutriTheme.primary,
            barRadius: const Radius.circular(10),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMacroItem(
                  "Protein", proteinProgress.clamp(0.0, 1.0), Colors.blue),
              _buildMacroItem(
                  "Carbs", carbsProgress.clamp(0.0, 1.0), Colors.orange),
              _buildMacroItem("Fat", fatProgress.clamp(0.0, 1.0), Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroItem(String label, double percent, Color color) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 8),
        CircularPercentIndicator(
          radius: 24.0,
          lineWidth: 4.0,
          percent: percent,
          center: Text("${(percent * 100).toInt()}%",
              style: const TextStyle(fontSize: 10)),
          progressColor: color,
          backgroundColor: color.withValues(alpha: 0.2),
          circularStrokeCap: CircularStrokeCap.round,
        ),
      ],
    );
  }

  Widget _buildMealSection(String title, String food, int calories,
      {bool isPlaceholder = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NutriTheme.surface, // Dark Surface
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isPlaceholder
                  ? Colors.grey.shade100
                  : NutriTheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPlaceholder ? Icons.add : Icons.restaurant,
              color: isPlaceholder ? Colors.grey : Colors.black,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Text(food,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white)),
              ],
            ),
          ),
          if (!isPlaceholder)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: NutriTheme.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text("$calories kcal",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: NutriTheme.primary,
                      fontSize: 12)),
            ),
        ],
      ),
    );
  }

  Widget _buildNutritionRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        Text(value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            )),
      ],
    );
  }
}
