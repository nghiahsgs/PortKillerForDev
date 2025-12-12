#!/bin/bash

# Build DMG for PortKiller
# Usage: ./scripts/build-dmg.sh [version]

set -e

VERSION=${1:-"1.0.0"}
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="$PROJECT_DIR/build"

echo "Building PortKiller v$VERSION..."

# 1. Build Release
cd "$PROJECT_DIR"
xcodebuild -project PortKiller.xcodeproj \
    -scheme PortKiller \
    -configuration Release \
    clean build | grep -E "(BUILD|error:)"

# 2. Find built app
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData/PortKiller-*/Build/Products/Release -name "PortKiller.app" -type d 2>/dev/null | head -1)

if [ -z "$APP_PATH" ]; then
    echo "Error: PortKiller.app not found"
    exit 1
fi

# 3. Prepare DMG contents
mkdir -p "$BUILD_DIR/dmg-contents"
rm -rf "$BUILD_DIR/dmg-contents/*"
cp -R "$APP_PATH" "$BUILD_DIR/dmg-contents/"
ln -sf /Applications "$BUILD_DIR/dmg-contents/Applications"

# 4. Create DMG
DMG_NAME="PortKiller-$VERSION.dmg"
rm -f "$BUILD_DIR/$DMG_NAME"

hdiutil create -volname "PortKiller" \
    -srcfolder "$BUILD_DIR/dmg-contents" \
    -ov -format UDZO \
    "$BUILD_DIR/$DMG_NAME"

# 5. Cleanup
rm -rf "$BUILD_DIR/dmg-contents"
rm -rf "$BUILD_DIR/PortKiller.app"

echo ""
echo "✅ Build complete!"
echo "📦 DMG: $BUILD_DIR/$DMG_NAME"
echo "📏 Size: $(du -h "$BUILD_DIR/$DMG_NAME" | cut -f1)"
