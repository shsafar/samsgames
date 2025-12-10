# Sam's Games - Version 1.9.1 Release Notes

## 🔧 Bug Fix Release

This is a focused bug fix release addressing UI and build issues in the WordStacks game introduced in version 1.9.

## 🎮 WordStacks Improvements

### UI Fixes
**Custom Keyboard Optimization**
- **Fixed**: Keyboard extending beyond phone screen boundaries
- **Improved**: Reduced keyboard size to fit perfectly on all iPhone models
- **Improved**: Compact key layout with optimized spacing (2px gaps, 3px row margins)
- **Improved**: Keys now use flexbox layout for responsive sizing (max-width: 36px)
- **Improved**: Reduced padding (8px vertical, 4px horizontal) for better fit

**Interface Cleanup**
- **Removed**: "Next Word" button from game interface
- **Reason**: Auto-advance feature makes manual button unnecessary
- **Result**: Cleaner, less cluttered game screen
- **Note**: Game logic unchanged - shapes still advance automatically when solved

### Technical Fixes
**Asset Catalog Build Error**
- **Fixed**: "Distill failed for unknown reasons" build error
- **Cause**: Spaces in WordStacks icon filenames
- **Solution**: Renamed icon files to standard naming convention:
  - `wordstackicon 1.png` → `wordstackicon@2x.png`
  - `wordstackicon 2.png` → `wordstackicon@3x.png`
- **Impact**: App now builds successfully without asset catalog errors

## 📊 Changes from 1.9

**Fixed:**
- Custom keyboard size overflow on iPhone screens
- Asset catalog distill build error
- WordStacks icon naming convention

**Removed:**
- "Next Word" button (auto-advance still works)

**Improved:**
- Keyboard layout and sizing for better mobile UX
- Overall game interface clarity

## 🎯 Version 1.9.1 Summary

This release focuses on polish and usability:
- ✅ WordStacks keyboard fits properly on all devices
- ✅ Build errors resolved
- ✅ Cleaner interface with removed redundant button
- ✅ All features from 1.9 preserved and enhanced
- ✅ No breaking changes

## 🎮 Complete Game Collection (12 Games)

1. **X-Numbers** - Cross-sum puzzle
2. **Word in Shapes** - Shape-based word finding
3. **JushBox** - Letter grid puzzle
4. **Double Bubble** - Word bubble matching
5. **Diamond Stack** - Stacked word pyramids
6. **Hashtag Words** - Crossword-style grid
7. **TraceWiz** - Path tracing puzzle
8. **Arrow Race** - Directional arrow patterns
9. **DiskBreak** - Disk matching game
10. **Water Table** - Water level puzzle
11. **Atomic Nails** - Precision placement challenge
12. **WordStacks** - Shape-based word tower (NEW in 1.9, improved in 1.9.1)

## 📱 Platform Support

- **Platform**: iOS (iPhone & iPad)
- **Minimum Version**: iOS 14.0 or later
- **Optimized For**: iOS 17

---

**Version**: 1.9.1
**Release Date**: December 7, 2025
**Type**: Bug Fix Release
**Build Status**: Stable

---

## Previous Versions

**1.9** - WordStacks game launch, Atomic Nails and Water Table fixes
**1.7.7** - Hashtag Words timer fix, iOS 17 compatibility
**1.7.6** - Universal exit warnings, DiskBreak improvements
**1.7.5** - DiskBreak game launch

---

**Feedback?** We'd love to hear from you! Please rate and review Sam's Games on the App Store.
