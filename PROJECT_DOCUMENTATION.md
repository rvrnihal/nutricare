# NutriCare+ Project Documentation
**Version**: 1.0.0  
**Last Updated**: March 31, 2026  
**Status**: Production Ready

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Architecture & Technology Stack](#architecture--technology-stack)
3. [Core Features](#core-features)
4. [Project Structure](#project-structure)
5. [Key Services & Providers](#key-services--providers)
6. [Database & Data Models](#database--data-models)
7. [API Endpoints](#api-endpoints)
8. [Setup & Installation](#setup--installation)
9. [Running the Project](#running-the-project)
10. [Deployment Guide](#deployment-guide)
11. [Contributing Guidelines](#contributing-guidelines)
12. [Troubleshooting](#troubleshooting)

---

## Project Overview

### What is NutriCare+?

**NutriCare+** is a comprehensive healthcare and fitness mobile application built with Flutter that combines:
- **Nutrition tracking** with detailed food analysis
- **Exercise & Workout management** with progress tracking
- **Medicine reminder system** with comprehensive drug information
- **AI-powered health recommendations** via chatbot
- **Health report analysis** with OCR text extraction
- **Real-time health monitoring** with wearable device integration

### Target Users
- Health-conscious individuals tracking their wellness
- People managing chronic conditions requiring medicine adherence
- Fitness enthusiasts planning workouts and nutrition
- Healthcare professionals seeking patient monitoring tools

### Key Benefits
✅ Complete health ecosystem in one app  
✅ AI-powered personalized recommendations  
✅ Medicine reminder system with drug information  
✅ Seamless Firebase integration for cloud sync  
✅ Wearable device support (smartwatch integration)  
✅ Health report analysis with OCR  
✅ Professional UI with dark mode support  

---

## Architecture & Technology Stack

### Frontend Architecture

```
┌─────────────────────────────────────┐
│         Flutter/Dart UI              │
│  (Material Design + Custom Widgets)  │
└──────────────┬──────────────────────┘
               │
       ┌───────┴────────┐
       │                │
┌──────▼──────────┐  ┌──▼────────────────┐
│  Provider State │  │  Navigation &     │
│  Management     │  │  Routing          │
└──────┬──────────┘  └──────────────────┘
       │
       ├─ NutritionProvider
       ├─ WorkoutProvider
       ├─ MedicineProvider
       └─ StreakProvider
       
       │
┌──────▼────────────────────────────────┐
│         Services Layer                 │
│  (Business Logic & External APIs)      │
└──────┬────────────────────────────────┘
       │
       ├─ AuthService (Firebase Auth)
       ├─ TrainedAIService (AI Chat)
       ├─ MedicineService (Drug Data)
       ├─ DietSuggestionService
       ├─ WorkoutSuggestionService
       ├─ HealthRecommendationService
       ├─ FoodMedicineReportService
       └─ [40+ other specialized services]
       │
┌──────▼────────────────────────────────┐
│      Cloud & Data Layer                │
│  (Firebase, Node.js APIs, Local Data)  │
└──────────────────────────────────────┘
```

### Technology Stack

#### Frontend
| Layer | Technology | Version |
|-------|-----------|---------|
| **Framework** | Flutter | Latest |
| **Language** | Dart | 2.18+ |
| **State Management** | Provider | 6.1.1 |
| **Navigation** | Custom AppRouter | - |
| **UI Components** | Material Design 3 | - |
| **Icons** | Google Fonts | 6.1.0 |
| **Charts** | fl_chart | 1.1.1 |

#### Backend
| Component | Technology | Details |
|-----------|-----------|---------|
| **Server** | Node.js/Express | `ai_server/server.js` |
| **AI Integration** | **Groq API** (Primary) | Mixtral-8x7b-32768 model with fallback chain |
| **Secondary AI** | Local/Trained Model | Fallback if Groq API fails |
| **Tertiary AI** | Database Fallback | Professional nutrition & medicine databases |
| **Databases** | Food (88 items), Medicines (1,500+) | JSONL & JSON formats |
| **Indexing** | In-memory Maps | O(1) lookups |

#### Cloud Platform
| Service | Usage | Version |
|---------|-------|---------|
| **Firebase Auth** | User authentication | 5.3.0 |
| **Cloud Firestore** | Real-time database | 5.5.0 |
| **Firebase Storage** | File storage | 12.1.0 |
| **Firebase Messaging** | Push notifications | 15.0.0 |
| **Firebase Hosting** | Web deployment | - |

#### Mobile & Hardware Integration
| Integration | Capability |
|-------------|-----------|
| **Notifications** | `flutter_local_notifications` 17.2.4 |
| **Location** | `geolocator` 10.1.0 |
| **Camera** | `image_picker` 1.0.7 |
| **Microphone** | `speech_to_text` 6.6.0 |
| **Health Data** | `health` 8.0.0 |
| **Smartwatch** | Custom sync service |
| **Maps** | `google_maps_flutter` 2.6.0 |

---

## Core Features

### 1. **Authentication & User Management**
- Email/Password authentication via Firebase Auth
- Google Sign-In integration
- User profile management with preferences
- Secure password reset mechanism
- Token-based session management

### 2. **Nutrition Tracking**
- **Food Database**: 88+ Indian foods with detailed nutrition data
  - Calories, macros (protein, carbs, fat)
  - Micronutrients (fiber, sugar, sodium)
  - Dietary classifications (vegetarian, vegan, etc.)
  
- **Nutrition Analysis**
  - Nutrition score (0-100 scale)
  - Daily intake tracking
  - Macro breakdown visualization
  - Benefits & dietary recommendations

- **Meal Logging**
  - Quick food entry
  - Portion size tracking
  - Meal history and analytics
  - Export nutrition reports

### 3. **Workout & Exercise Management**
- **Workout Database**: 100+ exercises with details
  - Exercise descriptions
  - Sets, reps, and duration tracking
  - Calorie burn estimation
  - Form tips and safety notes

- **Workout Plans**
  - Pre-built workout templates
  - Custom plan creation
  - Progress tracking with charts
  - Weekly workout schedules

- **Performance Analytics**
  - Strength progression charts
  - Endurance metrics
  - Workout history
  - Achievement badges & streaks

### 4. **Medicine & Drug Management** ⭐
- **Medicine Database**: 1,500+ medicines with comprehensive data
  - Generic names & brand names
  - Uses and therapeutic uses
  - Dosage information
  - Side effects & interactions
  - Contraindications & warnings

- **Medicine Reminders**
  - Customizable reminder times
  - Push notifications
  - Medicine adherence tracking
  - Quick refill requests

- **Drug Interaction Checker**
  - Multi-drug interaction analysis
  - Side effect predictions
  - Allergy tracking
  - Healthcare provider notes

### 5. **AI-Powered Health Assistant** 🤖
- **Smart Chatbot**
  - Natural language processing
  - Food & nutrition advice
  - Medicine information lookup
  - Health recommendations
  - Symptom analysis (non-diagnostic)

- **Report Generation**
  - Food nutrition reports with professional formatting
  - Medicine information cards with risk levels
  - Health recommendations based on user data
  - Downloadable PDF reports

- **Intelligent Suggestions**
  - Personalized diet recommendations
  - Custom workout suggestions
  - Medicine timing optimization
  - Health trend analysis

### 6. **Health Report Analysis**
- **Report Upload**
  - Image-based health report submission
  - Web upload interface
  - Cloud storage integration

- **OCR Text Extraction**
  - Automatic text recognition from reports
  - Data extraction and categorization
  - Medical data parsing

- **Report Dashboard**
  - Historical report tracking
  - Trend visualization
  - Doctor's feedback integration
  - Shareable reports

### 7. **Real-time Synchronization**
- **Cloud Sync**
  - Automatic data synchronization
  - Multi-device support
  - Offline-first architecture
  - Conflict resolution

- **Wearable Integration**
  - Smartwatch workout sync
  - Heart rate monitoring
  - Sleep tracking (if available)
  - Real-time health metrics

### 8. **Notifications & Reminders**
- **Local Notifications**
  - Medicine reminders
  - Workout schedules
  - Daily water intake
  - Health tips

- **Push Notifications**
  - Firebase Cloud Messaging (FCM)
  - Server-side triggering
  - Topic-based subscription
  - Silent & visible notifications

### 9. **Recent Activity & Analytics**
- **Activity Stream**
  - Comprehensive user activity log
  - Date-based filtering
  - Activity type categorization
  - Timeline visualization

- **Personal Analytics**
  - Daily stats dashboard
  - Weekly summaries
  - Monthly health reports
  - Long-term trend analysis

---

## Project Structure

```
nutricare/
├── lib/                                    # Flutter application source
│   ├── main.dart                          # App entry point
│   ├── core/
│   │   ├── theme.dart                     # Material Design theme
│   │   ├── app_router.dart                # Navigation routing
│   │   └── logger.dart                    # Logging utilities
│   │
│   ├── models/                            # Data models
│   │   ├── health_data.dart               # Health metrics model
│   │   ├── interaction_model.dart         # Drug interactions
│   │   ├── medicine_model.dart            # Medicine data structure
│   │   ├── nutrition_log_model.dart       # Nutrition tracking
│   │   ├── recent_activity_model.dart     # Activity logging
│   │   ├── user_progress_model.dart       # User achievements
│   │   └── [8+ other models]              # Additional data structures
│   │
│   ├── screens/                           # UI Screens (stateful/stateless)
│   │   ├── auth/
│   │   │   ├── login_screen.dart          # Login interface
│   │   │   └── register_screen.dart       # User registration
│   │   │
│   │   ├── main_layout.dart               # Main tab navigation
│   │   ├── home_screen.dart               # Home dashboard
│   │   ├── nutrition_screen.dart          # Nutrition tracking
│   │   ├── workout_screen.dart            # Workout management
│   │   ├── medicine_screen.dart           # Medicine management
│   │   │
│   │   ├── health_suggestions_screen.dart # AI recommendations
│   │   ├── ai_chatbot_screen.dart         # AI chat interface ⭐
│   │   ├── health_report_upload_screen.dart # Report submission
│   │   ├── health_insights_dashboard_screen.dart # Analytics
│   │   │
│   │   ├── profile_screen.dart            # User profile
│   │   ├── recent_activity_screen.dart    # Activity log
│   │   ├── [20+ additional screens]       # Other UI screens
│   │   └── main_layout.dart               # Navigation wrapper
│   │
│   ├── providers/                         # Provider state management
│   │   ├── nutrition_provider.dart        # Nutrition state
│   │   ├── workout_provider.dart          # Workout state
│   │   ├── medicine_provider.dart         # Medicine state
│   │   └── streak_provider.dart           # Streak/achievement state
│   │
│   ├── services/                          # Business logic layer
│   │   ├── auth_service.dart              # Firebase authentication
│   │   ├── trained_ai_service.dart        # AI chat service
│   │   ├── groq_service.dart              # Groq API client
│   │   ├── medicine_service.dart          # Medicine database access
│   │   ├── medicine_ai_service.dart       # AI medicine analysis
│   │   ├── medicine_notification_service.dart # Medicine reminders
│   │   │
│   │   ├── health_recommendation_service.dart # Health suggestions
│   │   ├── diet_suggestion_service.dart   # Diet recommendations
│   │   ├── workout_suggestion_service.dart # Workout suggestions
│   │   ├── medicine_suggestion_service.dart # Medicine suggestions
│   │   │
│   │   ├── food_medicine_report_service.dart # Report generation ⭐
│   │   ├── health_report_storage_service.dart # Report storage
│   │   ├── ocr_extraction_service.dart    # Text recognition
│   │   │
│   │   ├── notification_service.dart      # Local notifications
│   │   ├── medicine_firestore_service.dart # Firestore integration
│   │   ├── recent_activity_service.dart   # Activity logging
│   │   ├── realtime_database_service.dart # Firebase RTD
│   │   │
│   │   ├── analytics_service.dart         # Analytics tracking
│   │   ├── streak_service.dart            # Streak management
│   │   ├── workout_service.dart           # Workout database
│   │   ├── calorie_service.dart           # Calorie calculations
│   │   │
│   │   ├── smartwatch_service.dart        # Wearable integration
│   │   ├── watch_workout_sync_service.dart # Sync with watch
│   │   ├── user_history_service.dart      # User history
│   │   ├── ai_history_service.dart        # Chat history
│   │   └── [15+ additional services]      # Other services
│   │
│   ├── widgets/                           # Reusable UI components
│   │   ├── [Custom widgets library]
│   │   ├── food_report_widget.dart        # Food nutrition display ⭐
│   │   └── medicine_report_widget.dart    # Medicine info display ⭐
│   │
│   ├── components/                        # Complex UI components
│   │   ├── glass_card.dart                # Glassmorphism card
│   │   ├── live_graph.dart                # Live chart component
│   │   └── [Custom components]
│   │
│   └── firebase_options.dart              # Firebase configuration
│
├── ai_server/                             # Node.js backend server
│   ├── server.js                          # Express.js server ⭐
│   ├── food_medicine_database.js          # Database manager ⭐
│   │
│   ├── training/
│   │   ├── data/
│   │   │   ├── raw_nutricare.jsonl       # Raw training data
│   │   │   └── medicine_extracts.json    # Medicine dataset
│   │   │
│   │   ├── indian_foods_comprehensive.json # 88 foods database
│   │   ├── medicines_comprehensive_structured.json # 1,500+ medicines
│   │   │
│   │   ├── run_pipeline.py               # Training pipeline
│   │   ├── requirements.txt              # Python dependencies
│   │   └── models/                       # Trained models
│   │
│   ├── package.json                      # Node.js dependencies
│   └── .env                              # Environment variables
│
├── firebase/                             # Firebase configuration
│   ├── .firebaserc                       # Firebase project config
│   ├── firebase.json                     # Firebase settings
│   └── functions/                        # Cloud functions
│       ├── index.js
│       └── package.json
│
├── android/                              # Android native code
│   ├── app/build.gradle.kts
│   └── settings.gradle.kts
│
├── ios/                                  # iOS native code
│   ├── Runner/                           # Xcode project
│   └── Pods/                             # Native dependencies
│
├── web/                                  # Web build output
│   ├── index.html
│   ├── manifest.json
│   └── icons/
│
├── test/                                 # Unit & widget tests
│   └── widget_test.dart
│
├── assets/                               # Static assets
│   ├── fonts/
│   │   └── Noto_Sans/                   # Custom font
│   └── icon/                            # App icons
│
├── pubspec.yaml                         # Flutter dependencies
├── pubspec.lock                         # Locked dependency versions
├── analysis_options.yaml                # Dart analysis config
├── devtools_options.yaml                # DevTools config
│
└── documentation/
    ├── FOOD_MEDICINE_REPORTS.md         # Food/medicine features
    ├── QUICK_START.md                   # Quick start guide
    ├── QUICK_START_AI.md                # AI setup guide
    ├── AI_TRAINING_GUIDE.md             # AI model training
    ├── HEALTH_REPORT_INTEGRATION_GUIDE.md # Report system
    └── [8+ additional docs]

```

---

## Key Services & Providers

### State Management (Providers)

#### 1. **NutritionProvider**
Manages nutrition tracking state
```dart
Class: NutritionProvider extends ChangeNotifier
Methods:
  - addFoodEntry(food, portion, calories)
  - removeFoodEntry(id)
  - getTodayNutrition()
  - getNutritionHistory(date)
  - calculateMacros()
```

#### 2. **WorkoutProvider**
Manages workout and exercise state
```dart
Class: WorkoutProvider extends ChangeNotifier
Methods:
  - addWorkout(workout)
  - updateWorkoutProgress(id, sets, reps, weight)
  - getWorkoutHistory()
  - calculateCaloriesBurned()
  - generateWorkoutPlan()
```

#### 3. **MedicineProvider**
Manages medicine reminders and data
```dart
Class: MedicineProvider extends ChangeNotifier
Methods:
  - addMedicine(medicine, dosage, frequency)
  - setReminder(medicineId, time)
  - getMedicineSchedule()
  - markMedicineTaken(medicineId)
  - getAdherence()
```

#### 4. **StreakProvider**
Manages user achievements and streaks
```dart
Class: StreakProvider extends ChangeNotifier
Methods:
  - incrementStreak(activityType)
  - breakStreak(activityType)
  - getStreakData()
  - getAchievements()
```

### Core Services

#### 1. **AuthService**
Firebase authentication management
```dart
Responsibilities:
  - User registration
  - Login/logout
  - Password reset
  - Google Sign-In
  - Session management
```

#### 2. **TrainedAIService** ⭐
AI chatbot with intelligent fallback chain
```dart
Key Methods:
  - sendMessage(String message) → Future<String>
  - getHealthRecommendation() → Future<Map>
  - getMedicineDetails(String name) → Future<Map>
  - analyzeHealthData() → Future<List>
  - generatePersonalizedPlan() → Future<Map>

Features:
  - **Groq API Integration** (Primary)
    - Mixtral-8x7b-32768 model for advanced reasoning
    - Fast, high-quality health responses
    - Configurable timeout (default: 15s)
  
  - **Local Trained Model** (Secondary)
    - Fallback if Groq API fails
    - Pre-trained on healthcare data
    - No external API calls required
  
  - **Professional Database Fallback** (Tertiary)
    - 88 foods with nutrition data
    - 1,500+ medicines with drug information
    - Guaranteed response - never fails
    - JSON-formatted for consistency

  - **Automatic Fallback Chain**
    1. Try Groq API (15s timeout)
    2. If fails → Try Local Model
    3. If fails → Use Database Fallback
    4. ✅ Always returns valid response

Healthcare Features:
  - Medical disclaimer generation
  - Drug interaction analysis
  - Symptom-to-food recommendations
  - Personalized health plans
```

#### 3. **FoodMedicineReportService** ⭐
Food and medicine report generation
```dart
Key Methods:
  - getFoodReport(String foodName) → Future<Map>
  - getMedicineReport(String medicineName) → Future<Map>
  - searchFoods(query, filters) → Future<List>
  - searchMedicines(query, filters) → Future<List>

Provides:
  - FoodReportWidget (nutrition visualization)
  - MedicineReportWidget (drug information cards)
  - Color-coded risk levels
  - Professional disclaimers
```

#### 4. **HealthRecommendationService**
Intelligent health suggestions
```dart
Methods:
  - getDietRecommendation(userData) → Future<String>
  - getWorkoutRecommendation(userData) → Future<String>
  - getMedicineRecommendation(condition) → Future<String>
  - analyzeHealthTrends() → Future<Report>
```

#### 5. **Medicine-Related Services**

**MedicineService**
```dart
- Database access for medicine information
- Lookup by name or ingredient
- Dosage calculation
- Interaction checking
```

**MedicineNotificationService**
```dart
- Schedule medicine reminders
- Send local notifications
- Track adherence
- Manage notification preferences
```

**MedicineSuggestionService**
```dart
- Recommend medicines for symptoms
- Suggest timing optimization
- Predict interactions
- Risk assessment
```

#### 6. **Health Report Services**

**HealthReportStorageService**
```dart
- Upload reports to Firebase Storage
- Organize reports by date
- Retrieve historical reports
- Generate analytics from reports
```

**OCRExtractionService**
```dart
- Extract text from report images
- Parse medical data
- Categorize extracted information
- Validation and cleaning
```

#### 7. **Notification & Reminder Services**

**NotificationService**
```dart
- Initialize local notifications
- Create notification channels
- Schedule time-based notifications
- Handle user taps on notifications
```

**Medicine NotificationService**
```dart
- Medicine-specific reminders
- Customizable notification times
- Adherence tracking
- Compliance reporting
```

#### 8. **Integration Services**

**SmartwatchService**
```dart
- Connect to wearable devices
- Sync workout data
- Monitor heart rate
- Retrieve health metrics
```

**WatchWorkoutSyncService**
```dart
- Download workouts from watch
- Sync to app database
- Merge multi-source data
- Calculate statistics
```

#### 9. **Analytics & History Services**

**AnalyticsService**
```dart
- Track user events
- Log feature usage
- Generate analytics reports
- Firebase Analytics integration
```

**AIHistoryService**
```dart
- Store chat conversation history
- Retrieve chat history
- Search conversations
- Generate conversation summaries
```

**RecentActivityService**
```dart
- Log all user activities
- Create activity timeline
- Filter activities by type
- Generate activity reports
```

---

## Database & Data Models

### 1. **Food Database** (88 items)
**File**: `ai_server/training/indian_foods_comprehensive.json` (JSONL format)

**Schema**:
```dart
class FoodModel {
  final String name;
  final String type;              // Veg, Non-veg, Vegan
  final String region;            // Regional classification
  final int calories;             // Per 100g or serving
  final int protein;              // grams
  final int carbs;                // grams
  final int fat;                  // grams
  final int fiber;                // grams
  final int sugar;                // grams
  final int sodium;               // mg
  final List<String> benefits;    // Health benefits
  final List<String> considerations; // Dietary notes
  final List<String> recommendations; // Usage suggestions
}
```

**Sample Food Entry**:
```json
{
  "name": "Butter Chicken",
  "type": "Non-veg",
  "region": "North India",
  "calories": 350,
  "protein": 28,
  "carbs": 15,
  "fat": 20,
  "fiber": 1,
  "sugar": 2,
  "sodium": 450,
  "benefits": ["High protein", "Good for muscle building"],
  "considerations": ["High in fat", "Contains dairy"],
  "recommendations": ["Best with brown rice", "Add vegetables"]
}
```

### 2. **Medicine Database** (1,500+ items)
**File**: `ai_server/training/medicines_comprehensive_structured.json` (JSON format)

**Schema**:
```dart
class MedicineModel {
  final String name;              // Medicine name
  final String genericName;       // Generic/chemical name
  final List<String> brandNames;  // Brand variations
  final String therapeuticClass; // Category (antibiotics, etc.)
  final List<String> uses;        // Medical uses
  final String dosage;            // Typical dosing
  final List<String> sideEffects; // Common & serious side effects
  final List<String> interactions;// Drug interactions
  final String contraindications; // When NOT to use
  final String warning;           // Important safety notes
  final String availability;      // OTC/Prescription/Schedule
  final String riskLevel;         // Low/Moderate/High
  final List<String> monitoringNeeded; // What to monitor
}
```

**Sample Medicine Entry**:
```json
{
  "name": "Aspirin",
  "genericName": "Acetylsalicylic acid",
  "brandNames": ["Bayer", "Cardio Aspirin"],
  "therapeuticClass": "Analgesic, Antiplatelet",
  "uses": ["Pain relief", "Heart attack prevention", "Stroke prevention"],
  "dosage": "325-650mg every 4-6 hours for pain; 75-325mg daily for cardiovascular",
  "sideEffects": ["Stomach upset", "Nausea", "Easy bruising", "Bleeding risk"],
  "interactions": ["Warfarin (increased bleeding)", "NSAIDs (GI irritation)"],
  "contraindications": "Bleeding disorders, peptic ulcer disease, aspirin allergy",
  "warning": "Risk of Reye's syndrome in children with viral infections",
  "availability": "OTC",
  "riskLevel": "Low-Moderate",
  "monitoringNeeded": ["Bleeding signs", "GI symptoms", "Blood clotting time"]
}
```

### 3. **Firestore Collections** (Cloud Database)

#### users/
```
├── {uid}/
│   ├── email: string
│   ├── name: string
│   ├── age: number
│   ├── gender: string
│   ├── healthConditions: array
│   ├── allergies: array
│   ├── medications: array
│   ├── createdAt: timestamp
│   └── updatedAt: timestamp
```

#### nutrition_logs/
```
├── {userId}/
│   ├── {date}/
│   │   ├── foods: array<{name, calories, macros}>
│   │   ├── totalCalories: number
│   │   ├── totalProtein: number
│   │   ├── timestamp: timestamp
│   │   └── notes: string
```

#### workout_logs/
```
├── {userId}/
│   ├── {date}/
│   │   ├── exercises: array<{name, sets, reps, weight, duration}>
│   │   ├── totalCalories: number
│   │   ├── duration: number (minutes)
│   │   ├── timestamp: timestamp
│   │   └── notes: string
```

#### medicine_reminders/
```
├── {userId}/
│   ├── {medicineId}/
│   │   ├── medicineName: string
│   │   ├── dosage: string
│   │   ├── frequency: string
│   │   ├── times: array<timestamp>
│   │   ├── adherence: number (%)
│   │   ├── startDate: timestamp
│   │   ├── endDate: timestamp
│   │   └── notes: string
```

#### chat_history/
```
├── {userId}/
│   ├── {conversationId}/
│   │   ├── messages: array<{role, content, timestamp}>
│   │   ├── createdAt: timestamp
│   │   ├── title: string
│   │   └── metadata: object
```

#### health_reports/
```
├── {userId}/
│   ├── {reportId}/
│   │   ├── filename: string
│   │   ├── imageUrl: string
│   │   ├── extractedText: string
│   │   ├── analysis: string
│   │   ├── uploadDate: timestamp
│   │   ├── doctorNotes: string
│   │   └── metadata: object
```

---

## API Endpoints

### Node.js Backend Server (port 5000)

#### Food & Medicine Report APIs ⭐

**1. Get Food Nutrition Report**
```
POST /api/food-report
Content-Type: application/json

Request Body:
{
  "foodName": "Butter Chicken"
}

Response (200):
{
  "food": "Butter Chicken",
  "status": "success",
  "report": {
    "name": "Butter Chicken",
    "calories": 350,
    "macros": {
      "protein": 28,
      "carbs": 15,
      "fat": 20,
      "fiber": 1,
      "sugar": 2,
      "sodium": 450
    },
    "nutritionScore": 65,
    "benefits": ["High protein", "Good for muscle"],
    "considerations": ["High in fat", "Contains dairy"],
    "recommendations": ["Serve with brown rice", "Add vegetables"],
    "disclaimer": "For informational purposes only..."
  }
}
```

**2. Get Medicine Information Report**
```
POST /api/medicine-report
Content-Type: application/json

Request Body:
{
  "medicineName": "Aspirin"
}

Response (200):
{
  "medicine": "Aspirin",
  "status": "success",
  "report": {
    "name": "Aspirin",
    "genericName": "Acetylsalicylic acid",
    "therapeuticClass": "Analgesic, Antiplatelet",
    "uses": ["Pain relief", "Heart attack prevention"],
    "dosage": "325-650mg every 4-6 hours",
    "sideEffects": ["Stomach upset", "Easy bruising"],
    "interactions": ["Warfarin", "NSAIDs"],
    "riskLevel": "Low-Moderate",
    "warning": "Not for children with viral infections",
    "monitoringNeeded": ["Bleeding signs", "GI symptoms"],
    "disclaimer": "Consult healthcare provider..."
  }
}
```

#### Search & Filter APIs

**3. Search Foods**
```
GET /api/foods/search?query=butter&type=non-veg&region=north&lowCalorie=false&highProtein=true

Response (200):
{
  "status": "success",
  "results": [
    {
      "name": "Butter Chicken",
      "type": "Non-veg",
      "region": "North India",
      "calories": 350,
      "protein": 28,
      ...
    },
    ...
  ]
}
```

**4. Search Medicines**
```
GET /api/medicines/search?query=aspirin&system=cardiovascular&availability=OTC

Response (200):
{
  "status": "success",
  "results": [
    {
      "name": "Aspirin",
      "genericName": "Acetylsalicylic acid",
      "uses": ["Pain relief", "Heart attack prevention"],
      "riskLevel": "Low-Moderate",
      ...
    },
    ...
  ]
}
```

#### AI Chat APIs

**5. AI Chat with Fallback Chain** ⭐
```
POST /api/ai
Content-Type: application/json

Request Body:
{
  "text": "What's a healthy Indian meal plan?"
}

Response (200):
{
  "text": "A healthy Indian meal plan should include... [response from Groq API, Local Model, or Database]",
  "source": "groq|local|fallback|fallback_error"
}

Response Source Values:
  - "groq": Groq API response (high quality, fast)
  - "local": Local trained model response (good quality, reliable)
  - "fallback": Database fallback response (basic, always available)
  - "fallback_error": Fallback response after error recovery

Fallback Chain in Action:
1. Groq API called (15 second timeout)
   ✅ Success → Return groq response
   ❌ Timeout/Error → Continue to step 2

2. Local Model called (fallback if Groq fails)
   ✅ Success → Return local response
   ❌ Timeout/Error → Continue to step 3

3. Database Fallback (final fallback)
   ✅ Always returns valid response
   ✅ 100% reliability guarantee
```

**6. AI Chat with Report Integration**
```
POST /api/ai-chat-with-report
Content-Type: application/json

Request Body:
{
  "message": "What's the nutrition in Butter Chicken?",
  "reportType": "food",
  "reportName": "Butter Chicken"
}

Response (200):
{
  "status": "success",
  "aiResponse": "Butter Chicken is a rich source of protein...",
  "report": {
    "name": "Butter Chicken",
    "calories": 350,
    "nutritionScore": 65,
    ...
  },
  "source": "groq|local|fallback"
}
```

**7. General AI Chat**
```
POST /api/ai
Content-Type: application/json

Request Body:
{
  "text": "Tell me about heart health"
}

Response (200):
{
  "status": "success",
  "text": "Heart health requires a combination of...",
  "source": "groq|local|fallback"
}
```

---

## Setup & Installation

### Prerequisites

- **Flutter**: 3.0+
- **Dart**: 2.18+
- **Node.js**: 16+
- **Firebase Account**: Active project
- **Python**: 3.8+ (for AI training pipeline - optional)
- **Git**: For version control

### Step 1: Clone Repository

```bash
git clone https://github.com/yourusername/nutricare.git
cd nutricare
```

### Step 2: Flutter Setup

```bash
# Get Flutter dependencies
flutter pub get

# Generate build files
flutter pub run build_runner build

# (Optional) Fix any dependency issues
flutter pub cache repair
```

### Step 3: Firebase Configuration

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or use existing
3. Add Android, iOS, and Web apps
4. Download configuration files:
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`
   - Web config (automatic in Flutter)

4. Update Firebase project ID in `firebase.json`

### Step 4: Node.js Backend Setup

```bash
# Navigate to server directory
cd ai_server

# Install dependencies (including node-fetch for Groq API)
npm install

# Create .env file with Groq API configuration
cat > .env << EOF
# Groq API Configuration
GROQ_API_KEY=your_groq_api_key_here

# AI Mode: groq (primary), local (trained model), fallback (database)
AI_MODE=groq

# Server Configuration
PORT=5000
NODE_ENV=development

# Timeout settings (seconds)
API_TIMEOUT=30
GROQ_TIMEOUT=15

# Use fallback if all others fail
USE_FALLBACK=true
EOF

# Start server (background or separate terminal)
npm start
# or
node server.js
```

**Environment Variables** (`.env`):
```bash
GROQ_API_KEY=your_groq_api_key                # ✅ Groq API key (provided)
AI_MODE=groq                                  # AI fallback priority: groq|local|fallback
NODE_ENV=development                          # development|production
PORT=5000                                     # Server port
API_TIMEOUT=30                                # General API timeout (seconds)
GROQ_TIMEOUT=15                               # Groq API specific timeout (seconds)
USE_FALLBACK=true                             # Enable fallback when APIs fail
LOCAL_AI_URL=http://127.0.0.1:8000/generate  # Local model URL (optional)
HF_TOKEN=                                     # Hugging Face token (optional)
```

**AI Fallback Chain**:
```
User Request → Groq API (Primary) 
            → Local Model (Secondary, if Groq fails)
            → Database Fallback (Tertiary, if all fail)
            ✅ Guaranteed response from fallback database
```

### Step 5: Android Setup (Optional)

```bash
cd android

# Build Android app
./gradlew build

# Create signed APK (requires signing key)
./gradlew bundleRelease
```

### Step 6: iOS Setup (Optional)

```bash
cd ios

# Install pods
pod install

# Open Xcode for signing
open Runner.xcworkspace
```

### Step 7: Web Setup

```bash
# Build web version
flutter build web

# Serve development version
flutter run -d chrome
```

---

## Running the Project

### Option 1: Development with Hot Reload

**Terminal 1 - Start Backend Server:**
```bash
cd ai_server
npm start
# Server runs on http://localhost:5000
```

**Terminal 2 - Start Flutter App:**
```bash
flutter run -d chrome    # For web
flutter run -d android   # For Android emulator
flutter run              # For connected device
```

### Option 2: Production Build

**Web Build:**
```bash
flutter build web --release
# Output in: build/web/

# Deploy to Firebase Hosting
firebase deploy
```

**Android Build:**
```bash
flutter build apk --release
flutter build appbundle --release
# Submit to Google Play Store
```

**iOS Build:**
```bash
flutter build ios --release
# Submit to App Store via Xcode
```

### Option 3: Docker Deployment

Create `Dockerfile` for backend:
```dockerfile
FROM node:18-alpine

WORKDIR /app
COPY ai_server/ .
RUN npm install

ENV AI_MODE=fallback
EXPOSE 5000

CMD ["npm", "start"]
```

**Build & Run:**
```bash
docker build -t nutricare-backend .
docker run -p 5000:5000 nutricare-backend
```

---

## Deployment Guide

### Firebase Hosting Deployment

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase in project
firebase init hosting

# Build Flutter web app
flutter build web

# Deploy to Firebase Hosting
firebase deploy --only hosting
```

### Firestore Security Rules

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User data - only accessible to owner
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Nutrition logs - user specific
    match /nutrition_logs/{userId}/{document=**} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Medicine reminders - user specific
    match /medicine_reminders/{userId}/{document=**} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Chat history - user specific
    match /chat_history/{userId}/{document=**} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Health reports - user specific
    match /health_reports/{userId}/{document=**} {
      allow read, write: if request.auth.uid == userId;
    }
  }
}
```

### Storage Bucket Rules

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /health_reports/{userId}/{allPaths=**} {
      allow read, write: if request.auth.uid == userId;
    }
    
    match /user_profiles/{userId}/{allPaths=**} {
      allow read, write: if request.auth.uid == userId;
    }
  }
}
```

### Environment Variables for Production

Create `.env.production`:
```bash
FIREBASE_API_KEY=your_production_key
GROQ_API_KEY=your_groq_api_key
AI_MODE=groq                    # Use Groq API in production
NODE_ENV=production
PORT=5000
CORS_ORIGIN=https://nutricare-app.example.com
```

---

## Contributing Guidelines

### Code Style

1. **Dart/Flutter**
   - Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
   - Use `dart format` before committing
   - Use `dart analyze` to check for issues

2. **JavaScript**
   - Use ESLint with standard config
   - 2-space indentation
   - Semicolons required

3. **Naming Conventions**
   - Classes: `PascalCase` (e.g., `NutritionProvider`)
   - Methods/variables: `camelCase` (e.g., `getTodayNutrition`)
   - Constants: `CONSTANT_CASE`
   - Files: `snake_case` (e.g., `nutrition_provider.dart`)

### Commit Standards

```
Format: <type>(<scope>): <subject>

Examples:
feat(nutrition): Add food search filtering
fix(medicine): Correct dosage calculation
docs(api): Update API endpoint documentation
refactor(chat): Optimize message processing
test(reports): Add food report unit tests
chore(dependencies): Update Flutter to 3.10
```

**Types**: feat, fix, docs, style, refactor, test, chore

### Pull Request Process

1. Fork the repository
2. Create feature branch: `git checkout -b feat/feature-name`
3. Commit changes: `git commit -m "feat(scope): description"`
4. Push to branch: `git push origin feat/feature-name`
5. Open Pull Request with detailed description
6. Pass all CI/CD checks
7. Get code review approval
8. Merge to main

### Testing Requirements

- Unit tests for new services
- Widget tests for new UI screens
- Integration tests for critical flows
- Minimum 70% code coverage

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Generate coverage report
lcov --list coverage/lcov.info
```

---

## Troubleshooting

### Common Issues & Solutions

#### 1. **Server Not Starting**

**Error**: `Port 5000 already in use`
```bash
# Find process using port 5000
netstat -ano | findstr :5000

# Kill process (Windows)
taskkill /PID <PID> /F

# Or use different port
PORT=5001 npm start
```

**Error**: `GROQ_API_KEY not found or invalid`
```bash
# Solution 1: Create or update .env file
echo "GROQ_API_KEY=your_groq_api_key_here" > .env
echo "AI_MODE=groq" >> .env
echo "PORT=5000" >> .env

# Solution 2: System will automatically fallback to local model if key is invalid
# Check server logs to see fallback chain in action
npm start
```

**Error**: `Cannot find module 'node-fetch'`
```bash
# Solution: Install dependencies with node-fetch
cd ai_server
npm install
npm start
```

**Groq API Connection Issue**
```bash
# Test Groq API connectivity
curl -X POST https://api.groq.com/openai/v1/chat/completions \
  -H "Authorization: Bearer your_groq_api_key_here" \
  -H "Content-Type: application/json" \
  -d '{"model": "mixtral-8x7b-32768", "messages": [{"role": "user", "content": "Hello"}]}'

# If error occurs, check:
# 1. Groq API key validity
# 2. Network connectivity
# 3. API rate limits
# 4. Server will automatically use fallback if connection fails
```

#### 2. **Flutter Build Errors**

**Error**: `Could not find pubspec.yaml`
```bash
# Solution: Ensure you're in flutter project root
cd path/to/nutricare
flutter pub get
```

**Error**: `Android build tools not installed`
```bash
# Solution: Install Android SDK
flutter doctor -v
flutter clean
flutter pub get
```

**Error**: `iOS deployment target mismatch`
```bash
# Solution: Update Podfile
cd ios
pod repo update
pod install
```

#### 3. **Firebase Connection Issues**

**Error**: `Firebase initialization failed`
```bash
# Verify firebase.json
firebase use --add

# Reconfigure Firebase
rm google-services.json
firebase init (re-setup)
```

**Error**: `Firestore permission denied`
```bash
# Check Firestore rules in Firebase Console
# Ensure user is authenticated
# Verify Firestore security rules are configured
```

#### 4. **Medicine Reminder Not Working**

**Error**: `Notifications not received`
```dart
// Check notification permission
final status = await Permission.notification.request();

// Verify channel creation
MedicineNotificationService.initNotificationChannel();

// Check if notifications are enabled in system
```

#### 5. **Report Generation Failing**

**Error**: `Food not found in database`
```
Solution: Check food name spelling/formatting
- Use FoodMedicineReportService.searchFoods() first
- Verify database is loaded at server startup
```

**Error**: `Report API returning empty**
```bash
# Verify server is running
curl http://localhost:5000/api/food-report -X POST -H "Content-Type: application/json" -d '{"foodName":"Butter Chicken"}'

# Check server logs for errors
# Verify database files exist: food_*.json, medicine_*.json
```

#### 6. **AI Fallback Chain Issues**

**Understanding the Fallback Chain**
```
Request → Groq API (if GROQ_API_KEY configured)
       → Local Model (if Groq fails)
       → Database Fallback (if local fails)
```

**Problem**: AI responses seem slow
```
Solution: Enable Groq API for faster responses
1. Verify GROQ_API_KEY is set in .env
2. Check server logs show "Groq API" being called
3. Response time: Groq ~2-3s, Local ~5-10s, DB <1s

Optimize:
- Reduce GROQ_TIMEOUT in .env if needed (default: 15s)
- Ensure network connectivity to api.groq.com
- Check Groq API rate limits haven't been exceeded
```

**Problem**: Always getting database fallback responses
```
Solution: Verify Groq API configuration
1. Check .env has valid GROQ_API_KEY
2. Verify AI_MODE=groq in .env
3. Check server startup logs:
   ✅ Groq API: ✅ CONFIGURED
   🤖 Fallback Chain: Groq → Local Model → Database

If showing "❌ NOT CONFIGURED":
- Verify GROQ_API_KEY is set in .env
- Restart server after changing .env
- Check no typos in API key

If Groq API configured but not being used:
- Check network connectivity to api.groq.com
- Verify API key is valid (test with curl)
- Check API timeout settings in .env
- Review server logs for error messages
```

**Problem**: Getting "Groq API error"
```
Solutions by error type:

❌ 401 Unauthorized - API key invalid
   - Verify API key in .env
   - Check for whitespace/typos
   - Re-authenticate with Groq Dashboard

❌ 429 Too Many Requests - Rate limit exceeded
   - Wait before retrying
   - Reduce request frequency
   - Check Groq account limits

❌ Timeout error
   - Increase GROQ_TIMEOUT in .env
   - Check network connectivity
   - Possible Groq API overload (try again later)

❌ Connection refused
   - Verify internet connection
   - Check api.groq.com is accessible
   - Verify firewall/proxy settings
   - System will automatically fallback to local model
```

**Monitoring Fallback Chain**
```bash
# Check server logs to see which AI source is being used
# Look for these log messages:

🤖 Calling Groq API...          # Groq API attempt
✅ Groq API response received   # Groq succeeded
⚠️  Groq API error: ...         # Groq failed, trying next

🔄 Calling Local Model...        # Local model attempt
✅ Local model response received # Local model succeeded
⚠️  Local model error: ...       # Local model failed, trying next

🔄 Using Database Fallback...    # Database fallback attempt
✅ Database fallback response    # Database succeeded (always)

View logs in real-time:
npm start  # (server will output all fallback chain logs)
```

#### 6. **Performance Issues**

**Problem**: App is slow
```dart
// Use DevTools Performance tab
flutter run --profile

// Check for:
// - Unnecessary rebuilds (use repaint boundaries)
// - Heavy computations (move to isolates)
// - Large images (compress and cache)
// - Deep widget trees (flatten structure)
```

**Problem**: Server timeout
```
Solution:
- Increase timeout in FoodMedicineReportService (current: 10s)
- Check server logs for slow queries
- Add caching for frequently accessed data
- Optimize database queries
```

### Debug Logging

Enable debug logs:
```dart
// In main.dart
void main() {
  if (kDebugMode) {
    AppLogger.setLevel(LogLevel.debug);
  }
  runApp(MyApp());
}
```

View logs:
```bash
flutter logs
```

### Performance Profiling

```bash
# Run with profiling
flutter run --profile

# Use DevTools
flutter pub global activate devtools
flutter pub global run devtools

# Analyze frame statistics
# Check CPU/memory usage
# Identify janky frames
```

---

## Documentation Index

| Document | Purpose |
|----------|---------|
| [QUICK_START.md](QUICK_START.md) | 5-minute setup guide |
| [QUICK_START_AI.md](QUICK_START_AI.md) | AI system setup |
| [QUICK_START_FOOD_MEDICINE.md](QUICK_START_FOOD_MEDICINE.md) | Food/medicine features |
| [FOOD_MEDICINE_REPORTS.md](FOOD_MEDICINE_REPORTS.md) | Detailed feature docs |
| [AI_TRAINING_GUIDE.md](AI_TRAINING_GUIDE.md) | Model training pipeline |
| [HEALTH_REPORT_INTEGRATION_GUIDE.md](HEALTH_REPORT_INTEGRATION_GUIDE.md) | Report system |
| [AI_IMPLEMENTATION_COMPLETE.md](AI_IMPLEMENTATION_COMPLETE.md) | AI system details |
| [AI_SYSTEM_PROFESSIONAL_UPDATE.md](AI_SYSTEM_PROFESSIONAL_UPDATE.md) | System improvements |

---

## Support & Contact

- **Issues**: GitHub Issues
- **Discussions**: GitHub Discussions
- **Email**: support@nutricare.example.com
- **Documentation**: This file + linked docs
- **Community**: Slack/Discord (if applicable)

---

## License

This project is licensed under the MIT License - see LICENSE file for details.

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | Mar 31, 2026 | Initial production release |
| 0.9.0 | Mar 2026 | Food/medicine reports integration |
| 0.8.0 | Feb 2026 | Health report system |
| 0.7.0 | Jan 2026 | AI chatbot integration |

---

**Last Updated**: March 31, 2026  
**Maintainer**: Development Team  
**Status**: ✅ Production Ready
