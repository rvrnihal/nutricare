import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// Groq API AI Service with Comprehensive Fallback
/// Uses Groq Cloud API for fast LLM inference
/// Falls back to local nutrition database if API unavailable
class GroqAIService {
  static const String _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const int _timeoutSeconds = 30;
  
  // Models to try in order - start with most stable
  static const List<String> _models = [
    'mixtral-8x7b-32768',
    'llama2-70b-4096', 
    'gemma-7b-it',
  ];
  
  static String? _apiKey;
  static String? _workingModel;

  /// Initialize with Groq API key
  static void setApiKey(String apiKey) {
    _apiKey = apiKey;
    _workingModel = null;
    debugPrint('✅ Groq API configured');
  }

  /// Check if API key is set
  static bool isConfigured() => _apiKey != null && _apiKey!.isNotEmpty;

  /// Try API with automatic model fallback
  static Future<String> _callGroqAPI(
    String prompt, {
    String systemPrompt = 'You are a helpful health and nutrition assistant.',
    int modelIndex = 0,
  }) async {
    // Try cached working model first
    if (_workingModel != null && modelIndex == 0) {
      try {
        final result = await _callModel(_workingModel!, prompt, systemPrompt);
        if (!result.startsWith('Error:')) {
          return result;
        }
      } catch (e) {
        _workingModel = null;
      }
    }

    // Try models in sequence
    if (modelIndex >= _models.length) {
      return '';  // Return empty to trigger fallback
    }

    final model = _models[modelIndex];
    try {
      final result = await _callModel(model, prompt, systemPrompt);
      if (!result.startsWith('Error:')) {
        _workingModel = model;
        return result;
      }
    } catch (e) {
      debugPrint('Model $model failed');
    }

    // Try next model
    return await _callGroqAPI(prompt, systemPrompt: systemPrompt, modelIndex: modelIndex + 1);
  }

  /// Call a specific model
  static Future<String> _callModel(
    String model,
    String prompt,
    String systemPrompt,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': model,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.7,
          'max_tokens': 1000,
        }),
      ).timeout(const Duration(seconds: _timeoutSeconds));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final choices = data['choices'] as List?;
        if (choices?.isNotEmpty ?? false) {
          return choices![0]['message']['content'] ?? '';
        }
      }
    } catch (e) {
      debugPrint('API call error: $e');
    }

    return 'Error: Model $model failed';
  }

  /// ==================== PUBLIC METHODS ====================

  /// Ask AI a question
  static Future<String> askAI(String prompt, {String? context}) async {
    if (!isConfigured()) {
      return _getFallbackResponse(prompt);
    }

    try {
      final result = await _callGroqAPI(prompt);
      return result.isNotEmpty ? result : _getFallbackResponse(prompt);
    } catch (e) {
      return _getFallbackResponse(prompt);
    }
  }

  /// Analyze food nutrition
  static Future<Map<String, dynamic>> analyzeFood(String foodName) async {
    try {
      if (!isConfigured()) {
        return _getFallbackFood(foodName);
      }

      final prompt = '''Return ONLY valid JSON for "$foodName" nutrition:
{"calories":0,"protein":0,"carbs":0,"fat":0,"fiber":0,"sugar":0,"sodium":0}''';

      final result = await _callGroqAPI(prompt);
      
      try {
        if (result.contains('{')) {
          final json = result.substring(result.indexOf('{'), result.lastIndexOf('}') + 1);
          final data = jsonDecode(json) as Map<String, dynamic>;
          return {
            'calories': (data['calories'] as num?)?.toInt() ?? 0,
            'protein': (data['protein'] as num?)?.toInt() ?? 0,
            'carbs': (data['carbs'] as num?)?.toInt() ?? 0,
            'fat': (data['fat'] as num?)?.toInt() ?? 0,
            'fiber': (data['fiber'] as num?)?.toInt() ?? 0,
            'sugar': (data['sugar'] as num?)?.toInt() ?? 0,
            'sodium': (data['sodium'] as num?)?.toInt() ?? 0,
          };
        }
      } catch (e) {
        debugPrint('Parse error: $e');
      }

      return _getFallbackFood(foodName);
    } catch (e) {
      return _getFallbackFood(foodName);
    }
  }

  /// Check medicine interactions
  static Future<String> checkMedicineInteractions(List<String> medicines) async {
    if (medicines.isEmpty) return 'No medicines to check.';

    if (!isConfigured()) {
      return 'Consult your pharmacist about interactions between: ${medicines.join(', ')}';
    }

    try {
      final prompt = 'Check interactions between: ${medicines.join(", ")}. Be brief.';
      final result = await _callGroqAPI(prompt);
      return result.isNotEmpty ? result : 'Consult your pharmacist.';
    } catch (e) {
      return 'Consult your pharmacist about drug interactions.';
    }
  }

  /// Create meal plan
  static Future<String> createMealPlan(Map<String, dynamic> preferences) async {
    if (!isConfigured()) {
      return _getDefaultMealPlan();
    }

    try {
      final goal = preferences['goal'] ?? 'healthy';
      final prompt = 'Create 1-day meal plan for: $goal. Be practical.';
      final result = await _callGroqAPI(prompt);
      return result.isNotEmpty ? result : _getDefaultMealPlan();
    } catch (e) {
      return _getDefaultMealPlan();
    }
  }

  /// Get workout recommendations
  static Future<String> getWorkoutRecommendations(Map<String, dynamic> fitnessData) async {
    if (!isConfigured()) {
      return _getDefaultWorkout();
    }

    try {
      final level = fitnessData['level'] ?? 'beginner';
      final prompt = 'Suggest 15-min workout for $level level. Be specific.';
      final result = await _callGroqAPI(prompt);
      return result.isNotEmpty ? result : _getDefaultWorkout();
    } catch (e) {
      return _getDefaultWorkout();
    }
  }

  /// Get health insights
  static Future<String> getHealthInsights(Map<String, dynamic> userData) async {
    if (!isConfigured()) {
      return _getDefaultInsights();
    }

    try {
      final prompt = 'Based on health data $userData, give 2-3 quick tips.';
      final result = await _callGroqAPI(prompt);
      return result.isNotEmpty ? result : _getDefaultInsights();
    } catch (e) {
      return _getDefaultInsights();
    }
  }

  /// Analyze food from image (returns food name for analysis)
  static Future<String> analyzeImageFood(String base64Image) async {
    // Groq doesn't support vision APIs, so ask user to describe
    return 'Please describe the food in the image so I can analyze it!';
  }

  /// ==================== FALLBACK DATA ====================

  static String _getFallbackResponse(String prompt) {
    return '💡 Offline Mode: Check connection and try refreshing.';
  }

  static String _getDefaultMealPlan() {
    return '''📋 Basic Daily Plan:
Breakfast: Oats with fruit
Lunch: Grilled chicken with rice
Dinner: Salmon with vegetables
Snacks: Yogurt, nuts
\nConsult a nutritionist for personalized plans.''';
  }

  static String _getDefaultWorkout() {
    return '''💪 15-Min Quick Workout:
Warmup (2 min): Jumping jacks
Main (10 min): Squats, push-ups, lunges
Cool (3 min): Stretching''';
  }

  static String _getDefaultInsights() {
    return '''💚 Health Tips:
• 150 min cardio weekly
• 8+ glasses water daily  
• 7-9 hours sleep
• Track your progress''';
  }

  static Map<String, dynamic> _getFallbackFood(String foodName) {
    const db = {
      'chicken': {'calories': 165, 'protein': 31, 'carbs': 0, 'fat': 4, 'fiber': 0, 'sugar': 0, 'sodium': 75},
      'rice': {'calories': 130, 'protein': 3, 'carbs': 28, 'fat': 0, 'fiber': 0, 'sugar': 0, 'sodium': 2},
      'egg': {'calories': 77, 'protein': 6, 'carbs': 1, 'fat': 5, 'fiber': 0, 'sugar': 0, 'sodium': 62},
      'bread': {'calories': 80, 'protein': 4, 'carbs': 14, 'fat': 2, 'fiber': 2, 'sugar': 1, 'sodium': 140},
      'apple': {'calories': 52, 'protein': 0, 'carbs': 14, 'fat': 0, 'fiber': 2, 'sugar': 10, 'sodium': 2},
      'banana': {'calories': 105, 'protein': 1, 'carbs': 27, 'fat': 0, 'fiber': 3, 'sugar': 14, 'sodium': 2},
    };

    final key = foodName.toLowerCase().trim();
    return db[key] ?? {
      'calories': 100,
      'protein': 5,
      'carbs': 15,
      'fat': 2,
      'fiber': 1,
      'sugar': 2,
      'sodium': 50,
    };
  }
}
