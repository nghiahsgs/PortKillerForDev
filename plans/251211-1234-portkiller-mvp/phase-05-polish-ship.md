# Phase 05: Polish & Ship

**Status:** Pending | **Priority:** High

## Context
Final polish, testing, and preparing for distribution.

## Requirements
- App icon design
- Error handling polish
- Code signing & notarization
- DMG creation
- README and landing page basics

## Implementation Steps

### 1. App Icon
- [ ] Design 1024x1024 app icon
- [ ] Generate all required sizes (16, 32, 64, 128, 256, 512, 1024)
- [ ] Add to Assets.xcassets/AppIcon

### 2. Error Handling
- [ ] Handle lsof failures gracefully
- [ ] Show error when kill fails (permission denied)
- [ ] Handle no processes state
- [ ] Handle network timeout

### 3. UX Polish
- [ ] Add loading indicator during scan
- [ ] Animate row removal on kill
- [ ] Add confirmation for kill (optional toggle)
- [ ] Add "About" menu item
- [ ] Add "Quit" menu item

### 4. Code Signing
- [ ] Configure Developer ID certificate
- [ ] Enable Hardened Runtime
- [ ] Configure entitlements for process management

### 5. Notarization
```bash
# Build archive
xcodebuild archive -scheme PortKiller -archivePath PortKiller.xcarchive

# Export for distribution
xcodebuild -exportArchive -archivePath PortKiller.xcarchive -exportPath ./build -exportOptionsPlist exportOptions.plist

# Submit for notarization
xcrun notarytool submit PortKiller.app --apple-id YOUR_ID --team-id TEAM_ID --wait

# Staple ticket
xcrun stapler staple PortKiller.app
```

### 6. DMG Creation
- [ ] Use create-dmg or dmgbuild
- [ ] Design DMG background
- [ ] Add Applications folder shortcut
- [ ] Sign the DMG

### 7. Documentation
- [ ] Create README.md
- [ ] Add installation instructions
- [ ] Add screenshots
- [ ] Create simple landing page

## Success Criteria
- [ ] App opens without Gatekeeper warning
- [ ] DMG installs correctly
- [ ] App survives restart
- [ ] All features work on fresh Mac
- [ ] No memory leaks (Instruments check)

## Files Changed
- `Resources/Assets.xcassets/AppIcon.appiconset/`
- All views (error handling)
- `README.md`
- Build scripts

## Distribution Checklist
- [ ] Version number set (1.0.0)
- [ ] Build number incremented
- [ ] App signed with Developer ID
- [ ] Notarization successful
- [ ] DMG created and signed
- [ ] Test on fresh macOS installation
- [ ] Upload to distribution platform (Gumroad/website)
