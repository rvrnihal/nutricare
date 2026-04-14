# Quick Start Guide - Food & Medicine AI Chat Reports

## 🚀 Getting Started

### Prerequisites
- Node.js running (AI server on port 5000)
- Flutter app running (on web or device)
- Database files present in `ai_server/training/`

## 📋 Step-by-Step Setup

### 1. Start the AI Server
```bash
cd c:\nutricare\ai_server
node server.js
```

Expected output:
```
✅ AI Proxy running at http://localhost:5000 (mode=fallback)
✅ Food & Medicine databases loaded
📊 API Endpoints:
   POST /api/food-report - Get detailed food nutrition report
   POST /api/medicine-report - Get detailed medicine information report
   GET  /api/foods/search - Search foods by query or criteria
   GET  /api/medicines/search - Search medicines by query or criteria
   POST /api/ai-chat-with-report - Get AI chat with food/medicine report
```

### 2. Run Flutter App
```bash
cd c:\nutricare
flutter run -d chrome
```

### 3. Test in AI Chat Screen

## 🥗 Testing Food Reports

### Try these queries:
1. **"What are the calories in Butter Chicken?"**
   - AI responds with nutrition info
   - Displays beautiful food report card with:
     - Nutrition score
     - Macronutrient breakdown
     - Health benefits
     - Dietary recommendations

2. **"Tell me about Paneer Tikka nutrition"**
   - Shows detailed nutrition analysis
   - Protein content, calories, fat breakdown
   - Benefits of paneer

3. **"Show me low calorie Indian foods"**
   - Lists foods with < 150 calories
   - Each displayed with full nutrition

4. **"What's in Sambar?"**
   - Detailed nutritional profile
   - Regional information
   - Food type categorization

### Example Foods Available:
- Curries: Butter Chicken, Dal Makhani, Paneer Tikka, Sambar
- Breads: Naan, Roti, Paratha, Puri
- Rice Dishes: Biryani, Pulao, Rice varieties
- Desserts: Gulab Jamun, Kheer, Jalebi, Laddoo
- Vegetables: Aloo Gobi, Bhindi, Saag Paneer
- Legumes: Chana Masala, Rajma, Dals
- **And 40+ more dishes**

## 💊 Testing Medicine Reports

### Try these queries:
1. **"What is Aspirin used for?"**
   - AI explains uses
   - Displays detailed medicine card with:
     - Dosage information
     - Side effects list
     - Drug interactions
     - Safety warnings
     - Important notes

2. **"Tell me about Metformin side effects"**
   - Comprehensive list of potential side effects
   - Contraindications
   - Who should/shouldn't use it
   - Risk level assessment

3. **"Information about Paracetamol dosage"**
   - Recommended dosage ranges
   - Safe usage guidelines
   - Interactions with other drugs
   - Warning about overdose

4. **"Side effects of Ibuprofen"**
   - Detailed adverse effects
   - Risk assessment
   - Drug interactions
   - Special warnings

### Example Medicines Available:
- Pain Relief: Paracetamol, Ibuprofen, Aspirin, Diclofenac
- Antibiotics: Amoxicillin, Azithromycin, Cipro- floxacin
- Cardiovascular: Lisinopril, Atorvastatin, Amlodipine
- Diabetes: Metformin, Glibenclamide, Insulin
- Stomach: Omeprazole, Antacids, Domperidone
- **And 1,500+ more medicines**

## 🧪 API Testing (Using Command Line)

### Test Food Report:
```bash
curl -X POST http://localhost:5000/api/food-report \
  -H "Content-Type: application/json" \
  -d {"foodName": "Butter Naan"}
```

Expected response: 200 OK with detailed nutrition data

### Test Medicine Report:
```bash
curl -X POST http://localhost:5000/api/medicine-report \
  -H "Content-Type: application/json" \
  -d {"medicineName": "Aspirin"}
```

Expected response: 200 OK with detailed medicine info

### Search Foods:
```bash
curl "http://localhost:5000/api/foods/search?query=paneer"
```

### Search Medicines:
```bash
curl "http://localhost:5000/api/medicines/search?query=aspirin"
```

## 📊 UI Features to Look For

### In Chat:
1. **User message** - Shows your question
2. **AI response** - Shows NutriCare AI's text answer
3. **Report card** - Beautiful formatted report below the AI response

### Food Report Card Features:
- ✅ Nutrition Score Bar (visual 0-100 gauge)
- ✅ Nutrition Facts Grid (6-cell grid with macros)
- ✅ Benefits Section (checkmarks for positive aspects)
- ✅ Considerations (warnings if high sodium, sugar, etc.)
- ✅ Dietary Recommendations (how to eat this food)
- ✅ Color Coding (green for good foods, orange for moderate)
- ✅ Medical Disclaimer (professional legal note)

### Medicine Report Card Features:
- ✅ Risk Level Badge (High/Moderate/Low in color)
- ✅ Uses Section (blue icon + detailed uses)
- ✅ Dosage Section (teal icon + dosage info)
- ✅ Side Effects (orange section with list)
- ✅ Drug Interactions (purple icon + interaction warnings)
- ✅ Safety Notes (red background for important warnings)
- ✅ Medical Disclaimer (prominent warning)

## 🎯 Expected Behavior

### Successful Food Query:
```
User: "Food: Butter Chicken"
↓
AI: "Butter Chicken is a popular North Indian curry..."
[Beautiful food report card appears below with all details]
```

### Successful Medicine Query:
```
User: "Medicine: Aspirin"
↓
AI: "Aspirin is a common pain reliever..."
[Detailed medicine report card appears with safety warnings]
```

### No Match Found:
```
User: "Food: Unknown Dish"
↓
System: "Could not find 'Unknown Dish'. Try: Paneer Tikka, Dal Makhani..."
```

## ⚙️ Configuration

### Base URL Configuration:
The service uses `http://localhost:5000/api` by default.

To change in production, set environment variable:
```bash
flutter run --dart-define=API_BASE_URL=https://your-api.com/api
```

### Timeout Settings:
- Food/Medicine reports: 10 seconds
- AI chat with report: 15 seconds
- Search queries: 10 seconds

## 🐛 Troubleshooting

### Reports not showing?
1. ✅ Check server is running: `http://localhost:5000/ai`
2. ✅ Check database files exist in `ai_server/training/`
3. ✅ Look at server console for error messages
4. ✅ Try exact food/medicine names (check case sensitivity)

### Slow performance?
1. ✅ Ensure server isn't overloaded
2. ✅ Check network connection
3. ✅ Try simpler food/medicine names
4. ✅ Clear app cache if needed

### Wrong information displayed?
1. ✅ Verify food/medicine name is correct
2. ✅ Check database contains the item
3. ✅ Some names may need sanitization (spaces, punctuation)
4. ✅ Try searching instead (using search endpoints)

## 📝 Example Conversations

### Example 1: Food Query
```
User: "I want to know about Biryani nutrition. What are the calories and protein?"

AI: "Biryani is a popular rice dish from South India. It's a flavorful dish made 
with rice, meat, and spices. A typical serving contains approximately 380 calories 
with 22g of protein..."

[Food Report Card Shows]:
- Name: Biryani - Chicken
- Type: Rice dish | Region: South India
- Nutrition Score: 65/100 (Good)
- Calories: 380 kcal
- Protein: 22g
- Carbs: 45g
- Fat: 12g
- Fiber: 1g
- Sugar: 1g
- Benefits: Excellent source of protein, Part of balanced diet
- Recommendations: Good carbohydrate source, Serves as foundation for meals
```

### Example 2: Medicine  Query
```
User: "Tell me about Aspirin. What are the side effects and dosage?"

AI: "Aspirin is a widely used pain reliever and anti-inflammatory medication. 
It's commonly used for mild to moderate pain relief, fever reduction, and heart 
health. However, like all medications, it can have side effects..."

[Medicine Report Card Shows]:
- Name: Aspirin
- Generic: Acetylsalicylic Acid
- Type: Pain Reliever
- Risk Level: LOW (relatively common)
- Uses: Heart attack/stroke prevention, pain relief
- Dosage: For heart health: 75-325mg daily. For pain: 325-650mg every 4-6 hours
- Side Effects: Stomach upset, Bleeding risk, Easy bruising, Acid reflux
- Interactions: Increases bleeding with warfarin, NSAIDs may increase GI irritation
- Important Notes:
  🔴 NEVER self-medicate without consulting a healthcare professional
  🔴 Always inform your doctor about all medicines you are taking
  🔴 Report any unusual symptoms immediately
  🔴 Do not exceed prescribed dosage
  🔴 Store medicines as directed on packaging
```

## ✅ Verification Checklist

After setup, verify:
- [ ] Server starts without errors
- [ ] Food database loads (shows count in console)
- [ ] Medicine database loads (shows count in console)
- [ ] Can chat normally without reports
- [ ] Food queries show reports automatically
- [ ] Medicine queries show reports automatically
- [ ] UI renders properly without crashes
- [ ] Disclaimers display correctly
- [ ] Search suggestions work for unfound items

## 📞 Common Questions

**Q: Why is the report not showing?**
A: Food/medicine name might not exist in database or format doesn't match exactly.
Try searching first to confirm availability.

**Q: Can I add more foods/medicines?**
A: Yes! Edit the JSON files in `ai_server/training/` and restart the server.

**Q: Are the reports medically accurate?**
A: Yes, but they're for educational purposes. Always consult healthcare professionals.

**Q: Can this be used offline?**
A: Currently requires server connection. Offline mode can be added later.

**Q: What if I find incorrect information?**
A: Please report it so we can update the database with accurate information.

---

**Enjoy using NutriCare AI with Food & Medicine Reports!** 🎉
