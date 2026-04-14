import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nuticare/core/theme.dart';
import 'package:nuticare/models/health_report_model.dart';
import 'package:nuticare/services/ocr_extraction_service.dart';
import 'package:nuticare/services/health_analysis_engine.dart';

class ReportAnalysisScreen extends StatefulWidget {
  const ReportAnalysisScreen({super.key});

  @override
  State<ReportAnalysisScreen> createState() => _ReportAnalysisScreenState();
}

class _ReportAnalysisScreenState extends State<ReportAnalysisScreen> {
  bool _isProcessing = false;
  bool _hasReport = false;
  MedicalValues? _extractedValues;
  List<DetectedCondition>? _detectedConditions;
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickAndAnalyzeReport() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image =
          await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() => _isProcessing = true);

        // Extract text using OCR
        final ocrText =
            await OCRExtractionService.extractTextFromImage(image.path);

        if (ocrText == null || ocrText.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No text found in image')),
            );
          }
          setState(() => _isProcessing = false);
          return;
        }

        // Extract medical values
        final values = OCRExtractionService.extractMedicalValues(ocrText);

        // Analyze for conditions
        final conditions = HealthAnalysisEngine.analyzeValues(values);

        setState(() {
          _extractedValues = values;
          _detectedConditions = conditions;
          _hasReport = true;
          _isProcessing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Analysis'),
        elevation: 0,
        backgroundColor: NutriTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: !_hasReport
          ? _buildEmptyState()
          : _buildAnalysisView(),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            NutriTheme.primary.withOpacity(0.05),
            Colors.white,
          ],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: NutriTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: Icon(
                    Icons.description_outlined,
                    size: 80,
                    color: NutriTheme.primary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Upload Health Report',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[900],
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Analyze your health report to get personalized recommendations',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _pickAndAnalyzeReport,
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  label: _isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Select Report Image'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    backgroundColor: NutriTheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                if (_isProcessing)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          'Analyzing your health report...',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Health Values Summary
          if (_extractedValues != null) ...[
            _buildHealthSummaryCard(),
            const SizedBox(height: 16),
          ],
          // Detected Conditions
          if (_detectedConditions != null && _detectedConditions!.isNotEmpty)
            _buildDetectedConditionsCard(),
          const SizedBox(height: 16),
          // Notes Section
          _buildNotesSection(),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Report saved successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            icon: const Icon(Icons.save),
            label: const Text('Save Report'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              minimumSize: const Size.fromHeight(48),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthSummaryCard() {
    if (_extractedValues == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Health Values',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          if (_extractedValues!.glucose != null)
            _buildHealthValueRow(
                'Blood Glucose', '${_extractedValues!.glucose} mg/dL', Colors.orange),
          if (_extractedValues!.systolicBP != null)
            _buildHealthValueRow(
                'Blood Pressure',
                '${_extractedValues!.systolicBP}/${_extractedValues!.diastolicBP} mmHg',
                Colors.red),
          if (_extractedValues!.hemoglobin != null)
            _buildHealthValueRow('Hemoglobin', '${_extractedValues!.hemoglobin} g/dL',
                Colors.blue),
          if (_extractedValues!.totalCholesterol != null)
            _buildHealthValueRow('Cholesterol',
                '${_extractedValues!.totalCholesterol} mg/dL', Colors.purple),
        ],
      ),
    );
  }

  Widget _buildHealthValueRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                    ),
              ),
            ],
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetectedConditionsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
              const SizedBox(width: 8),
              Text(
                'Detected Conditions',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._detectedConditions!.map((condition) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.orange.shade600),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            condition.name,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[900],
                                ),
                          ),
                          Text(
                            condition.description,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Additional Notes',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Add any additional health information or symptoms...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }
}
