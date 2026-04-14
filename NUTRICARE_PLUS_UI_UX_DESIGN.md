# NutriCare+ Complete UI/UX Design System

**Application:** NutriCare+ - Comprehensive Health, Nutrition & Fitness Companion  
**Version:** 2.0  
**Date:** April 2026  
**Platform:** Flutter (iOS, Android, Web)

---

## Table of Contents

1. [Design System Overview](#design-system-overview)
2. [Global Layout & Navigation](#global-layout--navigation)
3. [Core Pages & Screens](#core-pages--screens)
4. [Component Library](#component-library)
5. [Interaction Patterns](#interaction-patterns)
6. [Design Improvements & Recommendations](#design-improvements--recommendations)

---

## Design System Overview

### Color Palette

#### Primary Colors
- **Neon Green (Primary):** `#76FF03` - High contrast, energetic, represents health/vitality
  - Light variant: `#9FFF4F`
  - Dark variant: `#64DD00`
- **Black (Background):** `#000000` - Deep, sophisticated, reduces eye strain
- **Dark Surface:** `#1E1E1E` - Secondary background for cards and containers

#### Accent Colors
- **AI Blue:** `#0B6E99` - Used for AI features and advanced functionality
- **Purple Gradient:** `#8B5CF6` → `#A78BFA` - Premium features, leaderboards
- **Orange/Amber:** `#FF6B35` → `#FF8C42` - Energy, activity, fitness
- **Teal:** `#14B8A6` → `#2DD4BF` - Wellness, hydration, recovery
- **Red (Error/Warning):** `#FF4B4B` - Critical interactions

#### Semantic Colors
- **Success:** `#10B981` (Green)
- **Warning:** `#F59E0B` (Amber)
- **Error:** `#FF4B4B` (Red)
- **Info:** `#0B6E99` (Blue)

### Typography System

**Font Family:** Outfit (Google Fonts), Plus Jakarta Sans (Premium variants)

#### Display Styles (Page Titles)
- **Display Large:** 56px, Weight 800, Letter-spacing -1.5px
- **Display Medium:** 44px, Weight 700, Letter-spacing -0.5px
- **Display Small:** 36px, Weight 700

#### Headline Styles (Section Headers)
- **Headline Large:** 32px, Weight 700
- **Headline Medium:** 28px, Weight 700
- **Headline Small:** 24px, Weight 600

#### Body Styles (Content)
- **Body Large:** 18px, Weight 500
- **Body Medium:** 16px, Weight 500
- **Body Small:** 14px, Weight 500

### Spacing System

| Unit | Value | Usage |
|------|-------|-------|
| xs | 4px | Minimal spacing |
| sm | 8px | Small gaps |
| md | 16px | Default padding/margin |
| lg | 24px | Large sections |
| xl | 32px | Screen margins |
| 2xl | 48px | Major sections |

### Radius System

- **Buttons:** 16px border radius
- **Cards:** 20px border radius
- **Input Fields:** 12px border radius
- **Modals:** 18px border radius

### Shadows

- **Subtle:** `blur 10px, offset 0 5px, alpha 0.05`
- **Standard:** `blur 20px, offset 0 10px, alpha 0.1`
- **Elevated:** `blur 20px, offset 0 10px, alpha 0.3`

---

## Global Layout & Navigation

### Navigation Architecture

#### Bottom Navigation Bar
Located at the bottom of the screen, always visible (white background on black content, reversed on light modes).

**Navigation Items (Left to Right):**
1. **Home** (Icon: `Icons.home_rounded`) - Primary dashboard
2. **Workout** (Icon: `Icons.fitness_center_rounded`) - Fitness tracking
3. **Food** (Icon: `Icons.restaurant_menu_rounded`) - Nutrition & meal logging
4. **Progress** (Icon: `Icons.bar_chart_rounded`) - Analytics & streaks
5. **Meds** (Icon: `Icons.medication_rounded`) - Medicine management
6. **More** (Icon: `Icons.more_horiz_rounded`) - Opens drawer menu

**Specifications:**
- Height: 64px (8px vertical padding + 48px content)
- Item spacing: Even distribution across 6 items
- Selected item: Black background, neon green text
- Unselected items: Transparent background, grey text
- Icon size: 24px
- Icon + label arrangement: Stacked vertically
- Label font size: 10px, weight 500

#### Drawer Menu

**Trigger:** "More" button on bottom nav

**Header Section:**
- Neon green background (`#76FF03`)
- User avatar (circular, 64px diameter)
- User name (18px, bold, white)
- User email (12px, grey, white)
- Height: 120px total

**Menu Items:** (List with dividers between each)
- AI Chatbot (Icons.auto_awesome)
- Health Insights (Icons.bar_chart)
- Leaderboard (Icons.emoji_events)
- Challenges (Icons.flag)
- Meal Planner (Icons.restaurant)
- Gym Locator (Icons.location_on)
- Health Reports (Icons.description)
- Social Chat (Icons.chat)
- Profile Settings (Icons.settings)
- Logout (Icons.exit_to_app)

**Item Styling:**
- 56px height each
- Left padding: 20px
- Icon: 24px, white
- Title: 16px, white weight 500
- Right arrow: grey, 24px

---

## Core Pages & Screens

### 1. Login Screen

#### Page Name & Purpose
**Login Screen** - Initial authentication entry point for new and returning users. Handles email/password login and social sign-in via Google.

#### Layout Structure (Top to Bottom)

1. **Background Gradient** (Full screen)
   - Gradient: Deep purple 400 → Deep purple 700
   - Direction: Top-left to bottom-right

2. **Header Section** (Vertical centering)
   - App logo circle: 64px diameter, white background
   - Icon inside: Restaurant menu (50px, deep purple)
   - Spacing below: 32px
   
3. **Title & Subtitle**
   - Title: "NutriCare+" (Display Large, white)
   - Subtitle: "Your Health & Fitness Companion" (Body Medium, white 90% opacity)
   - Spacing below: 48px

4. **Login Card Container**
   - Max width: 400px (responsive, takes 80% on mobile)
   - Background: White
   - Border radius: 20px
   - Elevation: 8 shadows with 20px blur
   - Padding: 24px all sides

5. **Card Content** (Within white card)
   - **Heading:** "Welcome Back" (Headline Small, dark grey, centered)
   - Spacing: 24px
   
   - **Email Input Field**
     - Label: "Email" (grey 700)
     - Type: TextFormField with emailAddress keyboard
     - Border: Underline style
     - Focus color: Deep purple
     - Height: 56px
     - Spacing below: 16px
   
   - **Password Input Field**
     - Label: "Password" (grey 700)
     - Type: Obscured text with visibility toggle
     - Icon (toggle): Eye icon, grey 600
     - Height: 56px
     - Spacing below: 12px
   
   - **Forgot Password Link**
     - Text: "Forgot Password?" (14px, deep purple)
     - Right-aligned
     - Underline on hover
     - Spacing below: 24px
   
   - **Login Button**
     - Type: ElevatedButton
     - Label: "Sign In" (16px, bold)
     - Full width
     - Height: 56px
     - Background: Deep purple
     - Text: White
     - Border radius: 12px
     - Spacing below: 16px
   
   - **Divider**
     - Text: "OR" (grey, centered)
     - Spacing: 16px top/bottom

6. **Social Sign-In Section**
   - **Google Sign-In Button**
     - Icon: Google logo (24px)
     - Label: "Sign in with Google"
     - Full width
     - Height: 56px
     - Background: Light grey (with hover lift)
     - Text: Grey 700
     - Spacing below: 12px

7. **Footer Section**
   - **Sign-Up Link**
     - Text: "Don't have an account? Sign Up" (14px)
     - "Sign Up" in deep purple, underlined
     - Centered
     - Spacing: 24px top

#### Components
- **Account Icon Badge:** 64px diameter circle, white background, centered icon
- **Text Input Fields:** Material style with bottom border, floating labels
- **Elevated Buttons:** Full-width, 56px height, smooth shadow
- **Social Button:** Icon + text, full-width layout
- **Error Display:** SnackBar at bottom with error icon and message
- **Loading Indicator:** Circular progress (appears during auth)

#### Interactions
- **Email field focus:** Border color changes to deep purple, floating label appears
- **Password visibility toggle:** Icon changes between eye/eye-off
- **Button hover:** Slight elevation increase, opacity change
- **Loading state:** Button becomes disabled, spinner appears inside
- **Error state:** Red SnackBar appears from bottom with dismiss animation
- **Navigation:** On success, user moves to MainLayout
- **Fade-in animation:** Entire card fades in on page load using `FadeTransition` with 800ms duration

#### Design Improvements
- **Recommendation 1:** Add biometric authentication option (fingerprint/face ID) for faster login
- **Recommendation 2:** Implement "Remember me" checkbox to persist user session across app restarts
- **Recommendation 3:** Add input validation hints that appear inline as user types
- **Recommendation 4:** Display password strength indicator in real-time
- **Recommendation 5:** Add app onboarding tutorial on first login with smooth animations
- **Accessibility:** Ensure sufficient contrast between purple and text; consider high-contrast mode toggle

---

### 2. Register Screen

#### Page Name & Purpose
**Register Screen** - New user account creation flow with profile setup. Collects email, password, and initial user preferences.

#### Layout Structure (Top to Bottom)

Similar to login screen with additional fields:

1. **Header Section** - Same as login (32px bottom spacing)
2. **Title:** "Create Account" (Headline Small, centered)
3. **Form Inputs** (within white card)
   - Full Name (TextFormField, 56px height, 16px margin bottom)
   - Email (TextFormField, email keyboard)
   - Password (Obscured with toggle, strength indicator below)
   - Confirm Password (Obscured, validation on change)
   - Terms checkbox (14px text + checkbox)

4. **Sign-Up Button** (Full width, 56px, deep purple)
5. **Sign-In Link** (Bottom, "Already have account? Sign In", centered)

#### Components
- **Name/Email/Password fields:** Material TextFormField with validators
- **Password Strength Indicator:** Color-coded bar (red → yellow → green)
- **Terms Checkbox:** Standard Material checkbox with link to TOS
- **Back Button:** Top-left corner (or swipe gesture)

#### Interactions
- **Password strength:** Updates in real-time as user types
- **Confirm password validation:** Shows error if doesn't match
- **Terms acceptance:** Checkbox toggles button enablement
- **Submit:** Validates all fields, shows loading state, navigates to MainLayout on success
- **Back navigation:** Returns to login screen

#### Design Improvements
- **Email verification:** Send confirmation email and verify before account activation
- **Multi-step form:** Break into 2-3 screens for better UX (personal info → password → preferences)
- **Social registration:** Offer "Sign up with Google" option
- **Onboarding flow:** After registration, guide user through profile setup

---

### 3. Home Screen

#### Page Name & Purpose
**Home Screen** - Primary dashboard showing personalized greeting, quick stats, daily summary, and quick action buttons to key features. AI onboarding tip appears first-time users.

#### Layout Structure (Top to Bottom)

1. **SafeArea with scrollable content**
2. **Header Section (20px all sides padding)**
   - **Greeting & Name Row**
     - Left side: Vertical stack
       - Greeting text: "Good Morning" (Body Medium, grey)
       - User name: "John" (Display Medium, white, bold 28px)
     - Right side: (Aligned to top-right)
       - Avatar circle: 48px
       - Background image or initials
       - Border: 2px white stroke

3. **Calendar/Date Section (16px bottom margin)**
   - Current date: "Tuesday, April 4"
   - Body Small, grey

4. **Quick Launch Section (Card-based)**
   - Title: "⚡ Quick Launch" (Headline Small)
   - 2-column grid layout (85px width each per item on mobile)
   - 6 Quick action buttons horizontal scrollable:
     - [Nutrition] (Orange icon, "Food")
     - [Medicine] (Red/Pink icon, "Meds")
     - [Fitness] (Blue icon, "Workout")
     - [Health Insights] (Green icon, "Health")
     - [Meal Planner] (Purple icon, "Planner")
     - [AI Chat] (Blue icon, "AI Chat")
   - Button specs: 
     - Size: 70x70px circle
     - Icon: 32px centered
     - Text below: 11px, weight 500
     - Background: Dark surface with border
     - Hover: Neon green border, scale up

5. **Daily Stats Cards Section (16px margin-top)**
   - Title: "📊 Today's Summary" (Headline Small)
   - Horizontal scrollable card stack
   - Each card: 160px width, 120px height, border-radius 16px
   
   **Card 1: Calories**
   - Background: Gradient orange/amber
   - Large number: "1,245 / 2,000" (28px, bold)
   - Label: "Calories" (13px, grey)
   - Progress bar: 62% filled
   
   **Card 2: Steps**
   - Background: Gradient teal
   - Number: "8,432" (28px)
   - Label: "Steps / 10,000" (13px)
   - Small icon: Footprint emoji
   
   **Card 3: Water**
   - Background: Gradient blue
   - Number: "6 / 8 L" (28px)
   - Label: "Water Intake" (13px)
   - Droplet icon

6. **Medicine Reminder Banner (if applicable)**
   - Background: Light red/pink (20% opacity red)
   - Icon: Pill icon (left side)
   - Text: "💊 Medicine reminder: Take Aspirin at 8 PM" (14px, white)
   - Right icon: Close button
   - Height: 56px
   - Border radius: 12px
   - Margin: 12px top/bottom

7. **Achievements Section (16px margin-top)**
   - Title: "🏆 Recent Achievements" (Headline Small)
   - Single horizontal scroll of achievement badges
   - Each badge: 80x80px circle
   - Icon/emoji: 40px
   - Text: 11px below
   - Examples: "Logged 7 meals", "5-day streak", "10K steps"

8. **Featured Widget: Streak View**
   - Background: Dark surface card (20px border-radius)
   - Left side: Large fire emoji "🔥" (40px)
   - Center:
     - Text: "3 Day Streak" (24px, neon green, bold)
     - Subtext: "Keep it going!" (13px, grey)
   - Right side: Green check icon or small progress ring
   - Height: 80px
   - Spacing from edge: 20px

9. **Bottom Section: Featured Articles/Tips (16px margin)**
   - Title: "💡 Wellness Tips" (Headline Small)
   - Horizontal card carousel
   - Each card: 280px width, 140px height
   - Content: Image, title (16px), snippet (12px, truncated)
   - Cards auto-scroll with indicators dots

#### Components
- **Greeting Widget:** Dynamic text based on time of day
- **Avatar Widget:** Network image or fallback initials
- **Quick Launch Buttons:** Icon + text, circular background
- **Gradient Cards:** Smooth linear gradients per category
- **Progress Bars:** Horizontal with percentage labels
- **Streak Card:** Animated fire emoji with scale animation
- **Carousel:** Horizontal scroll with snap behavior
- **Onboarding Dialog:** Material dialog with fade/scale entrance animation

#### Interactions
- **Greeting:** Changes from "Good Morning" → "Good Afternoon" → "Good Evening" based on time
- **Quick launch taps:** Navigate to respective screens with push transition
- **Card scrolling:** Smooth horizontal scroll with momentum
- **Streak card:** Tappable, goes to Progress screen
- **Medicine reminder:** Dismiss icon removes banner (persists until time passes)
- **Onboarding dialog:** Appears once on first visit (flag stored in Firestore)
  - Content: "Welcome to AI Personalization"
  - Action: "Got it" button closes dialog with scale-out animation
- **Pull-to-refresh:** Swipe down refreshes stats (future enhancement)

#### Design Improvements
- **Personalization:** Show content based on user's primary goals (fitness vs nutrition vs health)
- **AI suggestions:** Add daily recommendation card from AI based on user data
- **Weather integration:** Display weather widget, suggest outdoor activities
- **Social element:** Show friend streaks/achievements (gamification)
- **Dynamic backgrounds:** Subtle gradient background changes based on time/achievement
- **Accessibility:** Ensure emoji have alt text; support high-contrast mode
- **Notification badges:** Add red notification dots on tabs with pending actions

---

### 4. Nutrition Screen

#### Page Name & Purpose
**Nutrition Screen** - Track daily food intake, log meals with AI recognition, view macro breakdowns, manage dietary preferences and allergies.

#### Layout Structure (Top to Bottom)

1. **AppBar**
   - Title: "Nutrition" (Display Medium)
   - Background: Neon green with black text
   - Right action: Settings icon

2. **Header Section (20px padding)**
   - Date picker: "Monday, April 4" (Body Medium, clickable)
   - Selector for different dates (left/right arrows)

3. **Daily Calorie Progress Card (Primary)**
   - Background: Dark surface (20px border-radius)
   - Layout: Circular progress on left (100px diameter)
   - Progress bar: Shows consumed vs target
   - Center number: "1,245 / 2,000 cal" (24px, bold, neon green)
   - Right side:
     - "Remaining: 755 cal" (14px, grey)
     - Macro breakdown mini bars (protein, carbs, fat) - 3 horizontal bars (60px each)

4. **Macro Summary Cards (3-column grid)**
   - Card 1: Protein
     - Value: "45g / 150g" (20px, bold, colored)
     - Color: Pink/magenta
     - Icon: Muscle emoji
   - Card 2: Carbs
     - Value: "125g / 275g" (20px)
     - Color: Orange
     - Icon: Grain emoji
   - Card 3: Fat
     - Value: "35g / 65g" (20px)
     - Color: Purple
     - Icon: Droplet emoji
   - Height: 100px, border-radius: 12px

5. **Meal Logging Buttons Section (16px margin)**
   - **"📷 Scan Food" Button (Full width)**
     - Height: 56px
     - Background: Dark surface, neon green border (2px)
     - Text: "Scan Food with AI" (16px, bold, neon green)
     - Icon: Camera (24px, left-aligned)
   - Spacing: 12px
   - **"➕ Add Meal Manually" Button (Full width)**
     - Height: 56px
     - Background: Neon green
     - Text: "Add Meal Manually" (16px, bold, black)

6. **Today's Meals List**
   - Title: "📋 Meals Today" (Headline Small, 16px top margin)
   - Each meal item is a card:
     - Height: 80px
     - Background: Dark surface (12px border-radius)
     - Left section: 
       - Meal type emoji (24px)
       - Time: "09:30 AM" (12px, grey)
     - Center section (flex): 
       - Meal name: "Oatmeal with berries" (16px, bold)
       - Items count: "2 items" (12px, grey)
     - Right section:
       - Calories: "320 cal" (14px, bold)
       - Delete icon: Swipe left to show (or tap menu)
   - Empty state: "No meals logged yet. Start by scanning or adding a meal!" (centered, grey)

7. **AI Food Analysis Dialog (Modal)**
   - **Title:** "Identified: Chicken Biryani" (18px, bold)
   - **Macro breakdown table:**
     | Macro | Amount | Target |
     | Calories | 450 | 2000 |
     | Protein | 25g | 150g |
     | Carbs | 60g | 275g |
     | Fat | 12g | 65g |
   - **Food-medicine interaction warning** (if any):
     - Background: Red 20% opacity
     - Icon: Warning emoji (24px)
     - Text: "⚠️ This food may interact with Aspirin. Check with doctor." (13px)
     - Border: 1px red
   - **Allergy warning** (if applicable):
     - Yellow/orange background
     - "Contains gluten. Not suitable for your profile."
   - **Action buttons:**
     - "Cancel" (outlined, grey)
     - "Add to Log" (filled, neon green)

8. **Preferences Section (Collapsible, bottom)**
   - Title: "⚙️ Preferences" (Headline Small)
   - Items (expandable list):
     - Daily Calorie Goal: "2000 cal" (editable)
     - Allergies: "Peanuts, Shellfish" (editable, tag-based)
     - Dietary preference: "Vegetarian / Non-veg / Vegan" (dropdown)
     - Macro split: "Protein 30% / Carbs 40% / Fat 30%" (sliders)

#### Components
- **Circular Progress Indicator:** 80% filled, neon green stroke, black background
- **Food Image Capture:** Camera integration with gallery fallback
- **Macro Chart:** Horizontal stacked bar with 3 segments, color-coded
- **Meal Card:** Swipe-to-delete with trash icon reveal
- **Interaction Dialog:** Modal with dark surface background, rounded corners
- **Tag Input:** Chips-style for allergies and food items
- **Dropdown Selector:** Material dropdown for dietary preference

#### Interactions
- **Date picker:** Tap date to open calendar, left/right arrows move days
- **Scan button:** Opens camera with ImagePicker, shows loading spinner
- **Add manually:** Opens food input dialog with name field
- **Food analysis:** AI processes image, shows nutrition facts dialog
- **Allergy warnings:** Real-time check as food is added
- **Meal cards:** Tap to edit, swipe left to delete
- **Preferences expand:** Tap to show/hide, smooth height animation
- **Delete confirmation:** SnackBar with undo button appears

#### Design Improvements
- **Barcode scanning:** Add UPC barcode recognition for packaged foods
- **Recipe builder:** When adding multiple items, combine into custom recipe
- **Restaurant integration:** Suggest nearby restaurants and their menus
- **Meal history:** Show "Recent meals" for quick re-logging
- **Nutritionist notes:** Add comments/feedback on meals
- **Recipe suggestions:** AI recommends recipes based on preferences
- **Water intake tracking:** Dedicated water logging interface
- **Accessibility:** Voice input for hands-free logging; high contrast mode

---

### 5. Workout Screen

#### Page Name & Purpose
**Workout Screen** - Log and track exercise sessions, view live metrics (heart rate, calories burned), connect to health wearables, set fitness goals.

#### Layout Structure (Top to Bottom)

1. **Background & Effects**
   - Full screen gradient blur effect (iOS: BackdropFilter with ImageFilter.blur)
   - Background image: Subtle gradient black → grey 900
   - Overlay opacity: 80% black with filter

2. **Background Graph (Subtle, Low Opacity)**
   - Position: Bottom-right, 200px height, 20% opacity
   - Live graph of heart rate history (neon green line)
   - Purpose: Visual depth and data reference

3. **SafeArea Content**

4. **Header Section (Top, 24px horizontal padding)**
   - Left: Vertical stack
     - Label: "WORKOUT" (12px, grey, letter-spacing 2px)
     - Current type: "Cardio" (24px, bold, white)
   - Right: Icon buttons
     - History icon: Opens workout history
     - Watch icon: Coloration indicates connection status
     - Sync icon: Syncs with connected wearable

5. **Centered Circular Timer (Main Focus)**
   - Position: Center of screen, vertically centered
   - Circle diameter: 240px
   - Background: Dark surface with subtle gradient
   - Border: Neon green stroke (8px)
   - Center content:
     - Time: "12:34" (56px, neon green, mono-space font)
     - Status below: "Active" or "Paused" (14px, grey)
   - Animation: Slow breathing pulse effect

6. **Live Metrics Grid (Below timer, 4-column layout)**
   - Card height: 90px, border-radius: 12px
   - Each card: Colored gradient background
   
   **Metric 1: Heart Rate**
   - Value: "145 BPM" (24px, white)
   - Label: "Heart Rate" (11px, grey)
   - Icon: Heart emoji (left)
   - Background: Teal gradient
   
   **Metric 2: Calories**
   - Value: "245 cal" (24px, white)
   - Label: "Burned" (11px, grey)
   - Background: Orange gradient
   
   **Metric 3: Distance**
   - Value: "2.1 km" (24px, white)
   - Label: "Distance" (11px, grey)
   - Background: Blue gradient
   
   **Metric 4: Steps**
   - Value: "4,250" (24px, white)
   - Label: "Steps" (11px, grey)
   - Background: Purple gradient

7. **Control Buttons Section (Bottom, 3 buttons horizontal)**
   - Button layout: Flex-row with even spacing
   - **Start/Pause Button** (Center, prominent)
     - Size: 72px diameter circle
     - Background: Neon green
     - Icon: Play icon (if paused) or pause icon (if running)
     - Shadow: Elevated shadow
     - Text below: "Start" or "Pause" (12px)
   - **End Session Button** (Right)
     - Size: 56px square, border-radius 12px
     - Background: Dark surface with red border
     - Icon: Stop icon (red)
     - Tooltip: "End Workout"
   - **Reset Button** (Left)
     - Size: 56px square, border-radius 12px
     - Background: Dark surface with grey border
     - Icon: Redo icon
     - Tooltip: "Reset"

#### Components
- **Circular Progress Indicator:** Animated ring showing time/progress
- **Backdrop Filter:** Blur effect on dark background
- **Metrics Cards:** Gradient backgrounds per metric type
- **Live Graph:** Flutter chart showing real-time heart rate
- **Control Buttons:** Large tap targets, color-coded
- **Watch Connection Status:** Icon color feedback (green=connected, grey=disconnected)

#### Interactions
- **Start button:** Begins workout timer, becomes "Pause" button
- **Pause button:** Stops timer, becomes "Resume" button
- **End session:** Shows workout summary dialog, option to save or discard
- **History button:** Navigate to WorkoutHistoryScreen
- **Watch icon:** Tap to toggle connection (shows loading spinner, then status message)
- **Sync icon:** Pulls latest data from wearable device (shows progress)
- **Metrics animation:** Cards glow/pulse when values update significantly

#### Workout Summary Dialog (Post-session)
- Background: Dark surface modal
- **Header:** Workout type icon + duration
- Content:
  - Duration: "23 min 45 sec" (24px, bold)
  - Calories: "245 cal burned" (20px, neon green)
  - Distance: "2.1 km" (18px)
  - Heart rate avg: "128 BPM" (18px)
  - Step count: "4,250 steps" (18px)
- Footer buttons:
  - "Discard" (outlined, left)
  - "Save Workout" (filled, neon green, right)

#### Design Improvements
- **Form tracking:** Show reps/sets for strength training workouts
- **Music integration:** Spotify/Apple Music widget in workout
- **Friends feature:** Show friends' live workouts, compete in real-time
- **Weather display:** Show outdoor temperature and conditions
- **Post-workout recovery:** Suggest recovery exercises and stretches
- **Accessibility:** Voice cues for time intervals; large text mode
- **Vibration feedback:** Haptic feedback on button taps and milestones

---

### 6. Progress Screen & Streak Feature

#### Page Name & Purpose
**Progress Screen** - Comprehensive analytics dashboard with streak tracking, progress charts, historical data visualization, achievements and milestones.

#### Layout Structure (Top to Bottom)

1. **AppBar**
   - Title: "Your Progress" (Display Medium)
   - Right action: Add/increment button (test feature)

2. **Streak Card (Hero Feature, 20px margin)**
   - Background: Gradient based on streak level (red → orange → amber → purple)
   - Layout: 
     - Left: Large fire emoji "🔥" (48px, animated scale)
       - Animation: Subtle pulse (1 + 0.1 scale variation on repeat)
     - Center: Vertical stack
       - "3 Day Streak!" (28px, bold, gradient color like background)
       - "Keep the momentum going!" (14px, grey)
     - Border: 2px gradient color, border-radius 24px
     - Padding: 24px all sides
     - Height: 120px
   - **Streak color mapping:**
     - 1-6 days: Neon green
     - 7-13 days: Red (`#FF5722`)
     - 14-20 days: Orange (`#FF8C42`)
     - 21-29 days: Amber
     - 30+ days: Purple

3. **Streak Stats Sub-section (within card)**
   - Divider line (vertical, 40px height, grey)
   - Left stat:
     - "Current" (11px, grey, centered)
     - "3" (24px, bold, white, centered)
   - Right stat:
     - "Best" (11px, grey, centered)
     - "7" (24px, bold, amber, centered)

4. **Progress Charts Section (16px margin-top)**
   - Title: "📈 This Week's Progress" (Headline Small)
   - **Chart Container:** Dark surface card, 20px border-radius, 300px height
   - Chart library: fl_chart with custom styling
   - X-axis: Days (Mon - Sun)
   - Y-axis: Calories burned (number scale)
   - Bars: Neon green with shadow effect
   - Tapped bar: Expands to show tooltip with exact values

5. **Weekly Statistics Grid (16px margin)**
   - 4-column layout (or 2x2 on larger screens)
   - Each stat card: 80px height, border-radius 12px
   
   **Card 1: Total Calories**
   - Value: "8,456 cal" (16px, bold)
   - Label: "Total" (11px, grey)
   - Background: Orange gradient
   
   **Card 2: Workouts**
   - Value: "4" (16px, bold)
   - Label: "Workouts" (11px, grey)
   - Background: Blue gradient
   
   **Card 3: Steps**
   - Value: "52,341" (16px, bold)
   - Label: "Steps" (11px, grey)
   - Background: Teal gradient
   
   **Card 4: Water Intake**
   - Value: "42 L" (16px, bold)
   - Label: "Water" (11px, grey)
   - Background: Purple gradient

6. **Achievements Section (16px margin)**
   - Title: "🏅 Recent Achievements" (Headline Small)
   - Horizontal scrollable list of achievement badges
   - Each badge: 90x90px square, border-radius 16px, dark surface
   - Badge content:
     - Icon/emoji: 40px centered
     - Text below: Achievement name (11px, white)
   - Examples: "7-Day Streak", "10K Steps", "Logged 30 Meals"

7. **Detailed Metrics Tabs (Expandable sections)**
   - Title: "📊 Detailed Breakdown" (Headline Small, 16px margin)
   - Tab selector (buttons):
     - "Nutrition" (active)
     - "Fitness"
     - "Health"
   - **Nutrition Tab Content:**
     - Macro history chart (protein/carbs/fat stacked bars)
     - Daily average: "2,100 cal/day" (14px)
     - Trend: "↓ -200 cal from last week" (green text)
   - **Fitness Tab Content:**
     - Workout duration chart (line graph)
     - Total minutes: "245 min this week" (14px)
   - **Health Tab Content:**
     - Sleep, water, stress indicators
     - Trends and weekly comparison

#### Components
- **Animated Fire Emoji:** Scale animation using `AnimatedBuilder` + `AnimationController`
- **Circular Progress Indicator:** For achievements (optional)
- **Chart Widget:** fl_chart BarChart with custom X/Y styling
- **Streak Celebration Dialog:** Modal with emoji icon, message, action button
- **Gradient Cards:** Per-metric color schemes with shadows
- **Achievement Badge:** Icon + label, dark background, glow on hover

#### Interactions
- **Streak card:** Tappable, shows historical streak data
- **Streak celebration:** Shows motivational dialog popup when milestone reached
  - Content: Emoji icon, message (varies by streak level), "Awesome!" button
  - Animation: Scale-in with fade
- **Chart bars:** Tap to show tooltip with exact values and date
- **Achievement badges:** Tap to show details (date earned, description)
- **Tabs:** Smooth transition between different data views
- **Pull-to-refresh:** Sync latest data from Firebase

#### Design Improvements
- **Goal setting:** Allow users to set custom targets for each metric
- **Comparison view:** Week-over-week or month-over-month trends
- **Predictions:** AI predicts achievement dates based on current pace
- **Social sharing:** Share achievements with friends and on social media
- **Export data:** Generate PDF reports for sharing with doctors
- **Insights:** AI-generated insights ("You're 15% above your average this week")
- **Custom date range:** Allow viewing any date range history
- **Accessibility:** Charts should have text descriptions; support high-contrast

---

### 7. Medicine (Enhanced) Screen

#### Page Name & Purpose
**Enhanced Medicine Screen** - Track medication intake, set reminders, view medication history, log side effects, check medicine interactions.

#### Layout Structure (Top to Bottom)

1. **AppBar**
   - Title: "Medicines" (Display Medium, neon green background)
   - Right action: Add medicine button (+ icon)

2. **Today's Reminders Section (20px padding)**
   - Title: "💊 Today's Schedule" (Headline Small)
   - Reminder cards (vertical stack, 12px spacing):
     - Each reminder: 80px height, dark surface
     - Layout:
       - Left: Time in bold (14px, white)
       - Center: Medicine name + dosage (16px, neon green)
       - Right: Status badge
         - "Due" (grey background)
         - "Taken" (green background, checkmark)
         - "Missed" (red background)
     - Tappable: Tap to mark as taken or edit

3. **Add Medicine Button (Full width, 56px)**
   - Background: Neon green
   - Icon: Plus (24px, black)
   - Text: "Add New Medicine" (16px, bold, black)

4. **Current Medications List**
   - Title: "📋 Active Medications" (Headline Small, 16px margin)
   - Each medicine card: 100px height, dark surface, 12px border-radius
   - Layout:
     - Top: Medicine name (16px, bold, white)
     - Middle: Dosage + frequency (13px, grey) e.g., "500mg, 3x daily"
     - Bottom: 
       - Start date: "Started Mar 15" (11px, grey)
       - Refill date: "Refill on May 10" (11px, neon green)
   - Right side: 
     - Edit button (pencil icon)
     - Delete button (trash icon, reveals on swipe)

5. **Medicine Interactions Section (Collapsible)**
   - Title: "⚠️ Interactions & Warnings" (Headline Small, red text if warnings exist)
   - **If no interactions:** "No known interactions detected. Safe to take together." (green text, checkmark)
   - **If interactions exist:**
     - Each warning card: 90px height, orange/red background (20% opacity)
     - Icon: Warning emoji (24px)
     - Text: "Aspirin + Ibuprofen may increase bleeding risk" (12px, orange/red)
     - Advice: "Avoid taking both. Consult doctor." (11px)

6. **Side Effects Log Section (Collapsible)**
   - Title: "📝 Log Side Effects" (Headline Small)
   - Button: "Report Side Effect" (outlined, red border)
   - Recent side effects list:
     - Each entry: "Mar 28 - Headache (Mild)" (13px)
     - Status color-coded (green=mild, yellow=moderate, red=severe)

7. **Medication History (Scrollable)**
   - Title: "📅 Past Medications" (Headline Small, 16px margin)
   - List of completed medicines:
     - Medicine name (14px)
     - "Completed Mar 25" (11px, grey)
     - Duration badge: "45 days" (11px, background)

#### Components
- **Reminder Badge:** Time + status indicator
- **Medicine Card:** Icon + details with actions (edit/delete)
- **Interaction Warning:** Color-coded alert banner
- **Side Effect Selector:** Modal with severity picker (mild/moderate/severe)
- **Refill Calendar:** Visual indicator for refill dates
- **Time Picker:** For setting reminder times

#### Interactions
- **Add medicine:** Opens form dialog with name, dosage, frequency, start date, refill date
- **Mark as taken:** Tap checkbox, shows success animation/sound
- **Edit medicine:** Opens form with pre-filled values
- **Delete medicine:** Swipe left or tap delete, confirm dialog
- **Report side effect:** Opens bottom sheet with text input + severity options
- **Interactions check:** Real-time warning appears if conflicting medicines added
- **Refill reminder:** Notification sent 7 days before refill date

#### Design Improvements
- **Barcode scanning:** Scan medicine packaging for auto-fill details
- **Med history PDF:** Export medication history for doctor
- **Dosage calculator:** Calculate correct dosage based on weight/age
- **Medicine alternatives:** Suggest generic or alternative medicines
- **Pharmacy integration:** Show pharmacy locations and availability
- **Insurance info:** Display coverage and co-pays
- **Allergy alerts:** Cross-reference with known allergies
- **Accessibility:** Voice reminders; high contrast for warning colors

---

### 8. AI Chatbot Screen

#### Page Name & Purpose
**AI Chatbot Screen** - Conversational AI assistant for personalized health and nutrition advice, meal planning, workout suggestions backed by machine learning models.

#### Layout Structure (Top to Bottom)

1. **AppBar**
   - Background: AI Blue (`#0B6E99`)
   - Title: "NutriCare AI Engine" (18px, bold, white)
   - Icons (right side):
     - History icon (opens history screen)
     - Delete icon (clears chat)

2. **Chat Messages Area (Scrollable, flex 1)**
   - Background: Dark gradient
   - SafeArea container
   - Message list (reversed order, newest at bottom)
   - ScrollController with auto-scroll on new messages

   **User Message Bubble:**
   - Alignment: Right side
   - Background: Neon green
   - Text color: Black
   - Max width: 80% of screen
   - Border radius: 16px (top-left, bottom-left, bottom-right, top-right-0)
   - Padding: 12px, 16px
   - Avatar: Circular initials (left of first message only)
   - Animation: Fade-in from bottom

   **AI Message Bubble:**
   - Alignment: Left side
   - Background: Dark surface (`#1E1E1E`)
   - Text color: White
   - Max width: 85% of screen
   - Border radius: 16px (all except top-left-0)
   - Padding: 12px, 16px
   - Avatar: AI icon/logo (left)
   - Animation: Typewriter effect (character-by-character reveal)
   - **Typing indicator:** 3 animated dots when AI is responding

3. **Quick Actions Section (If first message or empty)**
   - Title: "💡 What would you like to know?" (14px, grey)
   - 4 quick message buttons (2x2 grid below):
     - "🥗 What should I eat?" → Suggests meal based on goals
     - "💪 Create workout plan" → Generates personalized routine
     - "📊 Analyze my health" → Provides health insights
     - "🎯 Set fitness goals" → Goal-setting wizard
   - Each button: Full width, 44px height, dark surface, neon green text

4. **Input Area (Fixed at bottom, above SafeArea)**
   - Background: Dark surface
   - Layout: TextFormField + send button horizontal
   - **Input field:**
     - Placeholder: "Ask me anything..." (13px, grey)
     - Min height: 44px
     - Max height: 100px (grows with text, then scrolls)
     - Border: Underline style, neon green focus
     - Padding: 12px (left), 8px (right)
     - Text style: 15px, white
   - **Send button:**
     - Icon: Send icon or arrow
     - Size: 44x44px
     - Background: Neon green
     - Icon color: Black
     - Border radius: 8px
     - Disabled state: Greyed out (no text entered)
   - **File picker button (optional):**
     - Icon: Attachment/paperclip (24px)
     - Opens file picker for health reports upload

#### Components
- **Chat Message Bubble:** Custom widget with alignment, background, radius
- **Typing Indicator:** 3 dots with scale animation
- **Typewriter Effect:** Text reveals character by character with slight delay
- **Quick Action Buttons:** Material buttons with icons
- **Input Text Field:** Material TextFormField with custom styling
- **Send Button:** Elevated button with icon
- **Avatar:** Circular container with initials or image

#### Interactions
- **Input field focus:** Border color changes to neon green, cursor appears
- **Send message:** 
  - Text submitted (Enter key or tap button)
  - Message appears in chat immediately (optimistic UI)
  - Input field clears, keyboard dismisses
  - Auto-scroll to bottom with smooth animation
  - API call to AI backend in background
- **AI response arrives:** Message appears with typewriter effect
- **Quick actions:** Tap button to auto-populate input field, auto-send
- **Clear chat:** Confirm dialog appears, clears all messages on confirm
- **History button:** Navigate to ChatHistoryScreen
- **Message long-press:** Copy button, delete button appear

#### AI Chat History Screen
- List of past conversations
- Each item: Date + first message preview (truncated)
- Tap to open conversation
- Swipe to delete
- Search bar at top

#### Design Improvements
- **Multi-turn context:** Maintain conversation history for better suggestions
- **File upload:** Upload health reports, photos, documents for analysis
- **Voice input:** Speech-to-text for hands-free input
- **Rich responses:** Format AI responses with sections, lists, links
- **Follow-up questions:** AI suggests next questions automatically
- **Citations:** Link to sources when AI provides health info
- **Ratings:** Rate helpfulness of responses to improve AI
- **Scheduling:** AI can schedule appointments, set reminders
- **Accessibility:** Screen reader support, closed captions for voice
- **Dark mode:** Already in dark mode, but ensure contrast is AA compliant

---

### 9. Leaderboard & Challenges Screen

#### Page Name & Purpose
**Leaderboard Screen** - Gamification feature showing user rankings, competitive challenges, achievements, and XP scores to drive engagement.

#### Layout Structure (Top to Bottom)

1. **SliverAppBar (Collapsible header)**
   - Expanded height: 200px
   - Background gradient: Purple (`#8B5CF6`) → Indigo (`#6366F1`)
   - Title when collapsed: "Leaderboard & Challenges" (24px, white)
   - Background content (expanded):
     - Motivational text: "🏆 Rise to the Top" (18px, white70)
     - Centered in expanded space

2. **TabBar (Below header, sticky)**
   - 3 tabs: "Weekly" | "All Time" | "My Achievements"
   - Tab color: Purple when active
   - Indicator: Purple line below active tab

3. **Tab View Content**

   **WEEKLY LEADERBOARD TAB:**
   - Heading: "🏆 Top Users This Week" (16px, bold)
   - List of ranked users (50 items max):
     - Each item: 70px height, light background for top-3
     
     **Rank 1, 2, 3 (Special styling):**
     - Left: Medal emoji (🥇, 🥈, 🥉) in colored circle (gold, silver, bronze)
     - Center: 
       - User name: "Alex Johnson" (14px, bold)
       - XP: "2,450 XP" (12px, grey)
     - Right: Trend arrow (up green or down red)
     - Background: Colored gradient (rank 1 = gold 10% opacity)
     - Border: 2px gold/silver/bronze
     
     **Rank 4+ (Standard styling):**
     - Left: Rank number in circle (grey)
     - Center: Name + XP (as above)
     - Right: Trend arrow
     - Background: Transparent
   
   **ALL TIME LEADERBOARD TAB:**
   - Similar layout to Weekly, but showing all-time rankings
   
   **MY ACHIEVEMENTS TAB:**
   - Grid of earned badges (2-column on mobile, 3+ on larger)
   - Each badge: 100x100px square, border-radius 16px, dark surface
   - Center: Icon/emoji (40px)
   - Bottom: Achievement name (11px, centered)
   - Examples:
     - "🔥 7-Day Streak"
     - "💪 100 Workouts"
     - "🥗 Logged 200+ Meals"
     - "🏃 10K Steps"
   - Tap to show details (earned date, description, progress to next tier)

#### Components
- **Medal icons:** Emoji or custom SVG
- **User avatar:** Circular image or initials
- **Ranking list item:** Flex layout with rank/name/xp/trend
- **Achievement badge:** Square with icon and label
- **Expandable header (SliverAppBar):** Collapse on scroll
- **Tab navigation:** Material TabBar with smooth transitions

#### Interactions
- **Scroll leaderboard:** Smooth scroll, header collapses
- **Rank item tap:** Navigate to user profile (future feature)
- **Achievement badge tap:** Show details modal with earned date
- **Week/All-Time tab switch:** Smooth transition, reload data
- **Refresh:** Pull-to-refresh to get latest rankings
- **Real-time updates:** Rankings update as users earn XP

#### Design Improvements
- **User profiles:** Click on user to see their stats and follow
- **Challenges integration:** Show active challenges with XP rewards
- **Seasonal leaderboards:** Monthly, seasonal, or themed competitions
- **Friend leaderboards:** Filter to show only friends
- **Global vs local:** Toggle between global and local (city/region) rankings
- **Achievement categories:** Filter achievements by type (fitness, nutrition, health)
- **Notifications:** Alert when user climbs/drops in rankings
- **Rewards system:** Unlock badges, cosmetics, or features based on XP
- **Streaming support:** Live leaderboard updates during active challenges

---

### 10. Profile & Settings Screens

#### Page Name & Purpose
**Profile Screen** - User personal information, achievements summary, quick access to profile settings and account management.

#### Layout Structure (Top to Bottom)

1. **AppBar (Transparent)**
   - Title: "My Profile" (20px, centered)
   - Back button (left)
   - Settings button (right, navigates to Settings Screen)

2. **Avatar Section (20px top margin)**
   - Circular avatar: 100px diameter
   - Background image or initials
   - Border: 3px white stroke
   - Centered

3. **Name & Email (12px margin-top)**
   - Name: "John Doe" (24px, bold, centered)
   - Email: "john@example.com" (14px, grey, centered)

4. **Stats Row (30px margin-top)**
   - 3 equal-width columns:
     - Weight: "75 kg" (20px, bold) / "Weight" label (12px, grey)
     - Height: "180 cm" (20px, bold) / "Height" label
     - Age: "28" (20px, bold) / "Age" label
   - Spacing: Even distribution

5. **Options List (30px margin)**
   - Container: Dark surface card, 20px border-radius
   - Each option: 56px height, ListTile
   - Layout:
     - Icon (24px, left)
     - Title (16px, white, flex)
     - Chevron (grey, right)
     - Divider between items
   - Menu items:
     - Edit Profile (pencil icon)
     - Health Suggestions (health icon)
     - Notifications (bell icon)
     - Privacy Policy (shield icon)
     - Help & Support (help icon)

6. **Logout Button (30px margin-top)**
   - Icon: Logout icon (24px, red)
   - Text: "Log Out" (16px, bold, red)
   - Outlined style with red border
   - Full width or center-aligned

7. **Settings Screen (Navigation target)**

   **AppBar:**
   - Title: "Settings" (Display Medium)
   - Back button

   **Content:**
   - **Account Section** (Subheading: "Account Settings")
     - Edit Email (button)
     - Change Password (button)
     - Two-factor authentication (toggle)
   
   - **Preferences Section** (Subheading: "Preferences")
     - Language (English / Spanish / French dropdown)
     - Theme (Light / Dark / System toggle)
     - Notifications (toggle)
       - Workout reminders (toggle)
       - Medicine reminders (toggle)
       - Social notifications (toggle)
   
   - **App Section** (Subheading: "About")
     - App version (text, right-aligned)
     - Check for updates (button)
     - Feedback (button, opens email)
   
   - **Danger Section** (Red text warning)
     - Delete account (button with confirmation)

#### Components
- **Avatar widget:** Network image with fallback initials
- **Stats cards:** Number + label pairs
- **Options list:** ListTile with icon/title/trailing
- **Toggles:** Material Switch for boolean settings
- **Dropdowns:** Material DropdownButton for selections
- **Buttons:** Various actions (edit, change, send)

#### Interactions
- **Avatar tap:** Open photo picker to change profile picture
- **Edit Profile:** Navigate to edit screen (form with current data pre-filled)
- **Health Suggestions:** Fetch user data, navigate to suggestions screen
- **All options:** Navigate to respective screens
- **Logout button:** Confirm dialog, then sign out and navigate to LoginScreen
- **Settings toggles:** Update preferences in real-time
- **Delete account:** Multi-step confirmation with email verification

#### Design Improvements
- **Profile picture editing:** Crop/filter options
- **Bio/about section:** Text field for personal bio
- **Social links:** Add links to social media profiles
- **Privacy controls:** Fine-grained permission settings
- **Data export:** Download personal data in CSV/JSON format
- **Account recovery:** Recovery email/phone number
- **Multi-device login:** Manage login sessions on other devices
- **Accessibility:** High contrast profile page; voice navigation support

---

### 11. Health Reports & Upload Screen

#### Page Name & Purpose
**Health Report Upload Screen** - Upload and analyze medical documents, health reports, blood tests for AI-powered health insights and recommendations.

#### Layout Structure (Top to Bottom)

1. **AppBar**
   - Title: "Health Reports" (Display Medium)

2. **Introduction Card (20px padding all)**
   - Background: Gradient blue/teal
   - Icon: Document icon (24px, top-left)
   - Title: "Upload Your Health Reports" (18px, bold, white)
   - Description: "Share your medical reports for personalized health analysis" (14px, white)

3. **Upload Area (Card, 16px margin)**
   - Background: Dark surface with dashed border (2px, neon green)
   - Border radius: 16px
   - Height: 160px
   - Content:
     - Icon: Upload cloud icon (48px, neon green)
     - Title: "Drag & Drop or Tap to Upload" (16px, white)
     - Subtitle: "PDFs, Images, or Documents" (12px, grey)
   - Tap to open file picker
   - Supports: PDF, JPG, PNG, HEIC

4. **Recent Uploads Section (16px margin)**
   - Title: "📋 Recent Reports" (Headline Small)
   - Table-like layout:
     - Column 1: File name (14px, white)
     - Column 2: Upload date (11px, grey)
     - Column 3: Status (12px, small badge)
   - Each row height: 60px
   - Status badges:
     - "Analyzing..." (orange)
     - "Analyzed" (green, checkmark)
     - "Failed" (red, error icon)

5. **Analysis Results (If document analyzed)**
   - Card: Dark surface, 20px padding
   - Title: "📊 Analysis Results" (18px, bold)
   - Sections:
     - **Key Findings:** Highlighted important data points
     - **Health Metrics:** Table with metric values and ranges
     - **AI Insights:** 3-4 bullet points from AI analysis
     - **Recommendations:** Action items based on report
   - Color coding: Green (good), yellow (caution), red (concerning)

#### Components
- **File upload zone:** Drag-drop + tap to upload
- **Loading spinner:** While analyzing
- **Status badge:** File upload status indicator
- **Analysis card:** Structured data presentation
- **Metric comparison:** Value vs. healthy range visualization

#### Interactions
- **Upload tap:** Opens FilePicker, allows selecting files
- **File select:** Shows loading spinner, uploads to server
- **Analysis complete:** Shows results card with insights
- **Report delete:** Swipe or tap menu, confirm deletion
- **Refresh:** Pull-to-refresh to check analysis status

#### Design Improvements
- **OCR processing:** Auto-extract text from images
- **Comparison history:** Show trends across multiple reports over time
- **Doctor sharing:** Securely share reports with healthcare providers
- **HL7/FHIR integration:** Import electronic health records
- **Insurance integration:** Link insurance to reports
- **Alerts system:** Notify for critical findings
- **HIPAA compliance:** Encrypt sensitive data

---

### 12. Additional Screens (Brief Overview)

#### Meal Planner Screen
- **Purpose:** Create weekly meal plans with AI suggestions
- **Layout:** Calendar view with meal slots (breakfast/lunch/dinner/snacks)
- **Features:** Drag-drop meals, auto-generate plans, nutrition summary
- **Colors:** Orange/amber gradients for food items
- **Interactions:** Tap meal to swap, tap date to select different day

#### Nearby Gyms/Gym Locator Screen
- **Purpose:** Find nearby gyms and fitness facilities using map integration
- **Layout:** Full-screen map with gym markers, bottom sheet with list
- **Features:** Filter by distance/rating/facilities, get directions
- **Placeholder:** Currently shows "Map integration requires valid API Key"
- **Plan:** Integrate Google Maps API, show directions, gym reviews

#### Challenges Screen
- **Purpose:** Display weekly/ongoing fitness and nutrition challenges
- **Layout:** 3 filter tabs (Active/Completed/Upcoming)
- **Challenge cards:** Title, description, progress bar, XP reward, difficulty badge
- **Interactions:** Tap to join, view details, log progress
- **Gamification:** XP rewards, rank progression, weekly resets

#### Social Chat Screen
- **Purpose:** Connect with fitness coaches, nutritionists, or other users
- **Layout:** Chat list view + individual chat screens
- **Features:** Message history, image sharing, call/video support
- **Plan:** Full chat implementation with real-time messaging

---

## Component Library

### Buttons

#### Elevated Button (Primary Action)
```
Size: 56px height
Background: Neon green
Text: Black, 16px bold
Border-radius: 16px
Padding: 24px horizontal, 16px vertical
Shadow: Subtle shadow
Hover/Focus: Scale up slightly, shadow increases
Disabled: Greyed out (50% opacity)
```

#### Outlined Button (Secondary)
```
Size: 56px height
Background: Transparent
Border: 2px neon green
Text: Neon green, 16px bold
Border-radius: 16px
Padding: 24px horizontal, 16px vertical
Hover: Background tints to neon green 10%
```

#### Text Button (Tertiary)
```
Background: Transparent
Text: Neon green, 16px
Padding: 12px horizontal
No minimum height
Hover: Text scales up 1.1x
```

#### Icon Button
```
Size: 48x48px (tap target)
Icon: 24px
Background: Transparent
Hover: Background tints to grey 20%
Border-radius: 12px
```

### Input Fields

#### TextFormField (Base Style)
```
Height: 56px
Background: Dark surface (1E1E1E)
Border: Bottom border (1px) in neon green when focused
Text: White, 16px
Label: Floating label, 12px
Placeholder: Grey, 14px
Padding: 12px horizontal, 12px vertical
Border-radius: 0 (underline style primary)
Focus color: Neon green
Error color: Red with error text below
```

#### Chip/Tag Input
```
Background: Neon green 20%
Border: 1px neon green
Text: White, 12px
Padding: 6px, 12px
Border-radius: 12px
X icon: 16px, right side, tap to remove
Spacing between chips: 8px
```

### Cards

#### Dark Surface Card (Standard)
```
Background: #1E1E1E
Border-radius: 20px
Padding: 20px
Box-shadow: 0 5px 10px rgba(0,0,0,0.2)
Border: 1px white, 10% opacity (optional luxury look)
Hover: Shadow increases, slight lift animation
```

#### Gradient Card (Metrics)
```
Background: Linear gradient (varies by type)
Border-radius: 16px
Padding: 16px
Min-height: 90px
Icon: Top-left or left side
Value: Large number, right-aligned
Label: Small text, bottom
```

#### Glass Card (Premium Variant)
```
Background: Dark surface with 10% white overlay
Backdrop: Blur effect (sigma 10)
Border: 1px white, 20% opacity
Border-radius: 20px
Padding: 20px
Creates frosted glass appearance
```

### Modals & Dialogs

#### Alert Dialog
```
Background: Dark surface (#1E1E1E)
Border-radius: 18px
Width: 90% of screen (max 400px on large screens)
Padding: 24px
Title: 18px bold, white
Content: 14px, white/grey
Actions: 2 buttons at bottom (left/right)
Box-shadow: Elevated shadow
Entrance: Fade-in + scale-in (Curves.easeOutBack)
```

#### Bottom Sheet Modal
```
Background: Dark surface, top border-radius 30px
Width: Full screen width
Max-height: 80% of screen
Padding: 24px
Slide up from bottom with smooth animation
Drag to dismiss from top
```

### Navigation Elements

#### Bottom Navigation Bar
- **Background:** White (reversed theme)
- **Height:** 64px with 8px padding
- **Items:** 5-6 items evenly spaced
- **Item height:** 48px
- **Icon:** 24px, color changes on selection
- **Label:** 10px, weight 500
- **Selected:** Black background, neon green icon/text
- **Unselected:** Transparent, grey icon/text

#### Drawer Menu
- **Background:** Black
- **Width:** 80% of screen (or 320px fixed)
- **Header:** 120px, neon green background
- **List items:** 56px height
- **Dividers:** Grey, 1px between items
- **Exit behavior:** Slide out (drawer animation)

---

## Interaction Patterns

### Page Transitions
- **Default:** Push transition (slides in from right on mobile)
- **Home to secondary screens:** Smooth page transition with slight fade
- **Modal dialogs:** Fade-in with scale animation (0.92 → 1.0 scale)
- **Bottom sheets:** Slide-up animation with over-scroll bounce effect

### Loading States
- **Global:** Center circular progress indicator
- **Button:** Spinner inside button, text becomes loading state
- **List:** Skeleton loading shimmers while fetching data
- **Chart:** Animated placeholder bars

### Empty States
- **Large icon:** 64px centered
- **Message:** "No data yet. Start by..." (14px, grey, centered)
- **CTA button:** Prompt user to take action

### Error States
- **SnackBar:** Bottom-sliding bar with error icon + message
- **Duration:** 3-5 seconds auto-dismiss
- **Action:** Undo/Retry button (right side)
- **Color:** Dark red background, white text

### Success States
- **SnackBar:** Green background, checkmark icon
- **Celebration:** For major achievements (modal with emoji + message)
- **Duration:** 2 seconds auto-dismiss

### Pull-to-Refresh Pattern
- **Gesture:** Drag down from top
- **Indicator:** Circular progress that rotates as you pull
- **Release:** Loads data, progress continues until complete
- **Duration:** Smooth 300ms animation on data arrival

### Swipe Interactions
- **Swipe left on list item:** Reveals delete/edit button
- **Swipe right on chat:** Close keyboard, back gesture
- **Vertical swipe:** Dismiss modals or bottom sheets

### Haptic Feedback
- **Button tap:** Light vibration (20ms)
- **Success action:** Success vibration pattern
- **Streak milestone:** Heavy vibration
- **Warnings:** Rhythmic vibrational pulses

---

## Design Improvements & Recommendations

### Accessibility Enhancements

#### Color Contrast
- ✅ **Current:** Neon green (#76FF03) on black has high contrast (8.59:1 ratio)
- ✅ **Recommendation:** Maintain this scheme; ensure all text meets AA standard (4.5:1)
- ⚠️ **Issue:** Some secondary greys may need improvement (dark grey on black)
- **Action:** Test with WCAG contrast checker; adjust grey palette to darker greys (e.g., #A0A0A0)

#### Typography Accessibility
- ✅ **Current:** Large, clear sans-serif font (Outfit)
- ✅ **Recommendation:** Provide text size scaling (14px-20px range in settings)
- **Action:** Implement MediaQuery.textScaleFactorOf() for dynamic text sizes

#### Touch Targets
- ✅ **Current:** 48-56px buttons meet accessibility standards
- ✅ **Recommendation:** Maintain minimum 48px tap targets throughout
- ⚠️ **Issue:** Small icons in navigation may be hard to tap (solution: increase hit area)

#### Screen Reader Support
- ✅ **Recommendation:** Add semantic labels to all icons using Semantics widget
- **Action:** Add altText to images, meaningful label to buttons

#### Dark Mode & High Contrast
- ✅ **Current:** Fully dark theme implemented
- ✅ **Recommendation:** Provide high-contrast mode toggle in settings
- **Action:** Create alternate color palette (higher contrast greys, white text)

---

### Visual Hierarchy Improvements

#### Current Strengths
- ✅ Clear primary/secondary/tertiary button distinction
- ✅ Consistent spacing using 4px/8px grid
- ✅ Neon green effectively highlights important CTAs
- ✅ Dark background reduces cognitive load

#### Recommended Enhancements

1. **Typography Hierarchy**
   - Increase letter-spacing on headlines for elegance
   - Use weight 800 for hero titles, 700 for headers, 500 for body
   - Implement line-height: 1.4-1.6 for readability

2. **Visual Weight Distribution**
   - Primary action (neon green): 100% opacity, bold
   - Secondary action (outline): 60% opacity
   - Tertiary action (text): 40% opacity
   - Disabled: 30% opacity

3. **Spacing Consistency**
   - **Compact:** 8px padding (between elements)
   - **Standard:** 16px padding (cards, sections)
   - **Generous:** 24px padding (page margins)
   - **Breathing room:** 32px+ between major sections

4. **Card Hierarchy**
   - **Primary cards:** Full size, prominent shadows, neon green accents
   - **Secondary cards:** Smaller, subtle shadows, grey accents
   - **Background cards:** Very subtle, minimal contrast

---

### Micro-interactions & Animations

#### Current Implementations
- ✅ Fade-in on login form (800ms)
- ✅ Streak card fire emoji pulse (1500ms repeat)
- ✅ Circular timer breathing effect

#### Recommended Additions

1. **Button Interactions**
   - Tap: Scale 0.98 → 1.0 (200ms) + shadow increase
   - Long-press: Opacity fade over 500ms
   - Disabled: Subtle greyscale filter

2. **Navigation Transitions**
   - Page enter: Slide from right + fade (300ms, Curves.easeOut)
   - Page exit: Slide to left + fade (200ms)
   - Modal: Zoom 0.92 → 1.0 + fade (280ms, Curves.easeOutBack)

3. **List Animations**
   - Item enter: Staggered fade-in (each item +50ms offset)
   - Item delete: Swipe-out to left (200ms)
   - Item update: Quick pulse highlight (yellow flash, 400ms)

4. **Data Updates**
   - Chart refresh: Smooth line redraw (800ms)
   - Score change: Number count-up animation (500ms)
   - Progress bar: Smooth width transition (600ms)

5. **Loading States**
   - Shimmer effect: Gradient sweep left-to-right (1000ms repeat)
   - Skeleton screens: Rounded rectangles where content loads
   - Spinner: Continuous rotation (1200ms per rotation)

---

### Responsive Design Strategy

#### Breakpoints

| Device | Width | Columns | Side padding |
|--------|-------|---------|--------------|
| Mobile | <600px | 1 | 20px |
| Tablet | 600-900px | 2 | 24px |
| Desktop | >900px | 3-4 | 32px |

#### Layout Adaptations

**Mobile (< 600px)**
- Single column layouts
- Full-width buttons and cards
- Bottom navigation for primary nav
- Side drawer for secondary menu

**Tablet (600-900px)**
- 2-column layouts where applicable
- Wider cards on progress/analytics screens
- Landscape: Side-by-side navigation and content
- Larger touch targets (56px buttons)

**Desktop (> 900px)**
- Multi-column dashboards (3-4 columns)
- Side navigation panel (optional)
- Wider cards and expanded tables
- Keyboard shortcuts for power users

#### Specific Screen Adaptations

**Home Screen:**
- Mobile: Vertical stack of quick launchers
- Tablet: 2x3 grid of quick launchers
- Desktop: 3x2 grid with larger cards

**Progress Screen:**
- Mobile: Stacked charts (vertical)
- Tablet: 2-column (streak + chart)
- Desktop: All metrics visible at once

**Leaderboard:**
- Mobile: List view, scrollable
- Tablet/Desktop: Table view with columns

---

### Performance & Loading Optimization

#### Recommendation 1: Lazy Loading
- Images in carousel: Load only visible + 1 adjacent
- Lists: Virtualized list for 100+ items
- Charts: Render simplified version until data loads

#### Recommendation 2: Skeleton Screens
- Show placeholder content while loading
- Use ShimmerEffect for visual feedback
- Replace with real content on completion

#### Recommendation 3: Progressive Data Loading
- Load critical data first (streaks, today's summary)
- Load secondary data in background (history, charts)
- Offline support: Show cached data if network unavailable

#### Recommendation 4: Image Optimization
- WEBP format for web
- Multiple resolutions for responsive images
- Progressive JPEG loading (bottom-up)

#### Recommendation 5: Network Efficiency
- Batch API calls where possible
- Implement request debouncing (typing input)
- Cache responses with TTL (time-to-live)

---

### Usability Enhancements

#### Recommendation 1: Onboarding & Guidance
- **First visit:** Multi-step tutorial (4-5 screens)
- **Feature discovery:** Tooltips on new features
- **Contextual help:** Question mark icons with explanations
- **Video guides:** Optional tutorial videos for complex features

#### Recommendation 2: Input Validation & Feedback
- **Real-time validation:** Show errors as user types
- **Helpful messages:** "Email is invalid. Please use name@example.com"
- **Success confirmation:** Green checkmark when field is valid
- **Smart suggestions:** "Did you mean: alex@gmail.com?" (for typos)

#### Recommendation 3: Confirmation & Safety
- **Destructive actions:** Require confirmation dialog
- **Accidental deletions:** Undo option with 5-second window
- **Incomplete forms:** Warn before leaving unsaved changes
- **Data sync:** Visual indicator when changes are saved

#### Recommendation 4: Error Recovery
- **Retry mechanism:** Failed actions get retry button
- **Fallback UI:** If feature unavailable, show helpful message
- **Clear error messages:** "Network error. Please check your connection and try again."
- **Support links:** "Still having trouble? Contact support" link in errors

#### Recommendation 5: User Guidance & Hints
- **Empty states:** Provide next steps (e.g., "Add your first meal")
- **Progress hints:** "Logging 3 more meals will complete this challenge"
- **Time-sensitive alerts:** "You have 2 hours to log your medicine"
- **Motivational messages:** Varies by current streak/progress

---

### Modern UI/UX Patterns

#### Recommendation 1: Glassmorphism
- Use for premium widgets and overlays
- Frosted glass effect with 10% white overlay + blur
- Apply to: Achievement badges, premium stats cards, modals
- Maintains dark theme while adding depth

#### Recommendation 2: Neumorphism (Subtle)
- Soft shadows for subtle background elevation
- Inset shadows for depressed button state
- Apply sparingly to avoid visual clutter
- Works well on: Input fields, toggle switches

#### Recommendation 3: Gradient Overlays
- Horizontal gradients on cards (subtle direction)
- Radial gradients for backgrounds (depth)
- Gradient buttons for CTAs (neon green base + lighter variant)
- Animated gradients for live data (smooth color transitions)

#### Recommendation 4: Micro-animations
- Button ripple effect on tap (Material Design)
- Icon rotation on state change (e.g., arrow animation)
- Number count-up animation for scores
- Smooth transitions for all state changes

#### Recommendation 5: Data Visualization
- Use smooth curves in charts (not sharp lines)
- Gradient fills under line charts
- Animated bar charts (grow from zero)
- 3D perspective for card stacks

---

### Accessibility Improvements Summary

| Area | Current | Improvement |
|------|---------|-------------|
| **Color Contrast** | Good (8.59:1) | Test all greys, ensure 4.5:1 minimum |
| **Touch Targets** | 48-56px ✅ | Maintain minimum throughout |
| **Text Scaling** | Fixed sizes | Add 14-20px scaling option |
| **Screen Reader** | Minimal support | Add semantic labels to all icons |
| **High Contrast Mode** | None | Create high-contrast variant |
| **Keyboard Navigation** | Not optimized | Add tab stops, focus indicators |
| **Video/Audio** | N/A | Add captions to tutorial videos |
| **Reduced Motion** | Not supported | Respect prefers-reduced-motion |

**WCAG 2.1 Target:** AA compliance (minimum, strive for AAA where possible)

---

### Summary of Design System

#### Design Tokens
- **Colors:** Neon green primary, black background, dark surface secondary
- **Typography:** Outfit/Plus Jakarta Sans, 14-56px range, weight 500-800
- **Spacing:** 4px base unit, multiples of 4 (4, 8, 12, 16, 20, 24, 32, 48px)
- **Radius:** 12px inputs, 16px buttons, 20px cards, 18px modals
- **Shadows:** Subtle (10px blur), standard (20px blur), elevated (20px blur, stronger alpha)
- **Animations:** 200-800ms durations, easing curves (easeOut for entrance, easeIn for exit)

#### Color Palette (Reference)
- Primary: `#76FF03` (neon green)
- Background: `#000000` (black)
- Surface: `#1E1E1E` (dark grey)
- Accent: `#0B6E99` (AI blue)
- Error: `#FF4B4B` (red)
- Success: `#10B981` (green teal)
- Warning: `#F59E0B` (amber)

#### Consistency Rules
- ✅ All buttons 56px height (except icon buttons 48px)
- ✅ All cards 20px border-radius
- ✅ All text heading hierarchy maintained
- ✅ All modals use dark surface background
- ✅ All transitions smooth and under 800ms
- ✅ All interactive elements have 48px+ tap target

---

## Design Principles

### 1. **Clarity First**
The dark theme is designed to reduce eye strain and highlight important information. All text must have sufficient contrast, and color should only emphasize, not confuse.

### 2. **Consistency**
Every screen follows the same design system. Components are reusable, spacing is uniform, and interactions are predictable.

### 3. **Accessibility**
By default, the design supports users with varying abilities. High contrast, large touch targets, keyboard navigation, and semantic meaning are built-in.

### 4. **Motivation & Gamification**
Progress streaks, achievements, and leaderboards keep users engaged. Visual feedback celebrates milestones.

### 5. **Personalization**
The AI chatbot and personalized recommendations make the app feel tailored to each user. Data is presented in a way that is relevant and actionable.

### 6. **Simplicity**
Despite rich functionality, the interface is clean and uncluttered. Navigation is intuitive, and primary actions are obvious.

---

## Conclusion

The NutriCare+ UI/UX design system provides a complete, modern, and accessible interface for health and nutrition tracking. The design balances aesthetics (dark theme, neon green accents, smooth animations) with functionality (clear navigation, detailed analytics, real-time feedback). 

Each screen is designed with the user's mental model in mind—clear hierarchy, intuitive interactions, and meaningful micro-interactions guide users through their health journey. The system is flexible enough to scale from mobile to desktop, and robust enough to accommodate future features and enhancements.

By following this blueprint, developers and designers can maintain consistency and quality across all features and updates to the NutriCare+ application.

---

**Design System Version:** 2.0  
**Last Updated:** April 4, 2026  
**Maintained By:** NutriCare+ Design Team  
**Status:** Ready for Implementation ✅
