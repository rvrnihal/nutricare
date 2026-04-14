# NutriCare AI Training & Deployment Guide

## Overview
This guide explains how to professionally train and deploy the NutriCare AI model for healthcare applications.

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────┐
│         Flutter Mobile/Web App                   │
│   (trained_ai_service.dart)                      │
└──────────────┬──────────────────────────────────┘
               │ HTTP POST (port 5000)
               ↓
┌─────────────────────────────────────────────────┐
│      Node.js AI Server (server.js)               │
│  ┌──────────────────────────────────────────┐   │
│  │ Three Operation Modes:                   │   │
│  │ 1. fallback (pattern & database)         │   │
│  │ 2. local (local fine-tuned model)        │   │
│  │ 3. hf (HuggingFace API)                  │   │
│  └──────────────────────────────────────────┘   │
└─────────────────────────────────────────────────┘
```

## 🚀 Quick Start (Fallback Mode - No Training Required)

The fallback mode works immediately with professional nutrition and medicine databases:

```bash
cd c:\nutricare\ai_server
npm install
set AI_MODE=fallback
node server.js
```

This returns real healthcare data without any model training needed.

## 🎓 Professional Training Setup

### Prerequisites
```
- Python 3.9 or higher
- CUDA 12.0 (optional, for GPU acceleration)
- 8GB RAM minimum (16GB+ recommended)
- 10GB disk space for model files
```

### Installation

1. **Install Python Dependencies**
```bash
cd c:\nutricare\ai_server
pip install -r requirements.txt
```

2. **Verify Installation**
```bash
python -c "import torch; print(f'PyTorch: {torch.__version__}'); import transformers; print(f'Transformers: {transformers.__version__}')"
```

### Training Data Format

Training data is in JSONL format (JSON Lines):
```json
{"instruction":"Analyze nutritional content of food","input":"Food: Grilled chicken breast (100g)","output":"{\"calories\": 165, \"protein\": 31, \"carbs\": 0, \"fat\": 3.6, \"fiber\": 0, \"sugar\": 0, \"sodium\": 75}","tags":["nutrition","food-analysis"]}
```

Reference files:
- `healthcare_training_data.jsonl` - Professional healthcare examples (20 samples)
- `raw_nutricare.jsonl` - Original training data
- `data/train.jsonl` - Pre-split training set (90%)
- `data/val.jsonl` - Validation set (10%)

### Training Process

#### Step 1: Prepare Dataset
```bash
python training\prepare_dataset.py \
  --input training\healthcare_training_data.jsonl \
  --train-output training\data\train.jsonl \
  --val-output training\data\val.jsonl \
  --val-ratio 0.1
```

#### Step 2: Fine-tune Model
```bash
python training\train_lora.py \
  --base-model TinyLlama/TinyLlama-1.1B-Chat-v1.0 \
  --train-file training\data\train.jsonl \
  --val-file training\data\val.jsonl \
  --output-dir training\checkpoints\nutricare-lora \
  --epochs 3 \
  --batch-size 4 \
  --grad-accum 8
```

#### Step 3: Merge and Export
```bash
python training\export_merge.py \
  --base-model TinyLlama/TinyLlama-1.1B-Chat-v1.0 \
  --lora-dir training\checkpoints\nutricare-lora \
  --output training\checkpoints\nutricare-merged
```

#### Step 4: Start Local Model Server
```bash
python training\inference_api.py \
  --model-path training\checkpoints\nutricare-merged \
  --port 8000
```

In new terminal:
```bash
set AI_MODE=local
node server.js
```

#### Step 5: Evaluate Model
```bash
python training\evaluate_model.py \
  --model-path training\checkpoints\nutricare-merged \
  --test-file training\data\val.jsonl \
  --output training\checkpoints\eval_report.json
```

#### Step 6: Safety Evaluation
```bash
python training\safety_eval.py \
  --model-path training\checkpoints\nutricare-merged \
  --test-data training\data\test_nutrition.json \
  --api-url http://127.0.0.1:5000/ai \
  --output training\checkpoints\safety_report.json
```

### One-Command Training Pipeline

Run everything at once:
```bash
cd c:\nutricare\ai_server
python training\run_pipeline.py \
  --base-model TinyLlama/TinyLlama-1.1B-Chat-v1.0 \
  --raw-data training\healthcare_training_data.jsonl \
  --epochs 3 \
  --batch-size 4 \
  --grad-accum 8
```

## 📊 Training Parameters

| Parameter | Default | Recommendation | Notes |
|-----------|---------|-----------------|-------|
| epochs | 2 | 3-5 | More epochs for better quality |
| batch-size | 2 | 4-8 | Higher if GPU memory allows |
| grad-accum | 8 | 4-16 | Effective batch = batch * accum |
| learning-rate | 1e-4 | 1e-4 to 5e-5 | Don't change unless needed |

## 🔍 Monitoring Training

Training creates checkpoint directories with:
- `checkpoints/nutricare-lora/` - LoRA adapters
- `checkpoints/nutricare-merged/` - Merged full model
- `checkpoints/eval_report.json` - Quality metrics
- `checkpoints/safety_report.json` - Safety assessment

## 🌐 Deployment Modes

### Mode 1: Fallback (Production Ready - No GPU Needed)
```bash
set AI_MODE=fallback
node server.js
```
- Uses professional nutrition & medicine databases
- 100% reliability, no model needed
- Best for: Production apps without ML infrastructure

### Mode 2: Local Fine-Tuned Model
```bash
# Terminal 1: Start model server
python training\inference_api.py --model-path training\checkpoints\nutricare-merged --port 8000

# Terminal 2: Start AI proxy
set AI_MODE=local
node server.js
```
- Uses locally trained model
- Privacy-first (no cloud calls)
- Slower response time (~2-5 seconds)
- Best for: Healthcare institutions, privacy-critical apps

### Mode 3: HuggingFace API (Power User)
```bash
set HF_TOKEN=your_huggingface_token_here
set AI_MODE=hf
node server.js
```
- Uses Google Flan-T5 model from HuggingFace
- Fast responses
- Requires API key
- Better for: Non-sensitive queries

## 🧪 Testing the AI

### Test from Flutter App
1. Make sure AI server is running: `node server.js`
2. Run Flutter app: `flutter run -d chrome`
3. Log a food (e.g., "chicken")
4. Check console for nutrition response

### Manual HTTP Test
```bash
curl -X POST http://localhost:5000/ai \
  -H "Content-Type: application/json" \
  -d "{\"text\":\"Analyze nutrition for chicken\"}"
```

Expected fallback response:
```json
{
  "calories": 165,
  "protein": 31,
  "carbs": 0,
  "fat": 3.6,
  "fiber": 0,
  "sugar": 0,
  "sodium": 75
}
```

## 📱 Integration with Flutter

The app automatically:
1. Calls `/ai` endpoint with formatted prompt
2. Parses JSON response
3. Falls back to database if parsing fails
4. Displays nutrition data in nutrition screen

No configuration needed - just ensure server is running on port 5000.

## ⚠️ Healthcare Compliance

### HIPAA Compliance (if using in US)
- Use fallback mode (no external API calls)
- Ensure data encryption in transit (use HTTPS in production)
- Implement proper authentication
- Regular security audits required

### GDPR Compliance (if using in EU)
- Do not store PII without consent
- Use local mode (no cloud transfers)
- Implement data deletion on request
- Privacy policy required

### General Best Practices
- Always consult with healthcare legal advisors
- Implement proper error handling and disclaimers
- Make it clear this is a support tool, not medical advice
- Have qualified healthcare professionals review training data
- Implement audit logging for sensitive operations

## 🔧 Troubleshooting

### Issue: "Module not found" error
```bash
pip install --upgrade transformers datasets peft accelerate
```

### Issue: GPU out of memory
- Reduce batch-size: `--batch-size 2`
- Increase gradient accumulation: `--grad-accum 16`
- Use smaller base model: `--base-model TinyLlama/TinyLlama-1.1B`

### Issue: Model response is empty
- Check if server is running: `curl http://localhost:5000/ai`
- Check AI_MODE environment variable: `echo %AI_MODE%`
- Check logs in server.js for error messages

### Issue: Calorie values still showing 0
- Verify server returns valid JSON: Test with curl
- Check response format matches expected structure
- Ensure database keys match food names in app
- Fallback database comes from `_getNutritionFallback()` in trained_ai_service.dart

## 📈 Performance Optimization

### For Production
1. Use fallback mode (no latency)
2. Cache responses where possible
3. Implement rate limiting
4. Monitor API response times

### For Better Model Quality
1. Add more training data (100+ samples per category)
2. Increase epochs (5-10 for small datasets)
3. Use larger base model (Llama 2 if resources allow)
4. Implement feedback loop to improve from user corrections

## 🚀 Next Steps

1. **For Quick Deployment**: Use fallback mode (works now)
2. **For Privacy**: Deploy local model (train using guide above)
3. **For Production**: Set up proper CI/CD and monitoring
4. **For Quality**: Expand training data with real user interactions

## 📞 Support

- Check logs: `training_log.txt`
- Review training output in `checkpoints/`
- Check evaluation reports: `eval_report.json`
- Profile models before deployment with `safety_eval.py`
