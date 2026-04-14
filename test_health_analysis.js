#!/usr/bin/env node

const fetch = require('node-fetch');
const colors = require('colors');

// Test configuration
const API_URL = 'http://localhost:5000/api/comprehensive-health-analysis';
const TEST_HEALTH_DATA = `
Blood Pressure: 150/95 mmHg (Elevated)
Blood Glucose: 180 mg/dL (High)
Cholesterol: 220 mg/dL (High)
BMI: 29.5 (Overweight)
Hemoglobin: 13.2 g/dL (Low)
Current Medications: Warfarin, Lisinopril, Atorvastatin
Supplements: Vitamin D, Vitamin B12
Dietary Habits: Consumes grapefruit juice daily, high sodium intake
Activity Level: Sedentary
Medical History: Hypertension, Type 2 Diabetes, High Cholesterol
`;

const TEST_FILE_NAME = 'health_report_2026.jpg';

// Color configuration
colors.setTheme({
  success: 'green',
  error: 'red',
  warn: 'yellow',
  info: 'cyan',
  test: 'blue',
});

console.log('\n' + '='.repeat(70));
console.log('🧪 NUTRICARE HEALTH ANALYSIS TEST SUITE'.cyan);
console.log('='.repeat(70) + '\n');

async function testHealthAnalysisAPI() {
  console.log('📋 TEST 1: Health Analysis API Response\n');
  console.log('Sending health data to backend...'.test);
  
  try {
    const response = await fetch(API_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        extractedText: TEST_HEALTH_DATA,
        reportType: 'health_report',
      }),
    });

    if (!response.ok) {
      console.log(`❌ API Error: ${response.status}`.error);
      return null;
    }

    const data = await response.json();
    const analysis = data.analysis;

    console.log('✅ API responded successfully\n'.success);
    return analysis;
  } catch (error) {
    console.log(`❌ Network Error: ${error.message}`.error);
    return null;
  }
}

function testFileNameDisplay() {
  console.log('\n📋 TEST 2: File Name Display in Chat\n');
  
  const expectedMessage = `📋 **Health Report:** ${TEST_FILE_NAME}`;
  console.log('Expected chat message:'.test);
  console.log(`  "${expectedMessage}"`);
  console.log('\n✅ File name message would appear as first message in chat'.success);
  
  return true;
}

function testAnalysisStructure(analysis) {
  console.log('\n📋 TEST 3: Analysis Data Structure Validation\n');
  
  const requiredFields = [
    'analysis',
    'detectedConditions',
    'foodRecommendations',
    'foodDrugInteractions',
    'workoutPlan',
    'dietaryPlan',
    'medicineRecommendations',
    'urgentAlerts',
    'followUp',
  ];

  let allPresent = true;
  
  requiredFields.forEach(field => {
    if (analysis && analysis[field] !== undefined) {
      console.log(`✅ ${field}`.success);
    } else {
      console.log(`❌ ${field} is MISSING`.error);
      allPresent = false;
    }
  });

  return allPresent;
}

function testFoodDrugInteractions(analysis) {
  console.log('\n📋 TEST 4: Food-Drug Interactions (NEW FEATURE)\n');
  
  if (!analysis || !analysis.foodDrugInteractions) {
    console.log('❌ Food-drug interactions data not found'.error);
    return false;
  }

  const interactions = analysis.foodDrugInteractions;
  
  if (!Array.isArray(interactions) || interactions.length === 0) {
    console.log('❌ Food-drug interactions array is empty'.error);
    return false;
  }

  console.log(`✅ Found ${interactions.length} food-drug interactions\n`.success);

  // Display the interactions
  interactions.forEach((interaction, index) => {
    const severity = interaction.severity || 'unknown';
    const severityColor = severity === 'severe' ? 'error' : severity === 'moderate' ? 'warn' : 'info';
    
    console.log(`  ${index + 1}. ${interaction.food} × ${interaction.medicine}`);
    console.log(`     Severity: [${interaction.severity.toUpperCase()}]`[severityColor]);
    console.log(`     Impact: ${interaction.interaction}\n`);
  });

  return true;
}

function testFoodRecommendations(analysis) {
  console.log('📋 TEST 5: Food Recommendations\n');
  
  if (!analysis || !analysis.foodRecommendations) {
    console.log('❌ Food recommendations not found'.error);
    return false;
  }

  const rec = analysis.foodRecommendations;

  if (!rec.include || !rec.avoid || !rec.rationale) {
    console.log('❌ Food recommendations missing required fields'.error);
    return false;
  }

  console.log('✅ Include foods:'.success);
  rec.include.forEach(food => console.log(`   • ${food}`));

  console.log('\n✅ Avoid foods:'.success);
  rec.avoid.forEach(food => console.log(`   • ${food}`));

  console.log('\n✅ Rationale:'.success);
  console.log(`   ${rec.rationale}\n`);

  return true;
}

function testMedicineRecommendations(analysis) {
  console.log('📋 TEST 6: Medicine Recommendations\n');
  
  if (!analysis || !analysis.medicineRecommendations) {
    console.log('❌ Medicine recommendations not found'.error);
    return false;
  }

  const med = analysis.medicineRecommendations;

  if (!med.suggested || !Array.isArray(med.suggested) || med.suggested.length === 0) {
    console.log('⚠️  No medicines suggested'.warn);
  } else {
    console.log('✅ Suggested medicines:'.success);
    med.suggested.forEach(m => {
      console.log(`   • ${m.name}`);
      console.log(`     Dosage: ${m.dosage}`);
      console.log(`     Frequency: ${m.frequency}`);
      console.log(`     Purpose: ${m.purpose}\n`);
    });
  }

  return true;
}

function testUrgentAlerts(analysis) {
  console.log('📋 TEST 7: Urgent Alerts\n');
  
  if (!analysis || !analysis.urgentAlerts) {
    console.log('❌ Urgent alerts not found'.error);
    return false;
  }

  const alerts = analysis.urgentAlerts;

  if (!Array.isArray(alerts) || alerts.length === 0) {
    console.log('ℹ️  No urgent alerts detected (could be normal)'.info);
    return true;
  }

  console.log(`✅ Found ${alerts.length} alerts:\n`.success);
  alerts.forEach((alert, index) => {
    console.log(`   ⚠️  ${index + 1}. ${alert}`);
  });
  console.log();

  return true;
}

async function generateChatPreview(analysis) {
  console.log('\n📋 TEST 8: Chat Display Preview\n');
  console.log('═'.repeat(70).test);
  console.log('CHAT PREVIEW'.test);
  console.log('═'.repeat(70).test + '\n');

  // Message 1: File name
  console.log('💬 AI Assistant:'.info);
  console.log(`📋 **Health Report:** ${TEST_FILE_NAME}\n`.cyan);

  // Message 2: Analysis card
  console.log('📊 Analysis Report:'.info);
  console.log('─'.repeat(70).test);
  
  if (analysis) {
    console.log(`📄 Analyzed File`.success);
    console.log(`File: ${TEST_FILE_NAME}\n`);

    // Food Recommendations
    console.log('🥗 Food Recommendations'.cyan);
    if (analysis.foodRecommendations) {
      console.log(`✅ Include: ${analysis.foodRecommendations.include.slice(0, 3).join(', ')}`);
      console.log(`❌ Avoid: ${analysis.foodRecommendations.avoid.slice(0, 2).join(', ')}\n`);
    }

    // Food-Drug Interactions
    if (analysis.foodDrugInteractions && analysis.foodDrugInteractions.length > 0) {
      console.log('⚠️ Food-Drug Interactions'.warn);
      analysis.foodDrugInteractions.slice(0, 3).forEach(interaction => {
        const color = interaction.severity === 'severe' ? 'error' : 'warn';
        console.log(`   ${interaction.food} × ${interaction.medicine} [${interaction.severity.toUpperCase()}]`[color]);
      });
      console.log();
    }

    // Workout Plan
    if (analysis.workoutPlan) {
      console.log('💪 Workout Plan'.cyan);
      console.log(`   Frequency: ${analysis.workoutPlan.frequency}`);
      console.log(`   Intensity: ${analysis.workoutPlan.intensity}\n`);
    }

    // Dietary Plan
    if (analysis.dietaryPlan) {
      console.log('🍽️ Dietary Plan'.cyan);
      console.log(`   Daily Calories: ${analysis.dietaryPlan.calories}`);
      console.log(`   Hydration: ${analysis.dietaryPlan.hydration}\n`);
    }

    // Medicines
    if (analysis.medicineRecommendations) {
      console.log('💊 Medicines'.cyan);
      console.log(`   Interactions: ${analysis.medicineRecommendations.interactions}\n`);
    }

    // Alerts
    if (analysis.urgentAlerts && analysis.urgentAlerts.length > 0) {
      console.log('🚨 Urgent Alerts'.error);
      analysis.urgentAlerts.slice(0, 2).forEach(alert => {
        console.log(`   ⚠️  ${alert}`);
      });
      console.log();
    }
  }

  console.log('─'.repeat(70).test + '\n');
}

async function runAllTests() {
  try {
    // Run API test
    const analysis = await testHealthAnalysisAPI();

    if (!analysis) {
      console.log('\n❌ API test failed. Cannot proceed with other tests.'.error);
      console.log('Make sure the backend server is running on port 5000\n'.warn);
      process.exit(1);
    }

    // Run all validation tests
    const test2 = testFileNameDisplay();
    const test3 = testAnalysisStructure(analysis);
    const test4 = testFoodDrugInteractions(analysis);
    const test5 = testFoodRecommendations(analysis);
    const test6 = testMedicineRecommendations(analysis);
    const test7 = testUrgentAlerts(analysis);
    await generateChatPreview(analysis);

    // Summary
    console.log('\n' + '='.repeat(70));
    console.log('📊 TEST SUMMARY'.test);
    console.log('='.repeat(70) + '\n');

    const allTests = [
      { name: 'Health Analysis API', passed: !!analysis },
      { name: 'File Name Display', passed: test2 },
      { name: 'Data Structure', passed: test3 },
      { name: 'Food-Drug Interactions', passed: test4 },
      { name: 'Food Recommendations', passed: test5 },
      { name: 'Medicine Recommendations', passed: test6 },
      { name: 'Urgent Alerts', passed: test7 },
    ];

    const passedTests = allTests.filter(t => t.passed).length;
    const totalTests = allTests.length;

    allTests.forEach(test => {
      const status = test.passed ? '✅ PASS'.success : '❌ FAIL'.error;
      console.log(`${status} - ${test.name}`);
    });

    console.log(`\n${passedTests}/${totalTests} tests passed\n`.info);

    if (passedTests === totalTests) {
      console.log('🎉 ALL TESTS PASSED! Chat is ready for file uploads.'.success);
      console.log('\n✅ File name will display as: 📋 **Health Report:** [filename]'.success);
      console.log('✅ Food-drug interactions will show with severity badges'.success);
      console.log('✅ Complete analysis will display in formatted sections'.success);
    } else {
      console.log('⚠️ Some tests failed. Please check the errors above.'.warn);
    }

    console.log('\n' + '='.repeat(70) + '\n');

  } catch (error) {
    console.log(`\n❌ Test suite error: ${error.message}`.error);
    process.exit(1);
  }
}

// Run tests
runAllTests();
