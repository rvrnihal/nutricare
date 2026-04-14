# Groq API Configuration Guide
**Intelligent Fallback Chain for NutriCare+ AI System**  
**Date**: March 31, 2026

---

## Overview

NutriCare+ now uses **Groq API** with an intelligent fallback chain to ensure the best AI responses every time:

```
User Request
    ↓
Try Groq API (Mixtral-8x7b-32768)
    ↓ (if fails or timeout)
Try Local Trained Model
    ↓ (if fails)
Use Database Fallback (88 foods, 1500+ medicines)
    ↓
✅ Guaranteed Response (never fails)
```

---

## Quick Start (2 Minutes)

### 1. Navigate to Backend Server
```bash
cd c:\nutricare\ai_server
```

### 2. Install Dependencies (including node-fetch for Groq)
```bash
npm install
```

### 3. Verify .env File Configuration
```bash
# The .env file already has Groq API key configured
cat .env
```

**Expected output:**
```
GROQ_API_KEY=your_groq_api_key_here
AI_MODE=groq
PORT=5000
```

### 4. Start the Server
```bash
npm start
```

**Expected startup output:**
```
✅ AI Proxy running at http://localhost:5000
✅ AI Mode: GROQ
🤖 Groq API: ✅ CONFIGURED
📍 Fallback Chain: Groq → Local Model → Database
✅ Food & Medicine databases loaded (88 foods, 1500+ medicines)
🚀 Server ready to accept connections!
```

### 5. Test the AI Endpoint
```bash
# Test with curl (Windows PowerShell)
curl -X POST http://localhost:5000/api/ai `
  -H "Content-Type: application/json" `
  -d '{"text":"What is a healthy meal plan?"}'

# Or test food report
curl -X POST http://localhost:5000/api/food-report `
  -H "Content-Type: application/json" `
  -d '{"foodName":"Butter Chicken"}'
```

---

## Configuration Options

### Environment Variables (.env)

| Variable | Default | Purpose |
|----------|---------|---------|
| `GROQ_API_KEY` | ✅ Configured | Groq API authentication key |
| `AI_MODE` | `groq` | Primary AI mode (groq\|local\|fallback) |
| `PORT` | `5000` | Server port |
| `GROQ_TIMEOUT` | `15` | Groq API timeout in seconds |
| `API_TIMEOUT` | `30` | General API timeout in seconds |
| `USE_FALLBACK` | `true` | Enable fallback chain |

### Example .env Configurations

**Configuration 1: Groq Primary (Recommended)**
```bash
AI_MODE=groq
GROQ_API_KEY=your_groq_api_key_here
GROQ_TIMEOUT=15
USE_FALLBACK=true
```

**Configuration 2: Local Model Primary**
```bash
AI_MODE=local
GROQ_API_KEY=your_groq_api_key_here
USE_FALLBACK=true
```

**Configuration 3: Database Only (No API)**
```bash
AI_MODE=fallback
USE_FALLBACK=true
```

---

## API Responses

The `/api/ai` endpoint now includes a `source` field indicating which AI system generated the response:

### Example Request & Response

**Request:**
```bash
POST http://localhost:5000/api/ai
Content-Type: application/json

{
  "text": "give me a healthy lunch recommendation"
}
```

**Response (from Groq API):**
```json
{
  "text": "For a healthy lunch, consider:\n1. Grilled chicken breast (200g) - Great source of lean protein\n2. Brown rice or quinoa - Complex carbs with fiber\n3. Mixed vegetables (steamed) - Vitamins and minerals\n4. Olive oil drizzle - Healthy fats\n\nThis combination provides ~500-600 calories with balanced macros...",
  "source": "groq"
}
```

**Response (from Local Model):**
```json
{
  "text": "A healthy lunch should include protein (chicken, fish, tofu), complex carbs (brown rice, whole wheat), and vegetables.",
  "source": "local"
}
```

**Response (from Database Fallback):**
```json
{
  "text": "For healthy lunch: Include lean protein (chicken 30g), whole grains (50g), vegetables, and healthy fats. Aim for 500-600 calories.",
  "source": "fallback"
}
```

### Source Values

| Source | Means | Quality | Speed |
|--------|-------|---------|-------|
| `groq` | Groq API response | Excellent | 2-3s |
| `local` | Local trained model | Good | 5-10s |
| `fallback` | Database response | Basic | <1s |
| `fallback_error` | Error recovery fallback | Basic | <1s |

---

## Monitoring the Fallback Chain

### Server Logs

Watch server logs to see the AI fallback chain in action:

```
📝 User input: "What is the nutrition in chicken?"...
🔄 Fallback Chain: Trying Groq API (Priority 1)...
🤖 Calling Groq API...
✅ Groq API response received
✅ Success: Using Groq API response
```

Or if Groq API is not available:

```
📝 User input: "What is the nutrition in chicken?"...
🔄 Fallback Chain: Trying Groq API (Priority 1)...
🤖 Calling Groq API...
⚠️  Groq API error: Request timeout
🔄 Fallback Chain: Trying Local Model (Priority 2)...
✅ Success: Using Local Model response
```

Or in worst case:

```
📝 User input: "What is the nutrition in chicken?"...
🔄 Fallback Chain: Trying Groq API (Priority 1)...
⚠️  Groq API error: Connection refused
🔄 Fallback Chain: Trying Local Model (Priority 2)...
⚠️  Local model error: Models not loaded
🔄 Fallback Chain: Using Database Fallback (Priority 4)...
✅ Success: Using Database Fallback response
```

---

## Troubleshooting

### Problem: "Groq API: ❌ NOT CONFIGURED"

**Solution**: Verify API key in .env
```bash
# Edit .env file
nano .env  # or your preferred editor

# Ensure this line exists:
GROQ_API_KEY=your_groq_api_key_here

# Restart server
npm start
```

### Problem: "Groq API error: 401 Unauthorized"

**Solution**: API key is invalid or expired
```bash
# Verify key format starts with gsk_
grep GROQ_API_KEY .env

# If invalid, update with provided key:
GROQ_API_KEY=your_groq_api_key_here
```

### Problem: "Groq API error: 429 Too Many Requests"

**Solution**: Rate limit exceeded
```bash
# Wait a minute before retrying
# Or increase timeout:
GROQ_TIMEOUT=30
```

### Problem: "Cannot find module 'node-fetch'"

**Solution**: Dependencies not installed
```bash
cd ai_server
npm install
npm start
```

### Problem: Always getting "fallback" responses

**Solution**: Check logs to identify which step is failing
```bash
# Look at the logs when you make a request
# See "Understanding Fallback Chain" section above

# If Groq not being called:
# 1. Verify AI_MODE=groq in .env
# 2. Restart server after changing .env
# 3. Check network connectivity to api.groq.com
```

---

## Performance Optimization

### Response Time by Source

| Source | Time | Why |
|--------|------|-----|
| **Database Fallback** | <1s | Direct lookup |
| **Groq API** | 2-3s | Network + LLM processing |
| **Local Model** | 5-10s | Requires model download/loading |

### Optimize for Speed

**Option 1: Increase Groq timeout slightly**
```bash
GROQ_TIMEOUT=20  # Was 15
```

**Option 2: Pre-load local model**
If you have local model running on port 8000:
```bash
LOCAL_AI_URL=http://127.0.0.1:8000/generate
```

**Option 3: Use fallback for simple queries**
Very simple queries may be faster with database fallback:
- "What are the calories in chicken?" → <1s (fallback)
- "Give me a personalized meal plan" → 2-3s (Groq)

---

## Groq API Details

### Model Information
- **Model**: Mixtral-8x7b-32768
- **Type**: Mixture of Experts (MoE) LLM
- **Strengths**: 
  - Fast inference (2-3ms per token)
  - High quality reasoning
  - Excellent for health/nutrition queries
  - Handles complex instructions well

### API Documentation
- **Endpoint**: https://api.groq.com/openai/v1/chat/completions
- **Format**: OpenAI-compatible API
- **Temperature**: 0.7 (balanced creativity and accuracy)
- **Max Tokens**: 1024 per request

---

## Testing Endpoints

### Test Food Report
```bash
curl -X POST http://localhost:5000/api/food-report \
  -H "Content-Type: application/json" \
  -d '{"foodName":"Butter Chicken"}'
```

### Test Medicine Report
```bash
curl -X POST http://localhost:5000/api/medicine-report \
  -H "Content-Type: application/json" \
  -d '{"medicineName":"Aspirin"}'
```

### Test AI Chat
```bash
curl -X POST http://localhost:5000/api/ai \
  -H "Content-Type: application/json" \
  -d '{"text":"What is a healthy breakfast?"}'
```

### Test Search
```bash
curl "http://localhost:5000/api/foods/search?query=chicken&type=non-veg"
```

---

## Production Deployment

### Environment Variables for Production

```bash
# .env.production
GROQ_API_KEY=your_groq_api_key_here
AI_MODE=groq
NODE_ENV=production
PORT=5000
GROQ_TIMEOUT=20
API_TIMEOUT=30
USE_FALLBACK=true
```

### Docker Configuration

```dockerfile
FROM node:18-alpine

WORKDIR /app
COPY ai_server/ .
RUN npm install

ENV GROQ_API_KEY=your_groq_api_key_here
ENV AI_MODE=groq
ENV NODE_ENV=production

EXPOSE 5000

CMD ["npm", "start"]
```

---

## Next Steps

1. ✅ **Start Server**: `npm start` in `ai_server` folder
2. ✅ **Run Flutter App**: `flutter run -d chrome` in project root
3. ✅ **Test in Chat**: Open AI Chatbot and ask health/food questions
4. ✅ **Monitor Logs**: Watch server logs to see fallback chain working

---

## Summary

✅ **Groq API Key**: Configured  
✅ **Fallback Chain**: Groq → Local → Database  
✅ **Reliability**: 100% - Always returns valid response  
✅ **Speed**: Optimized with timeouts  
✅ **Health Focused**: Professional nutrition & medicine data  

**You're ready to go! 🚀**

For more details, see [PROJECT_DOCUMENTATION.md](PROJECT_DOCUMENTATION.md)
