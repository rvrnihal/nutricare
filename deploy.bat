@echo off
REM NUTRICARE+ PRODUCTION DEPLOYMENT SCRIPT (Windows)
REM Automates: Build Flutter Web + Deploy to Firebase Hosting

setlocal enabledelayedexpansion

echo.
echo ╔════════════════════════════════════════════════════════════╗
echo ║       🚀 NUTRICARE+ PRODUCTION DEPLOYMENT SCRIPT          ║
echo ║                    Windows Version                         ║
echo ║                   April 1, 2026                            ║
echo ╚════════════════════════════════════════════════════════════╝
echo.

REM Configuration
set FIREBASE_PROJECT=gen-lang-client-0252200425
set APP_DIR=%CD%
set AI_SERVER_DIR=%APP_DIR%\ai_server
set BUILD_DIR=%APP_DIR%\build\web

echo 📋 Deployment Configuration:
echo    • Firebase Project: %FIREBASE_PROJECT%
echo    • App Directory: %APP_DIR%
echo    • Build Output: %BUILD_DIR%
echo    • AI Server: %AI_SERVER_DIR%
echo.

REM Step 1: Check prerequisites
echo 🔍 Step 1: Checking prerequisites...
echo.

where /q flutter
if errorlevel 1 (
    echo ✗ Flutter not found. Please install Flutter SDK.
    exit /b 1
)
echo ✓ Flutter installed

where /q firebase
if errorlevel 1 (
    echo ✗ Firebase CLI not found. Install: npm install -g firebase-tools
    exit /b 1
)
echo ✓ Firebase CLI installed

where /q node
if errorlevel 1 (
    echo ✗ Node.js not found. Please install Node.js.
    exit /b 1
)
echo ✓ Node.js installed
echo.

REM Step 2: Build Flutter Web
echo 🏗️  Step 2: Building Flutter web app (release mode)...
echo     This may take 5-10 minutes...
echo.

cd /d "%APP_DIR%"
flutter clean
flutter pub get
flutter build web --release

if not exist "%BUILD_DIR%" (
    echo ✗ Build failed: %BUILD_DIR% not found
    exit /b 1
)

echo ✓ Flutter web build complete
for /F "tokens=*" %%A in ('dir /-s /b %BUILD_DIR% 2^>nul ^| find /c /v ""') do set /a COUNT=%%A
echo   Build files: %COUNT% files
echo.

REM Step 3: Deploy to Firebase Hosting
echo 🔥 Step 3: Deploying to Firebase Hosting...
echo    Project: %FIREBASE_PROJECT%
echo    URL: https://%FIREBASE_PROJECT%.web.app
echo.

call firebase use %FIREBASE_PROJECT%
call firebase deploy --only hosting

if errorlevel 1 (
    echo ✗ Firebase deployment failed
    exit /b 1
)

echo ✓ Firebase hosting deployment complete
echo.

REM Step 4: AI Server deployment options
echo 🤖 Step 4: AI Server Deployment Options
echo.
echo Choose deployment option:
echo   1) Firebase Cloud Run (easiest, integrated)
echo   2) Railway.app (fastest setup)
echo   3) Render (free tier available)
echo   4) Skip (keep using localhost)
echo.

set /p AI_DEPLOY_OPTION="Enter option (1-4): "

if "%AI_DEPLOY_OPTION%"=="1" (
    echo 🌩️  Deploying to Firebase Cloud Run...
    if not exist "%AI_SERVER_DIR%\Dockerfile" (
        echo Creating Dockerfile...
        (
            echo FROM node:18-alpine
            echo WORKDIR /app
            echo COPY package*.json ./
            echo RUN npm install --production
            echo COPY . .
            echo EXPOSE 5000
            echo CMD ["node", "server.js"]
        ) > "%AI_SERVER_DIR%\Dockerfile"
        echo ✓ Dockerfile created
    ) else (
        echo ✓ Dockerfile found
    )
    echo.
    echo Next steps:
    echo   1. Install Google Cloud SDK: https://cloud.google.com/sdk/docs/install
    echo   2. Run: gcloud auth login
    echo   3. Run in ai_server directory:
    echo      gcloud run deploy nutricare-ai --source . --region us-central1
    echo.
) else if "%AI_DEPLOY_OPTION%"=="2" (
    echo 🚂 Deploying to Railway.app...
    echo.
    echo Next steps:
    echo   1. Go to: https://railway.app
    echo   2. Click 'New Project'
    echo   3. Connect GitHub repository
    echo   4. Select ai_server directory
    echo   5. Add environment variables:
    echo      - GROQ_API_KEY
    echo      - HF_TOKEN
    echo      - AI_MODE=groq
    echo   6. Deploy
    echo.
) else if "%AI_DEPLOY_OPTION%"=="3" (
    echo 📦 Deploying to Render...
    echo.
    echo Next steps:
    echo   1. Go to: https://render.com
    echo   2. Click 'New +' then 'Web Service'
    echo   3. Connect GitHub repository
    echo   4. Configuration:
    echo      - Name: nutricare-ai
    echo      - Root Directory: ai_server
    echo      - Build Command: npm install
    echo      - Start Command: node server.js
    echo      - Environment: Node
    echo   5. Add environment variables
    echo   6. Deploy
    echo.
) else if "%AI_DEPLOY_OPTION%"=="4" (
    echo ⏭️  Skipping AI server deployment
    echo Remember to keep the local server running: cd ai_server ^&^& node server.js
    echo.
)

REM Step 5: Summary
echo.
echo ╔════════════════════════════════════════════════════════════╗
echo ║           ✅ DEPLOYMENT SCRIPT COMPLETE!                  ║
echo ╚════════════════════════════════════════════════════════════╝
echo.
echo 🎉 Your NutriCare+ app is ready for production!
echo.
echo 📍 Live URL: https://%FIREBASE_PROJECT%.web.app
echo.
echo ✅ Next steps:
echo    1. Verify app loads correctly
echo    2. Test all major features
echo    3. Check API connectivity
echo    4. Monitor performance in Firebase Console
echo    5. (Optional) Deploy AI server to cloud
echo.
echo 📊 Dashboard: https://console.firebase.google.com/project/%FIREBASE_PROJECT%
echo.

REM Post-deployment checklist
echo 📋 Post-Deployment Checklist:
echo    [ ] App loads at production URL
echo    [ ] User authentication works
echo    [ ] Data syncs with Firestore
echo    [ ] AI features functional
echo    [ ] No console errors
echo    [ ] Performance good (less than 3s load)
echo.

echo ✨ Deployment complete! Your app is live!
echo.

pause
