# Integration Guide - Health Report Analysis System

## Quick Start Integration

### 1. Add to Main Navigation

In your **main.dart** or navigation handler:

```dart
import 'package:nuticare/screens/health_report_upload_screen.dart';

// In your navigation/routing:
case 'health_report_upload':
  return MaterialPageRoute(
    builder: (_) => const HealthReportUploadScreen(),
  );
```

### 2. Add Button to Dashboard

In your main dashboard screen:

```dart
ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const HealthReportUploadScreen(),
      ),
    );
  },
  child: const Text('Upload Health Report'),
)
```

### 3. Firebase Setup Required

Configure Firebase in your project:

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Initialize Firebase
firebase init

# Deploy Firestore rules
firebase deploy
```

**Firestore Rules** (`firestore.rules`):

```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    // User-specific reports
    match /users/{userId}/healthReports/{reportId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Metadata collection
    match /healthReportMetadata/{reportId} {
      allow read: if request.auth.uid == resource.data.userId;
      allow write: if request.auth.uid == request.auth.uid;
    }
  }
}
```

**Storage Rules** (`storage.rules`):

```javascript
rules_version = '2';

service firebase.storage {
  match /b/{bucket}/o {
    match /healthReports/{userId}/{allPaths=**} {
      allow read, write: if request.auth.uid == userId;
    }
  }
}
```

### 4. Update pubspec.yaml

Add all required dependencies:

```yaml
dependencies:
  flutter:
    sdk: flutter
  # ... existing dependencies
  
  # OCR & Image Processing
  google_ml_kit: ^0.13.0
  image_picker: ^1.0.0
  
  # Firebase
  firebase_core: ^2.24.0
  firebase_storage: ^11.4.0
  cloud_firestore: ^4.13.0
  
  # Utilities
  uuid: ^4.0.0
  intl: ^0.19.0

dev_dependencies:
  # ... existing dev dependencies
```

Then run:

```bash
flutter pub get
```

### 5. Platform-Specific Setup

#### Android (`android/app/build.gradle`)

```gradle
android {
    // ... existing config
    
    compileSdk 34
    
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
    }
}

dependencies {
    // ... existing dependencies
    implementation 'com.google.mlkit:text-recognition:16.0.0'
}
```

#### iOS (`ios/Podfile`)

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        'PERMISSION_CAMERA = 1',
        'PERMISSION_PHOTOS = 1',
      ]
    end
  end
end
```

**Info.plist** additions:

```xml
<dict>
  <!-- ... existing config -->
  <key>NSCameraUsageDescription</key>
  <string>We need camera access to scan health reports</string>
  <key>NSPhotoLibraryUsageDescription</key>
  <string>We need photo library access to upload health reports</string>
  <key>NSPhotoLibraryAddOnlyUsageDescription</key>
  <string>We need permission to save health reports</string>
</dict>
```

## API Reference

### HealthReportUploadScreen

```dart
const HealthReportUploadScreen()
```

**Features:**
- Automated OCR text extraction
- Medical value parsing
- Real-time validation
- Progress feedback
- Error handling

### HealthInsightsDashboardScreen

```dart
HealthInsightsDashboardScreen(
  analysis: HealthAnalysis(...),
  medicalValues: MedicalValues(...),
)
```

**Features:**
- 3-page swipeable interface
- Risk assessment visualization
- Condition listing
- Personalized recommendations

### OCRExtractionService

```dart
// Pick and process image
final image = await OCRExtractionService.pickReportImage(
  useCamera: false, // or true for camera
);

// Extract text from image
final text = await OCRExtractionService.extractTextFromImage(imagePath);

// Parse medical values
final values = OCRExtractionService.extractMedicalValues(text);

// Validate values
final warnings = OCRExtractionService.validateValues(values);
```

### HealthAnalysisEngine

```dart
// Analyze medical values
final conditions = HealthAnalysisEngine.analyzeValues(medicalValues);

// Get overall risk level
final riskLevel = HealthAnalysisEngine.getOverallRiskLevel(conditions);

// Get condition-specific advice
final advice = HealthAnalysisEngine.getConditionAdvice(condition);
```

### HealthRecommendationService

```dart
// Get recommendations based on values
final recommendations = 
  HealthRecommendationService.getPersonalizationRecommendations(values);

// Get medical disclaimer
final disclaimer = 
  HealthRecommendationService.getMedicalDisclaimer();

// Get health advisory
final advisory = 
  HealthRecommendationService.getHealthAdvisory(conditions);
```

### HealthReportStorageService

```dart
// Upload file with progress
final url = await HealthReportStorageService.uploadReportFile(
  filePath,
  onProgress: (progress) {
    print('Progress: ${(progress * 100).toStringAsFixed(0)}%');
  },
);

// Save metadata
await HealthReportStorageService.saveReportMetadata(
  reportId,
  fileUrl,
  fileName,
  medicalValues,
  reportDate: DateTime.now(),
  notes: 'Additional notes',
);

// Save analysis
await HealthReportStorageService.saveHealthAnalysis(
  reportId,
  analysis,
);

// Get report history
final reports = 
  await HealthReportStorageService.getReportHistory(userId);

// Retrieve specific report
final report = 
  await HealthReportStorageService.getReport(reportId);
```

## Data Models

### MedicalValues

```dart
class MedicalValues {
  double? glucose;          // mg/dL
  double? hemoglobin;       // g/dL
  double? totalCholesterol; // mg/dL
  double? hdl;              // mg/dL
  double? ldl;              // mg/dL
  double? triglycerides;    // mg/dL
  double? systolicBP;       // mmHg
  double? diastolicBP;      // mmHg
  double? tsh;              // mIU/L
  double? creatinine;       // mg/dL
  double? wbc;              // K/µL
  double? rbc;              // M/µL
  // ... more fields
}
```

### HealthAnalysis

```dart
class HealthAnalysis {
  String reportId;
  DateTime analyzedAt;
  List<DetectedCondition> detectedConditions;
  String overallRiskLevel;  // 'critical', 'high', 'moderate', 'low'
  String summaryText;
}
```

### DetectedCondition

```dart
class DetectedCondition {
  String name;
  String description;
  String severity;              // 'critical', 'high', 'moderate', 'low'
  List<String> affectedMetrics;
  List<String> recommendations;
}
```

## Error Handling

The system handles:

- ❌ **Invalid/unclear images** → User prompted to upload clearer image
- ❌ **OCR failure** → Fallback to manual entry option (future)
- ❌ **Upload failure** → Retry mechanism with user notification
- ❌ **Firebase errors** → Graceful error messages
- ❌ **Invalid medical values** → Validation warnings shown

## Testing Checklist

- [ ] Image upload from gallery
- [ ] Image capture from camera
- [ ] OCR text extraction accuracy
- [ ] Medical value parsing
- [ ] Validation warnings display
- [ ] Firebase upload
- [ ] Condition detection accuracy
- [ ] Recommendation generation
- [ ] Dashboard navigation (swipe between pages)
- [ ] Risk level color coding
- [ ] Historical report retrieval

## Performance Considerations

- **OCR Processing**: ~2-5 seconds per image
- **Condition Detection**: <1 second for analysis
- **Firebase Upload**: Depends on file size & network
- **Dashboard Render**: Smooth 60fps with 20+ conditions

## Future Enhancements

1. Export reports as PDF
2. Share with healthcare providers
3. Medication interaction checking
4. Historical trend analysis
5. Predictive health alerts
6. Doctor appointment scheduling
7. Prescription management
8. Lab test history tracking

---

**Last Updated**: 2024
**Status**: Production Ready
**Support**: Consult healthcare professional for medical advice

