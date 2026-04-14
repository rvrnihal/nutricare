import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:nuticare/core/theme.dart';
import 'package:nuticare/models/health_report_model.dart';
import 'package:nuticare/services/health_analysis_engine.dart';
import 'package:nuticare/services/health_recommendation_service.dart';
import 'package:nuticare/screens/health_insights_dashboard_screen.dart';
import 'package:nuticare/services/web_file_handler.dart';

class HealthReportWebUploadScreen extends StatefulWidget {
  const HealthReportWebUploadScreen({super.key});

  @override
  State<HealthReportWebUploadScreen> createState() =>
      _HealthReportWebUploadScreenState();
}

class _HealthReportWebUploadScreenState
    extends State<HealthReportWebUploadScreen> {
  int _currentStep = 0;

  // Step 1: File Upload
  WebFileInput? _selectedFile;
  String? _filePreviewUrl;
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  // Step 2: Manual Value Entry (for web fallback)
  final _glucoseController = TextEditingController();
  final _hemoglobinController = TextEditingController();
  final _cholesterolController = TextEditingController();
  final _systolicBPController = TextEditingController();
  final _diastolicBPController = TextEditingController();
  final _vitaminDController = TextEditingController();
  final _thyroidTSHController = TextEditingController();
  final _ironController = TextEditingController();

  bool _agreedToDisclaimer = false;
  bool _useManualEntry = false;

  @override
  void dispose() {
    _glucoseController.dispose();
    _hemoglobinController.dispose();
    _cholesterolController.dispose();
    _systolicBPController.dispose();
    _diastolicBPController.dispose();
    _vitaminDController.dispose();
    _thyroidTSHController.dispose();
    _ironController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final file = await WebFileHandler.pickFile();
    if (file != null) {
      final previewUrl = WebFileHandler.createObjectUrl(file.bytes);
      setState(() {
        _selectedFile = file;
        _filePreviewUrl = previewUrl;
      });
    }
  }

  double? _parseDouble(String value) {
    if (value.isEmpty) return null;
    return double.tryParse(value);
  }

  MedicalValues _getValuesFromForm() {
    return MedicalValues(
      glucose: _parseDouble(_glucoseController.text),
      hemoglobin: _parseDouble(_hemoglobinController.text),
      totalCholesterol: _parseDouble(_cholesterolController.text),
      systolicBP: _parseDouble(_systolicBPController.text),
      diastolicBP: _parseDouble(_diastolicBPController.text),
      vitaminD: _parseDouble(_vitaminDController.text),
      thyroidTSH: _parseDouble(_thyroidTSHController.text),
      iron: _parseDouble(_ironController.text),
    );
  }

  Future<void> _submitReport() async {
    if (!_agreedToDisclaimer) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the medical disclaimer'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final reportId = const Uuid().v4();
      final now = DateTime.now();
      final values = _getValuesFromForm();

      // Analyze health data
      final conditions = HealthAnalysisEngine.analyzeValues(values);
      final riskLevel = HealthAnalysisEngine.getOverallRiskLevel(conditions);

      // Create analysis
      final analysis = HealthAnalysis(
        reportId: reportId,
        analyzedAt: now,
        detectedConditions: conditions,
        overallRiskLevel: riskLevel,
        summaryText: HealthRecommendationService.getHealthAdvisory(conditions),
      );

      // For web, we skip Firebase upload and just show results
      if (kIsWeb) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report analyzed successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => HealthInsightsDashboardScreen(
                analysis: analysis,
                medicalValues: values,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isUploading = false);
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
            // Medical Disclaimer
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

            // Manual Entry Toggle
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: NutriTheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: _useManualEntry,
                    onChanged: (value) {
                      setState(() => _useManualEntry = value ?? false);
                    },
                    fillColor: WidgetStateProperty.all(NutriTheme.primary),
                  ),
                  Expanded(
                    child: Text(
                      "Enter health values manually",
                      style: NutriTheme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            if (_useManualEntry) ...[
              Text("Enter Health Values",
                  style: NutriTheme.textTheme.displayMedium
                      ?.copyWith(fontSize: 18)),
              const SizedBox(height: 16),
              _buildValueInput("Glucose (mg/dL)", _glucoseController),
              _buildValueInput("Hemoglobin (g/dL)", _hemoglobinController),
              _buildValueInput("Total Cholesterol (mg/dL)",
                  _cholesterolController),
              _buildValueInput("Systolic BP (mmHg)", _systolicBPController),
              _buildValueInput("Diastolic BP (mmHg)", _diastolicBPController),
              _buildValueInput("Vitamin D (ng/mL)", _vitaminDController),
              _buildValueInput("Thyroid TSH (mcIU/mL)", _thyroidTSHController),
              _buildValueInput("Iron (µg/dL)", _ironController),
            ] else ...[
              Text("Upload Health Report Image",
                  style: NutriTheme.textTheme.displayMedium
                      ?.copyWith(fontSize: 18)),
              const SizedBox(height: 16),
              if (_selectedFile == null)
                ElevatedButton.icon(
                  onPressed: _agreedToDisclaimer ? _pickFile : null,
                  icon: const Icon(Icons.upload_file),
                  label: const Text("Choose File"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NutriTheme.primary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                )
              else ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: NutriTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.check_circle,
                              color: Colors.green, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'File selected: ${_selectedFile!.name}',
                              style: NutriTheme.textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_filePreviewUrl != null && _filePreviewUrl!.isNotEmpty)
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.black12,
                          ),
                          child: Image.network(
                            _filePreviewUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Center(
                              child: Text(
                                'Image preview unavailable',
                                style: NutriTheme.textTheme.bodySmall,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Note: For web, please enter values manually below.",
                  style: NutriTheme.textTheme.bodySmall
                      ?.copyWith(color: Colors.orange),
                ),
              ],
            ],

            const SizedBox(height: 24),

            // Submit Button
            if (_isUploading)
              Column(
                children: [
                  LinearProgressIndicator(
                    value: _uploadProgress,
                    backgroundColor: Colors.grey.shade800,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(NutriTheme.primary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Processing...',
                    style: NutriTheme.textTheme.bodySmall,
                  ),
                ],
              )
            else
              ElevatedButton(
                onPressed: _agreedToDisclaimer ? _submitReport : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: NutriTheme.primary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Analyze Report",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildValueInput(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          filled: true,
          fillColor: NutriTheme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
