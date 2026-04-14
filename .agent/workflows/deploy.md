---
description: Deploy NutriCare app to web and Android
---

# NutriCare Deployment Workflow

This workflow guides you through deploying the NutriCare app to Firebase Hosting (web) and building Android release artifacts.

## Prerequisites

- Flutter SDK installed
- Firebase CLI installed and logged in (`firebase login`)
- Android SDK configured (for Android builds)

## Web Deployment

### 1. Clean and prepare
```bash
flutter clean
flutter pub get
```

### 2. Build web release
// turbo
```bash
flutter build web --release
```

### 3. Deploy to Firebase Hosting
```bash
firebase deploy --only hosting
```

**Result**: App will be live at https://gen-lang-client-0252200425.web.app

## Android Deployment

### 1. Build Android APK (for testing/sideloading)

**Note**: If you encounter Java VM memory errors, first configure gradle.properties:
```bash
# Edit android/gradle.properties and add:
org.gradle.jvmargs=-Xmx2048m -XX:MaxMetaspaceSize=512m
```

// turbo
```bash
flutter build apk --release
```

**Output**: `build/app/outputs/flutter-apk/app-release.apk`

### 2. Build Android App Bundle (for Play Store)

```bash
flutter build appbundle --release
```

**Output**: `build/app/outputs/bundle/release/app-release.aab`

### 3. Test Android build

Install the APK on a test device:
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

## Verification

- **Web**: Visit https://gen-lang-client-0252200425.web.app
- **Android**: Test APK on physical device or emulator
- **Firebase features**: Verify authentication, Firestore, and Firebase Messaging work correctly

## Troubleshooting

### Android Build Fails with Java VM Error

1. Edit `android/gradle.properties`:
   ```
   org.gradle.jvmargs=-Xmx2048m -XX:MaxMetaspaceSize=512m
   ```

2. Clean gradle cache:
   ```bash
   cd android
   ./gradlew clean
   ./gradlew assembleRelease --no-daemon
   ```

### Firebase Deployment Fails

- Ensure you're logged in: `firebase login`
- Check project ID in `.firebaserc` matches your Firebase project
- Verify `build/web` directory exists and contains built files

## Configuration Notes

- **Application ID**: `com.example.nutricare` (change for production)
- **Version**: Defined in `pubspec.yaml` (currently `1.0.0+1`)
- **Signing**: Currently uses debug signing (configure release signing for Play Store)
