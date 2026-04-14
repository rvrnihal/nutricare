import 'groq_ai_service.dart';

class MedicineAIService {
  static Future<String> checkInteractions(List<String> medicines) async {
    return await GroqAIService.checkMedicineInteractions(medicines);
  }
}
