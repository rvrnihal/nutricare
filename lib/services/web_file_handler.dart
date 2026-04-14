import 'package:flutter/foundation.dart';
import 'dart:typed_data';
// ignore: deprecated_member_use
import 'dart:html' as html if (dart.library.html) 'dart:html';

/// Web-specific file handling for Flutter web
class WebFileHandler {
  /// Pick a file from user's device on web
  static Future<WebFileInput?> pickFile() async {
    if (!kIsWeb) return null;

    try {
      final input = html.FileUploadInputElement();
      input.accept = 'image/*';
      input.click();

      // Wait for file selection
      await input.onChange.first;

      final files = input.files;
      if (files == null || files.isEmpty) return null;

      final file = files.first;
      final reader = html.FileReader();
      
      await reader.onLoad.first;
      
      return WebFileInput(
        name: file.name,
        bytes: Uint8List.fromList(reader.result as List<int>),
        size: file.size ?? 0,
      );
    } catch (e) {
      debugPrint('Error picking file on web: $e');
      return null;
    }
  }

  /// Display file preview on web
  static String createObjectUrl(Uint8List bytes) {
    if (!kIsWeb) return '';
    
    try {
      final blob = html.Blob([bytes], 'image/*');
      return html.Url.createObjectUrlFromBlob(blob);
    } catch (e) {
      debugPrint('Error creating object URL: $e');
      return '';
    }
  }
}

class WebFileInput {
  final String name;
  final Uint8List bytes;
  final int size;

  WebFileInput({
    required this.name,
    required this.bytes,
    required this.size,
  });
}
