import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nuticare/models/interaction_model.dart';
import 'package:nuticare/models/medicine_model.dart';
import 'package:nuticare/services/groq_ai_service.dart';

class InteractionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Cache for interaction results (expires after 7 days)
  final Map<String, FoodMedicineInteraction> _interactionCache = {};

  /// Check for interactions between a food and all user's medicines
  Future<InteractionCheckResult> checkFoodInteractions({
    required String userId,
    required String foodName,
  }) async {
    try {
      // Get all active medicines for the user
      final medicinesSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('medicines')
          .where('endDate', isGreaterThan: Timestamp.now())
          .get();

      if (medicinesSnapshot.docs.isEmpty) {
        return InteractionCheckResult.noInteraction();
      }

      final medicines = medicinesSnapshot.docs
          .map((doc) => Medicine.fromFirestore(doc))
          .toList();

      // Check for interactions with each medicine
      final List<FoodMedicineInteraction> interactions = [];

      for (final medicine in medicines) {
        final interaction = await _checkSingleInteraction(
          medicineName: medicine.name,
          foodName: foodName,
        );

        if (interaction != null) {
          interactions.add(interaction);
        }
      }

      return InteractionCheckResult.withInteractions(interactions);
    } catch (e) {
      return InteractionCheckResult.error('Failed to check interactions: $e');
    }
  }

  /// Check for interaction between a specific medicine and food
  Future<FoodMedicineInteraction?> _checkSingleInteraction({
    required String medicineName,
    required String foodName,
  }) async {
    // Create cache key
    final cacheKey = '${medicineName.toLowerCase()}_${foodName.toLowerCase()}';

    // Check cache first
    if (_interactionCache.containsKey(cacheKey)) {
      final cached = _interactionCache[cacheKey]!;
      // If cached less than 7 days ago, use it
      if (cached.lastChecked != null &&
          DateTime.now().difference(cached.lastChecked!).inDays < 7) {
        return cached;
      }
    }

    // Check local database first
    final localInteraction = await _checkLocalDatabase(medicineName, foodName);
    if (localInteraction != null) {
      _interactionCache[cacheKey] = localInteraction;
      return localInteraction;
    }

    // Fall back to AI if not in local database
    try {
      final aiInteraction = await _checkWithAI(medicineName, foodName);
      if (aiInteraction != null) {
        // Save to local database for future use
        await _saveToLocalDatabase(aiInteraction);
        _interactionCache[cacheKey] = aiInteraction;
        return aiInteraction;
      }
    } catch (e) {
      // AI check failed, return null (no interaction found)
      return null;
    }

    return null;
  }

  /// Check local Firestore database for known interactions
  Future<FoodMedicineInteraction?> _checkLocalDatabase(
    String medicineName,
    String foodName,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('interactions')
          .where('medicineName', isEqualTo: medicineName.toLowerCase())
          .where('foodName', isEqualTo: foodName.toLowerCase())
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return FoodMedicineInteraction.fromFirestore(querySnapshot.docs.first);
      }
    } catch (e) {
      // Database query failed, continue to AI check
    }
    return null;
  }

  /// Use AI to check for interactions
  Future<FoodMedicineInteraction?> _checkWithAI(
    String medicineName,
    String foodName,
  ) async {
    final prompt = '''
Check if there's an interaction between the medicine "$medicineName" and food "$foodName".

Respond ONLY in this exact JSON format:
{
  "hasInteraction": true/false,
  "severity": "mild/moderate/severe/critical",
  "description": "Brief description of the interaction",
  "recommendation": "What the user should do",
  "symptoms": ["symptom1", "symptom2"]
}

If there's NO interaction, respond: {"hasInteraction": false}
''';

    try {
      final response = await GroqAIService.askAI(prompt);

      // Parse AI response (expecting JSON)
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(response);
      if (jsonMatch == null) {
        return null;
      }

      final jsonStr = jsonMatch.group(0)!;
      final Map<String, dynamic> data = {};

      // Simple JSON parsing (for hasInteraction)
      if (jsonStr.contains('"hasInteraction": false') ||
          jsonStr.contains('"hasInteraction":false')) {
        return null; // No interaction
      }

      if (jsonStr.contains('"hasInteraction": true') ||
          jsonStr.contains('"hasInteraction":true')) {
        // Parse severity
        String severity = 'moderate';
        if (jsonStr.contains('"severity": "mild"')) severity = 'mild';
        if (jsonStr.contains('"severity": "moderate"')) severity = 'moderate';
        if (jsonStr.contains('"severity": "severe"')) severity = 'severe';
        if (jsonStr.contains('"severity": "critical"')) severity = 'critical';

        // Extract description and recommendation
        final descMatch =
            RegExp(r'"description":\s*"([^"]*)"').firstMatch(jsonStr);
        final recMatch =
            RegExp(r'"recommendation":\s*"([^"]*)"').firstMatch(jsonStr);

        final description = descMatch?.group(1) ?? 'Interaction detected';
        final recommendation = recMatch?.group(1) ?? 'Consult your doctor';

        return FoodMedicineInteraction(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          medicineName: medicineName,
          foodName: foodName,
          severity: InteractionSeverity.values.firstWhere(
            (s) => s.name == severity,
            orElse: () => InteractionSeverity.moderate,
          ),
          description: description,
          recommendation: recommendation,
          symptoms: [],
          lastChecked: DateTime.now(),
        );
      }
    } catch (e) {
      // AI parsing failed
      return null;
    }

    return null;
  }

  /// Save interaction to local database for future reference
  Future<void> _saveToLocalDatabase(FoodMedicineInteraction interaction) async {
    try {
      await _firestore.collection('interactions').add(interaction.toMap());
    } catch (e) {
      // Failed to save, but don't block the interaction check
    }
  }

  /// Get all known interactions for a medicine
  Future<List<FoodMedicineInteraction>> getMedicineInteractions(
    String medicineName,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('interactions')
          .where('medicineName', isEqualTo: medicineName.toLowerCase())
          .get();

      return querySnapshot.docs
          .map((doc) => FoodMedicineInteraction.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
