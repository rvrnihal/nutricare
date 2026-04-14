import 'dart:typed_data';

class OCRService {
  static Future<String> extractTextFromBytes(Uint8List bytes) async {
    // Web-safe fallback (real OCR requires backend)
    return "Food item detected from image";
  }
}
