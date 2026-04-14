# 🎨 ADVANCED UI/UX - QUICK REFERENCE CARD
## Copy-Paste Ready Components & Patterns
### NutriCare+ v2.0 - One-Page Implementation Guide

---

## 📋 COLORS - AT A GLANCE

```dart
// Import
import 'package:nutricare/core/design/premium_colors.dart';

// PRIMARY NEON GREEN
PremiumColors.primaryNeon           // #76FF03
PremiumColors.primaryGradient       // Multi-color gradient
PremiumColors.primaryNeonLight      // #9FFF4F
PremiumColors.primaryNeonDark       // #64DD00

// DARK BACKGROUNDS
PremiumColors.darkLuxury            // #0A0E1A (pure black)
PremiumColors.darkLuxuryLight       // #121829
PremiumColors.darkLuxuryLighter     // #1A1F2E
PremiumColors.darkLuxurySurface     // #1E232F

// ACCENT COLORS
PremiumColors.accentBlue            // #007AFF
PremiumColors.accentPurple          // #8B5CF6
PremiumColors.accentOrange          // #FF6B35
PremiumColors.accentPink            // #FF1493
PremiumColors.accentTeal            // #14B8A6

// GRADIENTS (Pre-made)
PremiumColors.primaryGradient       // Green gradient
PremiumColors.blueGradient          // Blue gradient
PremiumColors.purpleGradient        // Purple gradient
PremiumColors.orangeGradient        // Orange gradient
PremiumColors.pinkGradient          // Pink gradient
PremiumColors.tealGradient          // Teal gradient

// SEMANTIC
PremiumColors.success               // Green (#10B981)
PremiumColors.error                 // Red (#EF4444)
PremiumColors.warning               // Amber (#F59E0B)
PremiumColors.info                  // Blue (#3B82F6)

// TEXT COLORS
PremiumColors.textPrimary           // White (#FFFFFF)
PremiumColors.textSecondary         // Light gray (#B0B8CC)
PremiumColors.textTertiary          // Medium gray (#6B7280)
PremiumColors.textQuaternary        // Dark gray (#4B5563)

// GLASS EFFECTS
PremiumColors.glassLight            // 10% opacity green
PremiumColors.glassMedium           // 20% opacity white
PremiumColors.glassDark             // 30% opacity dark
```

---

## 📝 TYPOGRAPHY - AT A GLANCE

```dart
// Import
import 'package:nutricare/core/design/premium_typography.dart';

// DISPLAY (Large Page Titles)
PremiumTypography.displayLarge      // 56px, weight 800
PremiumTypography.displayMedium     // 44px, weight 700
PremiumTypography.displaySmall      // 36px, weight 700

// HEADLINES (Section Headers)
PremiumTypography.headlineLarge     // 32px, weight 700
PremiumTypography.headlineMedium    // 28px, weight 700
PremiumTypography.headlineSmall     // 24px, weight 600

// TITLES (Card Titles)
PremiumTypography.titleLarge        // 20px, weight 600
PremiumTypography.titleMedium       // 18px, weight 600
PremiumTypography.titleSmall        // 16px, weight 500

// BODY (Regular Text)
PremiumTypography.bodyLarge         // 16px, weight 400
PremiumTypography.bodyMedium        // 14px, weight 400
PremiumTypography.bodySmall         // 12px, weight 400

// LABELS (Tags, Badges)
PremiumTypography.labelLarge        // 14px, weight 600
PremiumTypography.labelMedium       // 12px, weight 600
PremiumTypography.labelSmall        // 11px, weight 600

// CUSTOM STYLES
PremiumTypography.buttonText        // Button text (16px, 600)
PremiumTypography.caption           // Small captions (10px)
PremiumTypography.overline          // Uppercase labels (12px)
PremiumTypography.errorText         // Red error text
PremiumTypography.successText       // Green success text
PremiumTypography.mutedText         // Secondary text
```

---

## 🎨 COMPONENT SNIPPETS

### 1️⃣ GLASS CARD (Basic)

```dart
import 'package:nutricare/widgets/premium_glass_card.dart';

PremiumGlassCard(
  child: Text('Your content here'),
)
```

### 2️⃣ GLASS CARD (Full Featured)

```dart
PremiumGlassCard(
  padding: const EdgeInsets.all(24),
  margin: const EdgeInsets.all(16),
  borderRadius: 24,
  blur: 20,
  backgroundColor: PremiumColors.glassLight,
  onTap: () => print('Tapped!'),
  child: Column(
    children: [
      Text('Title', style: PremiumTypography.titleLarge),
      Text('Content', style: PremiumTypography.bodyMedium),
    ],
  ),
)
```

### 3️⃣ ANIMATED GRADIENT BUTTON (Basic)

```dart
import 'package:nutricare/widgets/animated_gradient_button.dart';

AnimatedGradientButton(
  label: 'Click Me',
  onPressed: () => print('Pressed!'),
)
```

### 4️⃣ ANIMATED GRADIENT BUTTON (Full Featured)

```dart
AnimatedGradientButton(
  label: 'Start Now',
  onPressed: () {},
  gradient: PremiumColors.purpleGradient,
  icon: Icon(Icons.arrow_forward),
  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
  borderRadius: 20,
  fullWidth: true,
  isAnimated: true,
  hapticFeedback: true,
)
```

### 5️⃣ PREMIUM STATS CARD (Basic)

```dart
import 'package:nutricare/widgets/premium_stats_card.dart';

PremiumStatsCard(
  title: 'Calories',
  value: '2,350',
  unit: 'kcal',
  accentColor: PremiumColors.accentOrange,
)
```

### 6️⃣ PREMIUM STATS CARD (Full Featured)

```dart
PremiumStatsCard(
  title: 'Daily Steps',
  value: '8,234',
  unit: 'steps',
  subtitle: 'Great job today!',
  accentColor: PremiumColors.primaryNeon,
  icon: Icon(Icons.directions_walk),
  progressValue: 0.75,
  showTrend: true,
  trendValue: 12.5,
  trendLabel: 'vs yesterday',
  onTap: () => print('Card tapped!'),
)
```

### 7️⃣ SHIMMER LOADING

```dart
import 'package:nutricare/widgets/premium_shimmer.dart';

PremiumShimmer(
  enabled: isLoading,
  child: YourWidget(),
)

// OR Skeleton placeholder
PremiumShimmerCard(height: 120)

// OR Text lines
Column(
  children: [
    PremiumShimmerLine(),
    PremiumShimmerLine(width: 200),
  ],
)
```

---

## 🏗️ SCREEN LAYOUT TEMPLATE

```dart
import 'package:flutter/material.dart';
import 'package:nutricare/core/design/premium_colors.dart';
import 'package:nutricare/core/design/premium_typography.dart';
import 'package:nutricare/widgets/premium_glass_card.dart';
import 'package:nutricare/widgets/animated_gradient_button.dart';
import 'package:nutricare/widgets/premium_stats_card.dart';

class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PremiumColors.darkLuxury,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            backgroundColor: PremiumColors.darkLuxury,
            title: Text('My Screen', style: PremiumTypography.headlineSmall),
          ),
          // Content
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                PremiumGlassCard(
                  child: Text('Your content here'),
                ),
                PremiumStatsCard(
                  title: 'Metric',
                  value: '100',
                  accentColor: PremiumColors.primaryNeon,
                ),
                AnimatedGradientButton(
                  label: 'Action',
                  onPressed: () {},
                  fullWidth: true,
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 🎯 COLOR COMBINATIONS - READY TO USE

### Workout Cards
```dart
PremiumStatsCard(
  accentColor: PremiumColors.accentOrange,  // Energy
  icon: Icon(Icons.fitness_center),
)
```

### Health Cards
```dart
PremiumStatsCard(
  accentColor: PremiumColors.accentPink,    // Health
  icon: Icon(Icons.favorite),
)
```

### Hydration Cards
```dart
PremiumStatsCard(
  accentColor: PremiumColors.accentTeal,    // Water/Recovery
  icon: Icon(Icons.water_drop),
)
```

### Analytics Cards
```dart
PremiumStatsCard(
  accentColor: PremiumColors.accentBlue,    // Data/Professional
  icon: Icon(Icons.trending_up),
)
```

### Premium Cards
```dart
PremiumStatsCard(
  accentColor: PremiumColors.accentPurple,  // Luxury
  icon: Icon(Icons.star),
)
```

---

## 📱 RESPONSIVE GRID LAYOUT

```dart
SliverGrid(
  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: 180,        // Cards up to 180px wide
    mainAxisSpacing: 16,
    crossAxisSpacing: 16,
    childAspectRatio: 1,
  ),
  delegate: SliverChildBuilderDelegate(
    (context, index) => PremiumGlassCard(
      child: Center(child: Text('Card $index')),
    ),
    childCount: 6,
  ),
)
```

---

## 🔄 PAGE ROUTE ANIMATION

```dart
Navigator.of(context).push(
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => NextPage(),
    transitionsBuilder: (context, animation, _, child) {
      return FadeTransition(opacity: animation, child: child);
    },
    transitionDuration: const Duration(milliseconds: 400),
  ),
);
```

---

## 🌊 MICRO-INTERACTIONS

### Loading State
```dart
AnimatedGradientButton(
  label: isLoading ? 'Loading...' : 'Submit',
  isLoading: isLoading,
  onPressed: isLoading ? null : () => setState(() => isLoading = true),
)
```

### Icon Buttons
```dart
Container(
  decoration: BoxDecoration(
    color: PremiumColors.darkLuxuryLighter,
    borderRadius: BorderRadius.circular(12),
  ),
  child: Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Icon(Icons.menu, color: PremiumColors.primaryNeon),
      ),
    ),
  ),
)
```

### Floating Action Menu
```dart
Column(
  mainAxisSize: MainAxisSize.min,
  spacing: 12,
  children: [
    FloatingActionButton.extended(
      onPressed: () {},
      label: Text('Workout'),
      icon: Icon(Icons.fitness_center),
    ),
    FloatingActionButton.extended(
      onPressed: () {},
      label: Text('Meal'),
      icon: Icon(Icons.restaurant),
    ),
  ],
)
```

---

## ✅ QUICK IMPLEMENTATION CHECKLIST

- [ ] Import `premium_colors.dart`
- [ ] Import `premium_typography.dart`
- [ ] Import component widgets
- [ ] Set `backgroundColor: PremiumColors.darkLuxury` in Scaffold
- [ ] Replace text styles with `PremiumTypography.*`
- [ ] Replace cards with `PremiumGlassCard`
- [ ] Replace buttons with `AnimatedGradientButton`
- [ ] Replace stats display with `PremiumStatsCard`
- [ ] Test on mobile, tablet, desktop
- [ ] Run `flutter analyze` (should be clean)

---

## 🎨 FONT SETUP (One-time)

1. Download "Plus Jakarta Sans" from Google Fonts
2. Add to `pubspec.yaml`:
```yaml
flutter:
  fonts:
    - family: Plus Jakarta Sans
      fonts:
        - asset: assets/fonts/PlusJakartaSans-Regular.ttf
        - asset: assets/fonts/PlusJakartaSans-Bold.ttf
          weight: 700
```
3. Run `flutter pub get`
4. Done!

---

## 📊 COLOR PALETTE REFERENCE

```
Primary: #76FF03 (Neon Green)
Dark BG: #0A0E1A (Pure Black)
Accent 1: #007AFF (Blue)
Accent 2: #8B5CF6 (Purple)
Accent 3: #FF6B35 (Orange)
Accent 4: #FF1493 (Pink)
Accent 5: #14B8A6 (Teal)
Success: #10B981 (Green)
Error:   #EF4444 (Red)
Warning: #F59E0B (Amber)
Info:    #3B82F6 (Blue Light)
```

---

## 🚀 ONE-MINUTE START

```dart
// 1. Add imports
import 'package:nutricare/core/design/premium_colors.dart';
import 'package:nutricare/core/design/premium_typography.dart';
import 'package:nutricare/widgets/premium_glass_card.dart';
import 'package:nutricare/widgets/animated_gradient_button.dart';

// 2. Create your widget
class QuickStart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PremiumColors.darkLuxury,
      body: Column(
        children: [
          Text('Hello', style: PremiumTypography.displaySmall),
          PremiumGlassCard(
            child: Text('Content', style: PremiumTypography.bodyMedium),
          ),
          AnimatedGradientButton(
            label: 'Click',
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

// 3. Done! You have a professional UI!
```

---

## 💡 TIPS & TRICKS

### Use accent colors dynamically
```dart
final colors = PremiumColors.accentColors;  // List of 6 colors
final color = PremiumColors.accentForIndex(index);  // Get color by index
```

### Use gradients dynamically
```dart
final gradients = PremiumColors.accentGradients;  // List of 6 gradients
final gradient = PremiumColors.gradientForIndex(index);  // Get gradient by index
```

### Customize any text style
```dart
Text(
  'Hello',
  style: PremiumTypography.titleLarge.copyWith(
    color: PremiumColors.accentBlue,
    fontSize: 22,
  ),
)
```

### Responsive padding
```dart
final padding = MediaQuery.of(context).size.width > 600 ? 24.0 : 16.0;
```

---

## 🎯 COMMON PATTERNS

### Hero Section
```dart
Stack(
  children: [
    Container(height: 300, color: PremiumColors.darkLuxuryLight),
    PremiumGlassCard(child: Text('Floating Card')),
  ],
)
```

### Card List
```dart
ListView.builder(
  itemBuilder: (context, index) => PremiumGlassCard(
    margin: const EdgeInsets.all(8),
    child: ListTile(title: Text('Item $index')),
  ),
)
```

### Button Row
```dart
Row(
  spacing: 12,
  children: [
    Expanded(
      child: AnimatedGradientButton(label: 'Cancel', onPressed: () {}),
    ),
    Expanded(
      child: AnimatedGradientButton(label: 'Confirm', onPressed: () {}),
    ),
  ],
)
```

---

## 🎊 YOU'RE READY!

Everything you need is in this one page. Bookmark it! Use it as your reference while building.

**Status**: ✅ Ready to Code
**Confidence**: 💯 Battle-Tested
**Quality**: Enterprise Grade

Start with copying the "ONE-MINUTE START" section and build from there!

Good luck! 🚀

