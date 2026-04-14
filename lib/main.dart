import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'core/theme.dart';
import 'core/app_router.dart';

// PROVIDERS
import 'providers/nutrition_provider.dart';
import 'providers/workout_provider.dart';
import 'providers/medicine_provider.dart';
import 'providers/streak_provider.dart';

// SCREENS
import 'screens/login_screen.dart';
import 'screens/main_layout.dart';

// SERVICES
import 'services/notification_service.dart';
import 'services/medicine_notification_service.dart';
import 'services/groq_ai_service.dart';
import 'core/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Groq AI Service
  // Get your free API key from: https://console.groq.com
  // For web development, we hardcode it here. For production, use environment variables or backend.
  const String groqApiKey = 'your_groq_api_key_here';
  
  if (groqApiKey.isNotEmpty) {
    GroqAIService.setApiKey(groqApiKey);
    AppLogger.info('✅ Groq AI Service initialized');
  } else {
    AppLogger.warning('⚠️ GROQ_API_KEY not set. AI features will be unavailable.');
    AppLogger.info('📖 Get your free API key: https://console.groq.com');
  }

  if (!kIsWeb) {
    try {
      await NotificationService.init();
      await MedicineNotificationService.init(); // Initialize medicine reminders
      AppLogger.info('Notification services initialized');
    } catch (e) {
      AppLogger.warning('Failed to initialize notifications', e);
    }
  } else {
    AppLogger.info('Skipping notification initialization on web');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NutritionProvider()),
        ChangeNotifierProvider(create: (_) => WorkoutProvider()),
        ChangeNotifierProvider(create: (_) => MedicineProvider()),
        ChangeNotifierProvider(create: (_) => StreakProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NutriCare+',
      navigatorKey: AppRouter.navigatorKey,
      theme: NutriTheme.lightTheme,
      darkTheme: NutriTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasData) {
            return const MainLayout();
          }

          return const LoginScreen();
        },
      ),
    );
  }
}
