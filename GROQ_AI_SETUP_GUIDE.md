# 🚀 NutriCare+ Groq AI Integration Guide

**Status:** ✅ All AI services have been migrated from local Node.js server to **Groq Cloud API**

---

## Quick Start: Get Your Groq API Key

### Step 1: Sign Up for Free
Visit: **https://console.groq.com**
- Click "Sign Up" (or "Sign In" if you have an account)
- Use Google, GitHub, or email signup
- No credit card required for getting started

### Step 2: Generate API Key
1. Go to **API Keys** section in console
2. Click **"Create New API Key"**
3. Copy the key (looks like: `gsk_xxxxxxxxxxxxxxxxxx`)
4. Keep it safe! ⛔ Don't commit it to Git

---

## How to Configure Your App

### Option 1: Environment Variable (Recommended)

#### On Windows (PowerShell):
```powershell
$env:GROQ_API_KEY = "your_api_key_here"
flutter run -d chrome
```

#### On Mac/Linux (Bash):
```bash
export GROQ_API_KEY="your_api_key_here"
flutter run -d chrome
```

#### In VS Code Launch Configuration
Create `.vscode/launch.json`:
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Flutter (Chrome)",
      "type": "dart",
      "request": "launch",
      "program": "lib/main.dart",
      "args": [
        "-d",
        "chrome"
      ],
      "env": {
        "GROQ_API_KEY": "your_api_key_here"
      }
    }
  ]
}
```

### Option 2: Direct Configuration in Code

Edit `lib/main.dart` and replace:
```dart
const String groqApiKey = String.fromEnvironment(
  'GROQ_API_KEY',
  defaultValue: '', // TODO: Set this via build flags or environment variable
);
```

With:
```dart
const String groqApiKey = 'your_actual_api_key_here';
```

**⚠️ WARNING:** Don't commit this! Add to `.gitignore`:
```
.env
.env.local
pubspec.lock (already excluded)
```

### Option 3: .env File (Using flutter_dotenv)

1. Add to `pubspec.yaml`:
```yaml
dependencies:
  flutter_dotenv: ^5.1.0
```

2. Create `.env` file in project root:
```
GROQ_API_KEY=your_api_key_here
```

3. Update `lib/main.dart`:
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  // ...
  await dotenv.load();
  
  final String groqApiKey = dotenv.env['GROQ_API_KEY'] ?? '';
  if (groqApiKey.isNotEmpty) {
    GroqAIService.setApiKey(groqApiKey);
  }
  // ...
}
```

4. Add `.env` to `.gitignore`:
```
.env
.env.local
```

---

## Run the App

```powershell
# Set API key
$env:GROQ_API_KEY = "gsk_your_key_here"

# Run on Chrome (Web)
flutter run -d chrome

# Or run on Android/iOS if configured
flutter run -d android
flutter run -d ios
```

The app will now show: ✅ **Groq AI Service initialized**

---

## What Changed

### Before (Local Server)
```
NutriCare+ App → Local Node.js server (port 5000) → AI responses
                      (Had to run manually & manage locally)
```

### After (Groq Cloud)
```
NutriCare+ App → Groq Cloud API → AI responses
                  (No setup needed, just add API key)
```

### Services Updated
✅ `GroqAIService` - Main AI chat and analysis  
✅ `Medicine interactions checking` - Via Groq  
✅ `Food nutrition analysis` - Via Groq  
✅ `Meal planning` - Via Groq  
✅ `Workout recommendations` - Via Groq  
✅ All screens migrated from `TrainedAIService` to `GroqAIService`  

---

## API Limits & Pricing

### Free Tier:
- ✅ **30 requests per minute** (plenty for personal use)
- ✅ **Mixtral-8x7b model** (fast, high quality)
- ✅ 1000 requests per day limit
- ✅ **No credit card required**

### Pricing (if you exceed limits):
- Pay-as-you-go starting at **$0.27 per 1M input tokens**
- Very affordable for small/personal projects

👉 Check current pricing: https://groq.com/pricing

---

## Troubleshooting

### Error: "Network error. Make sure AI server is running on port 5000."
❌ **Old error** - This means you haven't set the Groq API key yet
✅ **Solution:** Follow "Get Your Groq API Key" section above

### Error: "Groq API key not configured"
❌ API key not found
✅ **Check:**
```dart
// In your terminal/IDE, verify:
echo $env:GROQ_API_KEY  # Windows PowerShell
echo $GROQ_API_KEY      # Mac/Linux
```

### Error: "AI Error: Invalid API key"
❌ API key is wrong or expired
✅ **Solution:**
1. Go to https://console.groq.com
2. Check/regenerate your API key
3. Make sure you're using the full key (starts with `gsk_`)

### Error: "Rate limit exceeded"
❌ Sent too many requests too fast
✅ **Solution:** Wait a minute or upgrade your tier

### AI responses are slow
- Normal! Groq is usually fast (< 2 seconds), but:
  - First request is slower (cold start)
  - Large prompts take longer
  - Network latency factors apply
- Timeout is set to 30 seconds - should be OK

---

## Testing the Integration

### Test in Terminal:
```powershell
# Set API key
$env:GROQ_API_KEY = "gsk_your_key_here"

# Run app
flutter run -d chrome

# Try these:
# - Type in AI Chat and send a message
# - Scan a food item
# - Add a medicine
# - Check interactions
```

### Expected Behavior:
✅ Messages appear with AI responses  
✅ No "port 5000" errors  
✅ No "API key" errors  
✅ Fast responses (< 3 seconds usually)  

---

## Production Deployment

When deploying to production (iOS App Store, Google Play, Firebase Hosting):

**NEVER hardcode API keys!** Instead:

1. **Store securely:** Use Firebase Remote Config or similar
2. **Server-side relay:** Have a backend server that calls Groq (preferred)
3. **API Gateway:** Use AWS API Gateway or similar
4. **Environment-specific:** Different keys for dev/staging/production

For now, the environment variable approach is fine for development.

---

## Groq AI Models Available

The app currently uses: **`mixtral-8x7b-32768`**

Other options:
- `llama-2-70b-chat` - Larger, more capable
- `llama3-70b-8192` - Latest, very fast
- `llama3-8b-8192` - Lightweight alternative

To try a different model, edit `groq_ai_service.dart`:
```dart
static const String _model = 'mixtral-8x7b-32768'; // ← Change here
```

Recommended: `mixtral-8x7b-32768` (best balance of speed & quality)

---

## Need Help?

### Groq Resources:
- 📖 Docs: https://console.groq.com/docs/
- 🆘 Support: https://support.groq.com/
- 💬 Discord: https://discord.gg/groq

### NutriCare+ AI Integration:
- 📁 Service file: `lib/services/groq_ai_service.dart`
- ✅ Already handles errors gracefully with fallback nutrition database
- 🔒 API key never exposed in logs (removed for security)

---

## Summary Checklist

- [ ] Got Groq API key from https://console.groq.com
- [ ] Set `GROQ_API_KEY` environment variable
- [ ] Ran `flutter run -d chrome` successfully
- [ ] Tested AI Chat (sent a message)
- [ ] Verified no "port 5000" errors
- [ ] App works without local Node.js server

**You're all set! 🎉**

---

**Last Updated:** April 7, 2026  
**Groq Integration:** Complete ✅

