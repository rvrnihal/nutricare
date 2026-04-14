import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/logger.dart';

class GroqService {
  static const String _apiKey = String.fromEnvironment('GROQ_API_KEY');
  static const String _baseUrl = 'https://api.groq.com/openai/v1';
  static const int _timeoutSeconds = 30;

  static Map<String, String> _headers() {
    if (_apiKey.isEmpty) {
      throw Exception(
        'Missing GROQ_API_KEY. Run with --dart-define=GROQ_API_KEY=<your_key>.',
      );
    }

    return {
      'Authorization': 'Bearer $_apiKey',
      'Content-Type': 'application/json',
    };
  }

  /* ================= ANALYZE FOOD (TEXT) ================= */
  static Future<Map<String, dynamic>> analyzeFood(String foodName) async {
    try {
      AppLogger.info('Analyzing food: $foodName');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: _headers(),
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile',
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are a nutrition expert. Provide accurate nutritional information for foods. Return ONLY valid JSON with no markdown formatting.'
            },
            {
              'role': 'user',
              'content': '''
Analyze the nutritional content of "$foodName" for a standard serving.

Return STRICT JSON format ONLY. No markdown. No explanation.

{
  "calories": <number>,
  "protein": <number in grams>,
  "carbs": <number in grams>,
  "fat": <number in grams>,
  "fiber": <number in grams>,
  "sugar": <number in grams>,
  "sodium": <number in mg>
}
'''
            }
          ],
          'temperature': 0.2,
          'max_tokens': 500,
        }),
      ).timeout(const Duration(seconds: _timeoutSeconds));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];

        // Clean the response
        String cleaned =
            content.replaceAll('```json', '').replaceAll('```', '').trim();

        final result = jsonDecode(cleaned);
        AppLogger.info('Food analysis successful: $foodName');
        return result;
      } else {
        AppLogger.error('API error: ${response.statusCode}');
        throw Exception('Failed to analyze food: ${response.statusCode} - ${response.body}');
      }
    } on http.ClientException catch (e) {
      AppLogger.error('Network error during food analysis', e);
      throw Exception('Network error: ${e.message}');
    } catch (e, st) {
      AppLogger.error('Error analyzing food', e, st);
      throw Exception('Error analyzing food: $e');
    }
  }

  /* ================= ANALYZE FOOD (IMAGE) ================= */
  static Future<String> analyzeImageFood(String base64Image) async {
    try {
      AppLogger.info('Analyzing food from image');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: _headers(),
        body: jsonEncode({
          'model': 'llama-3.2-90b-vision-preview',
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are a food recognition expert. Identify food items in images accurately and concisely.'
            },
            {
              'role': 'user',
              'content': [
                {
                  'type': 'text',
                  'text':
                      'Identify the food in this image. Return ONLY the food name, nothing else. Be specific and concise (e.g., "Chicken Biryani", "Apple", "Sambar").'
                },
                {
                  'type': 'image_url',
                  'image_url': {
                    'url': 'data:image/jpeg;base64,$base64Image',
                  }
                }
              ]
            }
          ],
          'temperature': 0.2,
          'max_tokens': 100,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String foodName = data['choices'][0]['message']['content'].trim();

        // Clean up the response
        foodName = foodName.replaceAll('"', '').replaceAll("'", '').trim();

        // If response contains extra text, try to extract just the food name
        if (foodName.toLowerCase().contains('the food') ||
            foodName.toLowerCase().contains('appears to be') ||
            foodName.toLowerCase().contains('looks like')) {
          // Extract the last part which is likely the food name
          final parts = foodName.split(RegExp(r'is|appears to be|looks like'));
          if (parts.length > 1) {
            foodName = parts.last.trim();
          }
        }

        return foodName;
      } else {
        throw Exception('Failed to analyze image: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error analyzing image: $e');
    }
  }

  /* ================= GENERAL AI ASSISTANT ================= */
  static Future<String> askAI(String question, {String? context}) async {
    try {
      final systemPrompt = context != null
          ? 'You are a helpful nutrition and health assistant. Use this context: $context'
          : 'You are a helpful nutrition and health assistant. Provide accurate, evidence-based information.';

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: _headers(),
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile',
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': question}
          ],
          'temperature': 0.3,
          'max_tokens': 1000,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('Failed to get AI response: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error asking AI: $e');
    }
  }

  /* ================= PERSONALIZED MEAL PLAN (SIMPLE) ================= */
  static Future<String> generatePersonalizedPlan(String conditions) async {
    try {
      final prompt = """
      Create a 1-day meal plan (Breakfast, Lunch, Dinner, Snack) for a person with these health conditions/goals: "$conditions".
      
      Format:
      **Breakfast**: [Meal Name] - [Calories] kcal
      **Lunch**: [Meal Name] - [Calories] kcal
      **Dinner**: [Meal Name] - [Calories] kcal
      **Snack**: [Meal Name] - [Calories] kcal
      
      Total Calories: [Total]
      Brief explanation of why this fits the condition.
      """;

      return await askAI(prompt, context: "Expert Dietitian");
    } catch (e) {
      return "Failed to generate plan.";
    }
  }

  /* ================= MEAL PLANNING ================= */
  static Future<String> generateMealPlan({
    required String dietType,
    required int targetCalories,
    required List<String> allergies,
  }) async {
    try {
      final allergyText = allergies.isEmpty ? 'none' : allergies.join(', ');

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: _headers(),
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile',
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are a professional nutritionist creating personalized meal plans.'
            },
            {
              'role': 'user',
              'content': '''
Create a daily meal plan with the following requirements:
- Diet type: $dietType
- Target calories: $targetCalories
- Allergies to avoid: $allergyText

Provide a structured meal plan with breakfast, lunch, dinner, and 2 snacks.
For each meal, include:
1. Meal name
2. Ingredients
3. Approximate calories
4. Preparation tips

Format the response in clear sections.
'''
            }
          ],
          'temperature': 0.7,
          'max_tokens': 2000,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('Failed to generate meal plan: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error generating meal plan: $e');
    }
  }

  /* ================= RECIPE SUGGESTIONS ================= */
  static Future<String> getRecipeSuggestions({
    required List<String> ingredients,
    required String cuisine,
  }) async {
    try {
      final ingredientList = ingredients.join(', ');

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: _headers(),
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile',
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are a creative chef providing recipe suggestions based on available ingredients.'
            },
            {
              'role': 'user',
              'content': '''
Suggest 3 $cuisine recipes using these ingredients: $ingredientList

For each recipe, provide:
1. Recipe name
2. Additional ingredients needed
3. Cooking steps
4. Estimated cooking time
5. Nutritional highlights
'''
            }
          ],
          'temperature': 0.8,
          'max_tokens': 2000,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('Failed to get recipes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting recipes: $e');
    }
  }
}
