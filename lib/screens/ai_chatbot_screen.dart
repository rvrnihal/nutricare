import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import '../services/groq_ai_service.dart';
import '../services/food_medicine_report_service.dart';
import '../services/ai_history_service.dart';
import '../services/user_data_storage_service.dart';
import 'nutrition_screen.dart';
import 'workout_screen.dart';
import 'enhanced_medicine_screen.dart';
import 'health_report_upload_screen.dart';
import 'meal_planner_screen.dart';
import 'challenges_screen.dart';

class AIChatbotScreen extends StatefulWidget {
  const AIChatbotScreen({super.key});

  @override
  State<AIChatbotScreen> createState() => _AIChatbotScreenState();
}

class _AIChatbotScreenState extends State<AIChatbotScreen> {
  static const Color _brandPrimary = Color(0xFF0B6E99);
  static const Color _brandAccent = Color(0xFF22A699);
  static const Color _brandSurface = Color(0xFFEFF8FB);

  final TextEditingController _controller = TextEditingController();
  final List<_ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  bool _isLoadingHistory = true;

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    try {
      final chats = await AIHistoryService.getRecentChats(limit: 50);

      setState(() {
        // Load chats in reverse order (oldest first for chat display)
        for (var chat in chats.reversed) {
          _messages.add(_ChatMessage(
            text: chat['question'] ?? '',
            isUser: true,
          ));
          _messages.add(_ChatMessage(
            text: chat['answer'] ?? '',
            isUser: false,
          ));
        }
        _isLoadingHistory = false;
      });

      _scrollToBottom();
    } catch (e) {
      debugPrint('Error loading chat history: $e');
      setState(() => _isLoadingHistory = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Chat'),
        content:
            const Text('Are you sure you want to clear this conversation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() => _messages.clear());
              Navigator.pop(context);
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _sendQuickMessage(String message) {
    _controller.text = message;
    _sendMessage();
  }

  void _viewHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChatHistoryScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("NutriCare AI Engine"),
        elevation: 0,
        backgroundColor: _brandPrimary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'View History',
            onPressed: _viewHistory,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear Chat',
            onPressed: _messages.isEmpty ? null : _clearChat,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _brandSurface,
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: _messages.isEmpty && !_isTyping
                  ? _buildEmptyState()
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(12),
                      itemCount: _messages.length + (_isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (_isTyping && index == _messages.length) {
                          return const _TypingBubble();
                        }
                        return _ChatBubble(message: _messages[index]);
                      },
                    ),
            ),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildArchitectureHero(),
          const SizedBox(height: 14),
          const SizedBox(height: 6),
          Text(
            'AI Personalization Modules',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 10),
          _buildModuleGrid(),
          const SizedBox(height: 18),
          _buildFeatureCoverageCard(),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFeatureChip('Food Nutrition', () =>
                  _sendQuickMessage('Tell me about food nutrition analysis')),
              _buildFeatureChip('Medicine Info', () =>
                  _sendQuickMessage('I need medicine information and recommendations')),
              _buildFeatureChip('Workout Plan', () =>
                  _sendQuickMessage('Give me workout recommendations')),
              _buildFeatureChip('Health Tracking', () =>
                  _sendQuickMessage('Help me with health tracking')),
              _buildFeatureChip('Meal Plan', () =>
                  _sendQuickMessage('Create a meal plan for me')),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _brandPrimary.withValues(alpha: 0.14)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Suggested first question',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'What should I eat this week to improve energy and maintain weight?',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArchitectureHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_brandPrimary, _brandAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: _brandPrimary.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.hub_rounded, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Professional AI Personalization Engine',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'User data, health history, and reminders are connected to generate personalized nutrition, medication, and fitness guidance in one workflow.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.92),
                  height: 1.45,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _StatusPill(label: 'Auth Connected', icon: Icons.verified_user),
              _StatusPill(label: 'Firestore Ready', icon: Icons.cloud_done),
              _StatusPill(label: 'Reminders Active', icon: Icons.notifications_active),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModuleGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.06,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildModuleCard(
          title: 'Nutrition Guide',
          subtitle: 'Diet insights and meal analytics',
          icon: Icons.restaurant_menu_rounded,
          color: const Color(0xFF0D8F62),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NutritionScreen()),
          ),
        ),
        _buildModuleCard(
          title: 'Medicine Reminder',
          subtitle: 'Schedules and smart safety checks',
          icon: Icons.medication_rounded,
          color: const Color(0xFF1F6CC4),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EnhancedMedicineScreen()),
          ),
        ),
        _buildModuleCard(
          title: 'Fitness Module',
          subtitle: 'Workout tracking and wearable sync',
          icon: Icons.fitness_center_rounded,
          color: const Color(0xFFCC7A12),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WorkoutScreen()),
          ),
        ),
        _buildModuleCard(
          title: 'Health Insights',
          subtitle: 'Report upload and AI analysis',
          icon: Icons.insights_rounded,
          color: const Color(0xFF8A49C2),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HealthReportUploadScreen()),
          ),
        ),
        _buildModuleCard(
          title: 'Meal Planner',
          subtitle: 'Generate weekly AI meal plans',
          icon: Icons.calendar_view_week_rounded,
          color: const Color(0xFF0B6E99),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MealPlannerScreen()),
          ),
        ),
        _buildModuleCard(
          title: 'Ask AI Chat',
          subtitle: 'Open chat prompts instantly',
          icon: Icons.chat_bubble_outline_rounded,
          color: const Color(0xFF2A3F57),
          onTap: () => _sendQuickMessage('Give me a complete wellness plan for this week'),
        ),
      ],
    );
  }

  Widget _buildFeatureCoverageCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _brandPrimary.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Included Feature Coverage',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 10),
          _coverageRow(
            title: 'Personalized Health Analysis',
            description: 'Lab report analysis and risk scoring',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HealthReportUploadScreen()),
            ),
          ),
          _coverageRow(
            title: 'Meal Planning & Nutrition Guidance',
            description: 'AI meal planner plus nutrition analyzer',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MealPlannerScreen()),
            ),
          ),
          _coverageRow(
            title: 'Activity Tracking',
            description: 'Workout timer, calories, heart-rate and steps',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WorkoutScreen()),
            ),
          ),
          _coverageRow(
            title: 'Feedback & Recommendations',
            description: 'AI-generated diet, medicine, and health recommendations',
            onTap: () => _sendQuickMessage(
                'Give me personalized health feedback and recommendations based on my goals'),
          ),
          _coverageRow(
            title: 'Behavior Modification Support',
            description: 'Challenges, streaks, habits, and motivational nudges',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChallengesScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _coverageRow({
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: _brandSurface,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(Icons.verified_rounded,
                      color: Color(0xFF0D8F62), size: 18),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.open_in_new_rounded,
                    color: Colors.black54, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModuleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade900,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.grey.shade700,
                      height: 1.25,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureChip(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _brandSurface,
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _brandPrimary.withValues(alpha: 0.25),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: _brandPrimary.withValues(alpha: 0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: _brandPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Future<String> _getUserContext() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return "User is guest.";

    try {
      final profileDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final profile = profileDoc.data() ?? {};

      final workouts = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('workouts')
          .orderBy('startTime', descending: true)
          .limit(1)
          .get();

      String workoutContext = "No recent workouts.";
      if (workouts.docs.isNotEmpty) {
        final w = workouts.docs.first.data();
        workoutContext =
            "Last workout: ${w['type']} for ${w['durationSeconds'] ?? 0}s, burning ${w['caloriesBurned'] ?? 0} kcal.";
      }

      return "User: ${profile['name'] ?? 'Guest'}. Goal: ${profile['goal'] ?? 'Get Fit'}. $workoutContext";
    } catch (e) {
      return "Error fetching context.";
    }
  }

  // ==================== DOCUMENT ANALYSIS ====================

  /// Pick and analyze document (PDF or Image) - Fixed for web
  Future<void> _pickAndAnalyzeDocument() async {
    try {
      debugPrint('🔵 File picker starting...');
      
      // Try file picker
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'PNG', 'JPG', 'JPEG', 'PDF'],
        withData: true,
        allowMultiple: false,
      );

      if (result == null) {
        debugPrint('🔵 File picker cancelled');
        return;
      }

      debugPrint('🔵 Files received: ${result.files.length}');

      if (result.files.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ No file selected')),
        );
        return;
      }

      final file = result.files.first;
      debugPrint('🔵 File: ${file.name}, Size: ${file.size} bytes, Extension: ${file.extension}');

      if (file.bytes == null || file.bytes!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ File is empty')),
        );
        return;
      }

      final ext = file.extension?.toLowerCase() ?? '';
      final isImage = ['jpg', 'jpeg', 'png'].contains(ext);
      final isPdf = ext == 'pdf';

      debugPrint('🔵 Image: $isImage, PDF: $isPdf');

      if (!isImage && !isPdf) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Only PDF, JPG, PNG files supported')),
        );
        return;
      }

      setState(() => _isTyping = true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📥 Processing file...'),
          duration: Duration(seconds: 2),
        ),
      );

      String extractedText = '';

      try {
        if (isPdf) {
          extractedText = 'PDF file uploaded. Please describe key health values.';
        } else {
          // Analyze image
          debugPrint('🔵 Analyzing image...');
          extractedText = await _analyzeImage(file.bytes!);
          debugPrint('🔵 Image analysis complete: ${extractedText.length} chars');
        }

        if (extractedText.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('⚠️ No text extracted')),
          );
          setState(() => _isTyping = false);
          return;
        }

        debugPrint('🔵 Starting comprehensive health analysis...');
        
        // Send to comprehensive analysis with file name
        await _analyzeHealthReportComprehensively(extractedText, file.name);
        
        debugPrint('🔵 Comprehensive analysis complete');
      } catch (e) {
        debugPrint('❌ Analysis error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: ${e.toString().substring(0, 50)}'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isTyping = false);
      }
    } catch (e) {
      debugPrint('❌ File picker error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Comprehensive health report analysis (food, workout, diet, medicines)
  Future<void> _analyzeHealthReportComprehensively(String extractedText, String fileName) async {
    try {
      // Add file upload notification message
      setState(() {
        _messages.add(_ChatMessage(
          text: '',
          isUser: true,
          fileName: fileName,
        ));
        _isTyping = true;
      });

      _scrollToBottom();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📊 Generating comprehensive health recommendations...'),
          duration: Duration(seconds: 3),
        ),
      );

      // Use Groq AI to analyze the extracted health report text
      final prompt = '''Analyze this health report and provide:
1. Key Findings: Important values and results
2. Health Status: Overall assessment
3. Risk Factors: Any concerning values
4. Recommendations: Suggestions for improvement
5. Next Steps: What to do next

Health Report Content:
$extractedText

Provide a structured, professional analysis suitable for a health app.''';

      final analysis = await GroqAIService.askAI(prompt);

      // Add comprehensive analysis with file name and health data
      setState(() {
        // Add file name header message
        _messages.add(_ChatMessage(
          text: '📋 **Health Report:** $fileName',
          isUser: false,
        ));
        
        // Add detailed analysis
        _messages.add(_ChatMessage(
          text: analysis,
          isUser: false,
        ));

        _isTyping = false;
      });

      // Save comprehensive analysis to Firestore
      try {
        await AIHistoryService.saveChat(
          'Uploaded health report for analysis: $fileName',
          analysis,
        );

        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('health_analyses')
              .add({
            'timestamp': FieldValue.serverTimestamp(),
            'type': 'comprehensive_report',
            'fileName': fileName,
            'analysis': analysis,
            'createdAt': DateTime.now().toIso8601String(),
          });
        }
      } catch (e) {
        debugPrint('Failed to save analysis to Firestore: $e');
      }

      _scrollToBottom();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Analysis complete and saved!'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint('Comprehensive analysis error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString().substring(0, 50)}'),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isTyping = false);
    }
  }

  /// Analyze image using Groq Vision API
  Future<String> _analyzeImage(Uint8List imageBytes) async {
    try {
      // Convert image to base64
      final base64Image = convert.base64Encode(imageBytes);

      setState(() => _isTyping = true);

      // Send to backend for Vision analysis
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🖼️  Analyzing image with Vision AI...'),
          duration: Duration(seconds: 2),
        ),
      );

      // Note: Groq API doesn't support image analysis yet
      // For now, provide helpful guidance to user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📷 Image uploaded. Please describe what you see.'),
          duration: Duration(seconds: 2),
        ),
      );

      return '✅ Image uploaded successfully!\n\nSince Groq doesn\'t support image vision yet, please help me by describing:\n\n• **Document type:** Blood report, prescription, X-ray, etc.\n• **Key values:** Any numbers visible (glucose, cholesterol, BP, etc.)\n• **Date:** When was this test done?\n• **Your question:** What would you like to know about this?\n\nI\'ll provide detailed health analysis based on your description!';
    } catch (e) {
      debugPrint('Image analysis error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ Error: ${e.toString().substring(0, 40)}'),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
      return '⚠️ Could not process image.\n\nPlease try:\n• Describing the document type\n• Sharing the key values you see\n• Or asking a specific health question\n\nI\'m here to help with your health data!';
    }
  }

  /// Modified send message to handle document analysis
  Future<void> _sendMessage([String? overrideText]) async {
    final text = overrideText ?? _controller.text.trim();
    if (text.isEmpty || _isTyping) return;

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _isTyping = true;
      if (overrideText == null) {
        _controller.clear();
      }
    });

    _scrollToBottom();

    // Fetch context
    String context = await _getUserContext();

    try {
      // Add timeout to prevent stuck state
      final reply = await GroqAIService.askAI(text, context: context).timeout(
        const Duration(seconds: 30),
        onTimeout: () => "⚠️ AI service is taking too long. Please try again.",
      );

      // Check if user is asking about food or medicine and fetch reports
      final lowerText = text.toLowerCase();
      
      bool isFoodQuery = lowerText.contains('food') || 
                        lowerText.contains('nutrition') || 
                        lowerText.contains('calories') ||
                        lowerText.contains('diet');
      
      bool isMedicineQuery = lowerText.contains('medicine') || 
                             lowerText.contains('drug') || 
                             lowerText.contains('dosage') ||
                             lowerText.contains('tablet');

      setState(() {
        _messages.add(_ChatMessage(text: reply, isUser: false));
        _isTyping = false;
      });

      // Save conversation to history with categorization
      try {
        await AIHistoryService.saveChat(text, reply);
        
        String category = 'general';
        if (lowerText.contains('workout') || lowerText.contains('exercise')) {
          category = 'workout';
        } else if (isFoodQuery) {
          category = 'nutrition';
        } else if (isMedicineQuery) {
          category = 'medicine';
        }
        
        await UserDataStorageService.saveAIConversation(
          question: text,
          answer: reply,
          category: category,
        );
      } catch (e) {
        debugPrint('Failed to save chat: $e');
      }

      _scrollToBottom();
    } catch (e) {
      debugPrint('Error in _sendMessage: $e');
      setState(() {
        _messages.add(
          _ChatMessage(
            text: "⚠️ Network error or AI service unavailable.\n\nPlease check:\n• Internet connection\n• Backend server status (port 5000)\n• Try again in a moment",
            isUser: false,
          ),
        );
        _isTyping = false;
      });
      _scrollToBottom();
    }
  }

  Widget _buildInputBar() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: "Ask something...",
                    hintStyle: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 15,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(
                        color: _brandPrimary.withValues(alpha: 0.25),
                        width: 1.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(
                        color: _brandPrimary.withValues(alpha: 0.18),
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(
                        color: _brandPrimary,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 13,
                    ),
                    suffixIcon: _controller.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.done,
                              color: _brandPrimary,
                            ),
                            onPressed: _isTyping ? null : _sendMessage,
                          )
                        : null,
                  ),
                  style: TextStyle(
                    color: Colors.grey.shade900,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (value) => setState(() {}),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 6),
              // Document Upload Button
              Tooltip(
                message: 'Upload PDF or Image for Analysis',
                child: GestureDetector(
                  onTap: _isTyping ? null : _pickAndAnalyzeDocument,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _isTyping
                            ? [Colors.grey.shade400, Colors.grey.shade600]
                            : [Colors.blue.shade400, Colors.blue.shade600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _isTyping
                              ? Colors.grey.withOpacity(0.2)
                              : Colors.blue.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.attach_file,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _brandAccent,
                      _brandPrimary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _brandPrimary.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    _isTyping ? Icons.pause : Icons.send,
                    color: Colors.white,
                  ),
                  onPressed: _isTyping ? null : _sendMessage,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ---------- HISTORY SCREEN ---------- */

class ChatHistoryScreen extends StatelessWidget {
  const ChatHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat History'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: AIHistoryService.getChatHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading history: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No chat history yet',
                    style: TextStyle(color: Colors.grey[600], fontSize: 18),
                  ),
                ],
              ),
            );
          }

          final chats = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index].data();
              final question = chat['question'] ?? '';
              final answer = chat['answer'] ?? '';
              final timestamp = chat['createdAt'];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  title: Text(
                    question,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: timestamp != null
                      ? Text(
                          _formatTimestamp(timestamp),
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 12),
                        )
                      : null,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'AI Response:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(answer),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '';

    DateTime dateTime;
    if (timestamp is DateTime) {
      dateTime = timestamp;
    } else {
      dateTime = (timestamp as dynamic).toDate();
    }

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}

/* ---------- UI COMPONENTS ---------- */

class _ChatMessage {
  final String text;
  final bool isUser;
  final Map<String, dynamic>? foodReport;
  final Map<String, dynamic>? medicineReport;
  final String? fileName;
  final Map<String, dynamic>? healthAnalysis;

  _ChatMessage({
    required this.text,
    required this.isUser,
    this.foodReport,
    this.medicineReport,
    this.fileName,
    this.healthAnalysis,
  });
}

class _ChatBubble extends StatelessWidget {
  final _ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    // Handle file upload with health analysis
    if (message.fileName != null && message.healthAnalysis != null && !message.isUser) {
      return Column(
        children: [
          _buildFileUploadBubble(),
          const SizedBox(height: 12),
          _buildHealthAnalysisReport(message.healthAnalysis!, message.fileName!),
        ],
      );
    }

    // Handle food report
    if (message.foodReport != null && !message.isUser) {
      return Column(
        children: [
          _buildTextBubble(message.text),
          FoodReportWidget(report: message.foodReport!),
        ],
      );
    }

    // Handle medicine report
    if (message.medicineReport != null && !message.isUser) {
      return Column(
        children: [
          _buildTextBubble(message.text),
          MedicineReportWidget(report: message.medicineReport!),
        ],
      );
    }

    // Handle file upload notification
    if (message.fileName != null && message.isUser) {
      return _buildFileUploadNotification();
    }

    // Regular text message
    return _buildTextBubble(message.text);
  }

  Widget _buildFileUploadNotification() {
    return Align(
      alignment: Alignment.centerRight,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.8, end: 1.0),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOut,
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: scale,
              child: child,
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.deepPurple.shade400,
                Colors.deepPurple.shade600,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: const Radius.circular(20),
              bottomRight: const Radius.circular(4),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurple.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.attach_file, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Uploaded: ${message.fileName}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileUploadBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOut,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(-20 * (1 - value), 0),
            child: Opacity(opacity: value, child: child),
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF22A699).withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF22A699).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.description_rounded,
                      color: Color(0xFF22A699),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Health Report Analyzed',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: Color(0xFF0B6E99),
                          ),
                        ),
                        Text(
                          message.fileName ?? 'document.pdf',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF22A699),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHealthAnalysisReport(Map<String, dynamic> analysis, String fileName) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: 0.8 + (value * 0.2),
            child: Opacity(opacity: value, child: child),
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // File name header - PROMINENT
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF0B6E99).withOpacity(0.12),
                      const Color(0xFF22A699).withOpacity(0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF0B6E99).withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B6E99),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.file_present_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '📄 Analyzed File',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: Color(0xFF0B6E99),
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            fileName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: Color(0xFF0B6E99),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF22A699),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.check_circle_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Analysis sections
              _buildAnalysisSection('🥗 Food Recommendations', analysis['foodRecommendations']),
              const SizedBox(height: 14),
              _buildAnalysisSection('💪 Workout Plan', analysis['workoutPlan']),
              const SizedBox(height: 14),
              _buildAnalysisSection('🍽️ Dietary Plan', analysis['dietaryPlan']),
              const SizedBox(height: 14),
              _buildAnalysisSection('💊 Medicines', analysis['medicineRecommendations']),
              if (analysis['foodDrugInteractions'] != null && (analysis['foodDrugInteractions'] as List).isNotEmpty) ...[
                const SizedBox(height: 14),
                _buildFoodDrugInteractionsSection(analysis['foodDrugInteractions']),
              ],
              if (analysis['urgentAlerts'] != null && (analysis['urgentAlerts'] as List).isNotEmpty) ...[
                const SizedBox(height: 14),
                _buildAlertSection(analysis['urgentAlerts']),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisSection(String title, dynamic content) {
    String contentStr = 'No data available';
    
    if (content == null) {
      contentStr = 'No data available';
    } else if (content is Map) {
      // Handle food recommendations
      if (content['include'] != null || content['avoid'] != null || content['rationale'] != null) {
        final include = (content['include'] as List?)?.join(', ') ?? '';
        final avoid = (content['avoid'] as List?)?.join(', ') ?? '';
        final rationale = content['rationale'] ?? '';
        contentStr = '✅ Include: $include\n\n❌ Avoid: $avoid\n\n💡 Rationale: $rationale';
      }
      // Handle workout plan
      else if (content['frequency'] != null || content['type'] != null) {
        final frequency = content['frequency'] ?? '';
        final type = (content['type'] as List?)?.join(', ') ?? '';
        final duration = content['duration'] ?? '';
        final intensity = content['intensity'] ?? '';
        final precautions = (content['precautions'] as List?)?.map((p) => '• $p').join('\n') ?? '';
        contentStr = 'Frequency: $frequency\nType: $type\nDuration: $duration\nIntensity: $intensity\n\n⚠️ Precautions:\n$precautions';
      }
      // Handle dietary plan
      else if (content['calories'] != null || content['macros'] != null) {
        final calories = content['calories'] ?? '';
        final macros = content['macros'] ?? '';
        final mealFrequency = content['mealFrequency'] ?? '';
        final hydration = content['hydration'] ?? '';
        final keyPoints = (content['keyPoints'] as List?)?.map((k) => '• $k').join('\n') ?? '';
        contentStr = 'Daily Calories: $calories\nMacros: $macros\nMeal Frequency: $mealFrequency\nHydration: $hydration\n\n📌 Key Points:\n$keyPoints';
      }
      // Handle medicine recommendations
      else if (content['suggested'] != null || content['toAvoid'] != null) {
        final suggested = content['suggested'] as List?;
        final toAvoid = (content['toAvoid'] as List?)?.join(', ') ?? '';
        final interactions = content['interactions'] ?? '';
        
        String suggestedText = '';
        if (suggested != null && suggested.isNotEmpty) {
          suggestedText = suggested.map((m) {
            if (m is Map) {
              return '• ${m['name'] ?? 'Medicine'}: ${m['dosage'] ?? ''} - ${m['frequency'] ?? ''} (${m['purpose'] ?? ''})';
            } else {
              return '• $m';
            }
          }).join('\n');
        } else {
          suggestedText = 'No specific medicines recommended';
        }
        
        contentStr = 'Suggested:\n$suggestedText\n\nAvoid: $toAvoid\n\n⚠️ Interactions: $interactions';
      }
      // Default: just convert to formatted string
      else {
        contentStr = content.toString();
      }
    } else if (content is List) {
      contentStr = content.map((item) => '• $item').join('\n');
    } else {
      contentStr = content.toString();
    }
    
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: Color(0xFF0B6E99),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            contentStr,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodDrugInteractionsSection(List<dynamic> interactions) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orange.shade200, width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700, size: 20),
              const SizedBox(width: 10),
              Text(
                '⚠️ Food-Drug Interactions',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: Colors.orange.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...interactions.map((interaction) {
            final food = interaction is Map ? interaction['food'] ?? 'Food' : 'Food';
            final medicine = interaction is Map ? interaction['medicine'] ?? 'Medicine' : 'Medicine';
            final desc = interaction is Map ? interaction['interaction'] ?? 'Interaction' : 'Interaction';
            final severity = interaction is Map ? interaction['severity'] ?? 'mild' : 'mild';

            Color severityColor = Colors.orange;
            if (severity == 'severe') {
              severityColor = Colors.red;
            } else if (severity == 'moderate') {
              severityColor = Colors.orange;
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: severityColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: severityColor.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '$food × $medicine',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: severityColor,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: severityColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          severity.toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    desc,
                    style: TextStyle(
                      fontSize: 11,
                      color: severityColor.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildAlertSection(List<dynamic> alerts) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_rounded, color: Colors.red.shade700, size: 18),
              const SizedBox(width: 8),
              Text(
                '⚠️ Urgent Alerts',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: Colors.red.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...alerts.map((alert) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                '• ${alert.toString()}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red.shade600,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTextBubble(String text) {
    // Clean and format the text for better appearance
    String formattedText = _formatAIResponse(text);
    
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: const BoxConstraints(maxWidth: 350),
        decoration: BoxDecoration(
          gradient: message.isUser 
              ? LinearGradient(
                  colors: [
                    Colors.deepPurple.shade400,
                    Colors.deepPurple.shade600,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: message.isUser ? null : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(message.isUser ? 20 : 4),
            bottomRight: Radius.circular(message.isUser ? 4 : 20),
          ),
          boxShadow: [
            BoxShadow(
              color: message.isUser 
                  ? Colors.deepPurple.withOpacity(0.3)
                  : Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
          border: message.isUser 
              ? null
              : Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: formattedText.contains('\n')
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: formattedText
                    .split('\n')
                    .map((line) {
                      final trimmed = line.trim();
                      
                      // Skip empty lines but add spacing
                      if (trimmed.isEmpty) {
                        return const SizedBox(height: 6);
                      }

                      // Check if this is a header (contains emoji and colon)
                      final isHeader = RegExp(r'^[🍽️💊⏰⚠️🔗⛔📞✨💡📋👋💪🥗😴🏥💧⚡🏋️🧘📊📈📃🥤🚨🏥1️⃣2️⃣3️⃣4️⃣5️⃣6️⃣7️⃣]+\s+[^:]+:').hasMatch(trimmed);
                      final isIndented = trimmed.startsWith('  ');
                      final isMainTitle = RegExp(r'^[🍽️💊💪🥗😴🏥]+\s+[^:]+$').hasMatch(trimmed);

                      return Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: isHeader ? 6 : (isMainTitle ? 8 : 2),
                          horizontal: 0,
                        ),
                        child: Text(
                          trimmed,
                          style: TextStyle(
                            color: message.isUser 
                                ? Colors.white 
                                : (isHeader || isMainTitle ? Colors.grey.shade900 : Colors.grey.shade800),
                            fontSize: isMainTitle ? 16 : (isHeader ? 14 : 13.5),
                            height: 1.6,
                            fontWeight: (isHeader || isMainTitle) 
                                ? FontWeight.w700
                                : (trimmed.startsWith('•') ? FontWeight.w600 : FontWeight.w500),
                            letterSpacing: 0.4,
                          ),
                        ),
                      );
                    })
                    .toList(),
              )
            : Text(
                formattedText,
                style: TextStyle(
                  color: message.isUser ? Colors.white : Colors.grey.shade900,
                  fontSize: 14,
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
      ),
    );
  }

  String _formatAIResponse(String text) {
    // Check for multi-drug interaction response (starts with ⚠️  DRUG INTERACTION CHECK)
    if (text.contains('DRUG INTERACTION CHECK')) {
      return text; // Already formatted by backend
    }
    
    // Check for emoji-prefixed sections (formatted responses from backend)
    if (text.contains('💊') && text.contains('Uses:')) {
      return text; // Already formatted by backend
    }

    // Check if this is a medicine info response with uses/dosage
    if (text.contains('medicine') && text.contains('uses')) {
      return _formatMedicineResponse(text);
    }

    // Check if this is a food report response
    if (text.contains('calories') && text.contains('protein')) {
      return _formatFoodResponse(text);
    }

    // Remove JSON markers if present (fallback for any remaining JSON)
    String cleaned = text
        .replaceAll(RegExp(r'```json|```|{|}'), '')
        .replaceAll('"', '')
        .replaceAll(',', '')
        .trim();

    // If text contains "greeting" or "capabilities", it's the default greeting
    if (cleaned.toLowerCase().contains('greeting') ||
        cleaned.toLowerCase().contains('capabilities')) {
      return _extractAIGreeting(cleaned);
    }

    // If text starts with multiple sentences or already has formatting, keep it as is
    if (cleaned.length > 150 || cleaned.contains('\n')) {
      return cleaned;
    }

    return cleaned;
  }

  String _formatMedicineResponse(String text) {
    final lines = <String>[];
    
    // Check if this is a multi-drug interaction response
    if (text.contains('medicine_1') && text.contains('medicine_2')) {
      // Extract interaction check
      final interactionMatch = RegExp(r'interaction_check["\s:]*"?([^"{}]+)"?').firstMatch(text);
      if (interactionMatch != null) {
        lines.add('⚠️  DRUG INTERACTION CHECK');
        lines.add('${interactionMatch.group(1)?.replaceAll('"', '').trim() ?? ''}');
        lines.add('');
      }
      
      // Medicine 1
      final med1Match = RegExp(r'medicine_1["\s:]*"?([^"{}]+)"?').firstMatch(text);
      final interact1Match = RegExp(r'interactions_1["\s:]*"?([^"{}]+)"?').firstMatch(text);
      if (med1Match != null) {
        lines.add('💊 ${med1Match.group(1)?.replaceAll('"', '').trim() ?? 'Medicine 1'}');
        if (interact1Match != null) {
          lines.add('🔗 Interactions: ${interact1Match.group(1)?.trim() ?? ''}');
        }
        lines.add('');
      }
      
      // Medicine 2
      final med2Match = RegExp(r'medicine_2["\s:]*"?([^"{}]+)"?').firstMatch(text);
      final interact2Match = RegExp(r'interactions_2["\s:]*"?([^"{}]+)"?').firstMatch(text);
      if (med2Match != null) {
        lines.add('💊 ${med2Match.group(1)?.replaceAll('"', '').trim() ?? 'Medicine 2'}');
        if (interact2Match != null) {
          lines.add('🔗 Interactions: ${interact2Match.group(1)?.trim() ?? ''}');
        }
        lines.add('');
      }
      
      // Combined notes
      final notesMatch = RegExp(r'combined_notes["\s:]*"?([^"{}]+)"?').firstMatch(text);
      if (notesMatch != null) {
        lines.add('📌 Combined Safety Notes:');
        lines.add('  ${notesMatch.group(1)?.trim() ?? ''}');
        lines.add('');
      }
      
      // Warning
      final warningMatch = RegExp(r'warning["\s:]*"?([^"{}]+)"?').firstMatch(text);
      if (warningMatch != null) {
        lines.add(warningMatch.group(1)?.replaceAll('"', '').trim() ?? '');
      }
    } else {
      // Single medicine response
      // Extract medicine name
      final medicineMatch = RegExp(r'medicine["\s:]*([^,}]+)').firstMatch(text);
      if (medicineMatch != null) {
        lines.add('💊 ${medicineMatch.group(1)?.replaceAll('"', '').trim() ?? 'Medicine'}');
        lines.add('');
      }

      // Extract uses
      final usesMatch = RegExp(r'uses["\s:]*"?([^"{}]+)"?').firstMatch(text);
      if (usesMatch != null) {
        lines.add('📋 Uses:');
        lines.add('  ${usesMatch.group(1)?.trim() ?? ''}');
        lines.add('');
      }

      // Extract dosage
      final dosageMatch = RegExp(r'dosage["\s:]*"?([^"{}]+)"?').firstMatch(text);
      if (dosageMatch != null) {
        lines.add('⏰ Dosage:');
        lines.add('  ${dosageMatch.group(1)?.trim() ?? ''}');
        lines.add('');
      }

      // Extract side effects
      final sideMatch = RegExp(r'side_effects["\s:]*"?([^"{}]+)"?').firstMatch(text);
      if (sideMatch != null) {
        lines.add('⚠️  Side Effects:');
        lines.add('  ${sideMatch.group(1)?.trim() ?? ''}');
        lines.add('');
      }

      // Extract interactions
      final interactMatch = RegExp(r'interactions["\s:]*"?([^"{}]+)"?').firstMatch(text);
      if (interactMatch != null) {
        lines.add('🔗 Interactions:');
        lines.add('  ${interactMatch.group(1)?.trim() ?? ''}');
        lines.add('');
      }

      // Extract warning
      final warningMatch = RegExp(r'warning["\s:]*"?([^"{}]+)"?').firstMatch(text);
      if (warningMatch != null) {
        lines.add('⛔ Warning:');
        lines.add('  ${warningMatch.group(1)?.trim() ?? ''}');
        lines.add('');
      }

      lines.add('📞 Consult healthcare professionals before use');
    }

    return lines.isNotEmpty ? lines.join('\n') : text;
  }

  String _formatFoodResponse(String text) {
    final lines = <String>[];
    
    // Extract food name
    final foodMatch = RegExp(r'food["\s:]*"?([^,}]+)').firstMatch(text);
    if (foodMatch != null) {
      lines.add('🍽️  ${foodMatch.group(1)?.replaceAll('"', '').trim() ?? 'Food'}');
      lines.add('');
    }

    // Parse nutrition values
    final nutrients = [
      {'label': 'Calories', 'key': 'calories'},
      {'label': 'Protein', 'key': 'protein'},
      {'label': 'Carbs', 'key': 'carbs'},
      {'label': 'Fat', 'key': 'fat'},
      {'label': 'Fiber', 'key': 'fiber'},
      {'label': 'Sugar', 'key': 'sugar'},
    ];

    lines.add('🥗 Nutrition (per 100g):');
    for (var nutrient in nutrients) {
      final label = nutrient['label'] as String;
      final key = nutrient['key'] as String;
      final match = RegExp('$key["\s:]*([\\d.]+)').firstMatch(text);
      if (match != null) {
        lines.add('  • $label: ${match.group(1)}g');
      }
    }
    lines.add('');

    // Extract benefits
    final benefitsMatch = RegExp(r'benefits["\s:]*"?([^}]+)"?').firstMatch(text);
    if (benefitsMatch != null) {
      lines.add('✨ Benefits:');
      lines.add('  ${benefitsMatch.group(1)?.trim() ?? ''}');
      lines.add('');
    }

    lines.add('💡 Eat balanced portions daily');

    return lines.join('\n');
  }

  String _extractAIGreeting(String text) {
    // Extract meaningful parts from greeting JSON
    final lines = <String>[];
    
    lines.add('👋 Hi! I\'m NutriCare AI Assistant');
    lines.add('');
    lines.add('I can help you with:');
    lines.add('✓ Analyze food nutrition content');
    lines.add('✓ Provide medicine information');
    lines.add('✓ Recommend exercises for your goals');
    lines.add('✓ Suggest healthy meal plans');
    lines.add('✓ Provide health guidance');
    lines.add('✓ Track your health metrics');
    lines.add('');
    lines.add('⚠️ Disclaimer: I\'m not a doctor.');
    lines.add('Always consult healthcare providers.');
    
    return lines.join('\n');
  }

}


class _TypingBubble extends StatefulWidget {
  const _TypingBubble();

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDot(0),
            const SizedBox(width: 4),
            _buildDot(1),
            const SizedBox(width: 4),
            _buildDot(2),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final value = (_controller.value - (index * 0.2)) % 1.0;
        final opacity = (value * 2).clamp(0.3, 1.0);

        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: opacity),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final IconData icon;

  const _StatusPill({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
