#!/bin/bash
# NUTRICARE+ PRODUCTION DEPLOYMENT SCRIPT
# Automates: Build Flutter Web + Deploy to Firebase Hosting + Deploy AI Server

set -e  # Exit on any error

echo "╔════════════════════════════════════════════════════════════╗"
echo "║       🚀 NUTRICARE+ PRODUCTION DEPLOYMENT SCRIPT          ║"
echo "║                   April 1, 2026                            ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration
FIREBASE_PROJECT="gen-lang-client-0252200425"
APP_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AI_SERVER_DIR="$APP_DIRECTORY/ai_server"
BUILD_DIR="$APP_DIRECTORY/build/web"

echo -e "${YELLOW}📋 Deployment Configuration:${NC}"
echo "  • Firebase Project: $FIREBASE_PROJECT"
echo "  • App Directory: $APP_DIRECTORY"
echo "  • Build Output: $BUILD_DIR"
echo "  • AI Server: $AI_SERVER_DIR"
echo ""

# Step 1: Check prerequisites
echo -e "${YELLOW}🔍 Step 1: Checking prerequisites...${NC}"

if ! command -v flutter &> /dev/null; then
    echo -e "${RED}✗ Flutter not found. Please install Flutter SDK.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Flutter installed${NC}"

if ! command -v firebase &> /dev/null; then
    echo -e "${RED}✗ Firebase CLI not found. Install: npm install -g firebase-tools${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Firebase CLI installed${NC}"

if ! command -v node &> /dev/null; then
    echo -e "${RED}✗ Node.js not found. Please install Node.js.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Node.js installed${NC}"

echo ""

# Step 2: Build Flutter Web
echo -e "${YELLOW}🏗️  Step 2: Building Flutter web app (release mode)...${NC}"
echo "   This may take 5-10 minutes..."
echo ""

cd "$APP_DIRECTORY"
flutter clean
flutter pub get
flutter build web --release

if [ ! -d "$BUILD_DIR" ]; then
    echo -e "${RED}✗ Build failed: $BUILD_DIR not found${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Flutter web build complete${NC}"
echo "  Build size: $(du -sh $BUILD_DIR | cut -f1)"
echo ""

# Step 3: Deploy to Firebase Hosting
echo -e "${YELLOW}🔥 Step 3: Deploying to Firebase Hosting...${NC}"
echo "  Project: $FIREBASE_PROJECT"
echo "  URL: https://$FIREBASE_PROJECT.web.app"
echo ""

firebase use "$FIREBASE_PROJECT"
firebase deploy --only hosting

echo -e "${GREEN}✓ Firebase hosting deployment complete${NC}"
echo ""

# Step 4: AI Server deployment options
echo -e "${YELLOW}🤖 Step 4: AI Server Deployment${NC}"
echo ""
echo "Choose deployment option:"
echo "  1) Firebase Cloud Run (easiest, integrated)"
echo "  2) Railway.app (fastest setup)"
echo "  3) Render (free tier available)"
echo "  4) Skip (keep using localhost)"
echo ""
read -p "Enter option (1-4): " AI_DEPLOY_OPTION

case $AI_DEPLOY_OPTION in
    1)
        echo -e "${YELLOW}Deploying to Firebase Cloud Run...${NC}"
        if [ -f "$AI_SERVER_DIR/Dockerfile" ]; then
            echo -e "${GREEN}✓ Dockerfile found${NC}"
        else
            echo -e "${YELLOW}Creating Dockerfile...${NC}"
            cat > "$AI_SERVER_DIR/Dockerfile" << 'EOF'
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install --production
COPY . .
EXPOSE 5000
CMD ["node", "server.js"]
EOF
            echo -e "${GREEN}✓ Dockerfile created${NC}"
        fi
        
        echo ""
        echo -e "${YELLOW}Next steps:${NC}"
        echo "  1. Install Google Cloud SDK: https://cloud.google.com/sdk/docs/install"
        echo "  2. Run: gcloud auth login"
        echo "  3. Run in ai_server directory:"
        echo "     gcloud run deploy nutricare-ai --source . --region us-central1"
        echo ""
        ;;
    2)
        echo -e "${YELLOW}Deploying to Railway.app...${NC}"
        echo ""
        echo -e "${YELLOW}Next steps:${NC}"
        echo "  1. Go to: https://railway.app"
        echo "  2. Click 'New Project'"
        echo "  3. Connect GitHub repository"
        echo "  4. Select ai_server directory"
        echo "  5. Add environment variables:"
        echo "     - GROQ_API_KEY"
        echo "     - HF_TOKEN"
        echo "     - AI_MODE=groq"
        echo "  6. Deploy"
        echo ""
        ;;
    3)
        echo -e "${YELLOW}Deploying to Render...${NC}"
        echo ""
        echo -e "${YELLOW}Next steps:${NC}"
        echo "  1. Go to: https://render.com"
        echo "  2. Click 'New +' → 'Web Service'"
        echo "  3. Connect GitHub repository"
        echo "  4. Configuration:"
        echo "     - Name: nutricare-ai"
        echo "     - Root Directory: ai_server"
        echo "     - Build Command: npm install"
        echo "     - Start Command: node server.js"
        echo "     - Environment: Node"
        echo "  5. Add environment variables"
        echo "  6. Deploy"
        echo ""
        ;;
    4)
        echo -e "${YELLOW}Skipping AI server deployment${NC}"
        echo "Remember to keep the local server running: cd ai_server && node server.js"
        echo ""
        ;;
    *)
        echo -e "${RED}Invalid option${NC}"
        ;;
esac

# Step 5: Summary
echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║           ✅ DEPLOYMENT SCRIPT COMPLETE!                  ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo -e "${GREEN}🎉 Your NutriCare+ app is ready for production!${NC}"
echo ""
echo "📍 Live URL: https://$FIREBASE_PROJECT.web.app"
echo ""
echo "✅ Next steps:"
echo "  1. Verify app loads correctly"
echo "  2. Test all major features"
echo "  3. Check API connectivity"
echo "  4. Monitor performance in Firebase Console"
echo "  5. (Optional) Deploy AI server to cloud"
echo ""
echo "📊 Dashboard: https://console.firebase.google.com/project/$FIREBASE_PROJECT"
echo ""

# Step 6: Post-deployment checklist
echo -e "${YELLOW}📋 Post-Deployment Checklist:${NC}"
echo "  [ ] App loads at production URL"
echo "  [ ] User authentication works"
echo "  [ ] Data syncs with Firestore"
echo "  [ ] AI features functional"
echo "  [ ] No console errors"
echo "  [ ] Performance good (< 3s load)"
echo ""

echo -e "${GREEN}✨ Deployment complete! Your app is live!${NC}"
