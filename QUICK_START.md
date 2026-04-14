# Quick Start Guide - NutriCare+ Development

## ✅ Prerequisites
- ✅ Flutter 3.35+ installed (`flutter --version`)
- ✅ All dependencies resolved (`flutter pub get`)
- ✅ Project builds without errors

---

## 🚀 **Get Running in 2 Minutes**

### Option 1: Web (Chrome)
```bash
cd c:\nutricare
flutter run -d chrome --dart-define=GROQ_API_KEY=your_groq_key
```
✅ Opens in browser at `localhost:54323`

### AI Proxy Setup (Hugging Face)
```bash
cd c:\nutricare\ai_server
copy .env.example .env
# edit .env and set HF_TOKEN
npm install
node server.js
```

### Option 2: Android Emulator
```bash
cd c:\nutricare
flutter run -d android
```
(Requires Android SDK & emulator running)

### Option 3: Web Build (Production)
```bash
cd c:\nutricare
flutter build web --release
# Output: build/web/
```

---

## 🏗️ Project Architecture

### **State Management** (Provider)
- `lib/providers/nutrition_provider.dart` - Nutrition state
- `lib/providers/workout_provider.dart` - Workout state
  
→ Add more providers as needed for medicine, streaks, etc.

### **Screens** (38 Total)
**Main Flows:**
- `login_screen.dart` → `main_layout.dart` → {home, nutrition, workout, medicine, profile}

**Key Screens:**
- `home_screen.dart` - Dashboard (calories, streaks, quick actions)
- `workout_screen.dart` - Live workout timer & metrics
- `nutrition_screen.dart` - Meal logging with OCR
- `medicine_screen.dart` / `enhanced_medicine_screen.dart` - Medicine tracking
- `progress_screen.dart` - Analytics & streaks

### **Services** (24 Total)
**Critical:**
- `auth_service.dart` - Firebase Auth
- `groq_service.dart` - AI responses
- `medicine_notification_service.dart` - Reminders

**Data:**
- `user_history_service.dart` - Query workouts/meals
- `meal_planner_service.dart` - Generate meal plans
- `progress_tracking_service.dart` - Calculate stats

### **Models** (7 Total)
- `workout_model.dart`
- `nutrition_log_model.dart`
- `medicine_model.dart`
- `health_data.dart`
- `interaction_model.dart`
- `user_progress_model.dart`
- `recent_activity_model.dart`

---

## 🔧 Common Development Tasks

### **Add a New Screen**
```dart
// lib/screens/new_screen.dart
import 'package:flutter/material.dart';
import '../core/theme.dart';

class NewScreen extends StatelessWidget {
  const NewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Feature')),
      body: Center(child: Text('Hello!')),
    );
  }
}
```

### **Add Navigation**
```dart
// In main_layout.dart or any screen
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const NewScreen()),
);
```

### **Use State (Provider)**
```dart
// In a screen
import 'package:provider/provider.dart';
import '../providers/nutrition_provider.dart';

// Read state
final provider = Provider.of<NutritionProvider>(context);
final calorieGoal = provider.calorieGoal;

// Modify state
provider.addMeal(mealData);
```

### **Access Firebase Data**
```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final user = FirebaseAuth.instance.currentUser;
if (user != null) {
  final snapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .get();
}
```

---

## 🎨 Design System

**Colors** (from `lib/core/theme.dart`):
```dart
NutriTheme.primary    // Neon Green (#00FF00)
NutriTheme.secondary  // Neon Blue
NutriTheme.background // Dark (#0a0a0a)
NutriTheme.surface    // Slightly lighter dark
```

**Typography**:
```dart
NutriTheme.textTheme.displayLarge  // Huge headlines
NutriTheme.textTheme.bodyMedium    // Regular text
```

**Components**:
```dart
// Glass morphism card
GlassCard(
  child: Text('Frosted effect'),
)

// Circular progress
CircularPercentIndicator(
  percent: 0.75,
  center: Text('75%'),
)

// Live graph
LiveGraph(
  spots: [FlSpot(0, 80), FlSpot(1, 85)],
)
```

---

## 🐛 Debugging Tips

### **Enable Hot Reload**
- Make code change → `Ctrl+S` (auto-saves in VS Code)
- App updates instantly (if possible)

### **View Errors**
```bash
# Terminal
flutter analyze
flutter logs
```

### **Debug Print**
```dart
debugPrint('Value: $value');
```

### **Dart Devtools**
```bash
flutter pub global activate devtools
devtools
# Then: flutter run (connect to Dart DevTools URL)
```

---

## 📦 Adding Dependencies

```bash
# Add package
flutter pub add package_name

# Get new packages
flutter pub get

# Update pubspec.yaml manually, then:
flutter pub get
```

**Common packages already included:**
- `firebase_core`, `firebase_auth`, `cloud_firestore`
- `provider` (state management)
- `fl_chart` (charts)
- `google_mlkit_text_recognition` (OCR)
- `flutter_local_notifications` (reminders)

---

## 🚨 Troubleshooting

### Build Fails
```bash
flutter clean
flutter pub get
flutter build web --release
```

### Hot Reload Not Working
- Check for syntax errors
- Restart Flutter: `Ctrl+C` → `flutter run -d chrome`

### Firebase Not Connecting
- Check `firebase_options.dart` configuration
- Ensure internet connection
- Verify Firebase project in console

### Watch Connection (Mobile)
1. Run on phone (not web/desktop): `flutter run -d android` or `flutter run -d ios`
2. Open Workout screen and tap the watch icon to connect.
3. Accept platform permissions:
  - Android: Google Fit / activity and sensor permissions
  - iOS: Apple Health permissions
4. Tap the sync icon to force a manual sync.
5. Confirm status changes to `SYNCED` and check last-sync time in the header.

### Analyzer Warnings
Most are lint-only (info level). Build still works.
```bash
# See all issues
flutter analyze

# Focus on errors only
flutter analyze 2>&1 | grep -i error
```

---

## 📚 Key Files to Know

| File | Purpose |
|------|---------|
| `lib/main.dart` | App entry, Firebase init, Provider setup |
| `lib/core/theme.dart` | Design tokens, colors, fonts |
| `lib/screens/main_layout.dart` | Bottom nav bar, screen switching |
| `pubspec.yaml` | Dependencies, assets, metadata |
| `firebase.json` | Firebase config (cloud functions) |
| `analysis_options.yaml` | Linter rules |

---

## 🎯 Development Workflow

1. **Start dev server**: `flutter run -d chrome`
2. **Edit code** in `lib/screens/` or `lib/providers/`
3. **Save** (`Ctrl+S`) → Hot reload
4. **Test** in browser
5. **Commit** changes
6. **Build** for release: `flutter build web --release`

---

## 📞 Support

**Issues?**
- Check `DEVELOPMENT_STATUS.md` for known issues
- Review analyzer output: `flutter analyze`
- Inspect Firebase Firestore rules & data

**Next Steps?**
- Complete missing providers (MedicineProvider, etc.)
- Add more screens (community features, analytics)
- Integrate with more APIs (Fitbit, Apple Health, etc.)

---

**Happy coding!** 🚀
