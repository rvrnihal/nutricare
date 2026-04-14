# NutriCare+ End-to-End Project Documentation

Last Updated: April 1, 2026

---

## 1) Project Summary

NutriCare+ is a Flutter-based health platform with a Node.js AI backend.
It combines:
- Nutrition tracking and food analysis
- Workout tracking 
- Medicine management and reminders
- Health report upload and AI analysis
- AI chatbot with Groq-powered responses and fallback logic

The app is designed for Android, iOS, and Web (Chrome for local testing).

---

## 2) High-Level Architecture

### 2.1 Frontend
- Framework: Flutter
- State Management: Provider
- Navigation: Material routes + AppRouter
- Main entry: lib/main.dart

### 2.2 Backend AI Proxy
- Runtime: Node.js (ES modules)
- Server: Express
- AI provider: Groq API
- Fallback chain: local model -> Groq -> database fallback
- Main file: ai_server/server.js

### 2.3 Data Layer
- Authentication: Firebase Auth
- Cloud Data: Firestore + Firebase Storage
- Notifications: Flutter Local Notifications + Firebase Messaging

### 2.4 Core AI Modes
Configured with AI_MODE in ai_server/.env:
- groq: Use Groq as primary
- local: Use local model endpoint
- fallback: try local and Groq, then database responses

---

## 3) Repository Structure

- lib/: Flutter app source
- lib/screens/: App screens
- lib/services/: Service layer (AI, data, health, analytics, persistence)
- lib/providers/: Provider state classes
- lib/models/: Data models
- ai_server/: Node backend proxy and AI endpoints
- android/, ios/, web/, windows/, linux/, macos/: Platform runners
- test/: Flutter tests

---

## 4) Technology Stack

### 4.1 Flutter Dependencies (high-level)
- firebase_core, firebase_auth, cloud_firestore, firebase_storage, firebase_messaging
- provider
- http
- fl_chart, percent_indicator
- flutter_local_notifications
- health (13.1.1)
- image_picker, file_picker, google_mlkit_text_recognition

### 4.2 Backend Dependencies
- express
- cors
- dotenv
- node-fetch

---

## 5) Application Boot Flow

1. Flutter starts in lib/main.dart.
2. Firebase.initializeApp executes.
3. Notification services initialize on non-web.
4. Providers are registered (Nutrition, Workout, Medicine, Streak).
5. Auth state stream selects:
   - MainLayout for logged-in users
   - LoginScreen for signed-out users

---

## 6) Main Screens and Responsibilities

### 6.1 MainLayout
- Bottom navigation host for core modules
- Drawer includes AI Chat and advanced modules

### 6.2 HomeScreen
- Daily overview
- Quick launch cards
- Streak and summary cards

### 6.3 NutritionScreen
- AI food scan/manual entry
- Daily macro and calorie progress
- Today meals stream from daily_nutrition_logs
- Meal logging updates calories bar and meal list

### 6.4 WorkoutScreen
- Start/pause/resume/stop workout
- Heart rate, calories, steps, timer
- Optional smartwatch sync through health plugin

### 6.5 EnhancedMedicineScreen
- Add medicine with reminder times
- Mark taken / ask AI medicine info

### 6.6 AIChatbotScreen
- Chat history
- Quick prompts
- Document upload and analysis flow
- Feature modules and direct navigation

### 6.7 Health Report Screens
- Upload report image or web file
- OCR extraction and health analysis
- Dashboard with risk and recommendations

---

## 7) Core Services

### 7.1 TrainedAIService
- Frontend bridge to backend AI proxy at localhost:5000
- Handles chat and specialized AI endpoints

### 7.2 DailyNutritionService
- Maintains daily totals under:
  users/{uid}/daily_nutrition_logs/{yyyy-mm-dd}
- Provides real-time streams:
  - watchTodayData
  - watchTodayMeals

### 7.3 SmartwatchService
- Uses health package (v13 API)
- Connects to Google Health Connect / Apple Health
- Syncs steps, heart rate, active calories

### 7.4 HealthAnalysisEngine
- Rule-based condition detection from extracted report values

### 7.5 HealthRecommendationService
- Generates condition-safe recommendations and advisories

### 7.6 MedicineNotificationService
- Schedules local medicine reminders
- Handles notification actions and routing

---

## 8) Backend API Endpoints (ai_server/server.js)

### 8.1 Chat
- POST /ai
  - input: text
  - output: text + source

### 8.2 Food/Medicine Reports
- POST /api/food-report
- POST /api/medicine-report

### 8.3 Search
- GET /api/foods/search
- GET /api/medicines/search

### 8.4 Combined AI + report
- POST /api/ai-chat-with-report

### 8.5 Image analysis
- POST /api/analyze-image
  - accepts base64 image payload
  - uses Groq vision model for extraction/summarization

### 8.6 Meal plan generation
- POST /api/generate-meal-plan

---

## 9) AI and Groq Configuration

Backend reads from ai_server/.env:
- GROQ_API_KEY
- AI_MODE
- GROQ_TIMEOUT
- API_TIMEOUT
- USE_FALLBACK
- Optional:
  - GROQ_TEXT_MODEL (default: llama-3.3-70b-versatile)
  - GROQ_VISION_MODEL (default: llama-3.2-90b-vision-preview)

Important:
- Keep real API keys only in .env and never hardcode keys in Dart source.

---

## 10) Firebase Data Model (Operational)

### 10.1 Typical user path
- users/{uid}

### 10.2 Nutrition
- users/{uid}/daily_nutrition_logs/{date}
- users/{uid}/daily_nutrition_logs/{date}/meals/{mealId}

### 10.3 Workouts
- users/{uid}/workouts/{workoutId}

### 10.4 Medicines
- users/{uid}/medicines/{medicineId}
- users/{uid}/medicine_logs/{logId}

### 10.5 AI history and other analytics
- multiple collections under users/{uid} depending on module

---

## 11) Build and Run Guide

### 11.1 Flutter app
1. flutter pub get
2. flutter run -d chrome

### 11.2 AI backend
1. cd ai_server
2. npm install
3. npm start

### 11.3 Recommended local run sequence
1. Start ai_server first
2. Start Flutter app second
3. Test AI chat and report upload after backend is online

---

## 12) Recent Stability Fixes Applied

1. Groq model migration
- Removed decommissioned model usage
- Standardized active text and vision models

2. Large report upload fix
- Increased Express JSON limit to 20mb
- Prevented payload-too-large failures for image analysis

3. Image analysis fallback quality
- Improved backend response checks
- Added guided non-empty fallback when OCR extraction is limited

4. Nutrition meal logging reliability
- Safe numeric parsing (int/double tolerant)
- Daily nutrition logging prioritized so calories bar and meals list update immediately
- Auxiliary history/persistence writes are best-effort and non-blocking

5. Analytics screen syntax cleanup
- Removed invalid trailing code causing parser/build issues

---

## 13) Troubleshooting

### 13.1 AI chat returns weak fallback answer
- Ensure ai_server is running at localhost:5000
- Verify GROQ_API_KEY is set in ai_server/.env
- Confirm AI_MODE is groq or fallback

### 13.2 Report upload says empty analysis
- Ensure backend is updated with 20mb JSON limit
- Use clear, full-page image with good lighting
- Confirm Groq vision model call is returning content

### 13.3 Meal logged but calories bar not updating
- Confirm user is authenticated
- Verify write path is daily_nutrition_logs/{today}/meals
- Verify DailyNutritionService.addMealToday succeeded

### 13.4 Port already in use on backend
- Stop old Node process using port 5000
- Restart backend

### 13.5 Flutter run on web fails with hero tag warnings
- Ensure unique FloatingActionButton hero tags per route/subtree

---

## 14) Security and Production Notes

- Move all sensitive keys to environment variables.
- Do not commit real API keys.
- Add stricter CORS and auth checks for production backend.
- Add rate limiting and request validation on AI endpoints.
- Add structured logging and error monitoring.

---

## 15) Testing Checklist (End-to-End)

1. Login flow works
2. Nutrition add meal updates:
   - calories bar
   - meal list
3. AI chat response source shows groq when available
4. Medicine add + reminder schedule works
5. Workout start/stop and history write works
6. Report upload returns analysis or guided fallback (not empty)
7. Analytics screen loads without syntax/runtime errors

---

## 16) Primary Source Files for Maintenance

Frontend:
- lib/main.dart
- lib/screens/main_layout.dart
- lib/screens/home_screen.dart
- lib/screens/nutrition_screen.dart
- lib/screens/workout_screen.dart
- lib/screens/enhanced_medicine_screen.dart
- lib/screens/ai_chatbot_screen.dart
- lib/screens/analytics_screen.dart

Services:
- lib/services/trained_ai_service.dart
- lib/services/daily_nutrition_service.dart
- lib/services/smartwatch_service.dart
- lib/services/health_analysis_engine.dart
- lib/services/health_recommendation_service.dart

Backend:
- ai_server/server.js
- ai_server/package.json
- ai_server/.env

---

## 17) Recommended Next Improvements

1. Add backend health-check endpoint and frontend connectivity indicator.
2. Add automated integration tests for meal logging and AI chat source assertion.
3. Add unified error banner for backend/network status in app.
4. Add production environment profiles and secure secret management pipeline.

---

End of document.
