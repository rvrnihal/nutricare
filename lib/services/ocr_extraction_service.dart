import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nuticare/models/health_report_model.dart';

/// Service for extracting medical data from uploaded reports
class OCRExtractionService {
  static final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  static final _imagePicker = ImagePicker();

  /// Pick an image from gallery or camera
  static Future<XFile?> pickReportImage({bool useCamera = false}) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: useCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 85,
      );
      return pickedFile;
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  /// Extract text from image using OCR
  static Future<String?> extractTextFromImage(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      return recognizedText.text;
    } catch (e) {
      debugPrint('Error extracting text: $e');
      return null;
    }
  }

  /// Parse OCR text to extract medical values
  static MedicalValues extractMedicalValues(String ocrText) {
    final text = ocrText.toLowerCase();

    return MedicalValues(
      glucose: _extractValue(text, ['glucose', 'fasting glucose', 'fbs'], 'mg/dl'),
      totalCholesterol: _extractValue(text, ['total cholesterol', 'cholesterol'], 'mg/dl'),
      ldl: _extractValue(text, ['ldl', 'ldl cholesterol', 'bad cholesterol'], 'mg/dl'),
      hdl: _extractValue(text, ['hdl', 'hdl cholesterol', 'good cholesterol'], 'mg/dl'),
      triglycerides: _extractValue(text, ['triglycerides', 'triglyceride'], 'mg/dl'),
      hemoglobin: _extractValue(text, ['hemoglobin', 'hb', 'hgb'], 'g/dl'),
      hematocrit: _extractValue(text, ['hematocrit', 'hct'], '%'),
      vitaminD: _extractValue(text, ['vitamin d', '25-oh d'], 'ng/ml'),
      vitaminB12: _extractValue(text, ['vitamin b12', 'b12', 'cobalamin'], 'pg/ml'),
      iron: _extractValue(text, ['iron', 'serum iron'], 'µg/dl'),
      systolicBP: _extractBloodPressureSystolic(text),
      diastolicBP: _extractBloodPressureDiastolic(text),
      bmi: _extractValue(text, ['bmi', 'body mass index'], 'kg/m²'),
      thyroidTSH: _extractValue(text, ['tsh', 'thyroid'], 'mciu/ml'),
      bloodType: _extractBloodType(text),
    );
  }

  /// Extract numeric value associated with keywords
  static double? _extractValue(
      String text, List<String> keywords, String unit) {
    for (final keyword in keywords) {
      final pattern = RegExp(
        '$keyword[^\\d]*([\\d.]+)',
        caseSensitive: false,
        multiLine: true,
      );

      final match = pattern.firstMatch(text);
      if (match != null && match.groupCount > 0) {
        try {
          return double.parse(match.group(1)!);
        } catch (e) {
          debugPrint('Error parsing $keyword: $e');
        }
      }
    }
    return null;
  }

  /// Extract systolic BP
  static double? _extractBloodPressureSystolic(String text) {
    final bpPatterns = [
      RegExp(r'bp\s*[:/]?\s*(\d+)\s*[x/]\s*\d+', caseSensitive: false),
      RegExp(r'blood\s*pressure\s*[:/]?\s*(\d+)', caseSensitive: false),
      RegExp(r'(\d+)\s*(?:mmhg|mm\s*hg)\s*[x/]\s*\d+', caseSensitive: false),
    ];

    for (final pattern in bpPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null && match.groupCount > 0) {
        try {
          return double.parse(match.group(1)!);
        } catch (e) {
          debugPrint('Error parsing BP systolic: $e');
        }
      }
    }
    return null;
  }

  /// Extract diastolic BP
  static double? _extractBloodPressureDiastolic(String text) {
    final bpPatterns = [
      RegExp(r'bp\s*[:/]?\s*\d+\s*[x/]\s*(\d+)', caseSensitive: false),
      RegExp(r'[x/]\s*(\d+)\s*(?:mmhg|mm\s*hg)', caseSensitive: false),
    ];

    for (final pattern in bpPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null && match.groupCount > 0) {
        try {
          return double.parse(match.group(1)!);
        } catch (e) {
          debugPrint('Error parsing BP diastolic: $e');
        }
      }
    }
    return null;
  }

  /// Extract blood type
  static String? _extractBloodType(String text) {
    final pattern = RegExp(
      r'(?:blood\s*type|blood\s*group|type)[:\s]+([abo]+\s*[+-])',
      caseSensitive: false,
    );

    final match = pattern.firstMatch(text);
    return match?.group(1)?.replaceAll(RegExp(r'\s+'), '').toUpperCase();
  }

  /// Validate extracted values (check if they're within reasonable ranges)
  static Map<String, String> validateValues(MedicalValues values) {
    final warnings = <String, String>{};

    if (values.glucose != null) {
      if (values.glucose! < 50 || values.glucose! > 400) {
        warnings['glucose'] = 'Unusual glucose value. Please verify.';
      }
    }

    if (values.hemoglobin != null) {
      if (values.hemoglobin! < 5 || values.hemoglobin! > 20) {
        warnings['hemoglobin'] = 'Unusual hemoglobin value. Please verify.';
      }
    }

    if (values.systolicBP != null) {
      if (values.systolicBP! < 50 || values.systolicBP! > 250) {
        warnings['systolicBP'] = 'Unusual blood pressure reading. Please verify.';
      }
    }

    if (values.totalCholesterol != null) {
      if (values.totalCholesterol! < 100 || values.totalCholesterol! > 500) {
        warnings['cholesterol'] = 'Unusual cholesterol value. Please verify.';
      }
    }

    return warnings;
  }

  /// Dispose resources
  static Future<void> dispose() async {
    await _textRecognizer.close();
  }
}
