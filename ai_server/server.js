import express from "express";
import cors from "cors";
import fetch from "node-fetch";
import dotenv from "dotenv";
import { dbManager, generateFoodReport, generateMedicineReport } from "./food_medicine_database.js";

// Load environment variables
dotenv.config();

const app = express();
app.use(cors());
app.use(express.json({ limit: "20mb" }));

// ===== ENVIRONMENT CONFIGURATION =====
const HF_TOKEN = process.env.HF_TOKEN;
const GROQ_API_KEY = process.env.GROQ_API_KEY;
const AI_MODE = (process.env.AI_MODE || "fallback").toLowerCase();
const LOCAL_AI_URL = process.env.LOCAL_AI_URL || "http://127.0.0.1:8000/generate";
const API_TIMEOUT = parseInt(process.env.API_TIMEOUT || "30") * 1000;
const GROQ_TIMEOUT = parseInt(process.env.GROQ_TIMEOUT || "15") * 1000;
const USE_FALLBACK = process.env.USE_FALLBACK !== "false";

// Groq API endpoint
const GROQ_API_URL = "https://api.groq.com/openai/v1/chat/completions";
const GROQ_TEXT_MODEL = process.env.GROQ_TEXT_MODEL || "llama-3.3-70b-versatile";
const GROQ_VISION_MODEL = process.env.GROQ_VISION_MODEL || "llama-3.2-90b-vision-preview";

// ✅ Router endpoint + stable text model
const MODEL_URL =
  "https://router.huggingface.co/hf-inference/models/google/flan-t5-base";

const buildPrompt = (userInput) =>
  `You are a health assistant. Give helpful advice.\nUser: ${userInput}`;

// ===== GROQ API FUNCTION =====
async function callGroqAPI(userInput) {
  if (!GROQ_API_KEY) {
    console.log("⚠️  Groq API key not configured, skipping Groq");
    return null;
  }

  try {
    console.log("🤖 Calling Groq API...");
    
    const response = await fetch(GROQ_API_URL, {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${GROQ_API_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        model: GROQ_TEXT_MODEL,
        messages: [
          {
            role: "system",
            content: "You are a helpful health and nutrition assistant. Provide accurate, professional health information. Always include disclaimers for medical advice."
          },
          {
            role: "user",
            content: userInput
          }
        ],
        temperature: 0.7,
        max_tokens: 1024,
      }),
      signal: AbortSignal.timeout(GROQ_TIMEOUT),
    });

    if (!response.ok) {
      const error = await response.text();
      console.log(`⚠️  Groq API error (${response.status}): ${error}`);
      return null;
    }

    const data = await response.json();
    
    if (data.choices && data.choices[0]?.message?.content) {
      const text = data.choices[0].message.content;
      console.log("✅ Groq API response received");
      return text;
    }

    console.log("⚠️  No content in Groq response");
    return null;
  } catch (error) {
    console.log(`⚠️  Groq API error: ${error.message}`);
    return null;
  }
}

// ===== HUGGING FACE IMAGE-TO-TEXT FUNCTION =====
async function analyzeImageWithHuggingFace(base64Image) {
  try {
    console.log("🖼️  Analyzing image with Document Analysis...");

    if (!GROQ_API_KEY) {
      console.log("⚠️  GROQ_API_KEY is missing for image analysis");
      return null;
    }

    // Use Groq vision model for document OCR-style extraction.
    const response = await fetch(GROQ_API_URL, {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${GROQ_API_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        model: GROQ_VISION_MODEL,
        messages: [
          {
            role: "system",
            content:
              "You are a medical document OCR and summarization assistant. Extract visible text faithfully and summarize key medical values without hallucinating.",
          },
          {
            role: "user",
            content: [
              {
                type: "text",
                text:
                  "Extract all visible text from this medical/health report image, then summarize: document type, key values, medicines, warnings, and practical next steps.",
              },
              {
                type: "image_url",
                image_url: {
                  url: `data:image/jpeg;base64,${base64Image}`,
                },
              },
            ],
          }
        ],
        temperature: 0.2,
        max_tokens: 2048,
      }),
      signal: AbortSignal.timeout(GROQ_TIMEOUT),
    });

    if (!response.ok) {
      const errText = await response.text();
      console.log(`⚠️  Vision API error (${response.status}): ${errText}`);
      return null;
    }

    const groqResponse = await response.json();

    if (groqResponse.choices && groqResponse.choices[0]?.message?.content) {
      const extractedText = groqResponse.choices[0].message.content;
      console.log("✅ Document text extracted: " + extractedText.substring(0, 100));
      return extractedText;
    }

    console.log("⚠️  No text extracted from image");
    return null;
  } catch (error) {
    console.log(`⚠️  Document analysis error: ${error.message}`);
    return null;
  }
}

// Professional healthcare-focused fallback responses
async function callFallbackModel(userInput) {
  const input = userInput.toLowerCase();
  
  // ===== FOOD/NUTRITION ANALYSIS =====
  if (input.includes("analyze") && (input.includes("food") || input.includes("nutrition"))) {
    // Extract food name
    const match = userInput.match(/(?:food|analyze|nutrition|estimate)[:\s]+([^.]+)/i);
    const foodName = match ? match[1].trim() : "unknown food";
    
    // Professional nutritional database fallback
    const nutritionDB = {
      "chicken": {calories: 165, protein: 31, carbs: 0, fat: 3.6, fiber: 0, sugar: 0, sodium: 75},
      "rice": {calories: 206, protein: 4.3, carbs: 45, fat: 0.3, fiber: 0.4, sugar: 0.1, sodium: 2},
      "bread": {calories: 80, protein: 4, carbs: 14, fat: 1.5, fiber: 2.4, sugar: 1, sodium: 140},
      "egg": {calories: 77, protein: 6.3, carbs: 0.6, fat: 5.3, fiber: 0, sugar: 0.6, sodium: 62},
      "salmon": {calories: 206, protein: 22, carbs: 0, fat: 13, fiber: 0, sugar: 0, sodium: 66},
      "broccoli": {calories: 34, protein: 2.8, carbs: 7, fat: 0.4, fiber: 2.4, sugar: 1.4, sodium: 64},
      "banana": {calories: 105, protein: 1.3, carbs: 27, fat: 0.3, fiber: 3.1, sugar: 14, sodium: 2},
      "yogurt": {calories: 59, protein: 10, carbs: 3.3, fat: 0.4, fiber: 0, sugar: 2.7, sodium: 29},
      "apple": {calories: 52, protein: 0.3, carbs: 14, fat: 0.2, fiber: 2.4, sugar: 10, sodium: 2},
      "fish": {calories: 100, protein: 20, carbs: 0, fat: 1, fiber: 0, sugar: 0, sodium: 65},
      "beef": {calories: 250, protein: 26, carbs: 0, fat: 15, fiber: 0, sugar: 0, sodium: 75},
      "pasta": {calories: 131, protein: 5, carbs: 25, fat: 1.1, fiber: 1.8, sugar: 0.6, sodium: 1},
      "milk": {calories: 61, protein: 3.2, carbs: 4.8, fat: 3.3, fiber: 0, sugar: 4.8, sodium: 44},
      "cheese": {calories: 402, protein: 25, carbs: 1.3, fat: 33, fiber: 0, sugar: 0.7, sodium: 621},
      "spinach": {calories: 23, protein: 2.9, carbs: 3.6, fat: 0.4, fiber: 2.2, sugar: 0.4, sodium: 58},
      "carrot": {calories: 41, protein: 0.9, carbs: 10, fat: 0.2, fiber: 2.8, sugar: 6, sodium: 69},
      "potato": {calories: 77, protein: 2, carbs: 17, fat: 0.1, fiber: 2.1, sugar: 0.8, sodium: 6},
      "tomato": {calories: 18, protein: 0.9, carbs: 3.9, fat: 0.2, fiber: 1.2, sugar: 2.6, sodium: 5},
      "orange": {calories: 47, protein: 0.9, carbs: 12, fat: 0.3, fiber: 2.4, sugar: 9.3, sodium: 0},
      "lentil": {calories: 116, protein: 9, carbs: 20, fat: 0.4, fiber: 8, sugar: 1.6, sodium: 4},
      "tofu": {calories: 76, protein: 8, carbs: 1.9, fat: 4.8, fiber: 1.2, sugar: 0.5, sodium: 7}
    };
    
    // Find matching food
    let nutrition = null;
    for (const [food, data] of Object.entries(nutritionDB)) {
      if (foodName.toLowerCase().includes(food) || food.includes(foodName.toLowerCase())) {
        nutrition = data;
        break;
      }
    }
    
    // Default valid nutrition if not found
    if (!nutrition) {
      nutrition = {calories: 150, protein: 12, carbs: 20, fat: 5, fiber: 3, sugar: 3, sodium: 200};
    }
    
    return JSON.stringify(nutrition);
  }
  
  // ===== MEDICINE INFORMATION =====
  // Check if user is asking about any medicine (keywords, categories, or medicine names)
  const medicineKeywords = ["medicine", "drug", "dosage", "side effect", "interaction", "pharmacy", "prescription", "tablet", "capsule", "medication", "nsaid", "antibiotic", "vaccine", "painkiller", "analgesic", "anti-inflammatory", "steroid", "hormone", "vitamin", "supplement"];
  const isMedicineQuery = medicineKeywords.some(keyword => input.toLowerCase().includes(keyword));
  
  // Common medicine name patterns to detect even without keywords
  const commonMedicines = ["metformin", "lisinopril", "aspirin", "atorvastatin", "ibuprofen", "dolo", "paracetamol", "dapagliflozin", "insulin", "amoxicillin", "omeprazole", "metoprolol", "simvastatin", "sertraline", "amlodipine", "levothyroxine", "nimesulide", "diclofenac", "cetirizine", "loratadine"];
  const hasMedicineName = commonMedicines.some(med => input.toLowerCase().includes(med));
  
  if (isMedicineQuery || hasMedicineName) {
    const medicineDB = {
      "metformin": {
        medicine: "Metformin",
        uses: "Type 2 diabetes management",
        side_effects: "Nausea, diarrhea, stomach upset, vitamin B12 deficiency with long-term use",
        interactions: "Alcohol increases lactic acidosis risk. Avoid with contrast dye procedures",
        dosage: "Usually 500-2550mg daily in divided doses",
        warning: "Not for Type 1 diabetes. Monitor kidney function regularly"
      },
      "lisinopril": {
        medicine: "Lisinopril",
        uses: "High blood pressure and heart failure",
        side_effects: "Dizziness, dry cough, headache, fatigue",
        interactions: "NSAIDs reduce effectiveness. Potassium supplements increase hyperkalemia risk",
        dosage: "Usually 10mg once daily, adjusted 10-40mg",
        warning: "Can cause dangerous hyperkalemia. Regular monitoring essential. Avoid in pregnancy"
      },
      "aspirin": {
        medicine: "Aspirin",
        uses: "Heart attack/stroke prevention, pain relief",
        side_effects: "Stomach upset, bleeding risk, easy bruising, acid reflux",
        interactions: "Increases bleeding with warfarin. NSAIDs may increase GI irritation",
        dosage: "For heart health: 75-325mg daily. For pain: 325-650mg every 4-6 hours",
        warning: "Higher bleeding risk in elderly. Not for children with viral infections"
      },
      "atorvastatin": {
        medicine: "Atorvastatin",
        uses: "High cholesterol and cardiovascular prevention",
        side_effects: "Muscle pain, liver enzyme elevation, headache, weakness",
        interactions: "Grapefruit juice increases levels. Careful with CYP3A4 metabolized drugs",
        dosage: "Usually 10-80mg daily in evening",
        warning: "Can cause muscle breakdown. Monitor liver function. Report unexplained pain"
      },
      "ibuprofen": {
        medicine: "Ibuprofen",
        uses: "Pain relief, fever reduction, inflammation",
        side_effects: "Stomach upset, heartburn, nausea, dizziness",
        interactions: "Reduces effectiveness of blood pressure meds. Increases GI bleeding risk with steroids",
        dosage: "200-400mg every 4-6 hours, max 1200mg/day",
        warning: "Avoid with kidney disease or if sensitive to NSAIDs. Take with food"
      },
      "dolo": {
        medicine: "Dolo (Paracetamol/Acetaminophen)",
        uses: "Pain relief, fever reduction, headaches, muscle aches",
        side_effects: "Rare at therapeutic doses; overdose can cause severe liver damage",
        interactions: "Caution with alcohol and other medicines containing paracetamol. May reduce warfarin effectiveness",
        dosage: "500mg tablet: 1-2 tablets every 4-6 hours, max 4000mg/day",
        warning: "Do not exceed 4000mg per day. Avoid with liver disease. Do not combine with other paracetamol-containing medicines"
      },
      "paracetamol": {
        medicine: "Paracetamol (Acetaminophen/Tylenol)",
        uses: "Pain relief, fever reduction, headaches, mild to moderate pain",
        side_effects: "Rare at therapeutic doses; overdose risk of liver damage",
        interactions: "Caution with alcohol. Check other medicines for paracetamol to avoid overdose. May reduce warfarin effectiveness",
        dosage: "500mg-1000mg every 4-6 hours, max 4000mg/day",
        warning: "Never exceed 4000mg in 24 hours. Overdose can cause severe liver damage. Avoid with liver disease or regular alcohol use"
      },
      "dapagliflozin": {
        medicine: "Dapagliflozin (Forxiga)",
        uses: "Type 2 diabetes management, heart failure, chronic kidney disease",
        side_effects: "Genital infections, urinary tract infections, low blood pressure, dehydration",
        interactions: "⚠️ DOLO (Paracetamol) + DAPAGLIFLOZIN: No major interaction. Safe to use together. Dolo can help with pain while dapagliflozin manages diabetes. Monitor for symptoms.",
        dosage: "Usually 5-10mg once daily by mouth",
        warning: "Can cause diabetic ketoacidosis. Monitor for infections. Stay hydrated. Report genital infections promptly"
      },
      "insulin": {
        medicine: "Insulin",
        uses: "Type 1 diabetes, severe Type 2 diabetes, blood sugar control",
        side_effects: "Hypoglycemia (low blood sugar), weight gain, allergic reactions",
        interactions: "Can increase hypoglycemia risk with other diabetes meds. Some medicines reduce insulin effectiveness",
        dosage: "Varies by type (Rapid, Short, Intermediate, Long-acting). Usually 10-100 units daily",
        warning: "Risk of severe hypoglycemia. Always carry fast-acting carbohydrates. Never skip insulin doses"
      },
      "amoxicillin": {
        medicine: "Amoxicillin",
        uses: "Bacterial infections (ear, throat, urinary, skin, pneumonia)",
        side_effects: "Nausea, diarrhea, rash, allergic reactions (anaphylaxis in severe cases)",
        interactions: "Reduces effectiveness of oral birth control. May interact with methotrexate. No major issue with paracetamol",
        dosage: "250-500mg every 8 hours or 500mg-875mg every 12 hours",
        warning: "Serious allergy risk if penicillin allergic. Report severe rash immediately. Complete full course"
      },
      "omeprazole": {
        medicine: "Omeprazole",
        uses: "Acid reflux (GERD), peptic ulcers, stomach protection",
        side_effects: "Headache, diarrhea, nausea, vitamin B12 deficiency with long-term use",
        interactions: "Reduces absorption of some minerals. May affect clopidogrel effectiveness. Safe with paracetamol",
        dosage: "Usually 20-40mg once daily, taken 30 minutes before breakfast",
        warning: "Long-term use may reduce bone density. Monitor B12 levels. Do not exceed recommended duration"
      },
      "metoprolol": {
        medicine: "Metoprolol",
        uses: "High blood pressure, angina, heart failure, heart attack prevention",
        side_effects: "Fatigue, dizziness, depression, sexual dysfunction, cold hands/feet",
        interactions: "NSAIDs and some decongestants may reduce effectiveness. Avoid sudden stopping",
        dosage: "Usually 25-190mg daily in divided doses",
        warning: "Do not stop abruptly - can cause dangerous blood pressure spike. May mask hypoglycemia symptoms"
      },
      "simvastatin": {
        medicine: "Simvastatin",
        uses: "High cholesterol, cardiovascular disease prevention",
        side_effects: "Muscle pain, weakness, liver enzyme elevation, potential muscle breakdown",
        interactions: "Avoid grapefruit juice. Reduces effectiveness of some medicines. Increased muscle risk with certain antibiotics",
        dosage: "Usually 5-40mg once daily in evening",
        warning: "Monitor for unexplained muscle pain or weakness. Check liver function regularly. Report persistent symptoms"
      },
      "sertraline": {
        medicine: "Sertraline (Zoloft)",
        uses: "Depression, anxiety, PTSD, OCD, panic disorder",
        side_effects: "Nausea, sexual dysfunction, insomnia, headache, weight changes",
        interactions: "Increased bleeding risk with NSAIDs and warfarin. Serotonin syndrome risk with other antidepressants",
        dosage: "Usually 50-200mg once daily",
        warning: "May increase suicide risk in young adults. Takes 4-6 weeks for full effect. Do not stop abruptly"
      },
      "amlodipine": {
        medicine: "Amlodipine",
        uses: "High blood pressure, angina (chest pain)",
        side_effects: "Headache, dizziness, flushing, ankle swelling, fatigue",
        interactions: "Can increase levels of some drugs. Grapefruit juice may increase side effects. Safe with paracetamol",
        dosage: "Usually 5-10mg once daily",
        warning: "Do not stop suddenly. May cause reflex tachycardia if dose reduced quickly. Report severe swelling"
      },
      "levothyroxine": {
        medicine: "Levothyroxine (Synthroid)",
        uses: "Hypothyroidism (low thyroid hormone), thyroid cancer treatment",
        side_effects: "Nervousness, insomnia, tremor, rapid heartbeat, weight loss",
        interactions: "Absorption reduced by calcium, iron, and antacids. Timing of doses important. Paracetamol safe to use",
        dosage: "Usually 25-200mcg once daily, taken on empty stomach",
        warning: "Take exactly as prescribed. Regular TSH monitoring required. Do not skip doses"
      }
    };
    
    // Find all mentioned medicines (for multi-drug interactions)
    const foundMedicines = [];
    for (const [med, data] of Object.entries(medicineDB)) {
      if (input.includes(med)) {
        foundMedicines.push({ name: med, data: data });
      }
    }
    
    // If asking about interaction between multiple drugs
    if (foundMedicines.length > 1 && input.includes("interaction")) {
      const med1 = foundMedicines[0].data;
      const med2 = foundMedicines[1]?.data || null;
      
      let response = `⚠️  DRUG INTERACTION CHECK\n`;
      response += `═══════════════════════════════════════════\n\n`;
      
      response += `💊 ${med1.medicine}\n`;
      response += `Uses: ${med1.uses}\n`;
      response += `Interactions: ${med1.interactions}\n\n`;
      
      if (med2) {
        response += `💊 ${med2.medicine}\n`;
        response += `Uses: ${med2.uses}\n`;
        response += `Interactions: ${med2.interactions}\n\n`;
      }
      
      response += `📌 COMBINED SAFETY NOTES:\n`;
      response += `When taking ${foundMedicines.map(m => m.data.medicine).join(" with ")}: Monitor medical status closely. Both medicines have documented information above. ALWAYS consult your pharmacist or doctor before combining medicines.\n\n`;
      
      response += `⚠️  IMPORTANT: DO NOT COMBINE MEDICINES WITHOUT PROFESSIONAL GUIDANCE. This information is educational only. Contact your pharmacist or doctor immediately before taking multiple medicines together.`;
      
      return response;
    }
    
    // Single medicine lookup
    let medicineInfo = null;
    if (foundMedicines.length > 0) {
      medicineInfo = foundMedicines[0].data;
    }
    
    if (medicineInfo) {
      let response = `💊 ${medicineInfo.medicine}\n`;
      response += `═══════════════════════════════════════════\n\n`;
      response += `📋 Uses:\n${medicineInfo.uses}\n\n`;
      response += `⏰ Dosage:\n${medicineInfo.dosage}\n\n`;
      response += `⚠️  Side Effects:\n${medicineInfo.side_effects}\n\n`;
      response += `🔗 Interactions:\n${medicineInfo.interactions}\n\n`;
      response += `🚨 Warning:\n${medicineInfo.warning}`;
      return response;
    }
    
    // Try Groq API for unknown medicines
    console.log("🔄 Medicine not found locally... Calling Groq API for unknown medicine...");
    
    const medicineQuery = input.toLowerCase();
    const groqMedicinePrompt = `RESPOND ONLY WITH MEDICINE INFORMATION - NO EXPLANATIONS OR QUESTIONS:

For ${input}, provide ONLY:
✓ Uses (indications)
✓ Dosage (typical adult)
✓ Side effects
✓ Drug interactions
✓ Warnings

Use emojis and be professional.`;

    try {
      console.log("📞 Sending medicine query to Groq API...");
      const groqResponse = await callGroqAPI(groqMedicinePrompt);
      
      if (groqResponse && groqResponse.length > 30) {
        // Clean up response to remove any echoed prompts
        let cleanedResponse = groqResponse;
        // Remove ALL types of prompt text
        cleanedResponse = cleanedResponse.replace(/RESPOND ONLY.*?:/gis, '');
        cleanedResponse = cleanedResponse.replace(/For.*?provide ONLY:/gis, '');
        cleanedResponse = cleanedResponse.replace(/provide complete medical information.*/gi, '');
        cleanedResponse = cleanedResponse.replace(/i'm searching for detailed information.*/gi, '');
        cleanedResponse = cleanedResponse.replace(/medicine information request:.*/gi, '');
        cleanedResponse = cleanedResponse.replace(/^.*?please provide.*?:/gis, '');
        
        // Remove common question patterns
        cleanedResponse = cleanedResponse.replace(/is this a generic or brand name.*/gis, '');
        cleanedResponse = cleanedResponse.replace(/what condition is it for.*/gis, '');
        
        cleanedResponse = cleanedResponse.trim();
        
        // Final check: ensure we have real content
        if (cleanedResponse.length > 30 && 
            !cleanedResponse.toLowerCase().includes('searching') && 
            !cleanedResponse.toLowerCase().includes('please provide') &&
            !cleanedResponse.toLowerCase().includes('respond only')) {
          console.log("✅ Groq API returned medicine information");
          return `💊 ${input.toUpperCase()}\n═══════════════════════════════════════════════════\n\n${cleanedResponse}`;
        }
      }
      console.log("⚠️ Groq API returned insufficient response");
    } catch (error) {
      console.log("⚠️ Groq API error: " + error.message);
    }
    
    // Fallback if both local and Groq fail
    console.log("⚠️ Could not fetch detailed medicine info. Returning generic response.");
    return `💊 MEDICINE INFORMATION REQUEST: ${input.toUpperCase()}\n═══════════════════════════════════════════════════

🔍 I'm searching for detailed information about ${input}.

📌 Common Medicines I Know About:
✓ Metformin (Diabetes)
✓ Lisinopril (Blood Pressure)
✓ Aspirin (Pain & Heart Health)
✓ Atorvastatin (Cholesterol)
✓ Ibuprofen (Pain & Inflammation)
✓ Dolo/Paracetamol (Pain & Fever)
✓ Dapagliflozin (Diabetes & Heart)
✓ Insulin (Type 1 Diabetes)
✓ Amoxicillin (Bacterial Infection)

💬 For '${input}', please provide:
• Is this a generic or brand name?
• What condition is it for?
• Any specific questions (dosage, side effects, interactions)?

⚠️ IMPORTANT REMINDER:
For accurate medicine information, consult:
• Your pharmacist
• Your doctor
• Trusted medical websites (WebMD, Mayo Clinic)
• Medicine package insert

This app provides EDUCATIONAL information only. Always get professional medical advice for your specific situation.`;
  }
  
  // ===== HEALTH CONDITION ASSESSMENT =====
  if (input.includes("diabetes") || input.includes("hypertension") || input.includes("cholesterol") || input.includes("condition")) {
    return `🏥 PROFESSIONAL MEDICAL EVALUATION REQUIRED

Your health condition requires professional assessment. Here's what you should do:

1️⃣  SCHEDULE APPOINTMENT
   • Contact your healthcare provider immediately
   • Be ready to discuss symptoms and medical history

2️⃣  GET APPROPRIATE TESTS
   • Blood tests, imaging, or other diagnostics as recommended
   • Keep records of all test results

3️⃣  FOLLOW TREATMENT PLAN
   • Take all medications as prescribed
   • Attend follow-up appointments
   • Report any side effects or concerns

4️⃣  MONITOR HEALTH METRICS
   • Keep daily records of relevant measurements
   • Track symptoms and changes
   • Share data with your doctor

5️⃣  MAINTAIN HEALTHY LIFESTYLE
   • Balanced diet, regular exercise, adequate sleep
   • Stress management and mental health support
   • Avoid harmful habits

⚠️ IMPORTANT DISCLAIMER: This app CANNOT diagnose or treat medical conditions. Only a licensed healthcare provider can diagnose conditions and prescribe treatment. 

🚨 FOR EMERGENCIES: Call emergency services (911 in US) immediately for severe symptoms.`;
  }
  
  // ===== WORKOUT/EXERCISE RECOMMENDATIONS =====
  if (input.includes("workout") || input.includes("exercise") || input.includes("fitness")) {
    return `💪 EXERCISE & FITNESS RECOMMENDATIONS

📋 WEEKLY EXERCISE GUIDELINE:
• 150 minutes of moderate cardio per week
• 2-3 strength training sessions per week
• Flexibility and balance work 2+ days per week

⚡ PRE-WORKOUT (5-10 minutes):
✓ Light cardio (walking, jogging)
✓ Dynamic stretches
✓ Joint mobility exercises

🏋️ STRENGTH TRAINING:
• 8-12 repetitions per exercise
• 3 sets per muscle group
• Rest 60-90 seconds between sets
• 2-3 days per week for best results

🧘 POST-WORKOUT (5-10 minutes):
✓ Cool down exercises
✓ Static stretching (hold 20-30 seconds)
✓ Deep breathing and relaxation

💧 HYDRATION & RECOVERY:
• Drink 17-20 oz water, 2-3 hours before exercise
• Drink 7-10 oz every 10-20 minutes during exercise
• Drink 16-24 oz per pound lost after exercise
• Get 7-9 hours of sleep for recovery

⚠️ IMPORTANT TIPS:
• Start slowly if you're sedentary
• Increase intensity gradually (no sudden jumps)
• Listen to your body and rest when needed
• Proper form is more important than heavy weights
• Consult your doctor before starting if you have health conditions

🚨 STOP EXERCISING IF YOU EXPERIENCE:
• Chest pain or pressure
• Severe shortness of breath
• Dizziness or fainting
• Severe joint pain

Always prioritize safety and consistency over intensity!`;
  }
  
  // ===== NUTRITION/DIET GUIDANCE =====
  if (input.includes("nutrition") || input.includes("diet") || input.includes("calorie")) {
    return `🥗 NUTRITION & DIET GUIDANCE

🍽️ BALANCED PLATE METHOD:
• 50% Vegetables & Fruits (colorful variety)
• 25% Whole Grains (brown rice, oats, whole wheat bread)
• 25% Protein (lean meat, fish, beans, tofu)

📊 DAILY NUTRITIONAL TARGETS:
• Calories: 2000 (varies by age, gender, activity level)
• Water: 2-3 liters (8-10 glasses per day)
• Fiber: 25-30g per day
• Protein: 0.8-1.0g per kilogram of body weight
• Healthy Fats: 20-35% of total calories

✅ NUTRITION BEST PRACTICES:
1. Eat whole foods, not processed
2. Include vegetables at every meal
3. Choose lean proteins (chicken, fish, beans)
4. Limit added sugars and salt
5. Practice portion control - use smaller plates
6. Eat slowly and chew thoroughly
7. Avoid skipping meals
8. Drink water, not sugary drinks

🥤 HEALTHY FOOD CHOICES:
PROTEIN: Chicken, fish, eggs, legumes, tofu, yogurt
CARBS: Brown rice, whole wheat bread, oats, sweet potatoes
VEGETABLES: Broccoli, spinach, carrots, tomatoes, peppers
FRUITS: Apples, bananas, berries, oranges
HEALTHY FATS: Avocados, nuts, olive oil, fatty fish

❌ FOODS TO LIMIT:
• Processed and fast foods
• Sugary drinks and desserts
• Excess salt and fried foods
• Refined carbohydrates (white bread, white rice)
• Alcohol (especially in excess)

⏰ MEAL TIMING:
• Breakfast within 2 hours of waking
• Lunch 4-5 hours after breakfast
• Dinner 4-5 hours after lunch
• Snacks if hungry between meals

💡 PORTION CONTROL TIPS:
• Use palm-sized portions for protein
• Fist-sized portions for carbs
• Thumb-sized portions for healthy fats
• Fill half your plate with vegetables

📱 TRACK YOUR INTAKE:
• Keep a food diary to understand eating patterns
• Use NutriCare to log meals and track nutrition
• Monitor how different foods make you feel

🚨 SPECIAL CONSIDERATIONS:
• Consult a dietitian for specific dietary needs
• Adjust portions based on your activity level
• Consider allergies and intolerances`;
  }
  
  // ===== SLEEP RECOMMENDATIONS =====
  if (input.includes("sleep") || input.includes("rest")) {
    return `😴 SLEEP & REST RECOMMENDATIONS

⏰ RECOMMENDED SLEEP DURATION:
• Adults: 7-9 hours per night
• Teenagers: 8-10 hours per night
• Children: 9-12 hours per night
• Consistency is more important than extra hours

🌙 SLEEP HYGIENE BEST PRACTICES:

1️⃣  MAINTAIN CONSISTENT SCHEDULE:
   • Sleep and wake at the same time daily (even weekends)
   • This helps regulate your body clock
   • Aim for consistency within 30-60 minutes

2️⃣  CREATE IDEAL SLEEP ENVIRONMENT:
   ✓ Keep bedroom COOL (65-68°F / 18-20°C)
   ✓ Make it DARK (blackout curtains, eye mask)
   ✓ Maintain QUIET (earplugs if needed)
   ✓ Use comfortable mattress and pillows
   ✓ Reserve bed for sleep only (not work/TV)

3️⃣  MANAGE SCREENS & LIGHT:
   ✓ Avoid screens 1 hour before bedtime
   ✓ Dim lights 1-2 hours before bed
   ✓ Use blue light filters on devices
   ✓ Turn off notifications during sleep

4️⃣  LIMIT CAFFEINE & FOOD:
   ✓ Avoid caffeine after 2 PM
   ✓ No large meals within 3 hours of bedtime
   ✓ No alcohol before bed (disrupts sleep quality)
   ✓ Light snack if hungry: banana, yogurt, nuts

5️⃣  EXERCISE & MOVEMENT:
   ✓ Regular exercise improves sleep quality
   ✓ Avoid vigorous exercise within 3 hours of bedtime
   ✓ Even 20-30 minutes of walking helps
   ✓ Morning sunlight exposure regulates melatonin

6️⃣  RELAXATION TECHNIQUES:
   ✓ Deep breathing: 4 counts in, 6 counts out
   ✓ Progressive muscle relaxation
   ✓ Meditation or mindfulness (10-20 minutes)
   ✓ Gentle yoga before bed
   ✓ Read a book or journal

7️⃣  IF YOU CAN'T FALL ASLEEP (After 20 minutes):
   ✓ Get up and do a quiet activity in dim light
   ✓ Return to bed only when drowsy
   ✓ Avoid clock-watching (increases anxiety)
   ✓ Try visualization or counting techniques

⚠️ SIGNS YOU NEED MORE SLEEP:
• Daytime drowsiness or fatigue
• Difficulty concentrating
• Mood changes or irritability
• Weakened immune function
• Increased appetite or weight gain
• Reduced athletic performance

💊 AVOID IF POSSIBLE:
✗ Sleeping pills (for long-term use)
✗ Alcohol as sleep aid (causes poor quality sleep)
✗ Napping (can interfere with nighttime sleep)
✗ Irregular sleep schedules

📱 TRACK YOUR SLEEP:
• Note bedtime, wake time, and how you feel
• Use sleep tracking apps for patterns
• Adjust habits based on what works for you

🚨 WHEN TO SEEK HELP:
If you consistently have trouble sleeping for 2+ weeks, consult your doctor. Conditions like sleep apnea, insomnia, or other disorders may need professional evaluation.`;
  }
  
  // ===== DEFAULT HEALTH ASSISTANT =====
  return `Hi! I'm NutriCare AI Assistant 👋

I can help you with:
✓ Analyze food nutrition content
✓ Provide medicine information (side effects, dosage, interactions)
✓ Recommend exercises for your goals
✓ Suggest meal plans
✓ Provide health guidance and resources
✓ Track health metrics

You can ask me about:
• Food nutrition (e.g., "What are the calories in chicken?")
• Medicine information (e.g., "Tell me about Metformin" or "Does Dolo interact with Dapagliflozin?")
• Workout plans (e.g., "Recommend exercises for weight loss")
• Meal suggestions (e.g., "What should I eat for a balanced diet?")
• Sleep tips (e.g., "How to improve sleep quality?")
• Health conditions (e.g., "Tips for managing diabetes")

⚠️ IMPORTANT DISCLAIMER: I AM NOT A DOCTOR. I cannot diagnose, treat, or prescribe. Always consult licensed healthcare providers for medical decisions.`;
}

async function callLocalModel(userInput) {
  try {
    const response = await fetch(LOCAL_AI_URL, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        text: userInput,
        max_new_tokens: 120,
        temperature: 0.3,
      }),
    });

    const raw = await response.text();
    if (!response.ok) {
      throw new Error(`Local model call failed: ${raw}`);
    }

    const data = JSON.parse(raw);
    return data.text || "AI response unavailable";
  } catch (error) {
    // If local model is unavailable, return null to trigger next fallback
    console.log(`⚠️  Local Model unavailable: ${error.message}`);
    return null;
  }
}

async function callHuggingFace(userInput) {
  if (!HF_TOKEN) {
    throw new Error("Missing HF_TOKEN environment variable on server");
  }

  const hfResponse = await fetch(MODEL_URL, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${HF_TOKEN}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      inputs: buildPrompt(userInput),
      parameters: {
        max_new_tokens: 100,
        temperature: 0.7,
      },
    }),
  });

  const raw = await hfResponse.text();
  console.log("HF RAW RESPONSE:", raw);

  if (!hfResponse.ok) {
    throw new Error(raw);
  }

  const data = JSON.parse(raw);
  if (Array.isArray(data) && data[0]?.generated_text) {
    return data[0].generated_text;
  }

  return "AI response unavailable";
}

app.post("/ai", async (req, res) => {
  try {
    const userInput = req.body?.text?.toString().trim();
    if (!userInput) {
      return res.status(400).json({ error: "Field 'text' is required" });
    }

    console.log(`📝 User input: "${userInput.substring(0, 50)}..."`);

    let text = null;

    // ===== FALLBACK CHAIN =====
    // Priority 1: Local Model (try first)
    if (AI_MODE === "local" || (AI_MODE !== "hf" && AI_MODE !== "groq")) {
      console.log("🔄 Fallback Chain: Trying Local Model (Priority 1)...");
      text = await callLocalModel(userInput);
      if (text) {
        console.log("✅ Success: Using Local Model response");
        return res.json({ text, source: "local" });
      }
    }

    // Priority 2: Groq API (fallback if local model fails)
    if (!text && (AI_MODE === "groq" || (AI_MODE !== "local" && AI_MODE !== "hf"))) {
      console.log("🔄 Fallback Chain: Trying Groq API (Priority 2)...");
      text = await callGroqAPI(userInput);
      if (text) {
        console.log("✅ Success: Using Groq API response");
        return res.json({ text, source: "groq" });
      }
    }

    // Priority 3: Hugging Face
    if (!text && AI_MODE === "hf") {
      console.log("🔄 Fallback Chain: Trying Hugging Face (Priority 3)...");
      text = await callHuggingFace(userInput);
      if (text && text !== "AI response unavailable") {
        console.log("✅ Success: Using Hugging Face response");
        return res.json({ text, source: "hf" });
      }
    }

    // Priority 4: Database Fallback (always available)
    if (!text && USE_FALLBACK) {
      console.log("🔄 Fallback Chain: Using Database Fallback (Priority 4)...");
      text = await callFallbackModel(userInput);
      console.log("✅ Success: Using Database Fallback response");
      return res.json({ text, source: "fallback" });
    }

    // Shouldn't reach here, but just in case
    res.json({ 
      text: "Sorry, I'm unable to process your request at the moment. Please try again later.",
      source: "none"
    });
  } catch (error) {
    console.error("❌ SERVER ERROR:", error);
    // Final fallback to database
    try {
      const text = await callFallbackModel(req.body?.text?.toString().trim() || "");
      res.json({ text, source: "fallback_error" });
    } catch (fallbackError) {
      res.status(500).json({ error: error.message || "Server error" });
    }
  }
});

// ===== NEW API ENDPOINTS FOR FOOD & MEDICINE SUGGESTIONS WITH REPORTS =====

// Food suggestion with detailed report
app.post("/api/food-report", (req, res) => {
  try {
    const { foodName } = req.body;
    if (!foodName || foodName.trim() === "") {
      return res.status(400).json({ error: "Food name is required" });
    }

    const food = dbManager.findFood(foodName.trim());
    if (!food) {
      const suggestions = dbManager.searchFoods(foodName);
      return res.json({
        status: 'not_found',
        message: `Could not find exact match for "${foodName}". Try these suggestions:`,
        suggestions: suggestions.map(f => ({ name: f.name, type: f.type, region: f.region }))
      });
    }

    const report = generateFoodReport(food);
    res.json(report);
  } catch (error) {
    console.error('Food report error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Medicine suggestion with detailed report
app.post("/api/medicine-report", (req, res) => {
  try {
    const { medicineName } = req.body;
    if (!medicineName || medicineName.trim() === "") {
      return res.status(400).json({ error: "Medicine name is required" });
    }

    const medicine = dbManager.findMedicine(medicineName.trim());
    if (!medicine) {
      const suggestions = dbManager.searchMedicines(medicineName);
      return res.json({
        status: 'not_found',
        message: `Could not find exact match for "${medicineName}". Try these suggestions:`,
        suggestions: suggestions.map(m => ({ 
          name: m.name, 
          generic: m.generic,
          type: m.type 
        }))
      });
    }

    const report = generateMedicineReport(medicine);
    res.json(report);
  } catch (error) {
    console.error('Medicine report error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Search foods
app.get("/api/foods/search", (req, res) => {
  try {
    const { query, type, region, lowCalorie, highProtein } = req.query;

    if (query) {
      const results = dbManager.searchFoods(query);
      return res.json({ success: true, foods: results });
    }

    const criteria = {
      type: type || null,
      region: region || null,
      lowCalorie: lowCalorie === 'true',
      highProtein: highProtein === 'true'
    };

    const suggestions = dbManager.suggestFoods(criteria);
    res.json({ success: true, foods: suggestions });
  } catch (error) {
    console.error('Food search error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Search medicines
app.get("/api/medicines/search", (req, res) => {
  try {
    const { query, system, availability } = req.query;

    if (query) {
      const results = dbManager.searchMedicines(query);
      return res.json({ success: true, medicines: results });
    }

    const criteria = {
      system: system || null,
      availability: availability || null
    };

    const suggestions = dbManager.suggestMedicines(criteria);
    res.json({ success: true, medicines: suggestions });
  } catch (error) {
    console.error('Medicine search error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Get intelligence summary with AI chat
app.post("/api/ai-chat-with-report", async (req, res) => {
  try {
    const { message, reportType, reportName } = req.body;

    if (!message) {
      return res.status(400).json({ error: "Message is required" });
    }

    let report = null;
    let chatResponse = message;

    // Get report if requested
    if (reportType === 'food' && reportName) {
      const food = dbManager.findFood(reportName);
      if (food) report = generateFoodReport(food);
    } else if (reportType === 'medicine' && reportName) {
      const medicine = dbManager.findMedicine(reportName);
      if (medicine) report = generateMedicineReport(medicine);
    }

    // Get AI response
    try {
      if (AI_MODE === "local") {
        chatResponse = await callLocalModel(message);
      } else if (AI_MODE === "hf") {
        chatResponse = await callHuggingFace(message);
      } else {
        chatResponse = await callFallbackModel(message);
      }
    } catch (aiError) {
      chatResponse = await callFallbackModel(message);
    }

    res.json({
      success: true,
      chat_response: chatResponse,
      report: report,
      disclaimer: "⚠️ This information is for educational purposes only. Always consult healthcare professionals."
    });
  } catch (error) {
    console.error('AI chat with report error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Analyze image using Vision Model with fallback chain
app.post("/api/analyze-image", async (req, res) => {
  try {
    const { imageData, imageType } = req.body;

    if (!imageData) {
      return res.status(400).json({ error: "Image data is required" });
    }

    // Remove data URL prefix if present
    let base64Image = imageData;
    if (imageData.includes(',')) {
      base64Image = imageData.split(',')[1];
    }

    console.log(`📸 Analyzing image (${imageType || 'image/jpeg'}, ${(base64Image.length / 1024).toFixed(2)} KB)...`);

    // Try Hugging Face Vision first
    let analysisResult = await analyzeImageWithHuggingFace(base64Image);
    
    // If document analysis fails, provide helpful guidance
    if (!analysisResult) {
      console.log("⚠️  Document analysis failed, returning guided fallback");
      analysisResult =
        "I could not fully extract text from this report image. Please upload a clearer image (good lighting, full page visible, no blur), or type key values like glucose, hemoglobin, cholesterol, BP, and medicines for analysis.";
    } else {
      // Analyze the extracted text for health insights
      try {
        console.log("🤖 Generating health insights from document...");
        const healthAnalysisResponse = await fetch(GROQ_API_URL, {
          method: "POST",
          headers: {
            "Authorization": `Bearer ${GROQ_API_KEY}`,
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            model: GROQ_TEXT_MODEL,
            messages: [
              {
                role: "system",
                content: "You are a professional health advisor and medical document analyzer. Analyze health documents and provide clear, actionable insights for patients. Always be accurate and include appropriate medical disclaimers."
              },
              {
                role: "user",
                content: `Analyze this health document content and provide insights:

---DOCUMENT CONTENT---
${analysisResult}
---END DOCUMENT---

Please provide:
1. 📋 Document Type (What type of medical document is this?)
2. 🩺 Key Findings (What are the main health indicators?)
3. 💊 Medications (Any medicines mentioned?)
4. ⚠️ Health Alerts (Any concerning results or warnings?)
5. 🎯 Recommendations (What should the user do next?)
6. 📞 Next Steps (Should they consult a doctor?)

Always be professional and include a disclaimer about consulting healthcare providers.`
              }
            ],
            temperature: 0.7,
            max_tokens: 1500,
          }),
          signal: AbortSignal.timeout(GROQ_TIMEOUT),
        }).then(r => r.json());

        if (healthAnalysisResponse.choices && healthAnalysisResponse.choices[0]?.message?.content) {
          const healthInsights = healthAnalysisResponse.choices[0].message.content;
          analysisResult = `📄 DOCUMENT ANALYSIS REPORT\n═══════════════════════════════════════════\n\n${healthInsights}\n\n⚠️ DISCLAIMER: This analysis is for informational purposes only. Always consult with a healthcare professional for medical advice.`;
          console.log("✅ Health insights generated");
        }
      } catch (groqError) {
        console.log("⚠️  Health analysis failed", groqError.message);
      }
    }

    res.json({
      success: true,
      analysis:
        analysisResult ||
        "Image received, but text extraction was limited. Please provide report details manually for analysis.",
      disclaimer: "⚠️ This AI analysis is for informational purposes only. Always consult healthcare professionals for medical advice."
    });
  } catch (error) {
    console.error('Image analysis error:', error);
    res.status(500).json({ error: error.message });
  }
});

// ===== GENERATE MEAL PLAN WITH GROQ API =====
app.post("/api/generate-meal-plan", async (req, res) => {
  try {
    const {
      conditions = "",
      allergies = "",
      preferences = "balanced",
      budget = "medium",
      calorieGoal = 2000,
      fitnessGoal = "maintain",
      age = 25,
      gender = "not_specified"
    } = req.body;

    console.log("🍽️  Generating personalized meal plan...");

    // Create a detailed prompt for Groq
    const mealPlanPrompt = `You are a professional nutritionist and meal planning expert. Generate a VERY DETAILED personalized meal plan based on the following:

**User Profile:**
- Age: ${age}
- Gender: ${gender}
- Daily Calorie Goal: ${calorieGoal} calories
- Fitness Goal: ${fitnessGoal}
- Budget: ${budget}
- Dietary Preference: ${preferences}

**Health Conditions:** ${conditions || "None specified"}
**Allergies:** ${allergies || "None"}

**CRITICAL REQUIREMENTS:**
1. Include SPECIFIC FOOD NAMES and RECIPES for EVERY meal (breakfast, lunch, dinner, snacks)
2. Each meal must have EXACT portion sizes and CALORIE counts
3. Balance macronutrients (protein, carbs, fats) for each meal
4. Stay within the calorie goal (±10%)
5. Consider all allergies and health conditions
6. Modify portions based on budget preference
7. Suggest foods that directly support the fitness goal
8. For "lose" goal: suggest low-calorie, high-protein foods
9. For "gain" goal: suggest calorie-dense, nutritious foods
10. For "maintain": suggest balanced, sustainable meals
11. Provide complete shopping list organized by food category
12. Add meal prep instructions and storage tips

**Format Your Response As:**
📋 7-DAY MEAL PLAN

**DAY 1**
🌅 Breakfast: [meal name] - [calories]kcal
[Brief description and nutrition breakdown]

[Continue for lunch, dinner, snacks, and other days...]

**SHOPPING LIST**
[Organized by category: vegetables, proteins, grains, etc.]

**MEAL PREP TIPS**
[5 practical tips]

⚠️ IMPORTANT DISCLAIMER:
This meal plan is for general health guidance. Always consult a healthcare provider before making significant dietary changes, especially if you have medical conditions.`;

    // Call Groq API with specialized parameters
    const response = await fetch(GROQ_API_URL, {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${GROQ_API_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        model: GROQ_TEXT_MODEL,
        messages: [
          {
            role: "system",
            content: "You are an expert nutritionist creating detailed, personalized meal plans. Be very specific with meal names, portion sizes, cooking methods, and nutritional values. Always prioritize health and safety. Format responses clearly with emojis and bullet points."
          },
          {
            role: "user",
            content: mealPlanPrompt
          }
        ],
        temperature: 0.8, // Slightly higher for more creative meal suggestions
        max_tokens: 3000, // Increased for comprehensive meal plan with specific foods
        top_p: 0.9,
      }),
      signal: AbortSignal.timeout(GROQ_TIMEOUT),
    });

    if (!response.ok) {
      const error = await response.text();
      console.log(`⚠️  Groq meal plan error (${response.status}): ${error}`);
      
      // Fallback: Generate structured meal plan from database with specific food suggestions
      const proteinG = Math.round(calorieGoal * 0.3 / 4);
      const carbsG = Math.round(calorieGoal * 0.5 / 4);
      const fatsG = Math.round(calorieGoal * 0.2 / 9);
      
      // Generate smart food suggestions based on fitness goal and conditions
      let breakfastSuggestions = "Oats with berries and milk (450 cal) OR Scrambled eggs with whole wheat toast (420 cal)";
      let lunchSuggestions = "Grilled chicken with brown rice and vegetables (650 cal) OR Lentil curry with roti (620 cal)";
      let dinnerSuggestions = "Baked fish with sweet potato and broccoli (550 cal) OR Chickpea salad with olive oil (580 cal)";
      let snackSuggestions = "Greek yogurt (150 cal) OR Almonds & fruits (200 cal)";
      
      if (fitnessGoal === "lose" && conditions.toLowerCase().includes("diabetes")) {
        breakfastSuggestions = "Vegetable omelette with whole wheat toast (380 cal) OR Plain yogurt with nuts (350 cal)";
        lunchSuggestions = "Grilled fish with quinoa and vegetables (550 cal) OR Mixed vegetable salad with chickpeas (480 cal)";
        dinnerSuggestions = "Steamed broccoli with lean chicken (450 cal) OR Lentil soup with spinach (420 cal)";
      }
      
      return res.json({
        success: true,
        source: "fallback",
        mealPlan: `📋 PERSONALIZED MEAL PLAN

👤 Your Profile:
• Daily Goal: ${calorieGoal} calories
• Fitness Goal: ${fitnessGoal}
${conditions ? `• Health Conditions: ${conditions}` : ''}
${allergies ? `• Allergies: ${allergies}` : ''}

📊 Recommended Macros:
• Protein: ${proteinG}g
• Carbs: ${carbsG}g
• Fats: ${fatsG}g

🍽️  DAILY MEAL STRUCTURE

🌅 Breakfast (400-500 cal):
${breakfastSuggestions}

🥗 Lunch (600-700 cal):
${lunchSuggestions}

🍲 Dinner (500-600 cal):
${dinnerSuggestions}

🥤 Snacks (200-300 cal):
${snackSuggestions}

💡 General Tips:
✓ Drink 2-3 liters of water daily
✓ Eat in small portions every 3-4 hours
✓ Avoid processed foods and excess oil
✓ Include vegetables in every meal
✓ Exercise 30 mins daily for best results

⚠️ DISCLAIMER: This is a general guideline. For personalized meal plans, ask the AI chatbot for detailed recipes and specific food combinations.`,
        disclaimer: "⚠️ Consult healthcare providers for personalized dietary guidance, especially with medical conditions."
      });
    }

    const data = await response.json();
    
    if (data.choices && data.choices[0]?.message?.content) {
      const mealPlan = data.choices[0].message.content;
      console.log("✅ Meal plan generated successfully");
      
      return res.json({
        success: true,
        source: "groq_api",
        mealPlan: mealPlan,
        userProfile: {
          calorieGoal,
          fitnessGoal,
          conditions,
          allergies
        }
      });
    }

    console.log("⚠️  No content in Groq meal plan response");
    res.status(500).json({ 
      error: "Failed to generate meal plan",
      message: "No response from AI service"
    });

  } catch (error) {
    console.error('Meal plan generation error:', error);
    res.status(500).json({ 
      error: error.message,
      message: "Failed to generate meal plan. Please try again."
    });
  }
});

// ===== COMPREHENSIVE HEALTH REPORT ANALYSIS =====
// POST /api/comprehensive-health-analysis
// Takes extracted health data and returns food, workout, dietary, and medicine recommendations
app.post('/api/comprehensive-health-analysis', async (req, res) => {
  try {
    const { extractedText, reportType } = req.body;

    if (!extractedText) {
      return res.status(400).json({ error: 'extractedText is required' });
    }

    const prompt = `You are a professional health advisor. Based on this health report data, provide comprehensive recommendations in JSON format:

HEALTH DATA:
${extractedText}

Generate a JSON response with EXACTLY this structure (no markdown, just raw JSON):
{
  "analysis": "Brief overall health assessment",
  "detectedConditions": ["condition1", "condition2"],
  "foodRecommendations": {
    "avoid": ["food1", "food2"],
    "include": ["food1", "food2"],
    "rationale": "Why these foods are recommended"
  },
  "foodDrugInteractions": [
    {"food": "food name", "medicine": "medicine name", "interaction": "what happens", "severity": "mild/moderate/severe"},
    {"food": "another food", "medicine": "another medicine", "interaction": "description", "severity": "mild/moderate/severe"}
  ],
  "workoutPlan": {
    "frequency": "times per week",
    "type": ["type1", "type2"],
    "duration": "minutes",
    "intensity": "low/moderate/high",
    "precautions": ["precaution1"]
  },
  "dietaryPlan": {
    "calories": "recommended daily calories",
    "macros": "protein/carbs/fat distribution",
    "mealFrequency": "times per day",
    "hydration": "liters per day",
    "keyPoints": ["point1", "point2"]
  },
  "medicineRecommendations": {
    "suggested": [{"name": "medicine", "dosage": "dose", "frequency": "frequency", "purpose": "why"}],
    "toAvoid": ["medicine1"],
    "interactions": "Important drug interactions to watch"
  },
  "urgentAlerts": ["alert1"],
  "followUp": "Next steps or checkups recommended"
}`;

    // Try Groq first
    let analysis = null;
    
    if (GROQ_API_KEY && AI_MODE !== 'fallback') {
      try {
        const groqResponse = await fetch(GROQ_API_URL, {
          method: "POST",
          headers: {
            "Authorization": `Bearer ${GROQ_API_KEY}`,
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            model: GROQ_TEXT_MODEL,
            messages: [
              {
                role: "system",
                content: "You are a medical analysis expert. Return ONLY valid JSON with no markdown or code blocks."
              },
              {
                role: "user",
                content: prompt
              }
            ],
            temperature: 0.7,
            max_tokens: 2048,
          }),
          signal: AbortSignal.timeout(GROQ_TIMEOUT),
        });

        if (groqResponse.ok) {
          const groqData = await groqResponse.json();
          const content = groqData.choices?.[0]?.message?.content;
          
          if (content) {
            // Parse JSON from response
            const jsonMatch = content.match(/\{[\s\S]*\}/);
            if (jsonMatch) {
              analysis = JSON.parse(jsonMatch[0]);
              console.log("✅ Groq comprehensive analysis generated");
            }
          }
        }
      } catch (groqError) {
        console.log('⚠️  Groq comprehensive analysis failed:', groqError.message);
      }
    }

    // Fallback structured analysis if Groq fails
    if (!analysis) {
      analysis = generateFallbackHealthAnalysis(extractedText);
      console.log("📋 Using fallback comprehensive health analysis");
    }

    res.json({
      success: true,
      source: analysis ? "groq_api" : "fallback",
      analysis: analysis,
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('Comprehensive health analysis error:', error);
    res.status(500).json({
      error: error.message,
      message: "Failed to analyze health data comprehensively"
    });
  }
});

// Fallback structured health analysis generator
function generateFallbackHealthAnalysis(healthData) {
  const lower = healthData.toLowerCase();

  // Detect conditions from keywords
  const conditions = [];
  if (lower.includes('glucose') || lower.includes('sugar')) conditions.push('Diabetes Risk');
  if (lower.includes('blood pressure') || lower.includes('bp ')) conditions.push('Hypertension');
  if (lower.includes('cholesterol')) conditions.push('High Cholesterol');
  if (lower.includes('hemoglobin') || lower.includes('hb ')) conditions.push('Anemia Risk');
  if (lower.includes('thyroid') || lower.includes('tsh')) conditions.push('Thyroid Disorder');
  if (lower.includes('iron')) conditions.push('Iron Deficiency');

  return {
    analysis: `Health analysis based on extracted report data. ${conditions.length > 0 ? 'Detected conditions: ' + conditions.join(', ') : 'Overall health status appears stable.'}`,
    detectedConditions: conditions.length > 0 ? conditions : ['General Health Maintenance'],
    foodRecommendations: {
      avoid: [
        'Processed foods high in sodium and sugar',
        'Deep-fried items and trans fats',
        'Excessive caffeine and alcohol',
        'Refined carbohydrates and sugary drinks'
      ],
      include: [
        'Leafy greens and colorful vegetables',
        'Lean proteins: chicken, fish, legumes',
        'Whole grains: brown rice, oats, quinoa',
        'Healthy fats: olive oil, nuts, avocados',
        'Fresh fruits: berries, citrus, melons'
      ],
      rationale: 'These foods support stable blood sugar, reduce inflammation, and provide essential vitamins and minerals for optimal health.'
    },
    foodDrugInteractions: [
      {
        food: 'Grapefruit and grapefruit juice',
        medicine: 'Blood pressure medications, cholesterol drugs',
        interaction: 'Increases drug levels in blood, potentially causing overdose effects',
        severity: 'severe'
      },
      {
        food: 'High-vitamin K foods (spinach, kale)',
        medicine: 'Warfarin (blood thinner)',
        interaction: 'Reduces medicine effectiveness, may cause blood clots',
        severity: 'severe'
      },
      {
        food: 'Calcium-rich foods and dairy',
        medicine: 'Antibiotics (tetracycline, fluoroquinolones)',
        interaction: 'Reduces antibiotic absorption, decreasing effectiveness',
        severity: 'moderate'
      },
      {
        food: 'Dairy and iron supplements',
        medicine: 'Iron supplements',
        interaction: 'Dairy reduces iron absorption by up to 40%',
        severity: 'moderate'
      },
      {
        food: 'High-fiber foods',
        medicine: 'Certain medications',
        interaction: 'May reduce absorption of some drugs',
        severity: 'mild'
      },
      {
        food: 'Caffeine',
        medicine: 'Stimulant medications',
        interaction: 'Increases side effects like tremors and anxiety',
        severity: 'moderate'
      }
    ],
    workoutPlan: {
      frequency: '4-5 times per week',
      type: ['Cardio (30-40 mins)', 'Strength training (20-30 mins)', 'Flexibility/Yoga (15-20 mins)'],
      duration: '45-60 minutes total per session',
      intensity: 'moderate',
      precautions: ['Warm up for 5-10 minutes', 'Stay hydrated', 'Cool down and stretch', 'Monitor heart rate']
    },
    dietaryPlan: {
      calories: '2000-2500 (adjust based on activity level)',
      macros: 'Protein 25%, Carbs 45%, Fats 30%',
      mealFrequency: '3 main meals + 2 healthy snacks',
      hydration: '2.5-3 liters water per day',
      keyPoints: [
        'Eat protein with each meal for satiety',
        'Time carbs around workouts',
        'Include fiber (25-30g daily)',
        'Limit sodium to 2300mg daily'
      ]
    },
    medicineRecommendations: {
      suggested: [
        { name: 'Vitamin D3', dosage: '1000-2000 IU', frequency: 'Daily', purpose: 'Bone health and immunity' },
        { name: 'Vitamin B12', dosage: '1000 mcg', frequency: 'Weekly or as advised', purpose: 'Energy and nerve health' }
      ],
      toAvoid: ['Self-medication without consultation'],
      interactions: 'Always inform doctor of all supplements and medicines. Check interactions before starting new medications.'
    },
    urgentAlerts: [
      'Consult your doctor for personalized medicine recommendations',
      'Monitor health metrics regularly',
      'Follow prescriptions exactly as advised'
    ],
    followUp: 'Schedule follow-up appointment in 2-4 weeks. Recheck blood work if values were abnormal. Contact doctor immediately if experiencing acute symptoms.'
  };
}

app.listen(5000, () => {
  console.log(`✅ AI Proxy running at http://localhost:5000`);
  console.log(`✅ AI Mode: ${AI_MODE.toUpperCase()}`);
  console.log(`🤖 Groq API: ${GROQ_API_KEY ? "✅ CONFIGURED" : "❌ NOT CONFIGURED"}`);
  console.log(`📍 Fallback Chain: Local Model → Groq API → Database`);
  console.log(`✅ Food & Medicine databases loaded (88 foods, 1500+ medicines)`);
  console.log(`📊 API Endpoints:`);
  console.log(`   POST /ai - Main AI chat endpoint (with fallback chain)`);
  console.log(`   POST /api/food-report - Get detailed food nutrition report`);
  console.log(`   POST /api/medicine-report - Get detailed medicine information report`);
  console.log(`   GET  /api/foods/search - Search foods by query or criteria`);
  console.log(`   GET  /api/medicines/search - Search medicines by query or criteria`);
  console.log(`   POST /api/ai-chat-with-report - Get AI chat with food/medicine report`);
  console.log(`\n🚀 Server ready to accept connections!`);
});
