import 'package:flutter/material.dart';
import 'package:nuticare/core/theme.dart';
import 'package:nuticare/services/medicine_suggestion_service.dart';
import 'package:nuticare/services/diet_suggestion_service.dart';
import 'package:nuticare/services/workout_suggestion_service.dart';

class HealthSuggestionsScreen extends StatefulWidget {
  final String healthReport;
  final String fitnessGoal;

  const HealthSuggestionsScreen({
    super.key,
    required this.healthReport,
    required this.fitnessGoal,
  });

  @override
  State<HealthSuggestionsScreen> createState() =>
      _HealthSuggestionsScreenState();
}

class _HealthSuggestionsScreenState extends State<HealthSuggestionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _loadingMedicines = false;
  bool _loadingDiet = false;
  bool _loadingWorkout = false;

  Map<String, dynamic>? _medicineSuggestions;
  Map<String, dynamic>? _dietPlan;
  Map<String, dynamic>? _workoutPlan;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _generateMedicineSuggestions() async {
    setState(() => _loadingMedicines = true);
    try {
      final suggestions =
          await MedicineSuggestionService.generateMedicineSuggestions(
              widget.healthReport);
      if (suggestions.containsKey('suggestions')) {
        await MedicineSuggestionService.saveSuggestion(suggestions);
      }
      setState(() => _medicineSuggestions = suggestions);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _loadingMedicines = false);
    }
  }

  Future<void> _generateDietPlan() async {
    setState(() => _loadingDiet = true);
    try {
      final plan =
          await DietSuggestionService.generateDietPlan(
              widget.healthReport, widget.fitnessGoal);
      if (plan.containsKey('mealPlan')) {
        await DietSuggestionService.saveDietPlan(plan);
      }
      setState(() => _dietPlan = plan);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _loadingDiet = false);
    }
  }

  Future<void> _generateWorkoutPlan() async {
    setState(() => _loadingWorkout = true);
    try {
      final plan = await WorkoutSuggestionService.generateWorkoutPlan(
          widget.healthReport, widget.fitnessGoal, 'Intermediate');
      if (plan.containsKey('workoutPlan')) {
        await WorkoutSuggestionService.saveWorkoutPlan(plan);
      }
      setState(() => _workoutPlan = plan);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _loadingWorkout = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NutriTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Health Suggestions",
            style: NutriTheme.textTheme.displayMedium?.copyWith(fontSize: 20)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: NutriTheme.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: NutriTheme.primary,
          tabs: const [
            Tab(icon: Icon(Icons.medication), text: "Medicines"),
            Tab(icon: Icon(Icons.restaurant), text: "Diet"),
            Tab(icon: Icon(Icons.fitness_center), text: "Workout"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Medicine Suggestions Tab
          _buildMedicineSuggestionsTab(),
          // Diet Suggestions Tab
          _buildDietSuggestionsTab(),
          // Workout Suggestions Tab
          _buildWorkoutSuggestionsTab(),
        ],
      ),
    );
  }

  Widget _buildMedicineSuggestionsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_medicineSuggestions == null)
            ElevatedButton.icon(
              onPressed: _loadingMedicines ? null : _generateMedicineSuggestions,
              icon: _loadingMedicines
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(_loadingMedicines
                  ? 'Generating...'
                  : 'Get Medicine Suggestions'),
              style: ElevatedButton.styleFrom(
                backgroundColor: NutriTheme.primary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            )
          else if (_medicineSuggestions!.containsKey('error'))
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Icon(Icons.error, color: Colors.red, size: 40),
                  const SizedBox(height: 10),
                  Text(
                    _medicineSuggestions!['error'],
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _generateMedicineSuggestions,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: NutriTheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Medicine Suggestions',
                    style: NutriTheme.textTheme.displayMedium
                        ?.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _medicineSuggestions!['suggestions'] ?? '',
                    style: NutriTheme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDietSuggestionsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_dietPlan == null)
            ElevatedButton.icon(
              onPressed: _loadingDiet ? null : _generateDietPlan,
              icon: _loadingDiet
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(_loadingDiet
                  ? 'Generating Diet Plan...'
                  : 'Get Personalized Diet Plan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: NutriTheme.primary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            )
          else if (_dietPlan!.containsKey('error'))
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Icon(Icons.error, color: Colors.red, size: 40),
                  const SizedBox(height: 10),
                  Text(
                    _dietPlan!['error'],
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _generateDietPlan,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: NutriTheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Personalized Diet Plan',
                    style: NutriTheme.textTheme.displayMedium
                        ?.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _dietPlan!['mealPlan'] ?? '',
                    style: NutriTheme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWorkoutSuggestionsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_workoutPlan == null)
            ElevatedButton.icon(
              onPressed: _loadingWorkout ? null : _generateWorkoutPlan,
              icon: _loadingWorkout
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(_loadingWorkout
                  ? 'Generating Workout Plan...'
                  : 'Get Personalized Workout Plan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: NutriTheme.primary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            )
          else if (_workoutPlan!.containsKey('error'))
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Icon(Icons.error, color: Colors.red, size: 40),
                  const SizedBox(height: 10),
                  Text(
                    _workoutPlan!['error'],
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _generateWorkoutPlan,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: NutriTheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Personalized Workout Plan',
                    style: NutriTheme.textTheme.displayMedium
                        ?.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _workoutPlan!['workoutPlan'] ?? '',
                    style: NutriTheme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
