import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

// Load comprehensive food and medicine databases
class DatabaseManager {
  constructor() {
    this.foodsDB = null;
    this.medicinesDB = null;
    this.foodIndex = new Map();
    this.medicineIndex = new Map();
    this.initialize();
  }

  initialize() {
    try {
      // Load Indian foods database
      const foodsPath = path.join(__dirname, 'training', 'indian_foods_comprehensive.json');
      if (fs.existsSync(foodsPath)) {
        const foodsFile = fs.readFileSync(foodsPath, 'utf8');
        this.foodsDB = foodsFile.split('\n')
          .filter(line => line.trim())
          .map(line => JSON.parse(line));
        
        // Create index for O(1) lookup
        this.foodsDB.forEach((food, idx) => {
          this.foodIndex.set(food.name.toLowerCase(), idx);
        });
        console.log(`✅ Loaded ${this.foodsDB.length} foods`);
      }

      // Load medicines structured database
      const medicinesPath = path.join(__dirname, 'training', 'medicines_comprehensive_structured.json');
      if (fs.existsSync(medicinesPath)) {
        const medicinesFile = fs.readFileSync(medicinesPath, 'utf8');
        const allMedicines = JSON.parse(medicinesFile);
        
        // Flatten all medicines from all categories
        this.medicinesDB = [];
        Object.keys(allMedicines).forEach(category => {
          const meds = allMedicines[category];
          if (Array.isArray(meds)) {
            this.medicinesDB.push(...meds);
          }
        });

        // Create comprehensive index
        this.medicinesDB.forEach((med, idx) => {
          if (med.name) this.medicineIndex.set(med.name.toLowerCase(), idx);
          if (med.generic) this.medicineIndex.set(med.generic.toLowerCase(), idx);
        });
        console.log(`✅ Loaded ${this.medicinesDB.length} medicines`);
      }
    } catch (error) {
      console.error('Error initializing databases:', error.message);
      this.foodsDB = [];
      this.medicinesDB = [];
    }
  }

  // Find food with detailed nutrition info
  findFood(foodName) {
    if (!foodName) return null;
    const idx = this.foodIndex.get(foodName.toLowerCase());
    return idx !== undefined ? this.foodsDB[idx] : null;
  }

  // Search foods by keyword
  searchFoods(keyword) {
    const lower = keyword.toLowerCase();
    return this.foodsDB.filter(f => 
      f.name.toLowerCase().includes(lower) || 
      f.type.toLowerCase().includes(lower) ||
      f.region.toLowerCase().includes(lower)
    ).slice(0, 5);
  }

  // Find medicine with detailed info
  findMedicine(medicineName) {
    if (!medicineName) return null;
    const idx = this.medicineIndex.get(medicineName.toLowerCase());
    return idx !== undefined ? this.medicinesDB[idx] : null;
  }

  // Search medicines by keyword
  searchMedicines(keyword) {
    const lower = keyword.toLowerCase();
    return this.medicinesDB.filter(m =>
      (m.name && m.name.toLowerCase().includes(lower)) ||
      (m.generic && m.generic.toLowerCase().includes(lower)) ||
      (m.uses && m.uses.toLowerCase().includes(lower)) ||
      (m.type && m.type.toLowerCase().includes(lower))
    ).slice(0, 5);
  }

  // Get food suggestions based on health profile
  suggestFoods(criteria) {
    let results = this.foodsDB;

    if (criteria.type) {
      results = results.filter(f => f.type.toLowerCase() === criteria.type.toLowerCase());
    }
    
    if (criteria.region) {
      results = results.filter(f => f.region.toLowerCase().includes(criteria.region.toLowerCase()));
    }

    if (criteria.lowCalorie) {
      results = results.filter(f => f.calories < 200);
    }

    if (criteria.highProtein) {
      results = results.filter(f => f.protein > 15);
    }

    if (criteria.lowSodium) {
      results = results.filter(f => f.sodium < 400);
    }

    return results.slice(0, 10);
  }

  // Get medicine suggestions by category
  suggestMedicines(criteria) {
    let results = this.medicinesDB;

    if (criteria.system) {
      const system = criteria.system.toLowerCase();
      results = results.filter(m => 
        (m.system && m.system.toLowerCase().includes(system)) ||
        (m.type && m.type.toLowerCase().includes(system))
      );
    }

    if (criteria.availability) {
      results = results.filter(m => 
        m.availability && m.availability.toLowerCase() === criteria.availability.toLowerCase()
      );
    }

    return results.slice(0, 10);
  }
}

export const dbManager = new DatabaseManager();

// Generate detailed food report
export function generateFoodReport(food) {
  if (!food) return null;

  const nutritionScore = calculateNutritionScore(food);
  
  return {
    status: 'success',
    food: {
      name: food.name,
      type: food.type,
      region: food.region,
      availability: 'Common'
    },
    nutrition_per_serving: {
      calories: food.calories,
      protein_g: food.protein,
      carbs_g: food.carbs,
      fat_g: food.fat,
      fiber_g: food.fiber,
      sugar_g: food.sugar,
      sodium_mg: food.sodium
    },
    nutrition_analysis: {
      score: nutritionScore,
      benefits: getNutritionBenefits(food),
      considerations: getNutritionConsiderations(food),
      daily_value_percent: {
        protein: Math.round((food.protein / 50) * 100),
        carbs: Math.round((food.carbs / 300) * 100),
        fat: Math.round((food.fat / 78) * 100),
        fiber: Math.round((food.fiber / 25) * 100),
        sodium: Math.round((food.sodium / 2300) * 100)
      }
    },
    dietary_recommendations: getDietaryRecommendations(food),
    medical_disclaimer: "⚠️ This information is for educational purposes only. Not a substitute for professional medical advice."
  };
}

// Generate detailed medicine report
export function generateMedicineReport(medicine) {
  if (!medicine) return null;

  return {
    status: 'success',
    medicine: {
      name: medicine.name,
      generic: medicine.generic || 'N/A',
      type: medicine.type || 'N/A',
      availability: medicine.availability || 'Consult Pharmacist'
    },
    therapeutic_info: {
      uses: medicine.uses || 'Consult healthcare provider',
      dosage: medicine.dosage || 'Follow prescription',
      side_effects: medicine.side_effects ? medicine.side_effects.split(',').map(s => s.trim()) : [],
      interactions: medicine.interactions || 'Consult pharmacist before combining medicines',
      warning: medicine.warning || 'CONSULT HEALTHCARE PROVIDER'
    },
    brand_names: medicine.brand_names || [],
    safety_information: {
      risk_level: determineMedicineRiskLevel(medicine),
      immediate_consultation_needed: requiresImmediateConsultation(medicine),
      monitoring_required: getMonitoringRequirements(medicine)
    },
    important_notes: [
      '🔴 NEVER self-medicate without consulting a healthcare professional',
      '🔴 Always inform your doctor about all medicines you are taking',
      '🔴 Report any unusual symptoms immediately',
      '🔴 Do not exceed prescribed dosage',
      '🔴 Store medicines as directed on packaging'
    ],
    medical_disclaimer: "⚠️ This information is for educational purposes only. NOT a substitute for professional medical advice. ALWAYS consult your healthcare provider."
  };
}

// Helper functions
function calculateNutritionScore(food) {
  let score = 0;
  if (food.protein > 15) score += 25;
  else if (food.protein > 10) score += 20;
  else if (food.protein > 5) score += 15;

  if (food.fiber > 5) score += 25;
  else if (food.fiber > 3) score += 20;
  else if (food.fiber > 0) score += 10;

  if (food.calories < 150) score += 20;
  else if (food.calories < 300) score += 15;
  else score += 5;

  if (food.sodium < 300) score += 15;
  else if (food.sodium < 600) score += 10;

  if (food.sugar < 5) score += 15;

  return Math.min(100, score);
}

function getNutritionBenefits(food) {
  const benefits = [];
  if (food.protein > 15) benefits.push('✅ Excellent source of protein');
  if (food.fiber > 3) benefits.push('✅ Good source of dietary fiber');
  if (food.calories < 150) benefits.push('✅ Low in calories');
  if (food.sodium < 300) benefits.push('✅ Low sodium content');
  if (food.sugar < 5) benefits.push('✅ Low in sugar');
  if (food.fat < 5) benefits.push('✅ Low in fat');
  return benefits.length > 0 ? benefits : ['✅ Part of balanced diet'];
}

function getNutritionConsiderations(food) {
  const considerations = [];
  if (food.sodium > 500) considerations.push('⚠️ Moderate to high sodium - limit if hypertensive');
  if (food.sugar > 15) considerations.push('⚠️ Contains significant sugar');
  if (food.fat > 15) considerations.push('⚠️ Higher fat content');
  if (food.calories > 350) considerations.push('⚠️ Calorie-dense - appropriate for high energy needs');
  return considerations;
}

function getDietaryRecommendations(food) {
  if (food.type.includes('legume')) return ['Good for vegetarian/vegan diets', 'Rich in plant-based protein'];
  if (food.type === 'meat') return ['Excellent protein source', 'Rich in B vitamins and iron'];
  if (food.type === 'vegetable') return ['Include daily for micronutrients', 'Low calorie, high nutrient density'];
  if (food.type === 'rice' || food.type === 'grain') return ['Good carbohydrate source', 'Serves as foundation for meals'];
  if (food.type === 'bread') return ['Carbohydrate source', 'Best in whole grain form'];
  if (food.type === 'dessert') return ['Occasional consumption recommended', 'High in sugar - limit portion'];
  return ['Include in balanced diet'];
}

function determineMedicineRiskLevel(medicine) {
  const warning = (medicine.warning || '').toLowerCase();
  if (warning.includes('emergency') || warning.includes('serious') || warning.includes('critical')) return 'HIGH';
  if (warning.includes('caution') || warning.includes('careful')) return 'MODERATE';
  return 'LOW (relatively common)';
}

function requiresImmediateConsultation(medicine) {
  const warning = (medicine.warning || '').toLowerCase();
  return warning.includes('emergency') || warning.includes('immediately') || warning.includes('urgent');
}

function getMonitoringRequirements(medicine) {
  const requirements = [];
  const warning = (medicine.warning || '').toLowerCase();
  
  if (warning.includes('kidney')) requirements.push('📋 Monitor kidney function');
  if (warning.includes('liver')) requirements.push('📋 Monitor liver function');
  if (warning.includes('blood')) requirements.push('📋 Monitor blood counts');
  if (warning.includes('pregnancy')) requirements.push('📋 Pregnancy status monitoring');
  if (warning.includes('monitoring')) requirements.push('📋 Regular medical monitoring');
  
  return requirements.length > 0 ? requirements : ['📋 Follow-up consultations as needed'];
}
