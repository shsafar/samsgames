# Release Notes - Version 2.2

## Archive Protection & UI Polish

Building on our 2.1 release, version 2.2 focuses on premium features, archive protection, and further UI refinements to our NYT Games-style interface.

### 🔒 Premium Archive Features (NEW)

- **Lock Icons on Archive Cards**:
  - Non-premium users now see lock icons on past day cards
  - Lock positioned in top-right corner (different from NYT's top-left)
  - Today's puzzle always free for everyone!
  - Clear visual indicator of which puzzles require Premium

- **Subscription Protection**:
  - Archive cards now require Premium to access past puzzles
  - Tapping locked archive puzzles shows Premium paywall
  - Premium members get unlimited access to all past puzzles
  - Protection works in both Archive view and main menu week view

- **Tappable Week View**:
  - Week day cards in main menu are now tappable
  - Premium users can tap any past day to play that archive puzzle
  - Non-premium users see paywall when tapping locked days
  - Seamless archive game launching from the week timeline

### 🎨 UI Refinements

- **Main Menu Week View**:
  - Lock icons display on non-premium archive day cards
  - Improved tap handling for week day cards
  - Better visual feedback for archive access
  - Consistent experience with Archive view

- **Archive View**:
  - Enhanced subscription checking before game launch
  - Better integration with paywall system
  - Improved user flow for premium features

### 🐛 Bug Fixes

- Fixed archive game access for non-premium users (now properly protected)
- Improved subscription state checking throughout app
- Better paywall presentation flow
- Fixed tap handling on week day cards

### 🔧 Technical Improvements

- Enhanced `MainMenuView.swift` with subscription checks in WeekScrollView
- Updated `ArchiveView.swift` with proper premium protection
- Added `SubscriptionManager` integration to week day cards
- Improved state management for archive game launching
- Better sheet presentation for archive games and paywall

---

## Previous Features (from 2.0 & 2.1)

All the great features from previous releases are still here:
- NYT Games-style UI with branded colors for all 13 games
- Week view timeline showing last 7 days
- WordStacks sound effects with toggle
- Archive replay functionality for Premium users
- Difficulty indicators on all games
- Unified iPad/iPhone experience

---

## What's Next?

We continue to refine the Sam's Games experience based on your feedback. More games, features, and improvements coming soon!

Thank you for playing Sam's Games! 🎮

---

**Version**: 2.2
**Release Date**: December 2025
**Compatibility**: iOS 15.0+
