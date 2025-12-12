#!/bin/bash

# Build DMG for Port Killer for Dev
# Usage: ./scripts/build-dmg.sh [version]

set -e

VERSION=${1:-"1.0.0"}
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="$PROJECT_DIR/build"
RESOURCES_DIR="$PROJECT_DIR/scripts/dmg-resources"

echo "🔨 Building Port Killer for Dev v$VERSION..."

# 1. Build Release
cd "$PROJECT_DIR"
xcodebuild -project PortKiller.xcodeproj \
    -scheme PortKiller \
    -configuration Release \
    clean build | grep -E "(BUILD|error:)"

# 2. Find built app
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData/PortKiller-*/Build/Products/Release -name "PortKiller.app" -type d 2>/dev/null | head -1)

if [ -z "$APP_PATH" ]; then
    echo "❌ Error: PortKiller.app not found"
    exit 1
fi

echo "📦 Found app: $APP_PATH"

# 3. Prepare build directory
mkdir -p "$BUILD_DIR"
DMG_NAME="PortKiller-$VERSION.dmg"
rm -f "$BUILD_DIR/$DMG_NAME"

# 4. Create styled DMG with create-dmg
echo "🎨 Creating styled DMG..."

create-dmg \
    --volname "Port Killer for Dev" \
    --volicon "$APP_PATH/Contents/Resources/AppIcon.icns" \
    --background "$RESOURCES_DIR/background.png" \
    --window-pos 200 120 \
    --window-size 600 400 \
    --icon-size 80 \
    --icon "PortKiller.app" 150 180 \
    --hide-extension "PortKiller.app" \
    --app-drop-link 450 180 \
    --no-internet-enable \
    "$BUILD_DIR/$DMG_NAME" \
    "$APP_PATH"

echo ""
echo "✅ Build complete!"
echo "📦 DMG: $BUILD_DIR/$DMG_NAME"
echo "📏 Size: $(du -h "$BUILD_DIR/$DMG_NAME" | cut -f1)"
