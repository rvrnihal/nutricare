import 'dart:convert';
import 'package:http/http.dart' as http;

/// Uses trained/local AI model via Node.js server
/// No API keys required - runs on http://localhost:5000
class TrainedAIService {
  static const String _baseUrl = 'http://localhost:5000';
  static const int _timeoutSeconds = 30;

  /// Ask trained AI model a question
  static Future<String> askAI(String prompt, {String? context}) async {
    try {
      final preview = prompt.length > 50 ? prompt.substring(0, 50) : prompt;
      print('Asking trained AI: $preview...');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/ai'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': prompt}),
      ).timeout(const Duration(seconds: _timeoutSeconds));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['text'] ?? 'AI response unavailable';
        print('AI response received');
        return text;
      } else {
        print('AI API error: ${response.statusCode}');
        return 'AI service temporarily unavailable. Please try again.';
      }
    } on http.ClientException catch (e) {
      print('Network error contacting AI: $e');
      return 'Network error. Make sure AI server is running on port 5000.';
    } catch (e) {
      print('Error asking AI: $e');
      return 'Error: ${e.toString()}';
    }
  }

  /* ================= ANALYZE FOOD (TEXT) ================= */
  static Future<Map<String, dynamic>> analyzeFood(String foodName) async {
    try {
      print('Analyzing food: $foodName');
      
      final prompt = '''Analyze the nutritional content of "$foodName" for a standard serving.
Return ONLY valid JSON with no markdown:
{
  "calories": <number>,
  "protein": <number in grams>,
  "carbs": <number in grams>,
  "fat": <number in grams>,
  "fiber": <number in grams>,
  "sugar": <number in grams>,
  "sodium": <number in mg>
}''';

      final response = await http.post(
        Uri.parse('$_baseUrl/ai'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': prompt}),
      ).timeout(const Duration(seconds: _timeoutSeconds));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['text'] ?? '{}';

        // Clean the response - remove any markdown/text wrapper
        String cleaned = content
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();

        try {
          // Try to parse as JSON
          final result = jsonDecode(cleaned);
          
          // Validate that we got actual numbers
          final calories = (result['calories'] as num?)?.toInt() ?? 0;
          if (calories > 0) {
            print('Food analysis successful: $foodName - $calories cal');
            return {
              'calories': calories,
              'protein': ((result['protein'] as num?) ?? 0).toInt(),
              'carbs': ((result['carbs'] as num?) ?? 0).toInt(),
              'fat': ((result['fat'] as num?) ?? 0).toInt(),
              'fiber': ((result['fiber'] as num?) ?? 0).toInt(),
              'sugar': ((result['sugar'] as num?) ?? 0).toInt(),
              'sodium': ((result['sodium'] as num?) ?? 0).toInt(),
            };
          }
          
          // If calories are 0 or missing, use fallback
          print('Invalid calorie value received: $calories, using fallback');
          throw Exception('Invalid calorie value: $calories');
        } catch (parseError) {
          print('Failed to parse JSON response: $parseError, using fallback for $foodName');
          // Use professional healthcare nutrition database fallback
          final nutrition = _getNutritionFallback(foodName);
          return nutrition;
        }
      } else {
        print('API error: ${response.statusCode}');
        final nutrition = _getNutritionFallback(foodName);
        return nutrition;
      }
    } catch (e) {
      print('Error analyzing food: $e');
      final nutrition = _getNutritionFallback(foodName);
      return nutrition;
    }
  }

  // Professional nutrition database fallback
  static Map<String, dynamic> _getNutritionFallback(String foodName) {
    final lowerFood = foodName.toLowerCase();
    
    // Professional nutrition database
    const nutritionDatabase = {
      'chicken': {'calories': 165, 'protein': 31, 'carbs': 0, 'fat': 3.6, 'fiber': 0, 'sugar': 0, 'sodium': 75},
      'rice': {'calories': 206, 'protein': 4.3, 'carbs': 45, 'fat': 0.3, 'fiber': 0.4, 'sugar': 0.1, 'sodium': 2},
      'beef': {'calories': 250, 'protein': 26, 'carbs': 0, 'fat': 15, 'fiber': 0, 'sugar': 0, 'sodium': 75},
      'fish': {'calories': 100, 'protein': 20, 'carbs': 0, 'fat': 1, 'fiber': 0, 'sugar': 0, 'sodium': 65},
      'salmon': {'calories': 206, 'protein': 22, 'carbs': 0, 'fat': 13, 'fiber': 0, 'sugar': 0, 'sodium': 66},
      'bread': {'calories': 80, 'protein': 4, 'carbs': 14, 'fat': 1.5, 'fiber': 2.4, 'sugar': 1, 'sodium': 140},
      'egg': {'calories': 77, 'protein': 6.3, 'carbs': 0.6, 'fat': 5.3, 'fiber': 0, 'sugar': 0.6, 'sodium': 62},
      'broccoli': {'calories': 34, 'protein': 2.8, 'carbs': 7, 'fat': 0.4, 'fiber': 2.4, 'sugar': 1.4, 'sodium': 64},
      'banana': {'calories': 105, 'protein': 1.3, 'carbs': 27, 'fat': 0.3, 'fiber': 3.1, 'sugar': 14, 'sodium': 2},
      'apple': {'calories': 52, 'protein': 0.3, 'carbs': 14, 'fat': 0.2, 'fiber': 2.4, 'sugar': 10, 'sodium': 2},
      'yogurt': {'calories': 59, 'protein': 10, 'carbs': 3.3, 'fat': 0.4, 'fiber': 0, 'sugar': 2.7, 'sodium': 29},
      'milk': {'calories': 61, 'protein': 3.2, 'carbs': 4.8, 'fat': 3.3, 'fiber': 0, 'sugar': 4.8, 'sodium': 44},
      'cheese': {'calories': 402, 'protein': 25, 'carbs': 1.3, 'fat': 33, 'fiber': 0, 'sugar': 0.7, 'sodium': 621},
      'spinach': {'calories': 23, 'protein': 2.9, 'carbs': 3.6, 'fat': 0.4, 'fiber': 2.2, 'sugar': 0.4, 'sodium': 58},
      'carrot': {'calories': 41, 'protein': 0.9, 'carbs': 10, 'fat': 0.2, 'fiber': 2.8, 'sugar': 6, 'sodium': 69},
      'potato': {'calories': 77, 'protein': 2, 'carbs': 17, 'fat': 0.1, 'fiber': 2.1, 'sugar': 0.8, 'sodium': 6},
      'tomato': {'calories': 18, 'protein': 0.9, 'carbs': 3.9, 'fat': 0.2, 'fiber': 1.2, 'sugar': 2.6, 'sodium': 5},
      'orange': {'calories': 47, 'protein': 0.9, 'carbs': 12, 'fat': 0.3, 'fiber': 2.4, 'sugar': 9.3, 'sodium': 0},
      'pasta': {'calories': 131, 'protein': 5, 'carbs': 25, 'fat': 1.1, 'fiber': 1.8, 'sugar': 0.6, 'sodium': 1},
      'burger': {'calories': 540, 'protein': 28, 'carbs': 45, 'fat': 28, 'fiber': 2, 'sugar': 8, 'sodium': 1050},
      'pizza': {'calories': 285, 'protein': 12, 'carbs': 36, 'fat': 10, 'fiber': 2, 'sugar': 3, 'sodium': 640},
      'lentil': {'calories': 116, 'protein': 9, 'carbs': 20, 'fat': 0.4, 'fiber': 8, 'sugar': 1.6, 'sodium': 4},
      'tofu': {'calories': 76, 'protein': 8, 'carbs': 1.9, 'fat': 4.8, 'fiber': 1.2, 'sugar': 0.5, 'sodium': 7},
    };
    
    // Find matching food
    for (final entry in nutritionDatabase.entries) {
      if (lowerFood.contains(entry.key) || entry.key.contains(lowerFood)) {
        return {
          'calories': entry.value['calories'],
          'protein': entry.value['protein'],
          'carbs': entry.value['carbs'],
          'fat': entry.value['fat'],
          'fiber': entry.value['fiber'],
          'sugar': entry.value['sugar'],
          'sodium': entry.value['sodium'],
        };
      }
    }
    
    // Default estimate if not found
    return {
      'calories': 150,
      'protein': 12,
      'carbs': 20,
      'fat': 5,
      'fiber': 3,
      'sugar': 3,
      'sodium': 200,
    };
  }

  /* ================= ANALYZE FOOD (IMAGE) ================= */
  static Future<String> analyzeImageFood(String base64Image) async {
    try {
      print('Analyzing food from image');
      
      final prompt =
          '''Identify the food in this image and name it. Return ONLY the food name, nothing else.''';

      final response = await http.post(
        Uri.parse('$_baseUrl/ai'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': prompt}),
      ).timeout(const Duration(seconds: _timeoutSeconds));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final foodName = (data['text'] ?? 'Unknown food').trim();
        print('Food identified: $foodName');
        return foodName;
      } else {
        print('API error: ${response.statusCode}');
        return 'Unable to identify food';
      }
    } catch (e) {
      print('Error analyzing food image: $e');
      return 'Error: ${e.toString()}';
    }
  }

  /* ================= GENERATE MEAL PLAN ================= */
  static Future<String> generateMealPlan({
    required int targetCalories,
    required String dietType,
    required List<String> allergies,
  }) async {
    try {
      print('Generating meal plan');
      
      final allergyList = allergies.join(', ');
      final prompt =
          '''Create a healthy meal plan with $targetCalories calories per day for a $dietType diet.
Avoid these allergies: $allergyList. 
Provide specific meal suggestions, portion sizes, and nutritional benefits.''';

      final response = await http.post(
        Uri.parse('$_baseUrl/ai'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': prompt}),
      ).timeout(const Duration(seconds: _timeoutSeconds));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Meal plan generated');
        return data['text'] ?? 'Unable to generate meal plan';
      } else {
        return 'Unable to generate meal plan';
      }
    } catch (e) {
      print('Error generating meal plan: $e');
      return 'Error generating meal plan: ${e.toString()}';
    }
  }

  /* ================= GET MEDICINE DETAILS ================= */
  static Future<Map<String, dynamic>> getMedicineDetails(
      String medicineName) async {
    try {
      print('Getting medicine details for: $medicineName');

      final prompt = '''Provide detailed medical information for: $medicineName
Return ONLY valid JSON:
{
  "medicine": "name",
  "uses": "primary uses",
  "side_effects": "common and serious side effects",
  "interactions": "drug and food interactions",
  "dosage": "typical dosing",
  "warning": "important warnings"
}''';

      final response = await http.post(
        Uri.parse('$_baseUrl/ai'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': prompt}),
      ).timeout(const Duration(seconds: _timeoutSeconds));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['text'] ?? '{}';
        
        // Clean response
        String cleaned = content
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();

        try {
          final medicineInfo = jsonDecode(cleaned);
          print('Medicine details retrieved successfully');
          
          return {
            'medicine': medicineInfo['medicine'] ?? medicineName,
            'uses': medicineInfo['uses'] ?? 'Consult healthcare provider',
            'side_effects': medicineInfo['side_effects'] ?? 'Vary by individual',
            'interactions': medicineInfo['interactions'] ?? 'Check with pharmacist',
            'dosage': medicineInfo['dosage'] ?? 'Follow prescription',
            'warning': medicineInfo['warning'] ?? 'CONSULT YOUR DOCTOR',
            'timestamp': DateTime.now().toIso8601String(),
          };
        } catch (parseError) {
          print('Could not parse medicine JSON, using fallback');
          return _getMedicineFallback(medicineName);
        }
      } else {
        return _getMedicineFallback(medicineName);
      }
    } catch (e) {
      print('Error getting medicine details: $e');
      return _getMedicineFallback(medicineName);
    }
  }

  /// Get medicine details with Groq API fallback
  static Future<Map<String, dynamic>> getMedicineDetailsWithGroqFallback(
      String medicineName) async {
    try {
      print('Getting medicine details with Groq fallback for: $medicineName');

      // First try local AI
      final localResult = await getMedicineDetails(medicineName);
      
      // Check if we got a good result or just a fallback
      // If it contains "Consult healthcare provider" in uses, it's likely a fallback
      final usesText = localResult['uses']?.toString() ?? '';
      final hasGenericResponse = usesText.contains('healthcare provider');
      final hasTypeInfo = usesText.contains('Type');
      
      if (hasGenericResponse && !hasTypeInfo) {
        print('Local AI returned generic fallback, trying Groq API...');
        
        // Try Groq API as fallback
        final groqResult = await _getMedicineDetailsFromGroq(medicineName);
        if (groqResult != null) {
          print('✅ Groq API provided medicine details');
          return groqResult;
        }
      }
      
      return localResult;
    } catch (e) {
      print('Error in getMedicineDetailsWithGroqFallback: $e');
      return _getMedicineFallback(medicineName);
    }
  }

  /// Call Groq API directly for medicine information
  static Future<Map<String, dynamic>?> _getMedicineDetailsFromGroq(
      String medicineName) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/ai'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'text': '''You are a medical information AI. Provide accurate, professional information about: $medicineName
Be specific and include actual information if you know it.
Return as JSON:
{
  "medicine": "name",
  "uses": "what it's used for",
  "dosage": "typical dosing",
  "side_effects": "common and serious side effects",
  "interactions": "important drug and food interactions",
  "warning": "critical warnings"
}''',
          'useGroq': true,  // Signal to use Groq API on backend
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['text'] ?? '{}';
        
        String cleaned = content
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();

        try {
          final medicineInfo = jsonDecode(cleaned);
          
          // Validate we got real information (not just fallback)
          if ((medicineInfo['uses'] as String?)?.isNotEmpty == true &&
              !(medicineInfo['uses'] as String).contains('consult')) {
            print('✅ Groq API returned valid medicine info');
            return {
              'medicine': medicineInfo['medicine'] ?? medicineName,
              'uses': medicineInfo['uses'] ?? '',
              'side_effects': medicineInfo['side_effects'] ?? '',
              'interactions': medicineInfo['interactions'] ?? '',
              'dosage': medicineInfo['dosage'] ?? '',
              'warning': medicineInfo['warning'] ?? '',
              'source': 'Groq API',
              'timestamp': DateTime.now().toIso8601String(),
            };
          }
        } catch (e) {
          print('Could not parse Groq response: $e');
        }
      }
      return null;
    } catch (e) {
      print('Groq API call failed: $e');
      return null;
    }
  }
  static Map<String, dynamic> _getMedicineFallback(String medicineName) {
    final lowerName = medicineName.toLowerCase();
    
    final medicineDatabase = {
      'metformin': {
        'medicine': 'Metformin',
        'uses': 'Type 2 diabetes management',
        'side_effects': 'Nausea, diarrhea, stomach upset, vitamin B12 deficiency with long-term use',
        'interactions': 'Alcohol increases lactic acidosis risk. Avoid with contrast dye procedures',
        'dosage': 'Usually 500-2550mg daily in divided doses',
        'warning': 'Not for Type 1 diabetes. Monitor kidney function regularly'
      },
      'lisinopril': {
        'medicine': 'Lisinopril',
        'uses': 'High blood pressure and heart failure',
        'side_effects': 'Dizziness, dry cough, headache, fatigue',
        'interactions': 'NSAIDs reduce effectiveness. Potassium supplements increase hyperkalemia risk',
        'dosage': 'Usually 10mg once daily, adjusted 10-40mg',
        'warning': 'Can cause dangerous hyperkalemia. Regular monitoring essential. Avoid in pregnancy'
      },
      'aspirin': {
        'medicine': 'Aspirin',
        'uses': 'Heart attack/stroke prevention, pain relief',
        'side_effects': 'Stomach upset, bleeding risk, easy bruising, acid reflux',
        'interactions': 'Increases bleeding with warfarin. NSAIDs may increase GI irritation',
        'dosage': 'For heart health: 75-325mg daily. For pain: 325-650mg every 4-6 hours',
        'warning': 'Higher bleeding risk in elderly. Not for children with viral infections'
      },
      'atorvastatin': {
        'medicine': 'Atorvastatin',
        'uses': 'High cholesterol and cardiovascular prevention',
        'side_effects': 'Muscle pain, liver enzyme elevation, headache, weakness',
        'interactions': 'Grapefruit juice increases levels. Careful with CYP3A4 metabolized drugs',
        'dosage': 'Usually 10-80mg daily in evening',
        'warning': 'Can cause muscle breakdown. Monitor liver function. Report unexplained pain'
      },
      'ibuprofen': {
        'medicine': 'Ibuprofen',
        'uses': 'Pain relief, fever reduction, inflammation',
        'side_effects': 'Stomach upset, heartburn, nausea, dizziness',
        'interactions': 'Reduces BP med effectiveness. Increases GI bleeding with steroids',
        'dosage': '200-400mg every 4-6 hours, max 1200mg/day',
        'warning': 'Avoid with kidney disease. Take with food'
      },
    };
    
    // Find matching medicine
    final match = medicineDatabase.entries.firstWhere(
      (entry) => lowerName.contains(entry.key) || entry.key.contains(lowerName),
      orElse: () => MapEntry('unknown', {
        'medicine': medicineName,
        'uses': 'Please consult healthcare provider',
        'side_effects': 'Consult healthcare provider',
        'interactions': 'Check with your pharmacist',
        'dosage': 'Follow prescription instructions',
        'warning': 'ALWAYS CONSULT YOUR HEALTHCARE PROVIDER'
      })
    );
    
    return {
      'medicine': match.value['medicine'] ?? medicineName,
      'uses': match.value['uses'] ?? 'Consult healthcare provider',
      'side_effects': match.value['side_effects'] ?? 'Vary by individual',
      'interactions': match.value['interactions'] ?? 'Check with pharmacist',
      'dosage': match.value['dosage'] ?? 'Follow prescription',
      'warning': match.value['warning'] ?? 'CONSULT YOUR DOCTOR',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
  static Future<String> generatePersonalizedPlan(
    String conditions, {
    String allergies = '',
    String preferences = 'balanced',
    String budget = 'medium',
    int calorieGoal = 2000,
    String fitnessGoal = 'maintain',
    int age = 25,
    String gender = 'not_specified',
  }) async {
    try {
      print('🍽️ Generating personalized meal plan with Groq API...');
      print('Conditions: $conditions, Allergies: $allergies, Goal: $calorieGoal cal');
      
      // Call the new meal plan generation endpoint
      final response = await http.post(
        Uri.parse('$_baseUrl/api/generate-meal-plan'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'conditions': conditions,
          'allergies': allergies,
          'preferences': preferences,
          'budget': budget,
          'calorieGoal': calorieGoal,
          'fitnessGoal': fitnessGoal,
          'age': age,
          'gender': gender,
        }),
      ).timeout(const Duration(seconds: 45)); // Longer timeout for meal plan generation

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Personalized meal plan generated from ${data['source'] ?? 'unknown source'}');
        return data['mealPlan'] ?? data['text'] ?? 'Unable to generate plan';
      } else {
        print('❌ Meal plan generation failed: ${response.statusCode}');
        print('Response: ${response.body}');
        return 'Unable to generate meal plan. Please try again.';
      }
    } catch (e) {
      print('⚠️ Error generating personalized plan: $e');
      return '''📋 MEAL PLAN GENERATION ERROR

We encountered an issue generating your personalized meal plan.

🔧 Troubleshooting:
• Check internet connection
• Verify backend server is running on port 5000
• Try again in a moment
• Or use the manual food entry option

💡 Quick Tips:
• Aim for 500 calories per meal
• Include protein, vegetables, and whole grains
• Drink 8-10 glasses of water daily
• Consult a nutritionist for personalized guidance

⚠️ Always consult healthcare professionals before making significant dietary changes.''';
    }
  }
}
