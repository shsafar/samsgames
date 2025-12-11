# Release Notes - Version 2.0

## Major UI Redesign - NYT Games Style

We've completely redesigned Sam's Games with a premium, polished interface inspired by NYT Games! This is our biggest update yet with a fresh new look and enhanced user experience.

### 🎨 Brand New Main Menu

- **NYT-Style Game Cards**: Each game now has a beautifully branded card with unique colors
  - Orange for SumStacks
  - Mint green for WordStacks
  - Blue for XNumbers
  - Purple for WordInShapes
  - And unique colors for all 13 games!

- **Week View Timeline**: See your progress at a glance
  - Horizontal scrollable week view showing the last 7 days
  - Visual completion indicators with green checkmarks
  - Quick access to any day's puzzle
  - "Go to Archive" button for exploring more past puzzles

- **Game Information at Your Fingertips**:
  - (?) info button on every game card for quick instructions
  - "By Sam H S" attribution on all games
  - Difficulty indicators with colored circles (green/yellow/red)
  - Easy-to-see completion status

- **Optimized Layout**:
  - Cards sized perfectly to show scrollability
  - Darker, richer background colors for better contrast
  - Unified experience across iPhone and iPad
  - Professional spacing and typography

### 🔒 Premium Archive Features

- **Lock Icons on Archive Cards**:
  - Non-premium users can clearly see which puzzles require Premium
  - Lock icons positioned in top-right corner of past day cards
  - Today's puzzle always free for everyone!

- **Subscription Protection**:
  - Tapping locked archive puzzles shows Premium upgrade options
  - Seamless paywall integration
  - Premium members get unlimited access to all past puzzles

### 🎮 Enhanced Game Features

**WordStacks**:
- Added sound effects! 🔊
- Success sound when solving each shape
- Victory fanfare when completing all 21 words
- Sound toggle button (🔊/🔇) to control audio during gameplay
- Uses Web Audio API for crisp, pleasant sounds

**SumStacks**:
- Fixed shape positioning - shapes now properly centered
- Improved iOS touch scrolling with momentum
- Better gameplay experience with no edge truncation
- All shapes stay within visible area

### 🐛 Bug Fixes

**Archive Replay Fixed**:
- Premium users can now replay any archive puzzle unlimited times
- Fixed issue where completed archive puzzles showed completion screen instead of allowing replay
- Only TODAY's completed puzzle shows the "already completed" screen
- Archive mode now works consistently across all games

**UI Improvements**:
- Changed Archive button from calendar icon to clear "Archive" text label
- Better discoverability for accessing past puzzles
- Fixed card width to properly indicate horizontal scrolling
- Improved color differentiation between games (WordStacks changed from orange to mint green)

**Difficulty Indicators**:
- Added difficulty level display to ALL games (not just XNumbers and JushBox)
- Single-difficulty games now show "One Level" with green indicator
- Multi-difficulty games show rotating levels: Beginner (green), Intermediate (yellow), Expert (red)
- Consistent difficulty display in both main menu and archive

**iPad Experience**:
- Unified iPad and iPhone layouts for consistency
- Same beautiful horizontal scroll experience on all devices
- No more separate layouts causing confusion
- Identical functionality across all screen sizes

### 📱 User Experience

- **Archive View Enhanced**:
  - Same NYT-style cards in archive as main menu
  - Completion tracking shows green checkmarks on completed puzzles
  - Difficulty indicators for each day's puzzle
  - Premium-only access clearly marked with lock icons

- **Statistics Tracking**:
  - Improved completion tracking for archive games
  - Accurate date-specific completion records
  - Better streak calculations

### 🔧 Technical Improvements

- Enhanced `MainMenuView.swift` with week scroll view for all games
- Updated `ArchiveView.swift` with subscription checks and improved UI
- Fixed `WebWordStacksGameView.swift` for proper archive replay
- Fixed `SumStacksGameView.swift` for proper archive replay
- Improved `sumstacks.html` with better positioning and touch scrolling
- Added `SubscriptionManager` integration throughout archive system
- Better state management for premium features

---

## What's Next?

We're committed to making Sam's Games the best daily puzzle experience! Stay tuned for more games, features, and improvements based on your feedback.

Thank you for playing Sam's Games! 🎮

---

**Version**: 2.0
**Release Date**: December 2025
**Compatibility**: iOS 15.0+
