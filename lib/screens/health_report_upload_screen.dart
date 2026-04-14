import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:nuticare/core/theme.dart';
import 'package:nuticare/models/health_report_model.dart';
import 'package:nuticare/services/health_report_storage_service.dart';
import 'package:nuticare/services/ocr_extraction_service.dart';
import 'package:nuticare/services/health_analysis_engine.dart';
import 'package:nuticare/services/health_recommendation_service.dart';
import 'package:nuticare/screens/health_insights_dashboard_screen.dart';

class HealthReportUploadScreen extends StatefulWidget {
  const HealthReportUploadScreen({super.key});

  @override
  State<HealthReportUploadScreen> createState() =>
      _HealthReportUploadScreenState();
}

class _HealthReportUploadScreenState extends State<HealthReportUploadScreen> {
  double _uploadProgress = 0.0;
  double _processingProgress = 0.0;
  bool _isUploading = false;
  bool _isProcessing = false;

  String? _selectedImagePath;
  MedicalValues? _extractedValues;
  List<DetectedCondition>? _detectedConditions;
  Map<String, String>? _validationWarnings;
  final _reportDateController = TextEditingController();
  final _notesController = TextEditingController();
  bool _agreedToDisclaimer = false;

  @override
  void dispose() {
    _reportDateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage({bool useCamera = false}) async {
    if (!_agreedToDisclaimer) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the medical disclaimer first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final image = await OCRExtractionService.pickReportImage(
          useCamera: useCamera);

      if (image != null) {
        setState(() => _selectedImagePath = image.path);
        await _processImage(image.path);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _processImage(String imagePath) async {
    setState(() => _isProcessing = true);

    try {
      // Extract text using OCR
      final ocrText = await OCRExtractionService.extractTextFromImage(imagePath);

      if (ocrText == null || ocrText.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No text found in image. Try a clearer image.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Extract medical values
      final values = OCRExtractionService.extractMedicalValues(ocrText);

      // Validate extracted values
      final warnings = OCRExtractionService.validateValues(values);

      setState(() {
        _extractedValues = values;
        _validationWarnings = warnings;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error processing image: $e')),
        );
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _uploadAndAnalyze() async {
    if (_selectedImagePath == null || _extractedValues == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No report processed yet')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      // Upload file to Firebase Storage
      final fileUrl = await HealthReportStorageService.uploadReportFile(
        _selectedImagePath!,
        onProgress: (progress) {
          setState(() => _uploadProgress = progress);
        },
      );

      if (fileUrl == null) throw 'Upload failed';

      // Save report metadata
      final reportId = const Uuid().v4();
      final fileName = _selectedImagePath!.split('/').last;

      await HealthReportStorageService.saveReportMetadata(
        reportId,
        fileUrl,
        fileName,
        _extractedValues!,
        reportDate: _reportDateController.text.isNotEmpty
            ? DateTime.parse(_reportDateController.text)
            : null,
        notes: _notesController.text,
      );

      // Analyze health data
      final conditions =
          HealthAnalysisEngine.analyzeValues(_extractedValues!);

      // Save analysis
      final analysis = HealthAnalysis(
        reportId: reportId,
        analyzedAt: DateTime.now(),
        detectedConditions: conditions,
        overallRiskLevel:
            HealthAnalysisEngine.getOverallRiskLevel(conditions),
        summaryText:
            HealthRecommendationService.getHealthAdvisory(conditions),
      );

      await HealthReportStorageService.saveHealthAnalysis(reportId, analysis);

      setState(() => _detectedConditions = conditions);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report analyzed successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Show insights dashboard
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HealthInsightsDashboardScreen(
              analysis: analysis,
              medicalValues: _extractedValues!,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading report: $e')),
        );
      }
    } finally {
      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
      });
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
        title: Text("Health Report Upload",
            style: NutriTheme.textTheme.displayMedium?.copyWith(fontSize: 20)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 🔴 Medical Disclaimer Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                border: Border.all(color: Colors.red, width: 1.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          color: Colors.red, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Medical Disclaimer",
                          style: NutriTheme.textTheme.displayMedium
                              ?.copyWith(fontSize: 16, color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    HealthRecommendationService.getMedicalDisclaimer(),
                    style:
                        NutriTheme.textTheme.bodySmall?.copyWith(fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Checkbox(
                        value: _agreedToDisclaimer,
                        onChanged: (value) {
                          setState(() => _agreedToDisclaimer = value ?? false);
                        },
                        fillColor: WidgetStateProperty.all(NutriTheme.primary),
                      ),
                      Expanded(
                        child: Text(
                          "I understand and agree to the disclaimer above",
                          style: NutriTheme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Upload Section
            if (_selectedImagePath == null) ...[
              Text("Select Report",
                  style: NutriTheme.textTheme.displayMedium
                      ?.copyWith(fontSize: 18)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _agreedToDisclaimer
                          ? () => _pickImage(useCamera: false)
                          : null,
                      icon: const Icon(Icons.image),
                      label: const Text("Gallery"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: NutriTheme.primary,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _agreedToDisclaimer
                          ? () => _pickImage(useCamera: true)
                          : null,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text("Camera"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Processing Progress
              if (_isProcessing) ...[
                Text("Processing Report...",
                    style: NutriTheme.textTheme.displayMedium
                        ?.copyWith(fontSize: 18)),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                    backgroundColor: Colors.grey.shade800,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(NutriTheme.primary)),
                const SizedBox(height: 24),
              ] else if (_extractedValues != null) ...[
                // Extracted Values Display
                Text("Extracted Values",
                    style: NutriTheme.textTheme.displayMedium
                        ?.copyWith(fontSize: 18)),
                const SizedBox(height: 12),
                _buildExtractedValuesGrid(),
                const SizedBox(height: 16),
                // Warnings
                if (_validationWarnings != null &&
                    _validationWarnings!.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      border: Border.all(color: Colors.orange),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("⚠️ Verification Warnings:",
                            style:
                                NutriTheme.textTheme.bodyMedium?.copyWith(
                              color: Colors.orange,
                            )),
                        const SizedBox(height: 8),
                        ..._validationWarnings!.values
                            .map((w) => Text("• $w",
                                style: NutriTheme.textTheme.bodySmall))
                            .toList(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                // Report Date Input
                TextField(
                  controller: _reportDateController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Report Date (Optional)",
                    labelStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: NutriTheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.calendar_today,
                        color: Colors.green),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      _reportDateController.text = date.toString().split(' ')[0];
                    }
                  },
                ),
                const SizedBox(height: 12),
                // Notes Input
                TextField(
                  controller: _notesController,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Additional Notes (Optional)",
                    hintStyle: TextStyle(color: Colors.grey.shade600),
                    filled: true,
                    fillColor: NutriTheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],

              // Upload Button
              if (_extractedValues != null && !_isProcessing) ...[
                const SizedBox(height: 24),
                if (_isUploading)
                  Column(
                    children: [
                      LinearProgressIndicator(
                        value: _uploadProgress,
                        backgroundColor: Colors.grey.shade800,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            NutriTheme.primary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(_uploadProgress * 100).toStringAsFixed(0)}% Uploaded',
                        style: NutriTheme.textTheme.bodySmall,
                      ),
                    ],
                  )
                else
                  ElevatedButton(
                    onPressed: _uploadAndAnalyze,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: NutriTheme.primary,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Upload & Analyze",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExtractedValuesGrid() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: NutriTheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          if (_extractedValues!.glucose != null)
            _buildValueCard("Glucose", "${_extractedValues!.glucose} mg/dL",
                Icons.favorite),
          if (_extractedValues!.hemoglobin != null)
            _buildValueCard("Hemoglobin", "${_extractedValues!.hemoglobin} g/dL",
                Icons.bloodtype_outlined),
          if (_extractedValues!.totalCholesterol != null)
            _buildValueCard("Cholesterol",
                "${_extractedValues!.totalCholesterol} mg/dL", Icons.trending_up),
          if (_extractedValues!.systolicBP != null)
            _buildValueCard(
                "BP",
                "${_extractedValues!.systolicBP}/${_extractedValues!.diastolicBP}",
                Icons.favorite),
        ],
      ),
    );
  }

  Widget _buildValueCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: NutriTheme.primary, size: 20),
          const SizedBox(height: 4),
          Text(label,
              style: NutriTheme.textTheme.bodySmall,
              textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(value,
              style: NutriTheme.textTheme.bodyMedium
                  ?.copyWith(color: NutriTheme.primary),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
