# Sam's Games - Version 1.7.7 Release Notes

## 🔧 Bug Fix Release

This is a focused bug fix release addressing a gameplay issue in Hashtag Words.

## 🎮 Hashtag Words Timer Fix

### Problem Fixed
Players could continue entering letters and using hints after the timer reached zero, allowing indefinite play time despite the timer expiring.

### Solution Implemented
- **Proper Game End**: When timer reaches zero, game state is set to "solved" to disable all input
- **Input Disabled**: Letter entry no longer works after timeout
- **Hints Disabled**: All four hint buttons (top, bottom, left, right) are disabled when time runs out
- **Clear Feedback**: "⏰ Time's up!" message displays when timer expires

### Impact
- Fair gameplay across all difficulty levels
- Consistent scoring based on time limits
- Proper enforcement of time constraints
- Better competitive integrity

## 🛠️ Technical Improvements

### iOS 17 Compatibility
- **TraceWiz**: Updated `.onChange()` modifier to new iOS 17 syntax
  - Changed from deprecated single-parameter closure to two-parameter (oldValue, newValue) syntax
  - Ensures compatibility with latest iOS versions

- **Arrow Race**: Fixed WebKit deprecation warning
  - Replaced deprecated `javaScriptEnabled` property
  - Updated to `allowsContentJavaScript` (modern API)

### Code Quality
- Removed deprecation warnings
- Improved future compatibility
- Cleaner build output

## 📊 Changes from 1.7.6

**Added:**
- Hashtag Words timeout enforcement

**Fixed:**
- Hashtag Words timer not ending gameplay
- iOS 17 deprecation warnings in TraceWiz
- WebKit deprecation warning in Arrow Race

**Technical:**
- Updated to modern iOS 17 APIs
- Improved code compatibility

## 🎯 Version 1.7.7 Summary

This release focuses on quality and correctness:
- ✅ Hashtag Words timer now works correctly
- ✅ iOS 17 compatibility warnings resolved
- ✅ All existing features from 1.7.6 preserved
- ✅ No breaking changes

## 📱 Platform Support

- **Platform**: iOS (iPhone & iPad)
- **Minimum Version**: iOS 14.0 or later
- **Optimized For**: iOS 17

---

**Version**: 1.7.7
**Release Date**: November 29, 2025
**Type**: Bug Fix Release
**Build Status**: Stable

---

## Previous Versions

**1.7.6** - Universal exit warnings, DiskBreak improvements
**1.7.5** - DiskBreak game launch
**1.7.2** - TraceWiz, Hashtag Words, Word in Shapes improvements

---

**Feedback?** We'd love to hear from you! Please rate and review Sam's Games on the App Store.
